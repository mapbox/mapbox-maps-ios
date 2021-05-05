import UIKit
import SceneKit
import MapboxMaps

@objc(SceneKitExample)

public class SceneKitExample: UIViewController, ExampleProtocol, CustomLayerHost {

    internal var mapView: MapView!

    let modelOrigin = CLLocationCoordinate2D(latitude: -35.39847, longitude: 148.9819)
    var renderer: SCNRenderer!
    var scene: SCNScene!
    var modelNode: SCNNode!
    var cameraNode: SCNNode!
    var textNode: SCNNode!
    var useCPUOcclusion = false

    override public func viewDidLoad() {
        super.viewDidLoad()

        let camera = CameraOptions(center: self.modelOrigin,
                                   zoom: 18,
                                   bearing: 180,
                                   pitch: 60)
        let options = MapInitOptions(cameraOptions: camera)

        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(mapView)

        self.mapView.on(.styleLoaded) { [weak self] _ in
            self?.addModelAndTerrain()
        }
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    func addModelAndTerrain() {
        try! mapView.style.addCustomLayer(
            withId: "Custom",
            layerHost: self,
            layerPosition: LayerPosition(above: nil, below: "waterway-label", at: nil))

        var demSource = RasterDemSource()
        demSource.url = "mapbox://mapbox.mapbox-terrain-dem-v1"
        demSource.tileSize = 512
        demSource.maxzoom = 14.0

        try! mapView.style.addSource(demSource, id: "mapbox-dem")

        let terrain = Terrain(sourceId: "mapbox-dem")
        _ = self.mapView.style.setTerrain(terrain)

        var skyLayer = SkyLayer(id: "sky-layer")
        skyLayer.paint?.skyType = .constant(.atmosphere)
        skyLayer.paint?.skyAtmosphereSun = .constant([0, 0])
        skyLayer.paint?.skyAtmosphereSunIntensity = .constant(15.0)

        try! self.mapView.style.addLayer(skyLayer)

        // Re-use terrain source for hillshade
        let properties = [
            "id": "terrain_hillshade",
            "type": "hillshade",
            "source": "mapbox-dem",
            "hillshade-illumination-anchor": "map"
        ] as [ String: Any ]

        mapView.mapboxMap.__map.addStyleLayer(
            forProperties: properties,
            layerPosition: LayerPosition(above: nil, below: "water", at: nil))
    }

    public func renderingWillStart(_ metalDevice: MTLDevice, colorPixelFormat: UInt, depthStencilPixelFormat: UInt) {
        renderer = SCNRenderer(device: metalDevice)
        scene = SCNScene()
        renderer.scene = scene

        modelNode = SCNScene(named: "34M_17")?.rootNode.clone()
        scene.rootNode.addChildNode(modelNode)

        cameraNode = SCNNode()
        let camera = SCNCamera()
        cameraNode.camera = camera
        camera.usesOrthographicProjection = false
        scene.rootNode.addChildNode(cameraNode)
        renderer.pointOfView = cameraNode
        self.setupLight()
        // In order to use depth occlusion, align with gl-native Z handling (doesn't use reverse Z).
        if #available(iOS 13.0, *) {
            renderer.usesReverseZ = false
        } else {
            // Fallback on earlier versions, disable depth in render()
            self.useCPUOcclusion = true
        }
    }

    func setupLight() {
        // Ambient light
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = SCNLight.LightType.ambient
        ambientLight.light?.color = UIColor(white: 0.4, alpha: 1.0)
        modelNode.addChildNode(ambientLight)

        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = SCNLight.LightType.directional
        lightNode.light?.orthographicScale = 30
        lightNode.light?.color = UIColor(white: 0.8, alpha: 1.0)
        lightNode.position = SCNVector3Make(-50, 100, 100)
        lightNode.light?.zNear = 1
        lightNode.light?.zFar = 1000
        lightNode.light?.intensity = 2000
        lightNode.look(at: modelNode.worldPosition)
        modelNode.addChildNode(lightNode)
        let pointNode = SCNNode()
        pointNode.light = SCNLight()
        pointNode.light?.type = SCNLight.LightType.omni
        pointNode.light?.intensity = 3000
        pointNode.position = SCNVector3Make(0, 25, 0)
        modelNode.addChildNode(pointNode)
    }

    internal func makeTranslationMatrix(tx: Double, ty: Double, tz: Double) -> simd_double4x4 {
        var matrix = matrix_identity_double4x4

        matrix[3, 0] = tx
        matrix[3, 1] = ty
        matrix[3, 2] = tz

        return matrix
    }

