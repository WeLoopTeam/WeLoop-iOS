# WeLoop

[![Version](https://img.shields.io/cocoapods/v/WeLoop.svg?style=flat)](https://cocoapods.org/pods/WeLoop)
[![License](https://img.shields.io/cocoapods/l/WeLoop.svg?style=flat)](https://cocoapods.org/pods/WeLoop)
[![Platform](https://img.shields.io/cocoapods/p/WeLoop.svg?style=flat)](https://cocoapods.org/pods/WeLoop)


<img src="https://weloop.io/img/logo/weloop_logo_black.svg" width="250">


## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

WeLoop is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'WeLoop'
```

## Usage

### Invocation

In order to invoke WeLoop you have two options. 

1. You provide the user identity. This is the default option. Simply provide your project key, and identity the current user by calling `identifyUser`.

```swift
WeLoop.initialize(apiKey: "YOUR_PROJECT_GUID");
WeLoop.identifyUser(firstName: "John", lastName: "Doe", email: "john.doe@weloop.io")
```

2. You let the user provide its login infos. Pass autoAuthentication to false when calling the `initialize` function.

```swift
WeLoop.initialize(apiKey: "YOUR_PROJECT_GUID", autoAuthentication: false);
```

### Invocation method

You can choose between different methods to invoke the WeLoop widget inside your application:

1. Floating Action Button

```swift
// Set the invocation preferences. You can always change them after invoking the SDK
WeLoop.set(preferredButtonPosition: .bottomRight)
WeLoop.set(invocationMethod: .fab)
```

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


## License

WeLoop is available under the MIT license. See the LICENSE file for more info.
