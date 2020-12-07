[![Version](https://img.shields.io/cocoapods/v/WeLoop.svg?style=flat)](https://cocoapods.org/pods/WeLoop)
[![Platform](https://img.shields.io/cocoapods/p/WeLoop.svg?style=flat)](https://cocoapods.org/pods/WeLoop)


## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

Inside the AppDelegate.swift, update the dummy `projectGUID` with your own.

## Requirements

Since WeLoop builds in swift 5.0, Xcode 10.2 is required to build the project.

The dependency requires iOS 9.0 or above to be built.

## Installation

WeLoop is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'WeLoop'
```

## Usage

### Compatibility with scene delegates

If your application uses a `UISceneSession`, you need to configure the SDK early on in your ApplicationDelegate:

```swift
WeLoop.set(sceneBasedApplication: true)
```

In the next major release, this will no longer be necessary.

### Invocation

In order to invoke WeLoop you have two options. 

1. You provide the user identity. Simply provide your project key, and identity the current user by calling `identifyUser`.

```swift
WeLoop.initialize(apiKey: "YOUR_PROJECT_GUID");
let user = User(id: "1", email: "test1@yopmail.com", firstName: "test1", lastName: "test2")
WeLoop.authenticateUser(user: user)
```

2. You let the user provide its login infos: don't call `authenticateUser``, and the widget will show the login page when it's launched.

```swift
WeLoop.initialize(apiKey: "YOUR_PROJECT_GUID");
```


### Invocation method

You can choose between different methods to invoke the WeLoop widget inside your application:

1. Floating Action Button

```swift
WeLoop.set(invocationMethod: .fab)
```

Customisation options for the button (color, icon, placement) can be done inside your WeLoop project settings.

2. Shake Gesture

```swift
WeLoop.set(invocationMethod: .shakeGesture)
```

3. Manual

```swift
WeLoop.set(invocationMethod: .manual)

// Then, in your own button or control:

WeLoop.invoke()

```

### Delegate methods

You can set up a delegate to listen for some events returned by the SDK with the following method: `WeLoop.set(delegate: self)`

You can then implement the following optional delegate methods:

````swift
extension AppDelegate: WeLoopDelegate {
    
    func initializationSuccessful() {
        // From this point forward, we can safely invoke the Widget manually
    }
    
    func initializationFailed(with error: Error) {
        // Initialization Failed (no network for example). Based on the error you'll have to retry the initialization later.
        print(error)
    }
    
    func failedToLaunch(with error: Error) {
        // The widget could not be launched. Most likely is that the initialization process failed, or the user is missing in autoAuthentication
        print(error)
    }
    
    func notificationCountUpdated(newCount: Int) {
        // Set the new count on your custom view
        print(newCount)
    }
}
````



### Updating your plist

Since WeLoop offers the possibility to upload photos from the user photo gallery and from the camera, you will have to add the following entries to your plist, if they are not already present:

```plist
<key>NSPhotoLibraryUsageDescription</key>
<string>WeLoop needs to access your library to share pictures from your library</string>
<key>NSCameraUsageDescription</key>
<string>WeLoop needs to access your camera to take pictures</string>
```

## License

WeLoop is available under the MIT license. See the LICENSE file for more info.