    internal func makeScaleMatrix(xScale: Double, yScale: Double, zScale: Double) -> simd_double4x4 {
        var matrix = matrix_identity_double4x4

        matrix[0, 0] = xScale
        matrix[1, 1] = yScale
        matrix[2, 2] = zScale

        return matrix
    }

    public func render(_ parameters: CustomLayerRenderParameters, mtlCommandBuffer: MTLCommandBuffer, mtlRenderPassDescriptor: MTLRenderPassDescriptor) {
        guard let colorTexture = mtlRenderPassDescriptor.colorAttachments[0].texture else {
            return
        }
        let m = parameters.projectionMatrix

        // It is essential to use double precision for computation below: using simd instead
        // of SceneKit matrix operations.
        var transformSimd = matrix_identity_double4x4
        transformSimd[0, 0] = m[0].doubleValue
        transformSimd[0, 1] = m[1].doubleValue
        transformSimd[0, 2] = m[2].doubleValue
        transformSimd[0, 3] = m[3].doubleValue
        transformSimd[1, 0] = m[4].doubleValue
        transformSimd[1, 1] = m[5].doubleValue
        transformSimd[1, 2] = m[6].doubleValue
        transformSimd[1, 3] = m[7].doubleValue
        transformSimd[2, 0] = m[8].doubleValue
        transformSimd[2, 1] = m[9].doubleValue
        transformSimd[2, 2] = m[10].doubleValue
        transformSimd[2, 3] = m[11].doubleValue
        transformSimd[3, 0] = m[12].doubleValue
        transformSimd[3, 1] = m[13].doubleValue
        transformSimd[3, 2] = m[14].doubleValue
        transformSimd[3, 3] = m[15].doubleValue

        // Model is using metric unit system: scale x and y from meters to mercator and keep z is in meters.
        let meterInMercatorCoordinateUnits = 1.0 / (Projection.getMetersPerPixelAtLatitude(forLatitude: modelOrigin.latitude, zoom: parameters.zoom))
        let modelScale = makeScaleMatrix(xScale: meterInMercatorCoordinateUnits, yScale: -meterInMercatorCoordinateUnits, zScale: 1)

        // Translate scaled model to model origin (in web mercator coordinates) and elevate to model origin's altitude (in meters).
        let origin = Projection.project(for: modelOrigin, zoomScale: pow(2, parameters.zoom))
        var elevation = 0.0
        if let elevationData = parameters.elevationData, let elevationValue = elevationData.getElevationFor(self.modelOrigin) {
            elevation = elevationValue.doubleValue
        }
        let translateModel = makeTranslationMatrix(tx: origin.x, ty: origin.y, tz: elevation)

        let transform = transformSimd * translateModel * modelScale

        let scnMat = SCNMatrix4(
            m11: Float(transform[0, 0]),
            m12: Float(transform[0, 1]),
            m13: Float(transform[0, 2]),
            m14: Float(transform[0, 3]),
            m21: Float(transform[1, 0]),
            m22: Float(transform[1, 1]),
            m23: Float(transform[1, 2]),
            m24: Float(transform[1, 3]),
            m31: Float(transform[2, 0]),
            m32: Float(transform[2, 1]),
            m33: Float(transform[2, 2]),
            m34: Float(transform[2, 3]),
            m41: Float(transform[3, 0]),
            m42: Float(transform[3, 1]),
            m43: Float(transform[3, 2]),
            m44: Float(transform[3, 3])
        )
        cameraNode.camera!.projectionTransform = scnMat

        // flush automatic SceneKit transaction as SceneKit animation is not running and
        // there's need to use transform matrix in this frame (not to have it used with delay).
        SCNTransaction.flush()

        if self.useCPUOcclusion {
            mtlRenderPassDescriptor.depthAttachment = nil
            mtlRenderPassDescriptor.stencilAttachment = nil
            // Example uses depth buffer to occlude model when e.g. behind the hill.
            // If depth buffer (SCNRenderer.usesReverseZ = false) is not available, or if wished to
            // to indicate that model is occluded or e.g. implement fade out / fade in model occlusion,
            // the example here needs to provide CPU side occlusion implementation, too.
            // TODO: this is blocked on https://github.com/mapbox/mapbox-maps-ios/issues/155
        }
        renderer.render(withViewport: CGRect(x: 0, y: 0, width: CGFloat(colorTexture.width), height: CGFloat(colorTexture.height)), commandBuffer: mtlCommandBuffer, passDescriptor: mtlRenderPassDescriptor)

    }

    public func renderingWillEnd() {
        // The below line is used for internal testing purposes only.
        self.finish()
    }
}
