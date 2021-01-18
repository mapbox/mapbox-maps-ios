#!/usr/bin/env ruby

# PURPOSE ---------------------------------------------------------------------
# The goal of this script is to calculate the current binary size of the Mapbox
# framework across different architectures and then record the sizes to a file.
#
# Usage:
#        ruby measure_binary_size <GIT_SHA>
# -----------------------------------------------------------------------------

require "csv"
require "fileutils"

if ARGV.length > 1
  puts "Too many arguments. Accepted usage:
  EXAMPLE: measure_binary_size.rb <GIT_SHA>
  where <GIT_SHA> is the git commit SHA/hash ID."
  exit
end

git_sha = ARGV[0]

# -----------------------------------------------------------------------------
# Measure the current size of the Mapbox framework and append this measurement
# to a data source. Right now its just appending to a local CSV, but later we"ll
# want to send this to an appropriate S3 bucket.

cartfile_content = "github \"mapbox/mapbox-maps-ios\" \"#{git_sha}\""


Dir.mkdir "tmp"

File.open("tmp/Cartfile", "w+") { |file| file.write(cartfile_content) }

# TODO: --use-ssh should be removed once this repo is public
system "cd tmp && carthage update --platform iOS --use-ssh && /
        cd Carthage/Build/iOS/ &&
        xcrun bitcode_strip MapboxMaps.framework/MapboxMaps -r -o MapboxMaps-stripped &&
        strip -Sx -no_code_signature_warning MapboxMaps-stripped &&
        lipo MapboxMaps-stripped -extract x86_64 -output MapboxMaps-stripped-x86_64
        echo 'Binary sizes measured. Report incoming...'
        " #TODO: Add additional archs once we start making them.

# $? is the exit code from the previous system command
if $?.exitstatus != 0
  abort("The 'system' command failed. Debug this by running each shell command individually.")
end

# Sizes are in bytes
x86_64_size = File.stat("tmp/Carthage/Build/iOS/MapboxMaps-stripped-x86_64").size

puts "
  Architecture x86_64 is #{x86_64_size} bytes (#{(x86_64_size.to_f / 1024000).round(2)} Mb)
" 

# TODO: Send this to the appropriate S3 bucket when available
CSV.open("binary-sizes.csv", "a+") do |row|
 row << ["#{git_sha}", "nil", "nil", "nil", "#{x86_64_size}"]
end

# Remove tmp folder holding frameworks when done
FileUtils.rm_r "tmp"
# -----------------------------------------------------------------------------
