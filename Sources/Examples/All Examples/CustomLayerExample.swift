import UIKit
@_spi(Experimental) import MapboxMaps
import MetalKit
import simd

final class CustomLayerExample: UIViewController, ExampleProtocol {
    private var mapView: MapView!
    private var cancelables: Set<AnyCancelable> = []
    // The CustomLayerExampleCustomLayerHost() should be created and stored outside of MapStyleContent so that it is not recreated with every style update.
    let renderer = CustomLayerExampleCustomLayerHost()

    private var displayLink: CADisplayLink! {
        didSet {
            oldValue?.invalidate()
        }
    }

    deinit {
        displayLink?.invalidate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let cameraOptions = CameraOptions(center: .hanoi, zoom: 1.5)

        mapView = MapView(frame: view.bounds, mapInitOptions: MapInitOptions(cameraOptions: cameraOptions))
        mapView.debugOptions = .camera
        mapView.mapboxMap.mapStyle = .streets
        mapView.mapboxMap.setMapStyleContent {
            CustomLayer(id: "custom-layer-example", renderer: renderer)
                .position(.below("waterway"))
        }

        mapView.mapboxMap.onRenderFrameStarted.observeNext { [weak self] _ in
            guard let self else { return }

            self.displayLink = CADisplayLink(target: self, selector: #selector(self.triggerMapRepaint))
            self.displayLink.add(to: .main, forMode: .common)
        }.store(in: &cancelables)


        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        navigationController?.isNavigationBarHidden = true
        view.addSubview(mapView)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         // The below line is used for internal testing purposes only.
        finish()
    }

    @objc private func triggerMapRepaint() {
        mapView.mapboxMap.triggerRepaint()
    }
}

private struct CubeConfiguration {
    let location: CLLocationCoordinate2D
    let cubeTessellation: Int
    let cubeSize: Float // in meters
    let altitude: Float
}

private struct PointsConfiguration {
    let start, end: CLLocationCoordinate2D
    let pointsCount: Int
}

final class CustomLayerExampleCustomLayerHost: NSObject, CustomLayerHost {

    var simpleShaderProgram: ShaderProgram!
    var globeShaderProgram: ShaderProgram!
    var metalDevice: MTLDevice!

    // For example 1: Render cubes
    private let cubeConfiguration = CubeConfiguration(location: .helsinki, cubeTessellation: 1, cubeSize: 1_000, altitude: 0)
    private var cubeVertexBuffer: MTLBuffer!

    // For example 2: Render moving points
    private let pointsConfiguration = PointsConfiguration(start: .berlin, end: .tokyo, pointsCount: 128)
    private var pointsVertexBuffer: MTLBuffer!
    private var pointsUniformBuffer: MTLBuffer!

    private lazy var renderMovingPointsStartTime = CACurrentMediaTime()

    func renderingWillStart(_ metalDevice: MTLDevice, colorPixelFormat: UInt, depthStencilPixelFormat: UInt) {
        guard let library = metalDevice.makeDefaultLibrary() else {
            fatalError("Failed to create shader")
        }

        do {
            simpleShaderProgram = try library.loadShaderProgram(vertexFunctionName: "vertexShader", fragmentFunctionName: "fragmentShader")
            try simpleShaderProgram.setup(metalDevice: metalDevice, colorPixelFormat: colorPixelFormat, depthStencilPixelFormat: depthStencilPixelFormat)

            globeShaderProgram = try library.loadShaderProgram(vertexFunctionName: "globeVertexShader", fragmentFunctionName: "globeFragmentShader")
            try globeShaderProgram.setup(metalDevice: metalDevice, colorPixelFormat: colorPixelFormat, depthStencilPixelFormat: depthStencilPixelFormat)
        } catch {
            print("Failed to load shader programs \(error)")
        }

        // ---- Create buffer
        let cubeVertexData = cubeVertexDataFrom(
            cubeConfiguration: cubeConfiguration)
        cubeVertexBuffer = metalDevice.makeBuffer(
            bytes: cubeVertexData,
            length: MemoryLayout<VertexData>.stride * cubeVertexData.count,
            options: [])

        pointsVertexBuffer = metalDevice.makeBuffer(length: pointsConfiguration.pointsCount * MemoryLayout<GlobeVertexData>.stride, options: [])
        pointsUniformBuffer = metalDevice.makeBuffer(length: MemoryLayout<GlobeUniforms>.stride, options: [])
    }

