fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew install fastlane`

# Available Actions
## iOS
### ios bump_version
```
fastlane ios bump_version
```
Bump version and commit build information
### ios match_signings
```
fastlane ios match_signings
```
Sync certificates/provision profiles
### ios tests
```
fastlane ios tests
```
Test project
### ios prepare_to_build
```
fastlane ios prepare_to_build
```
Prepare building project
### ios build_project
```
fastlane ios build_project
```
Build project and package signed ipa
### ios build_debug
```
fastlane ios build_debug
```
Build a debug build
### ios build_release
```
fastlane ios build_release
```
Build a release build
### ios deploy_to_testflight
```
fastlane ios deploy_to_testflight
```
Deploy to TestFlight
### ios beta
```
fastlane ios beta
```
Push a new beta build to TestFlight
### ios register_new_device
```
fastlane ios register_new_device
```
Register new device
### ios refresh_profiles
```
fastlane ios refresh_profiles
```
A helper lane for refreshing provisioning profiles.

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
