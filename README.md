# AVAudioEngine Offline Manual Rendering Mode

Sample to demonstrate AVAudioEngine's API to manually render a processing change

## Overview

This sample demonstrates using AVAudioEngine's manual rendering mode API, added in macOS 10.13, iOS 11.0, watchOS 4.0 and tvOS 11.0.

AVAudioEngine by default is connected to an audio device and automatically renders in realtime. It can also be configured to operate in manual rendering mode i.e. not connected to any audio device and rendering in response to requests from the client, normally at or faster than realtime rate.

There are two variants of the manual rendering mode - offline and realtime.
In the offline manual rendering mode, the engine operates under no deadlines or realtime constraints. In the realtime manual rendering mode, the engine assumes that it is rendering under a realtime context, and hence does not make any blocking call (e.g. calling libdispatch, blocking on a mutex, allocating memory etc.) while rendering.

This sample demonstrates using AVAudioEngine in the offline manual rendering mode.

