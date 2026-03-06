source "https://rubygems.org"
# Requires `force_legacy_encryption` flag support
gem "fastlane", ">= 2.232.1"
gem 'faraday', '~> 1.10.5' # Fix https://nvd.nist.gov/vuln/detail/CVE-2026-25765
plugins_path = File.join(File.dirname(__FILE__), '.fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
