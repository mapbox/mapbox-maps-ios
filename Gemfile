source "https://rubygems.org"

gem "fastlane"
gem "multi_json", "= 1.15.0" # Forced by CI

plugins_path = File.join(File.dirname(__FILE__), '.fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
