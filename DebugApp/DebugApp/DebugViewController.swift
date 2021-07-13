import UIKit
import SceneKit
import MapboxMaps
import Turf
// import MapboxDirections

let start = CLLocationCoordinate2D(latitude: 37.762708812633562, longitude: -122.43520083917338)
let end = CLLocationCoordinate2D(latitude: 37.7597, longitude: -122.4482)
let startBearing = 260.0

@objc(DebugViewController)

public class DebugViewController: UIViewController, CustomLayerHost {

    internal var mapView: MapView!
    internal var coordinates: [CLLocationCoordinate2D]!
    internal var ruler = CheapRuler(latitude: start.latitude)
    internal var routeProgress = 0.0
    internal var routeLength = 0.0
    public var peer: MBXPeerWrapper?

    var resourceOptions: ResourceOptions {
        guard let accessToken = AccountManager.shared.accessToken else {
            fatalError("Access token not set")
        }

        let resourceOptions = ResourceOptions(accessToken: accessToken)
        return resourceOptions
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        self.mapView = MapView(with: view.bounds, resourceOptions: resourceOptions)
        mapView.update { (mapOptions) in
            mapOptions.camera.maximumPitch = 85
            mapOptions.render.presentsWithTransaction = true
        }

        mapView.cameraManager.setCamera(
            centerCoordinate: start,
            padding: UIEdgeInsets(top: self.view.bounds.height * 0.5, left: 0, bottom: 0, right: 0),
            zoom: 19.7,
            bearing: startBearing,
            pitch: 69
        )
        
        mapView.on(.styleLoadingFinished) { [weak self] _ in
            self?.addTerrain()
            self?.addFillExtrusion()

            try! self?.mapView.__map.addStyleCustomLayer(forLayerId: "Custom",
                                                         layerHost: self!,
                                                    layerPosition: LayerPosition())

            self?.mapView.on(.mapLoadingFinished) {_ in
                self?.useTestRoute()
                self?.stepRouteAnimation();
            }
        }
        self.view.addSubview(mapView)
    }

    func addTerrain() {
        var demSource = RasterDemSource()
        demSource.url = "mapbox://mapbox.mapbox-terrain-dem-v1"
        demSource.tileSize = 512
        demSource.maxzoom = 14.0
        mapView.style.addSource(source: demSource, identifier: "mapbox-dem")
        var terrain = Terrain(sourceId: "mapbox-dem");
        terrain.exaggeration = .constant(1)
        _ = self.mapView.style.setTerrain(terrain)
        
        let light = [
            "anchor": "map",
            "color": "white",
            "intensity": 0.1
        ] as [ String: Any ]
        try! self.mapView.style.styleManager.setStyleLightForProperties(light)

        var skyLayer = SkyLayer(id: "sky-layer")
        skyLayer.paint?.skyType = .atmosphere
        skyLayer.paint?.skyAtmosphereSun = .constant([-81.649, 89])
        skyLayer.paint?.skyAtmosphereSunIntensity = .constant(12.0)

        _ = self.mapView.style.addLayer(layer: skyLayer)
        
        var hillshadeLayer = HillshadeLayer(id: "terrain-hillshade")
        hillshadeLayer.paint?.hillshadeIlluminationAnchor = .map
        hillshadeLayer.source = "mapbox-dem"
        _ = self.mapView.style.addLayer(layer: hillshadeLayer, layerPosition: LayerPosition(above: nil, below: "water", at: nil))
    }
    
    func addFillExtrusion() {
        let map = self.mapView.__map!
        do {
            if (!(try map.styleSourceExists(forSourceId: "composite"))) { return }
            let properties = [
                "id": "3d-buildings",
                "type": "fill-extrusion",
                "source": "composite",
                "minzoom": 15.0,
                "source-layer": "building",
                "filter": ["==", "extrude", "true"],
                "fill-extrusion-color": "white",
                "fill-extrusion-height": ["get", "height"],
                "fill-extrusion-vertical-gradient": true,
                "fill-extrusion-base": ["get", "min_height"]
            ] as [String : Any]
            
            try map.addStyleLayer(forProperties: properties, layerPosition: nil)
        } catch {
            print("Unexpected error: \(error).")
        }
    }
    
