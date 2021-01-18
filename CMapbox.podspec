Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.name = "CMapbox"
  s.version = "0.0.1"
  s.summary = "Mapbox Maps SDK."

  s.description  = <<-DESC
  The Mapbox Maps SDK for iOS.
                   DESC

  s.homepage = "https://docs.mapbox.com/ios/maps/"
  s.documentation_url = "https://docs.mapbox.com/ios/api/maps/"

  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.license = { :type => "ISC", :file => "LICENSE.md" }

  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.author = { "Mapbox" => "mobile@mapbox.com" }
  s.social_media_url = "https://twitter.com/mapbox"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.ios.deployment_target = "11.0"

  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.source = { :git => "https://github.com/mapbox/mapbox-maps-ios.git", :tag => "v#{s.version.to_s}" }

  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.source_files =  "Sources/CMapbox/empty.c",
  "Sources/CMapbox/include/MBXAccounts.h",
  "Sources/CMapbox/include/MBXAnimationOptions.h",
  "Sources/CMapbox/include/MBXAnimationTransitionFinish.h",
  "Sources/CMapbox/include/MBXAnimationTransitionFrame.h",
  "Sources/CMapbox/include/MBXBoundOptions.h",
  "Sources/CMapbox/include/MBXCacheManager.h",
  "Sources/CMapbox/include/MBXCacheStatusCallback.h",
  "Sources/CMapbox/include/MBXCameraChange.h",
  "Sources/CMapbox/include/MBXCameraChangeMode.h",
  "Sources/CMapbox/include/MBXCameraOptions.h",
  "Sources/CMapbox/include/MBXCancelTileFunctionCallback.h",
  "Sources/CMapbox/include/MBXCanonicalTileID.h",
  "Sources/CMapbox/include/MBXConstrainMode.h",
  "Sources/CMapbox/include/MBXContextMode.h",
  "Sources/CMapbox/include/MBXCoordinateBounds.h",
  "Sources/CMapbox/include/MBXCoordinateQuad.h",
  "Sources/CMapbox/include/MBXCoreMapView.h",
  "Sources/CMapbox/include/MBXCustomGeometrySourceOptions.h",
  "Sources/CMapbox/include/MBXCustomLayerHost.h",
  "Sources/CMapbox/include/MBXCustomLayerRenderParameters.h",
  "Sources/CMapbox/include/MBXDEMEncoding.h",
  "Sources/CMapbox/include/MBXEdgeInsets.h",
  "Sources/CMapbox/include/MBXExpected.h",
  "Sources/CMapbox/include/MBXFeature.h",
  "Sources/CMapbox/include/MBXFeatureExtensionValue.h",
  "Sources/CMapbox/include/MBXFetchTileFunctionCallback.h",
  "Sources/CMapbox/include/MBXFillAnnotation.h",
  "Sources/CMapbox/include/MBXGeometry.h",
  "Sources/CMapbox/include/MBXHttpRequest.h",
  "Sources/CMapbox/include/MBXHttpRequestError.h",
  "Sources/CMapbox/include/MBXHttpRequestErrorType.h",
  "Sources/CMapbox/include/MBXHttpResponse.h",
  "Sources/CMapbox/include/MBXHttpResponseCallback.h",
  "Sources/CMapbox/include/MBXHttpResponseData.h",
  "Sources/CMapbox/include/MBXHttpServiceFactory.h",
  "Sources/CMapbox/include/MBXHttpServiceInterface.h",
  "Sources/CMapbox/include/MBXImage.h",
  "Sources/CMapbox/include/MBXImageContent.h",
  "Sources/CMapbox/include/MBXImageStretches.h",
  "Sources/CMapbox/include/MBXLayerMetadata.h",
  "Sources/CMapbox/include/MBXLayerType.h",
  "Sources/CMapbox/include/MBXLineAnnotation.h",
  "Sources/CMapbox/include/MBXMap.h",
  "Sources/CMapbox/include/MBXMapCameraDelegate.h",
  "Sources/CMapbox/include/MBXMapChange.h",
  "Sources/CMapbox/include/MBXMapClient.h",
  "Sources/CMapbox/include/MBXMapDebugOptions.h",
  "Sources/CMapbox/include/MBXMapLoadError.h",
  "Sources/CMapbox/include/MBXMapMode.h",
  "Sources/CMapbox/include/MBXMapObserver.h",
  "Sources/CMapbox/include/MBXMapOptions.h",
  "Sources/CMapbox/include/MBXMapSnapshot.h",
  "Sources/CMapbox/include/MBXMapSnapshotOptions.h",
  "Sources/CMapbox/include/MBXMapSnapshotter.h",
  "Sources/CMapbox/include/MBXMapViewDelegate.h",
  "Sources/CMapbox/include/MBXNetworkState.h",
  "Sources/CMapbox/include/MBXNetworkStatus.h",
  "Sources/CMapbox/include/MBXNorthOrientation.h",
  "Sources/CMapbox/include/MBXOfflineDatabaseMergeCallback.h",
  "Sources/CMapbox/include/MBXOfflineManager.h",
  "Sources/CMapbox/include/MBXOfflineRegion.h",
  "Sources/CMapbox/include/MBXOfflineRegionCallback.h",
  "Sources/CMapbox/include/MBXOfflineRegionCreateCallback.h",
  "Sources/CMapbox/include/MBXOfflineRegionDownloadState.h",
  "Sources/CMapbox/include/MBXOfflineRegionGeometryDefinition.h",
  "Sources/CMapbox/include/MBXOfflineRegionObserver.h",
  "Sources/CMapbox/include/MBXOfflineRegionStatus.h",
  "Sources/CMapbox/include/MBXOfflineRegionTilePyramidDefinition.h",
  "Sources/CMapbox/include/MBXOnlineManager.h",
  "Sources/CMapbox/include/MBXPeerWrapper.h",
  "Sources/CMapbox/include/MBXProjectedMeters.h",
  "Sources/CMapbox/include/MBXProjectionMode.h",
  "Sources/CMapbox/include/MBXRenderFrameStatus.h",
  "Sources/CMapbox/include/MBXRenderMode.h",
  "Sources/CMapbox/include/MBXRenderedQueryOptions.h",
  "Sources/CMapbox/include/MBXResourceKind.h",
  "Sources/CMapbox/include/MBXResourceOptions.h",
  "Sources/CMapbox/include/MBXResourceTransformInterface.h",
  "Sources/CMapbox/include/MBXResponseError.h",
  "Sources/CMapbox/include/MBXResponseErrorReason.h",
  "Sources/CMapbox/include/MBXRunLoop.h",
  "Sources/CMapbox/include/MBXSKUIdentifier.h",
  "Sources/CMapbox/include/MBXScheme.h",
  "Sources/CMapbox/include/MBXScreenBox.h",
  "Sources/CMapbox/include/MBXScreenCoordinate.h",
  "Sources/CMapbox/include/MBXSettings.h",
  "Sources/CMapbox/include/MBXSize.h",
  "Sources/CMapbox/include/MBXSnapshotCompleteCallback.h",
  "Sources/CMapbox/include/MBXSourceMetadata.h",
  "Sources/CMapbox/include/MBXSourceQueryOptions.h",
  "Sources/CMapbox/include/MBXSourceType.h",
  "Sources/CMapbox/include/MBXStillImageCallback.h",
  "Sources/CMapbox/include/MBXStylePropertyValue.h",
  "Sources/CMapbox/include/MBXStylePropertyValueKind.h",
  "Sources/CMapbox/include/MBXSymbolAnnotation.h",
  "Sources/CMapbox/include/MBXTileOptions.h",
  "Sources/CMapbox/include/MBXTileset.h",
  "Sources/CMapbox/include/MBXTimer.h",
  "Sources/CMapbox/include/MBXTimerCallback.h",
  "Sources/CMapbox/include/MBXTransitionOptions.h",
  "Sources/CMapbox/include/MBXUnitBezier.h",
  "Sources/CMapbox/include/MBXUtils.h",
  "Sources/CMapbox/include/MBXValueConverter.h",
  "Sources/CMapbox/include/MBXVersion.h",
  "Sources/CMapbox/include/MBXViewportMode.h",
  "Sources/CMapbox/include/NSValue+MBXMarshal.h"
                

  s.public_header_files =   "Sources/CMapbox/include/MBXAccounts.h",
  "Sources/CMapbox/include/MBXAnimationOptions.h",
  "Sources/CMapbox/include/MBXAnimationTransitionFinish.h",
  "Sources/CMapbox/include/MBXAnimationTransitionFrame.h",
  "Sources/CMapbox/include/MBXBoundOptions.h",
  "Sources/CMapbox/include/MBXCacheManager.h",
  "Sources/CMapbox/include/MBXCacheStatusCallback.h",
  "Sources/CMapbox/include/MBXCameraChange.h",
  "Sources/CMapbox/include/MBXCameraChangeMode.h",
  "Sources/CMapbox/include/MBXCameraOptions.h",
  "Sources/CMapbox/include/MBXCancelTileFunctionCallback.h",
  "Sources/CMapbox/include/MBXCanonicalTileID.h",
  "Sources/CMapbox/include/MBXConstrainMode.h",
  "Sources/CMapbox/include/MBXContextMode.h",
  "Sources/CMapbox/include/MBXCoordinateBounds.h",
  "Sources/CMapbox/include/MBXCoordinateQuad.h",
  "Sources/CMapbox/include/MBXCoreMapView.h",
  "Sources/CMapbox/include/MBXCustomGeometrySourceOptions.h",
  "Sources/CMapbox/include/MBXCustomLayerHost.h",
  "Sources/CMapbox/include/MBXCustomLayerRenderParameters.h",
  "Sources/CMapbox/include/MBXDEMEncoding.h",
  "Sources/CMapbox/include/MBXEdgeInsets.h",
  "Sources/CMapbox/include/MBXExpected.h",
  "Sources/CMapbox/include/MBXFeature.h",
  "Sources/CMapbox/include/MBXFeatureExtensionValue.h",
  "Sources/CMapbox/include/MBXFetchTileFunctionCallback.h",
  "Sources/CMapbox/include/MBXFillAnnotation.h",
  "Sources/CMapbox/include/MBXGeometry.h",
  "Sources/CMapbox/include/MBXHttpRequest.h",
  "Sources/CMapbox/include/MBXHttpRequestError.h",
  "Sources/CMapbox/include/MBXHttpRequestErrorType.h",
  "Sources/CMapbox/include/MBXHttpResponse.h",
  "Sources/CMapbox/include/MBXHttpResponseCallback.h",
  "Sources/CMapbox/include/MBXHttpResponseData.h",
  "Sources/CMapbox/include/MBXHttpServiceFactory.h",
  "Sources/CMapbox/include/MBXHttpServiceInterface.h",
  "Sources/CMapbox/include/MBXImage.h",
  "Sources/CMapbox/include/MBXImageContent.h",
  "Sources/CMapbox/include/MBXImageStretches.h",
  "Sources/CMapbox/include/MBXLayerMetadata.h",
  "Sources/CMapbox/include/MBXLayerType.h",
  "Sources/CMapbox/include/MBXLineAnnotation.h",
  "Sources/CMapbox/include/MBXMap.h",
  "Sources/CMapbox/include/MBXMapCameraDelegate.h",
  "Sources/CMapbox/include/MBXMapChange.h",
  "Sources/CMapbox/include/MBXMapClient.h",
  "Sources/CMapbox/include/MBXMapDebugOptions.h",
  "Sources/CMapbox/include/MBXMapLoadError.h",
  "Sources/CMapbox/include/MBXMapMode.h",
  "Sources/CMapbox/include/MBXMapObserver.h",
  "Sources/CMapbox/include/MBXMapOptions.h",
  "Sources/CMapbox/include/MBXMapSnapshot.h",
  "Sources/CMapbox/include/MBXMapSnapshotOptions.h",
  "Sources/CMapbox/include/MBXMapSnapshotter.h",
  "Sources/CMapbox/include/MBXMapViewDelegate.h",
  "Sources/CMapbox/include/MBXNetworkState.h",
  "Sources/CMapbox/include/MBXNetworkStatus.h",
  "Sources/CMapbox/include/MBXNorthOrientation.h",
  "Sources/CMapbox/include/MBXOfflineDatabaseMergeCallback.h",
  "Sources/CMapbox/include/MBXOfflineManager.h",
  "Sources/CMapbox/include/MBXOfflineRegion.h",
  "Sources/CMapbox/include/MBXOfflineRegionCallback.h",
  "Sources/CMapbox/include/MBXOfflineRegionCreateCallback.h",
  "Sources/CMapbox/include/MBXOfflineRegionDownloadState.h",
  "Sources/CMapbox/include/MBXOfflineRegionGeometryDefinition.h",
  "Sources/CMapbox/include/MBXOfflineRegionObserver.h",
  "Sources/CMapbox/include/MBXOfflineRegionStatus.h",
  "Sources/CMapbox/include/MBXOfflineRegionTilePyramidDefinition.h",
  "Sources/CMapbox/include/MBXOnlineManager.h",
  "Sources/CMapbox/include/MBXPeerWrapper.h",
  "Sources/CMapbox/include/MBXProjectedMeters.h",
  "Sources/CMapbox/include/MBXProjectionMode.h",
  "Sources/CMapbox/include/MBXRenderFrameStatus.h",
  "Sources/CMapbox/include/MBXRenderMode.h",
  "Sources/CMapbox/include/MBXRenderedQueryOptions.h",
  "Sources/CMapbox/include/MBXResourceKind.h",
  "Sources/CMapbox/include/MBXResourceOptions.h",
  "Sources/CMapbox/include/MBXResourceTransformInterface.h",
  "Sources/CMapbox/include/MBXResponseError.h",
  "Sources/CMapbox/include/MBXResponseErrorReason.h",
  "Sources/CMapbox/include/MBXRunLoop.h",
  "Sources/CMapbox/include/MBXSKUIdentifier.h",
  "Sources/CMapbox/include/MBXScheme.h",
  "Sources/CMapbox/include/MBXScreenBox.h",
  "Sources/CMapbox/include/MBXScreenCoordinate.h",
  "Sources/CMapbox/include/MBXSettings.h",
  "Sources/CMapbox/include/MBXSize.h",
  "Sources/CMapbox/include/MBXSnapshotCompleteCallback.h",
  "Sources/CMapbox/include/MBXSourceMetadata.h",
  "Sources/CMapbox/include/MBXSourceQueryOptions.h",
  "Sources/CMapbox/include/MBXSourceType.h",
  "Sources/CMapbox/include/MBXStillImageCallback.h",
  "Sources/CMapbox/include/MBXStylePropertyValue.h",
  "Sources/CMapbox/include/MBXStylePropertyValueKind.h",
  "Sources/CMapbox/include/MBXSymbolAnnotation.h",
  "Sources/CMapbox/include/MBXTileOptions.h",
  "Sources/CMapbox/include/MBXTileset.h",
  "Sources/CMapbox/include/MBXTimer.h",
  "Sources/CMapbox/include/MBXTimerCallback.h",
  "Sources/CMapbox/include/MBXTransitionOptions.h",
  "Sources/CMapbox/include/MBXUnitBezier.h",
  "Sources/CMapbox/include/MBXUtils.h",
  "Sources/CMapbox/include/MBXValueConverter.h",
  "Sources/CMapbox/include/MBXVersion.h",
  "Sources/CMapbox/include/MBXViewportMode.h",
  "Sources/CMapbox/include/NSValue+MBXMarshal.h"

  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.resources = ['']

  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.requires_arc = true
  s.module_name = "CMapbox"
  s.library = 'c++'
  s.ios.framework  = 'GLKit',
                     'MetalKit'
  s.vendored_libraries = 'Sources/CMapbox/lib/libMapboxCore.a'
  s.swift_version = "5.1"
  s.prepare_command = <<-CMD
                        cd Sources/CMapbox/lib
                        unzip -u libMapbox.a.zip
                        cp libMapbox.a libMapboxCore.a
                    CMD
end
