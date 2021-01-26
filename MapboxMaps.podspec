Pod::Spec.new do |m|

  version = '10.0.0-beta.12'

  m.name = 'MapboxMaps'
  m.version = version

  m.summary = 'Vector map solution for iOS with full styling capabilities.'
  m.description = 'Metal-based vector map solution for iOS with full styling capabilities.'
  m.homepage = 'https://docs.mapbox.com/ios/beta/maps/guides/'
  m.license = { type: 'Commercial', file: 'LICENSE.md' }
  m.author = { 'Mapbox' => 'mobile@mapbox.com' }
  m.social_media_url = 'https://twitter.com/mapbox'
  m.documentation_url = 'https://docs.mapbox.com/ios/beta/maps/api-reference/'

  m.source = { http: "https://api.mapbox.com/downloads/v2/mobile-maps-ios/releases/ios/packages/#{version.to_s}/MapboxMaps.xcframework.zip" }
  m.vendored_frameworks = 'MapboxMaps.xcframework'

  m.platform = :ios
  m.ios.deployment_target = '11.0'
  m.swift_version = '5.3'
  m.requires_arc = true
  m.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

  m.dependency 'MapboxCoreMaps', '10.0.0-beta.13'
  m.dependency 'MapboxCommon', '10.0.0-beta.8'
  m.dependency 'MapboxMobileEvents', '0.10.7'

  # The consuming app must specify Turf in their Podfile because this version of MapboxMaps depends on an unreleased Turf version:
  #
  #   pod 'Turf', git: 'https://github.com/mapbox/turf-swift.git', commit: '17c5fd8a7757b4a37a859e75f0a3c4f8f6f177e3'
  #
  # Additionally, you must add a post-install hook to your Podfile to add a configuration to the Turf target:
  #
  #   post_install do |installer|
  #     installer.pods_project.targets.each do |target|
  #       if target.name == 'Turf'
  #         target.build_configurations.each do |config|
  #           config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
  #         end
  #       end
  #     end
  #   end
  #
  m.dependency 'Turf'

end
