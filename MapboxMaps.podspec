Pod::Spec.new do |m|

  maps_version = '10.16.0'

  m.name = 'MapboxMaps'
  m.version = maps_version

  m.summary = 'Vector map solution for iOS with full styling capabilities.'
  m.description = 'Metal-based vector map solution for iOS with full styling capabilities.'
  m.homepage = 'https://docs.mapbox.com/ios/maps/guides/'
  m.license = { type: 'Commercial', file: 'LICENSE.md' }
  m.author = { 'Mapbox' => 'mobile@mapbox.com' }
  m.social_media_url = 'https://twitter.com/mapbox'
  m.documentation_url = 'https://docs.mapbox.com/ios/maps/api-reference/'

  m.source = { :git => 'https://github.com/mapbox/mapbox-maps-ios.git', :tag => "v#{maps_version}" }
  m.platform = :ios
  m.ios.deployment_target = '11.0'
  m.swift_version = '5.5'

  m.source_files = 'Sources/MapboxMaps/**/*.{swift,h}'
  m.resource_bundles = { 'MapboxMapsResources' => ['Sources/**/*.{xcassets,strings}', 'Sources/MapboxMaps/MapboxMaps.json'] }

  # Xcode 14.x throws an error about code signing on resource bundles, turn it off for now.
  # TODO: remove after Cocoapods 1.12 is released
  m.pod_target_xcconfig = { 'CODE_SIGNING_ALLOWED' => 'NO' }

  m.dependency 'MapboxCoreMaps', '10.16.0'
  m.dependency 'MapboxMobileEvents', '1.0.10'
  m.dependency 'MapboxCommon', '23.8.0'
  m.dependency 'Turf', '~> 2.0'

end