    func render(_ parameters: CustomLayerRenderParameters, mtlCommandBuffer: MTLCommandBuffer, mtlRenderPassDescriptor: MTLRenderPassDescriptor) {
        guard let renderCommandEncoder = mtlCommandBuffer.makeRenderCommandEncoder(descriptor: mtlRenderPassDescriptor) else {
            fatalError("Could not create render command encoder from render pass descriptor.")
        }

        let pixelRatio = UIScreen.main.scale

        let viewport = MTLViewport(
            originX: 0,
            originY: 0,
            // convert logical pixels to device pixels.
            width: parameters.width * pixelRatio,
            height: parameters.height * pixelRatio,
            znear: 0,
            zfar: 1
        )

        renderCommandEncoder.label = "Custom Layer"
        renderCommandEncoder.pushDebugGroup("Custom Layer")

        renderCommandEncoder.setViewport(viewport)

        // ----
        renderCubesInMeters(parameters: parameters, renderCommandEncoder: renderCommandEncoder)
        renderMovingPoints(parameters: parameters, renderCommandEncoder: renderCommandEncoder)
        // ----

        renderCommandEncoder.popDebugGroup()
        renderCommandEncoder.endEncoding()
    }

    func renderingWillEnd() {
        // Unimplemented
    }

    // MARK: Render

    private func renderCubesInMeters(
        parameters: CustomLayerRenderParameters,
        renderCommandEncoder: MTLRenderCommandEncoder
    ) {
        // 1. Get projection matrix from Mapbox
        let projectionMatrix = parameters.projectionMatrix.simdFloat4x4

        // 2.
        let modelMatrix = parameters.createModelMatrixMeters(
            location: cubeConfiguration.location,
            altitude: cubeConfiguration.altitude,
            size: cubeConfiguration.cubeSize)
        // 3.
        let transformedMatrix = parameters.projection.convertMercatorModelMatrix(
            forMatrix: modelMatrix.nsNumberArray,
            ignoreDistortion: false
        )!.simdFloat4x4

        // 4. MVP
        var finalMatrix = projectionMatrix * transformedMatrix

        // 5. Send data to GPU
        renderCommandEncoder.setDepthStencilState(simpleShaderProgram.depthStencilState)
        renderCommandEncoder.setRenderPipelineState(simpleShaderProgram.pipelineState)

        renderCommandEncoder.setVertexBuffer(cubeVertexBuffer, offset: 0, index: 0)
        renderCommandEncoder.setVertexBytes(&finalMatrix, length: MemoryLayout<simd_float4x4>.stride, index: 1)

        // 6. Draw
        let vertexCount = 6 * verticesPerCubeSide(tessellation: cubeConfiguration.cubeTessellation)
        renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount)
    }

