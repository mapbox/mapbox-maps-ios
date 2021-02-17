Pod::Spec.new do |m|

  maps_version = '10.0.0-beta.13.1'

  m.name = 'MapboxMaps'
  m.version = maps_version

  m.summary = 'Vector map solution for iOS with full styling capabilities.'
  m.description = 'Metal-based vector map solution for iOS with full styling capabilities.'
  m.homepage = 'https://docs.mapbox.com/ios/beta/maps/guides/'
  m.license = { type: 'Commercial', file: 'LICENSE.md' }
  m.author = { 'Mapbox' => 'mobile@mapbox.com' }
  m.social_media_url = 'https://twitter.com/mapbox'
  m.documentation_url = 'https://docs.mapbox.com/ios/beta/maps/api-reference/'

  m.source = { http: "https://api.mapbox.com/downloads/v2/mobile-maps-ios/releases/ios/packages/#{maps_version.to_s}/MapboxMaps.xcframework.zip" }
  m.vendored_frameworks = 'MapboxMaps.xcframework'

  m.platform = :ios
  m.ios.deployment_target = '11.0'
  m.swift_version = '5.3'
  m.requires_arc = true
  m.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

  m.dependency 'MapboxCoreMaps', '10.0.0-beta.14.2'
  m.dependency 'MapboxCommon', '10.0.0-beta.9.2'
  m.dependency 'MapboxMobileEvents', '0.10.7'
  m.dependency 'Turf', '2.0.0-alpha.2'

end
