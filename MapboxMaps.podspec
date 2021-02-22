Pod::Spec.new do |m|

  maps_version = '10.0.0-beta.13'

  m.name = 'MapboxMaps'
  m.version = maps_version

  m.summary = 'Vector map solution for iOS with full styling capabilities.'
  m.description = 'Metal-based vector map solution for iOS with full styling capabilities.'
  m.homepage = 'https://docs.mapbox.com/ios/beta/maps/guides/'
  m.license = { type: 'Commercial', file: 'LICENSE.md' }
  m.author = { 'Mapbox' => 'mobile@mapbox.com' }
  m.social_media_url = 'https://twitter.com/mapbox'
  m.documentation_url = 'https://docs.mapbox.com/ios/beta/maps/api-reference/'
  
  m.source = { :git => 'https://github.com/mapbox/mapbox-maps-ios.git', :tag => maps_version }
  m.platform = :ios
  m.ios.deployment_target = '11.0'
  m.swift_version = '5.3'
  m.requires_arc = true

  m.source_files = 'Sources/MapboxMaps/**/*.{swift,h}'
  m.resources = 'Sources/MapboxMaps/Location/Pucks/IndicatorAssets.xcassets'

  m.dependency 'MapboxCoreMaps', '10.0.0-beta.15'
  m.dependency 'MapboxCommon', '10.0.0-beta.11'
  m.dependency 'MapboxMobileEvents', '0.10.8'
  m.dependency 'Turf', '1.2.0'

end