    private func renderMovingPoints(
        parameters: CustomLayerRenderParameters,
        renderCommandEncoder: MTLRenderCommandEncoder
    ) {
        let elapsed = CACurrentMediaTime() - renderMovingPointsStartTime
        let worldSize = Projection.worldSize(scale: parameters.zoomScale)

        // 1. Setup globe vertices buffer
        let globeVertices = pointsVertexBuffer.contents().bindMemory(
            to: GlobeVertexData.self,
            capacity: pointsConfiguration.pointsCount)

        for i in 0 ..< pointsConfiguration.pointsCount {
            let phase = Float(i) / Float(pointsConfiguration.pointsCount - 1)
            let wavePhase = Float(Double.pi * 2) * phase * 8.0 + Float(elapsed * Double.pi * 2)
            let lat = interpolate(Float(pointsConfiguration.start.latitude), Float(pointsConfiguration.end.latitude), phase)
            let lng = interpolate(Float(pointsConfiguration.start.longitude), Float(pointsConfiguration.end.longitude), phase)
            let altitude = sin(wavePhase) * 300_000.0 + 400_000.0 // meters

            let ecef = latLngToECEF(lat: lat, lng: lng, altitude: altitude)
            let merc = Projection.latLngToMercatorXY(coordinate: CLLocationCoordinate2D(latitude: Double(lat), longitude: Double(lng)))

            let mercPos = SIMD3<Float>(Float(merc.x * worldSize), Float(merc.y * worldSize), Float(altitude))
            let ecefPos = SIMD3<Float>(Float(ecef.x), Float(ecef.y), Float(ecef.z))
            let color   = SIMD3<Float>(1.0, 1.0, 0.0) // yellow
            globeVertices[i] = GlobeVertexData(pos_merc: mercPos, pos_ecef: ecefPos, color: color)
        }

        // 2. Set up uniform buffer
        let globeModelMatrix = parameters.projection.getModelMatrix().simdFloat4x4
        let globeWvp = parameters.projectionMatrix.simdFloat4x4 * globeModelMatrix
        let mercWvp = parameters.projectionMatrix.simdFloat4x4 * parameters.projection.getTransitionMatrix().simdFloat4x4
        let transitionPhase = parameters.projection.getTransitionPhase()

        var uniforms = GlobeUniforms(
            u_matrix_merc: mercWvp,
            u_matrix_ecef: globeWvp,
            u_transition: transitionPhase,
            u_point_size: 40
        )

        pointsUniformBuffer.contents().copyMemory(from: &uniforms, byteCount: MemoryLayout<GlobeUniforms>.stride)

        // --- 3. Encode draw commands ---
        renderCommandEncoder.setRenderPipelineState(globeShaderProgram.pipelineState)
        renderCommandEncoder.setVertexBuffer(pointsVertexBuffer, offset: 0, index: 0)
        renderCommandEncoder.setVertexBuffer(pointsUniformBuffer, offset: 0, index: 1)

        renderCommandEncoder.setTriangleFillMode(.fill)
        renderCommandEncoder.setCullMode(.none)
        renderCommandEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: pointsConfiguration.pointsCount)
    }
}

// MARK: Shader programs

final class ShaderProgram {
    let vertexFunction: MTLFunction
    let fragmentFunction: MTLFunction

    private(set) var depthStencilState: MTLDepthStencilState!
    private(set) var pipelineState: MTLRenderPipelineState!

    init(vertexFunction: MTLFunction, fragmentFunction: MTLFunction) {
        self.vertexFunction = vertexFunction
        self.fragmentFunction = fragmentFunction
    }

    func setup(metalDevice: MTLDevice, colorPixelFormat: UInt, depthStencilPixelFormat: UInt) throws {
        // Set up vertex descriptor
        let vertexDescriptor = MTLVertexDescriptor()

        // Set up pipeline descriptor
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.label = "Test Layer"
        pipelineStateDescriptor.vertexFunction = vertexFunction
        pipelineStateDescriptor.vertexDescriptor = vertexDescriptor
        pipelineStateDescriptor.fragmentFunction = fragmentFunction

        // Set up color attachment
        let colorAttachment = pipelineStateDescriptor.colorAttachments[0]
        colorAttachment?.pixelFormat = MTLPixelFormat(rawValue: colorPixelFormat)!
        colorAttachment?.isBlendingEnabled = true
        colorAttachment?.rgbBlendOperation = colorAttachment?.alphaBlendOperation ?? .add
        colorAttachment?.sourceAlphaBlendFactor = colorAttachment?.sourceAlphaBlendFactor ?? .one
        colorAttachment?.destinationRGBBlendFactor = .oneMinusSourceAlpha

        // Configure render pipeline descriptor
        pipelineStateDescriptor.depthAttachmentPixelFormat = MTLPixelFormat(rawValue: depthStencilPixelFormat)!
        pipelineStateDescriptor.stencilAttachmentPixelFormat = MTLPixelFormat(rawValue: depthStencilPixelFormat)!

        // Configure the depth stencil
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.isDepthWriteEnabled = true
        depthStencilDescriptor.depthCompareFunction = .less

        depthStencilState = metalDevice.makeDepthStencilState(descriptor: depthStencilDescriptor)
        pipelineState = try metalDevice.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
    }
}

enum ShaderProgramLoadError: Error {
    case noVertexFunction, noFragmentFunction
}

extension MTLLibrary {