    func useTestRoute() {
        // simulate data
        // Result of calling  https://api.mapbox.com/directions/v5/mapbox/driving/-122.43520083917338,37.762708812633562;-122.4482,37.7597?geometries=geojson&access_token=pk.eyJ1IjoiYXN0b2ppbGoiLCJhIjoiY2p3dnNhemFsMDA1bzQ1cG1yazA2aXB5YiJ9.kQcgsabhhzdCPsDuOsNhAQ
        // Access token used is from https://docs.mapbox.com/help/glossary/directions-api/ example - use your own.
        self.coordinates = [[-122.435203,37.76271],[-122.436078,37.762436],[-122.450598,37.761565],
                            [-122.450288,37.760062],[-122.449234,37.759618],[-122.448173,37.759675]].map { CLLocationCoordinate2D(latitude:$0[1], longitude:$0[0]) };
        self.routeLength = self.ruler.lineDistance(points: self.coordinates)
        
        // let routeLine = LineAnnotation(coordinates: self.coordinates)
        // self.mapView.annotationManager.addAnnotation(routeLine)
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        mapView.cameraManager.setCamera(padding: UIEdgeInsets(top: self.view.bounds.height * 0.5, left: 0, bottom: 0, right: 0))
    }

    func easing(from: Double, to: Double) -> Double {
        var easing = to - from
        easing += easing > 180.0 ? -360.0 : easing < -180.0 ? 360.0 : 0.0
        return easing
    }

    func stepRouteAnimation() {
        if (routeProgress > 1.0) {
            routeProgress = 0;
            routeIncrement = 0;
        }
        let maxSpeed = 0.0004
        let pointInFurtherFuture = ruler.along(line: coordinates, dist: (routeProgress + 10 * maxSpeed) * routeLength)
        let routeInFurtherFutureEasing = abs(easing(from: modelBearing, to: ruler.bearing(a: self.position, b: pointInFurtherFuture)))
        if (routeInFurtherFutureEasing > 10) {
            slowdown = min(30, Int(routeInFurtherFutureEasing.rounded()))
        }
        slowdown -= 1
        if (slowdown > 0) {
            let speed = maxSpeed - Double(slowdown) * 0.00001
            routeIncrement = speed > routeIncrement ? routeIncrement + 0.00001 : routeIncrement - 0.00001
        } else {
            routeIncrement = routeIncrement > maxSpeed ? maxSpeed : 0.00001 + routeIncrement;
        }

        let camera = self.mapView.cameraView.camera;
        let pointInFuture = ruler.along(line: coordinates, dist: (routeProgress + 6 * routeIncrement) * routeLength)

        let cameraRouteBearing = ruler.bearing(a: camera.center!, b: pointInFuture)
        let routeBearing = ruler.bearing(a: self.position, b: pointInFuture)
        
        bearing = routeProgress < 0.01 ? startBearing : (camera.bearing! + 0.03 * easing(from: camera.bearing!, to: cameraRouteBearing))
        
        let modelEasing = easing(from: modelBearing, to: routeBearing)
        modelBearing = routeProgress == 0 ? startBearing : (modelBearing + 0.2 * modelEasing)

        // The example serves for demonstrating SceneKit rendering and unecessary details are left out on purpose.
        // In real application, important to follow speed per segment and increase distance according to it.

        let timeStep = 0.033333333333333333;
        let constAngleSpeed:Float = 0.3
        
        for (index, wheel) in wheels.enumerated() {
            wheel.simdEulerAngles[0] += constAngleSpeed
            if (index < 2) {
                let exaggeratedEasing = routeProgress != 0 ? min(max(-60, -modelEasing * 1.5), 60) : 0
                wheel.simdEulerAngles[1] = Float(exaggeratedEasing * Double.pi / 180.0)
            }
        }

        // Car position and orientation
        self.position = ruler.along(line: coordinates, dist: routeProgress * routeLength)

        mapView.cameraManager.setCamera(
            centerCoordinate: self.position,
            bearing: bearing
        )
        routeProgress += routeIncrement
        DispatchQueue.main.asyncAfter(deadline: .now() + timeStep) {
            self.stepRouteAnimation();
        }
        mapView.needsDisplayRefresh = true
    }
    
