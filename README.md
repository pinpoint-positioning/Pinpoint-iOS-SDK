# Pinpoint iOS SDK

## Demo App
This repo contains a sample app that demonstrates the usage of the `Pinpoint iOS SDK`


## Installation

To integrate the `easylocate-ios-sdk` add the repo as a swift package dependency to you project.

### Versioning
This package highly depends in the Pinpoint Hardware you are using.

Make sure to use the corresponding tag (e.g. 12.1.0) when adding this package to your project,



## Usage

To use the `Pinpoint iOS SDK`  in your iOS project, follow the steps below..

### Importing the Module

First, import the module at the top of your Swift file:

```swift
import PinpointSDK
```

### API Class Overview

The `Easylocate` class provides various functions to interact with nearby tracelets using Bluetooth. Below are the main functions available for public use:

### Singleton Instance

Access the singleton instance of the `API` class:

```swift
let api = EasylocateAPI.shared
```

### Flow-logic to receive postion data

1. Scan for tracelet
2. Connect to tracelet
3. Send 'StartPositioning'-Command to tracelet.
4. Listen to position stream.


### Scanning for Tracelets (1)

Start scanning for nearby tracelets with a specified timeout. The completion handler returns a list of discovered tracelets.

```swift
api.scan(timeout: 3.0) { tracelets in
    print("Discovered tracelets: \(tracelets)")
}
```

Stop the scanning process:

```swift
api.stopScan()
```

### Connecting to a Tracelet and start positioning (2+3)


Preferably use this function, to connect and directly start positioning mode:

```swift
if let tracelet = discoveredTracelets.first {
    do {
        let success = try await api.connectAndStartPositioning(device: tracelet)
        print("Connection and positioning success: \(success)")
    } catch {
        print("Connection and positioning failed with error: \(error)")
    }
}
```
*Hint:* The function `connectAndStartPositioning(device: tracelet)` will set up the tracelet with settings, broadcasted by the SATlets.
This will only work, if you are in a location with a set up Pinpoint UWB network!


### Listen to local position stream (4)

#### @Published location stream

When using SwiftUI, you can simply observe the published `api.localPosition` variable for changes.

```swift

.onAppear {
    // Set initial position
    xPos = api.localPosition.xCoord
    yPos = api.localPosition.yCoord
}
.onChange(of: api.localPosition) { newPosition in
    // Update position when localPosition changes
    xPos = newPosition.xCoord
    yPos = newPosition.yCoord
}

```

#### Callback Function

Alternatively you can make use of a callback function `onwNewLocalPosition()`

The callback returns a `PositionData` object and can be assigned as follows:


```swift
api.onPositionUpdate = { position in
    self.updatePositionData(localPosition: position)
}
```



### Disconnect from a tracelet:

```swift
await api.disconnect()
```


### More Tracelet Commands

Send a "ShowMe" command to a connected tracelet:

```swift
let success = await api.showMe()
```

Start UWB-positioning on a connected tracelet:

```swift
let success = await api.startPositioning()
```

Stop UWB-positioning on a connected tracelet:

```swift
let success = api.stopPositioning()
```

Set the communication channel (5 or 9):

```swift
let success = await api.setChannel(channel: 9, preamble: 9)
print("Channel set success: \(success)")
```

Set the SiteID filter for the tracelet (This filters the tracelet for a specific SiteID - Don`t use if not neccessary):

```swift
let success = await api.setSiteID(siteID: 0x0001)
print("SiteID set success: \(success)")
```

Set the positioning interval:

```swift
let success = await api.setMotionCheckInterval(interval: 1) // Interval in n x 250ms, Default: 1 (update every 1 x 250ms)
```

### Retrieving Tracelet Information

Request the status of a connected tracelet:

```swift
if let status = await api.getStatus() {
    print("Tracelet status: \(status)")
}
```


Request the firmware version of a connected tracelet:

```swift
if let version = await api.getVersion() {
    print("Tracelet firmware version: \(version)")
}
```

### Known issues

If you get an error of rsync missing permissions, make sure to update your Xcode project build option ENABLE_USER_SCRIPT_SANDBOXING to 'No'.

![XCode Settings Image](https://i.stack.imgur.com/vqk8D.png)




