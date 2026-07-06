source "https://rubygems.org"
# Requires `force_legacy_encryption` flag support
gem "fastlane", "~> 2.237" # excon CVE-2026-54171 and altool fixes (fastlane/fastlane#30106)
gem 'faraday', '~> 1.10.6' # Fix https://nvd.nist.gov/vuln/detail/CVE-2026-54297
gem 'excon', '>= 1.5.0' # Fix https://nvd.nist.gov/vuln/detail/CVE-2026-54171
gem 'json', '>= 2.19.2' # Fix https://nvd.nist.gov/vuln/detail/CVE-2026-33210
gem "addressable", ">= 2.9.0" # Fix https://nvd.nist.gov/vuln/detail/CVE-2026-35611

plugins_path = File.join(File.dirname(__FILE__), '.fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
