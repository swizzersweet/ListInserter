#!/bin/bash

# output=$(xcrun simctl list devices available)

iphone_device_id = $(xctrace list  devices | grep -m 1 "iPhone 12" | awk '{print substr($0,length($0)-36,36)}')

echo $iphone_device_id


# Define the scheme and destination
scheme="ListInserter"
# simulator_name="iPhone 8"
# simulator_os="14.0"

# xcodebuild test -scheme ListInserter -destination 'platform=iOS Simulator,id=1BFAB756-39B6-4D1D-8980-71843A3639B0' -sdk 'iOS 17.0'
xcodebuild test -scheme "$scheme" -destination 'platform=iOS Simulator,id="$iphone_device_id"' -sdk 'iOS 17.0'