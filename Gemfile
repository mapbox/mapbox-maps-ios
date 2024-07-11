source "https://rubygems.org"

# Fastlane 2.220.0 introduced a new crypto algo for Match, which is not compatible with the pre-existed versions
gem "fastlane", '= 2.219.0'

plugins_path = File.join(File.dirname(__FILE__), '.fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
