source "https://rubygems.org"
# Requires `force_legacy_encryption` flag support
# Pin to fastlane git until a RubyGems release includes excon >= 1.5.0 (CVE-2026-54171)
# and match certificate renewal (fastlane/fastlane#30096).
gem "fastlane", github: "fastlane/fastlane", ref: "20f68fd02beeb623e5c43763f7556838123d3601"
gem 'faraday', '~> 1.10.6' # Fix https://nvd.nist.gov/vuln/detail/CVE-2026-54297
gem 'excon', '>= 1.5.0' # Fix https://nvd.nist.gov/vuln/detail/CVE-2026-54171
gem 'json', '>= 2.19.2' # Fix https://nvd.nist.gov/vuln/detail/CVE-2026-33210
gem "addressable", ">= 2.9.0" # Fix https://nvd.nist.gov/vuln/detail/CVE-2026-35611

plugins_path = File.join(File.dirname(__FILE__), '.fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