    func loadShaderProgram(vertexFunctionName: String, fragmentFunctionName: String) throws -> ShaderProgram {
        guard let vertexFunction = makeFunction(name: vertexFunctionName) else {
            throw ShaderProgramLoadError.noVertexFunction
        }
        guard let fragmentFunction = makeFunction(name: fragmentFunctionName) else {
            throw ShaderProgramLoadError.noFragmentFunction
        }

        return ShaderProgram(vertexFunction: vertexFunction, fragmentFunction: fragmentFunction)
    }
}

// MARK: Vertex Data

private func cubeVertexDataFrom(cubeConfiguration: CubeConfiguration) -> [VertexData] {
    let mercatorPos = Projection.latLngToMercatorXY(coordinate: cubeConfiguration.location)
    let x = Float(mercatorPos.x)
    let y = Float(mercatorPos.y)
    let z = cubeConfiguration.altitude
    let h = cubeConfiguration.cubeSize / 2.0

    let positions: [SIMD3<Float>] = [
        // Front face
        [x - h, y - h, z + h], [x + h, y - h, z + h], [x + h, y + h, z + h],
        [x - h, y - h, z + h], [x + h, y + h, z + h], [x - h, y + h, z + h],
        // Back face
        [x - h, y - h, z - h], [x + h, y + h, z - h], [x + h, y - h, z - h],
        [x - h, y - h, z - h], [x - h, y + h, z - h], [x + h, y + h, z - h],
        // Left face
        [x - h, y - h, z - h], [x - h, y - h, z + h], [x - h, y + h, z + h],
        [x - h, y - h, z - h], [x - h, y + h, z + h], [x - h, y + h, z - h],
        // Right face
        [x + h, y - h, z - h], [x + h, y + h, z + h], [x + h, y - h, z + h],
        [x + h, y - h, z - h], [x + h, y + h, z - h], [x + h, y + h, z + h],
        // Top face
        [x - h, y + h, z - h], [x - h, y + h, z + h], [x + h, y + h, z + h],
        [x - h, y + h, z - h], [x + h, y + h, z + h], [x + h, y + h, z - h],
        // Bottom face
        [x - h, y - h, z - h], [x + h, y - h, z + h], [x - h, y - h, z + h],
        [x - h, y - h, z - h], [x + h, y - h, z - h], [x + h, y - h, z + h]
    ]

    let colors = createCubeVertexColors(sides: [
        SIMD4(1, 0, 0, 0.6), // Front - Red
        SIMD4(0, 1, 0, 0.6), // Back - Green
        SIMD4(0, 0, 1, 0.6), // Left - Blue
        SIMD4(1, 1, 0, 0.6), // Right - Yellow
        SIMD4(0, 1, 1, 0.6), // Top - Cyan
        SIMD4(1, 0, 1, 0.6)  // Bottom - Magenta
    ])

    let vertexData = zip(positions, colors)
        .map {
            let (position, color) = $0
            return VertexData(position: position, color: color)
        }

    return vertexData
}

func createCubeVertexColors(sides: [SIMD4<Float>], tessellation: Int = 1) -> [SIMD4<Float>] {
    let tessellation = max(tessellation, 1)
    let verticesPerColor = verticesPerCubeSide(tessellation: tessellation) // Each side: quads * 2 triangles

    var colors: [SIMD4<Float>] = []
    colors.reserveCapacity(verticesPerColor * 6)

    for color in sides {
        colors.append(contentsOf: Array(repeating: color, count: verticesPerColor))
    }

    return colors
}

// MARK: Utils

extension simd_float4x4 {
    var nsNumberArray: [NSNumber] {
        return [
            self.columns.0.x, self.columns.0.y, self.columns.0.z, self.columns.0.w,
            self.columns.1.x, self.columns.1.y, self.columns.1.z, self.columns.1.w,
            self.columns.2.x, self.columns.2.y, self.columns.2.z, self.columns.2.w,
            self.columns.3.x, self.columns.3.y, self.columns.3.z, self.columns.3.w
        ].map(NSNumber.init(value:))
    }
}

extension Array where Element == NSNumber {
    var simdFloat4x4: simd_float4x4 {
        return simd_float4x4([
            simd_float4(self[0].floatValue, self[1].floatValue, self[2].floatValue, self[3].floatValue),
            simd_float4(self[4].floatValue, self[5].floatValue, self[6].floatValue, self[7].floatValue),
            simd_float4(self[8].floatValue, self[9].floatValue, self[10].floatValue, self[11].floatValue),
            simd_float4(self[12].floatValue, self[13].floatValue, self[14].floatValue, self[15].floatValue)
        ])
    }
}

