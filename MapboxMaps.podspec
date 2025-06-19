Pod::Spec.new do |m|

  m.name = 'MapboxMaps'
  m.version = '11.13.1'

  m.summary = 'Vector map solution for iOS with full styling capabilities.'
  m.description = 'Metal-based vector map solution for iOS with full styling capabilities.'
  m.homepage = 'https://docs.mapbox.com/ios/maps/guides/'
  m.license = { type: 'Commercial', file: 'LICENSE.md' }
  m.author = { 'Mapbox' => 'mobile@mapbox.com' }
  m.social_media_url = 'https://twitter.com/mapbox'
  m.documentation_url = 'https://docs.mapbox.com/ios/maps/api-reference/'

  m.source = { :git => 'https://github.com/mapbox/mapbox-maps-ios.git', :tag => "v#{m.version.to_s}" }
  m.platform = :ios
  m.ios.deployment_target = '14.0'
  m.swift_version = '5.9'

  m.source_files = 'Sources/MapboxMaps/**/*.{swift,h}'
  m.resource_bundles = { 'MapboxMapsResources' => ['Sources/MapboxMaps/**/*.{xcassets,strings}', 'Sources/MapboxMaps/MapboxMaps.json', 'Sources/MapboxMaps/PrivacyInfo.xcprivacy'] }

  m.dependency 'MapboxCoreMaps', '11.13.1'
  m.dependency 'MapboxCommon', '24.13.1'
  m.dependency 'Turf', '4.0.0'

end
