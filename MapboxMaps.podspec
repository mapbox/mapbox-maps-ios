Pod::Spec.new do |m|

  maps_version = '11.6.0-beta.1'

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
  m.ios.deployment_target = '12.0'
  m.swift_version = '5.9'

  m.source_files = 'Sources/MapboxMaps/**/*.{swift,h}'
  m.resource_bundles = { 'MapboxMapsResources' => ['Sources/**/*.{xcassets,strings}', 'Sources/MapboxMaps/MapboxMaps.json', 'Sources/MapboxMaps/PrivacyInfo.xcprivacy'] }

  m.dependency 'MapboxCoreMaps', '11.6.0-beta.1'
  m.dependency 'MapboxCommon', '24.6.0-beta.1'
  m.dependency 'Turf', '2.8.0'

end
