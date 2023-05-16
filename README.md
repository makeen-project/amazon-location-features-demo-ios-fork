# Amazon Location Services
iOS Application for using Location Services of Amazon

## Tool & Services

* Tools:
  * [Xcode 14.1] with latest iOS SDK

## Project Setup

### Prerequistes
Things you have install before start working with a project

### Configuration.

Before the build the configuration file should be added:

Config.xcconfig should be created, placed into main working directory under LocationServices directory and filled with


IDENTITY_POOL_ID = xx-xxxx-x:xxxxxx-xxxxxx-xxxxx-xxxxx-xxxxxxxx
AWS_REGION = xx-xxxx-x

### Installation

## E2E testing using XCTest framework

### Prerequistes
* Installed Xcode 14.3 or newer
* Simulator/device with iOS 16.4 or newer
* The main project is configured

### Configuration.

Before the build the configuration file should be added:

ConfigTest.xcconfig should be created, placed into main working directory under LocationServices directory and filled with

* Default configuration to run the map
IDENTITY_POOL_ID = REGION:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
AWS_REGION = REGION

* Info for tests
TEST_IDENTITY_POOL_ID = REGION:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
TEST_USER_POOL_CLIENT_ID = USER_POOL_CLIENT_ID
TEST_USER_POOL_ID = USER_POOL_ID
TEST_USER_DOMAIN = USER_DOMAIN
TEST_WEB_SOCKET_URL = WEB_SOCKET_URL
TEST_SAMPLE_USER_NAME = USER_NAME
TEST_SAMPLE_PASSWORD = PASSWORD

* How to create a new Cloud Formation on Amazon

Follow this [Document](https://location.aws.com/demo/help) to create & configure a new Cloud formation

### Run from Xcode
* Choose device/simulator as a destination
* Press cmd+U

### Run from command line
xcodebuild \
 test \
 -project LocationServices.xcodeproj \
 -scheme LocationServices \
 -destination "platform=iOS Simulator,name=iPhone 14"
  

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.