    func positionCarOverTerrain(elevationData: ElevationData, scale: Double, modelToMapRotation: inout simd_quatd) throws -> Double {
        // let elevationValue = elevationData.getElevationFor(position)
        let mercatorPosition = try Projection.project(for: self.position, zoomScale: scale)
        var dataNotAvailable = false;
        let ps = try wheels.map {
            (wheel: SCNNode) -> simd_double3 in
            let pos = wheel.convertPosition(SCNVector3Zero, to: self.scene.rootNode)
            let rotated = modelToMapRotation.act(SIMD3<Double>(Double(pos.x), -Double(pos.y), 0.0))
            let wheelRotated = MercatorCoordinate(x: mercatorPosition.x + rotated.x * meterInMercatorCoordinateUnits, y: mercatorPosition.y + rotated.y * meterInMercatorCoordinateUnits)
            let elevation = try elevationData.getElevationFor(Projection.unproject(for: wheelRotated, zoomScale: scale))
            dataNotAvailable = dataNotAvailable || elevation == nil
            return simd_make_double3(rotated.x, rotated.y, elevation != nil ? elevation!.doubleValue : 0.0)
        }
        
        if (dataNotAvailable) {
            let elevationValue = elevationData.getElevationFor(position)
            return elevationValue != nil ? elevationValue!.doubleValue : 0.0
        }

        let e0 = ps[0][2], e1 = ps[1][2], e2 = ps[2][2], e3 = ps[3][2]
        let d03 = (e0 + e3) / 2;
        let d12 = (e1 + e2) / 2;

        func rotationFor3Points(p0: simd_double3, p1: simd_double3, p2: simd_double3) {
            let p1p0 = simd_make_double2(p1 - p0);
            let p2p0 = simd_make_double2(p2 - p0);
            let from = simd_cross(p1p0, p2p0);
            let to = simd_cross(simd_make_double3(p1p0, (p1[2] - p0[2])),
                                simd_make_double3(p2p0, (p2[2] - p0[2])))
            // modelToMapRotation = simd_mul(modelToMapRotation, simd_quatd(from: from, to: to)) // after rotating around Z, rotate the car base
            modelToMapRotation = simd_mul(simd_quatd(from: simd_normalize(from), to: simd_normalize(to)), modelToMapRotation)
        };
        if (d03 > d12) {
            if (e1 < e2) {
                rotationFor3Points(p0: ps[1], p1: ps[3], p2: ps[0])
            } else {
                rotationFor3Points(p0: ps[2], p1: ps[0], p2: ps[3])
            }
        } else {
            if (e0 < e3) {
                rotationFor3Points(p0: ps[0], p1: ps[1], p2: ps[2])
            } else {
                rotationFor3Points(p0: ps[3], p1: ps[2], p2: ps[1])
            }
        }
        return max(d03, d12)
    }

/*    func startRouteAnimation_MapboxDirections() {
        // Code copied from https://github.com/mapbox/mapbox-directions-swift/blob/main/Directions%20Example/ViewController.swift#L65
        let wp1 = Waypoint(coordinate: start)
        let wp2 = Waypoint(coordinate: end)
        let routeOptions = RouteOptions(waypoints: [wp1, wp2], profileIdentifier: .automobile)
        routeOptions.routeShapeResolution = .full
        routeOptions.attributeOptions = [.congestionLevel, .maximumSpeedLimit]
        routeOptions.includesSteps = true
 
        let directions = Directions(credentials: DirectionsCredentials(accessToken: "pk.eyJ1IjoiYXN0b2ppbGoiLCJhIjoiY2p3dnNhemFsMDA1bzQ1cG1yazA2aXB5YiJ9.kQcgsabhhzdCPsDuOsNhAQ"))
        directions.calculate(routeOptions) { (session, result) in
            switch result {
            case let .failure(error):
                print("Error calculating directions: \(error)")
            case let .success(response):
                if let route = response.routes?.first, let leg = route.legs.first {
                    print("Route via \(leg):")
                    
                    let distanceFormatter = LengthFormatter()
                    let formattedDistance = distanceFormatter.string(fromMeters: route.distance)
                    
                    let travelTimeFormatter = DateComponentsFormatter()
                    travelTimeFormatter.unitsStyle = .short
                    let formattedExpectedTravelTime = travelTimeFormatter.string(from: route.expectedTravelTime)
                    var validTypicalTravelTime = "Not available"
                    if let typicalTravelTime = route.typicalTravelTime, let formattedTypicalTravelTime = travelTimeFormatter.string(from: typicalTravelTime) {
                        validTypicalTravelTime = formattedTypicalTravelTime
                    }
                    
                    print("Distance: \(formattedDistance); ETA: \(formattedExpectedTravelTime!); Typical travel time: \(validTypicalTravelTime)")
                    
                    if let routeCoordinates = route.shape?.coordinates, routeCoordinates.count > 0 {
                        // Convert the route’s coordinates into a polyline.
                        let routeLine = LineAnnotation(coordinates: routeCoordinates)

                        // Add the polyline to the map.
                        self.mapView.annotationManager.addAnnotation(routeLine)
                    }
                }
            }
        }
    }*/
    
