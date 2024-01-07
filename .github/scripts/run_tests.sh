#!/bin/bash

output=$(xcrun simctl list devices available)

echo $output