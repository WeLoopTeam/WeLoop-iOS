# Release process

## Cocoapods

1. Authenticate with cocopoad (the centralized dependency manager): https://guides.cocoapods.org/making/getting-setup-with-trunk.html
1. If you are not a maintainer ask an existing maintainer to add you: `pod trunk add-owner WeLoop your.email@address.com`
1. In the podspec file, update the `s.version`. Follow semver, people use it.
1. Commit your changes.
1. Tag your commit with the same version number as you just set in the podspec.
1. Push your changes **and** your tag to github
1. Publish your pod to the trunk: `pod trunk push WeLoop.podspec --allow-warnings`

## Carthage

Carthage is not setup yet.
