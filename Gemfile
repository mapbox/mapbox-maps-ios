source "https://rubygems.org"
# Requires `force_legacy_encryption` flag support
gem "fastlane", ">= 2.223.0"
gem 'rexml', '~> 3.4.2' # Fix CVE-2025-58767

plugins_path = File.join(File.dirname(__FILE__), '.fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
