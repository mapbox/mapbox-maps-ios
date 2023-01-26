source "https://rubygems.org"

# Downgrade fastlane to 2.210.1 to fix the issue with the latest version
# https://github.com/fastlane/fastlane/issues/20960#issuecomment-1378738366
gem "fastlane", "~> 2.210.0"

plugins_path = File.join(File.dirname(__FILE__), '.fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
