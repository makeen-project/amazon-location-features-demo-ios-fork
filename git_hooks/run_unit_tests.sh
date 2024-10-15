#!/bin/sh

# Set the path to Xcode project and scheme
project_path="./LocationServices/LocationServices.xcodeproj"
scheme="LocationServicesUnitTests"

# Execute the test cases using xcodebuild
xcodebuild test -project $project_path -scheme $scheme -destination 'platform=iOS Simulator,name=iPhone 15 pro,OS=latest'