func interpolate(_ a: Float, _ b: Float, _ t: Float) -> Float {
    return a + (b - a) * t
}

// Height of renderable models (i.e. the z-axis) is defined meters and the conversion into pixels
// is baked into the projection matrix. Because the projection matrix uses `metersToPixels` computed at
// the map center whereas the value is actually a function of latitude, we might need to apply compensation
// to transformation matrices of models located at different latitudue coordinates.
func heightScalerForLatitude(_ latitude: CLLocationDegrees, centerLatitude: CLLocationDegrees) -> Float {
    Float(Projection.getLatitudeScale(centerLatitude) / Projection.getLatitudeScale(latitude))
}

func latLngToECEF(lat: Float, lng: Float, altitude: Float = 0.0) -> SIMD3<Float> {
    let EXTENT: Float = 8192.0
    let M2PI = Float.pi * 2.0
    let DEG2RAD = Float.pi / 180.0

    let radius = EXTENT / M2PI
    let ecefPerMeter = Float(Projection.metersToMercator(latitude: 0.0)) * EXTENT
    let z = radius + altitude * ecefPerMeter

    let latRad = lat * DEG2RAD
    let lngRad = lng * DEG2RAD

    let sx = cos(latRad) * sin(lngRad) * z
    let sy = -sin(latRad) * z
    let sz = cos(latRad) * cos(lngRad) * z

    return SIMD3<Float>(sx, sy, sz)
}

// Creates a matrix that scales from meters into world units (i.e. pixel units)
func createMetricScaleMatrix(
    x: Float,
    y: Float,
    z: Float,
    altitudeScaler: Float
) -> simd_float4x4 {
    var mat = matrix_identity_float4x4

    mat[0, 0] = x
    mat[1, 1] = y
    mat[2, 2] = z * altitudeScaler

    return mat
}

func verticesPerCubeSide(tessellation: Int) -> Int {
    tessellation * tessellation * 6
}

extension Projection {

    static func metersToMercator(latitude: CLLocationDegrees) -> Double {
        let pixelsPerMeters = 1.0 / Projection.metersPerPoint(for: latitude, zoom: 0)
        let pixelsToMercator = 1.0 / Projection.worldSize(scale: 1.0)

        return pixelsPerMeters * pixelsToMercator
    }
}

extension CustomLayerRenderParameters {

    var zoomScale: Double { pow(2, zoom) }

    private func createTranslationMatrix(
        location: CLLocationCoordinate2D,
        altitude: Float,
        heightScaler: Float
    ) -> simd_float4x4 {
        // 1. Convert lat/lng to Mercator XY
        let mercatorPos = Projection.latLngToMercatorXY(coordinate: location)

        // 2. Compute world size for current zoom
        let worldSize = Projection.worldSize(scale: zoomScale)

        // 3. World position in pixels
        let worldPos = (x: Float(mercatorPos.x * worldSize), y: Float(mercatorPos.y * worldSize))

        // 4. Construct translation matrix
        let translation = simd_float4x4([
            simd_float4(1, 0, 0, 0),
            simd_float4(0, 1, 0, 0),
            simd_float4(0, 0, 1, 0),
            simd_float4(worldPos.x, worldPos.y, altitude * heightScaler, 1)
        ])

        return translation
    }

    func createModelMatrixMeters(
        location: CLLocationCoordinate2D,
        altitude: Float,
        size: Float
    ) -> simd_float4x4 {
        let altitudeScaler = heightScalerForLatitude(location.latitude, centerLatitude: latitude)

        // 1. Translation matrix
        let translation = createTranslationMatrix(location: location, altitude: altitude, heightScaler: altitudeScaler)

        // 2. Meters to pixels
        let metersToPixels = 1.0 / Float(Projection.metersPerPoint(for: location.latitude, zoom: zoom))
        let xSize = size * metersToPixels
        let ySize = size * metersToPixels

        // 3. Scale matrix
        let scale = createMetricScaleMatrix(
            x: xSize,
            y: ySize,
            z: size,
            altitudeScaler: altitudeScaler
        )

        // 4. Combine: translation * scale
        return translation * scale
    }
}