    func setupVehicle() {
        wheels = [
            car.childNode(withName: "wheelLocator_FL", recursively: true)!,
            car.childNode(withName: "wheelLocator_FR", recursively: true)!,
            car.childNode(withName: "wheelLocator_RL", recursively: true)!,
            car.childNode(withName: "wheelLocator_RR", recursively: true)!
        ]
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
        lightNode.position = SCNVector3Make(-50, 100, 100);
        lightNode.light?.zNear = 1
        lightNode.light?.zFar = 1000
        lightNode.light?.intensity = 2000
        lightNode.light?.castsShadow = true
        lightNode.look(at: modelNode.worldPosition)
        modelNode.addChildNode(lightNode)
        
        let pointNode = SCNNode()
        pointNode.light = SCNLight()
        pointNode.light?.type = SCNLight.LightType.omni
        pointNode.light?.intensity = 3000
        pointNode.light?.castsShadow = true
        pointNode.position = SCNVector3Make(0, 25, 0)
        modelNode.addChildNode(pointNode)

                let floor = SCNNode()
floor.geometry = SCNFloor()
floor.geometry?.firstMaterial!.colorBufferWriteMask = []
floor.geometry?.firstMaterial!.readsFromDepthBuffer = true
floor.geometry?.firstMaterial!.writesToDepthBuffer = true
floor.geometry?.firstMaterial!.lightingModel = .constant
modelNode.addChildNode(floor)


    }
    
    func setupText() {
        let text = SCNText(string:"SceneKit Vehicle demo", extrusionDepth:3.0)
        text.firstMaterial!.diffuse.contents = UIColor.lightGray
        textNode = SCNNode(geometry:text)
        textNode.position = SCNVector3Make(14, 14, 10)
        textNode.scale = SCNVector3Make(0.4, 0.4, 0.4)
        textNode.rotation = SCNVector4(0,1,0,Double.pi)
        // scene.rootNode.addChildNode(textNode)
    }
    
