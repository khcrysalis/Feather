#!/bin/sh
# this shouldn't be ran when testing, only when building via workflow
version=$(git rev-parse HEAD)
agvtool new-version -all $version 
