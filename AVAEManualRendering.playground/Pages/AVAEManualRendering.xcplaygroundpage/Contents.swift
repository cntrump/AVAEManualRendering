//: # AVAudioEngine Offline Manual Rendering Mode
//:   Use AVAudioEngine in the offline mode to process an audio file with a reverb effect.
import AVFoundation
//: ## Source File
//: Open the audio file to process
let sourceFile: AVAudioFile
let format: AVAudioFormat
do {
    let sourceFileURL = Bundle.main.url(forResource: "mixLoop", withExtension: "caf")!
    sourceFile = try AVAudioFile(forReading: sourceFileURL)
    format = sourceFile.processingFormat
} catch {
    fatalError("could not open source audio file, \(error)")
}
//: ## Engine Setup
//:    player -> reverb -> mainMixer -> output
//: ### Create and configure the engine and its nodes
let engine = AVAudioEngine()
let player = AVAudioPlayerNode()
let reverb = AVAudioUnitReverb()

engine.attach(player)
engine.attach(reverb)

// set desired reverb parameters
reverb.loadFactoryPreset(.mediumHall)
reverb.wetDryMix = 50

// make connections
engine.connect(player, to: reverb, format: format)
engine.connect(reverb, to: engine.mainMixerNode, format: format)

// schedule source file
player.scheduleFile(sourceFile, at: nil)
//: ### Enable offline manual rendering mode
do {
    let maxNumberOfFrames: AVAudioFrameCount = 4096 // maximum number of frames the engine will be asked to render in any single render call
    try engine.enableManualRenderingMode(.offline, format: format, maximumFrameCount: maxNumberOfFrames)
} catch {
    fatalError("could not enable manual rendering mode, \(error)")
}
//: ### Start the engine and player
do {
    try engine.start()
    player.play()
} catch {
    fatalError("could not start engine, \(error)")
}
//: ## Offline Render
//: ### Create an output buffer and an output file
//: Output buffer format must be same as engine's manual rendering output format
let outputFile: AVAudioFile
do {
    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    let outputURL = URL(fileURLWithPath: documentsPath + "/mixLoopProcessed.caf")
    outputFile = try AVAudioFile(forWriting: outputURL, settings: sourceFile.fileFormat.settings)
} catch {
    fatalError("could not open output audio file, \(error)")
}

// buffer to which the engine will render the processed data
let buffer: AVAudioPCMBuffer = AVAudioPCMBuffer(pcmFormat: engine.manualRenderingFormat, frameCapacity: engine.manualRenderingMaximumFrameCount)!
//: ### Render loop
//: Pull the engine for desired number of frames, write the output to the destination file
while engine.manualRenderingSampleTime < sourceFile.length {
    do {
        let framesToRender = min(buffer.frameCapacity, AVAudioFrameCount(sourceFile.length - engine.manualRenderingSampleTime))
        let status = try engine.renderOffline(framesToRender, to: buffer)
        switch status {
        case .success:
            // data rendered successfully
            try outputFile.write(from: buffer)
            
        case .insufficientDataFromInputNode:
            // applicable only if using the input node as one of the sources
            break
            
        case .cannotDoInCurrentContext:
            // engine could not render in the current render call, retry in next iteration
            break
            
        case .error:
            // error occurred while rendering
            fatalError("render failed")
        }
    } catch {
        fatalError("render failed, \(error)")
    }
}

player.stop()
engine.stop()

print("Output \(outputFile.url)")
print("AVAudioEngine offline rendering completed")

//: [LICENSE](LICENSE)