    public func renderingWillStart(_ metalDevice: MTLDevice, colorPixelFormat: UInt, depthStencilPixelFormat: UInt) {
        renderer = SCNRenderer(device:metalDevice)
        scene = SCNScene()
        renderer.scene = scene
        modelNode = SCNNode()
        modelNode.rotation = SCNVector4(1,0,0,Double.pi/2)
        scene.rootNode.addChildNode(modelNode)

        car = SCNScene(named:"rc_car")?.rootNode.childNode(withName:"rccarBody", recursively:false);
        modelNode.addChildNode(car)
        
        
        setupVehicle()
        setupLight()
        setupText()
        
        cameraNode = SCNNode();
        let camera = SCNCamera();
        cameraNode.camera = camera;
        camera.usesOrthographicProjection = false;
        scene.rootNode.addChildNode(cameraNode);
        // scnRenderer.debugOptions = SCNDebugOptionShowLightInfluences | SCNDebugOptionShowLightExtents;
        renderer.pointOfView = cameraNode;
        // In order to use depth occlusion, align with gl-native Z handling (doesn't use reverse Z).
        if #available(iOS 13.0, *) {
            renderer.usesReverseZ = false
        } else {
            // Fallback on earlier versions
        }
        // renderer.debugOptions = [SCNDebugOptions.showPhysicsFields, SCNDebugOptions.showPhysicsShapes, SCNDebugOptions.showWireframe];
    }
    
    func makeTranslationMatrix(tx: Double, ty: Double, tz: Double) -> simd_double4x4 {
        var matrix = matrix_identity_double4x4
    
        matrix[3, 0] = tx
        matrix[3, 1] = ty
        matrix[3, 2] = tz
    
        return matrix
    }
    
    
    
    func makeScaleMatrix(xScale: Double, yScale: Double, zScale: Double) -> simd_double4x4 {
        var matrix = matrix_identity_double4x4
    
        matrix[0, 0] = xScale
        matrix[1, 1] = yScale
        matrix[2, 2] = zScale
    
        return matrix
    }
    
    func toSCNMatrix(transform: simd_double4x4) -> SCNMatrix4 {
                var scnMat = SCNMatrix4()
            scnMat.m11 = Float(transform[0, 0])
            scnMat.m12 = Float(transform[0, 1])
            scnMat.m13 = Float(transform[0, 2])
            scnMat.m14 = Float(transform[0, 3])
            scnMat.m21 = Float(transform[1, 0])
            scnMat.m22 = Float(transform[1, 1])
            scnMat.m23 = Float(transform[1, 2])
            scnMat.m24 = Float(transform[1, 3])
            scnMat.m31 = Float(transform[2, 0])
            scnMat.m32 = Float(transform[2, 1])
            scnMat.m33 = Float(transform[2, 2])
            scnMat.m34 = Float(transform[2, 3])
            scnMat.m41 = Float(transform[3, 0])
            scnMat.m42 = Float(transform[3, 1])
            scnMat.m43 = Float(transform[3, 2])
            scnMat.m44 = Float(transform[3, 3])
        return scnMat;
    }

    public func render(_ parameters: CustomLayerRenderParameters, mtlCommandBuffer: MTLCommandBuffer, mtlRenderPassDescriptor: MTLRenderPassDescriptor) {
        let m = parameters.projectionMatrix;
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

        do {
            
            let zRotation = .pi + modelBearing * .pi / 180.0
            let scale = pow(2, parameters.zoom);
            let start = try Projection.project(for: position, zoomScale: scale);
            let metersPerPixel = try Projection.getMetersPerPixelAtLatitude(forLatitude: position.latitude, zoom: parameters.zoom);
            self.meterInMercatorCoordinateUnits = 1.0 / metersPerPixel;
            var elevation = 0.0;
            var quaternion = simd_quatd(angle: zRotation, axis: SIMD3(0, 0, 1));
            if let elevationData = parameters.elevationData {
                elevation = try self.positionCarOverTerrain(elevationData: elevationData, scale: scale, modelToMapRotation: &quaternion)
                let pixel = try! self.mapView.__map.pixelForCoordinate(for: position)
                print(pixel.x, pixel.y)
            }
            
            let modelRotation = simd_double4x4(quaternion)
            let transformModel = makeTranslationMatrix(tx: start.x, ty: start.y, tz: elevation)
            let modelScale = makeScaleMatrix(xScale: meterInMercatorCoordinateUnits, yScale: meterInMercatorCoordinateUnits, zScale: 1)
            let flipYScale = makeScaleMatrix(xScale: 1, yScale: -1, zScale: 1)
            let transform = transformSimd * transformModel * modelScale * modelRotation * flipYScale
//            modelNode.transform = toSCNMatrix(transform: flipYScale)

            cameraNode.camera!.projectionTransform = toSCNMatrix(transform: transform)
            SCNTransaction.flush()

            if let colorTexture = mtlRenderPassDescriptor.colorAttachments[0].texture {
                renderer.render(withViewport: CGRect(x: 0, y: 0, width: CGFloat(colorTexture.width), height: CGFloat(colorTexture.height)), commandBuffer:mtlCommandBuffer, passDescriptor:mtlRenderPassDescriptor)
            }
        } catch {
        
        }


    }

    public func renderingWillEnd() {
        // Unimplemented
    }
    
    var renderer: SCNRenderer!
    var scene: SCNScene!
    var modelNode: SCNNode!
    var cameraNode: SCNNode!
    var textNode: SCNNode!
    var lightNode: SCNNode!
    var vehicle: SCNPhysicsVehicle!
    var car: SCNNode!
    var position = start
    var bearing = 200.0
    var modelBearing = startBearing
    var routeIncrement = 0.0
    var slowdown = 0;
    var wheels: [SCNNode]!
    var meterInMercatorCoordinateUnits: Double!
}
