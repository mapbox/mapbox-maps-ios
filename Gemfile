source "https://rubygems.org"
# Requires `force_legacy_encryption` flag support
gem "fastlane", ">= 2.223.0"
gem 'rexml', '~> 3.4.2' # Fix CVE-2025-58767
gem 'nkf', '~> 0.2.0' # https://github.com/fastlane/fastlane/issues/21942
gem 'abbrev', '~> 0.1.2' # https://github.com/fastlane/fastlane/issues/29183

plugins_path = File.join(File.dirname(__FILE__), '.fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
