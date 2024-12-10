import UIKit
@_spi(Experimental) import MapboxMaps
import MetalKit

final class CustomLayerExample: UIViewController, ExampleProtocol {
    private var mapView: MapView!

    var colorArray = [
        simd_float4(1, 0, 0, 0.5),
        simd_float4(0.5, 0, 0, 0.5),
        simd_float4(0, 1, 0, 0.5),
        simd_float4(0, 0.5, 0, 0.5),
        simd_float4(0, 0, 1, 0.5),
        simd_float4(0, 0, 0.5, 0.5),
    ]

    // The CustomLayerExampleCustomLayerHost() should be created and stored outside of MapStyleContent so that it is not recreated with every style update.
    let renderer = CustomLayerExampleCustomLayerHost()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Update", style: .plain, target: self, action: #selector(barButtonTap(_:)))

        let cameraOptions = CameraOptions(center: CLLocationCoordinate2D(latitude: 58, longitude: 20), zoom: 3)

        mapView = MapView(frame: view.bounds, mapInitOptions: MapInitOptions(cameraOptions: cameraOptions))
        mapView.mapboxMap.mapStyle = .streets
        if #available(iOS 13.0, *) {
            mapView.mapboxMap.setMapStyleContent {
                StyleProjection(name: .mercator)
                CustomLayer(id: "custom-layer-example", renderer: renderer)
                    .position(.below("waterway"))
            }
        }

        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)
    }

    @objc func barButtonTap(_ barButtonItem: UIBarButtonItem) {
        renderer.colors = colorArray.shuffled()

        // You must trigger a repaint manually to re-draw the updated Custom Layer
        mapView.mapboxMap.triggerRepaint()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         // The below line is used for internal testing purposes only.
        finish()
    }
}

final class CustomLayerExampleCustomLayerHost: NSObject, CustomLayerHost {
    var colors = [
        simd_float4(1, 0, 0, 0.5),
        simd_float4(0, 1, 0, 0.5),
        simd_float4(0, 0, 1, 0.5),
    ]

    var depthStencilState: MTLDepthStencilState!
    var pipelineState: MTLRenderPipelineState!

    func renderingWillStart(_ metalDevice: MTLDevice, colorPixelFormat: UInt, depthStencilPixelFormat: UInt) {
        guard let library = metalDevice.makeDefaultLibrary() else {
            fatalError("Failed to create shader")
        }

        guard let vertexFunction = library.makeFunction(name: "vertexShader") else {
            fatalError("Could not find vertex function")
        }

        guard let fragmentFunction = library.makeFunction(name: "fragmentShader") else {
            fatalError("Could not find fragment function")
        }

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
        depthStencilDescriptor.isDepthWriteEnabled = false
        depthStencilDescriptor.depthCompareFunction = .always

        depthStencilState = metalDevice.makeDepthStencilState(descriptor: depthStencilDescriptor)

        do {
            pipelineState = try metalDevice.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        } catch {
            fatalError("Could not make render pipeline state: \(error.localizedDescription)")
        }
    }

    func render(_ parameters: CustomLayerRenderParameters, mtlCommandBuffer: MTLCommandBuffer, mtlRenderPassDescriptor: MTLRenderPassDescriptor) {

        let zoomScale = pow(2, parameters.zoom)
        let projectedHelsinki = Projection.project(.helsinki, zoomScale: zoomScale)
        let projectedBerlin = Projection.project(.berlin, zoomScale: zoomScale)
        let projectedKyiv = Projection.project(.kyiv, zoomScale: zoomScale)
        let positions = [
            simd_float2(Float(projectedHelsinki.x), Float(projectedHelsinki.y)),
            simd_float2(Float(projectedBerlin.x), Float(projectedBerlin.y)),
            simd_float2(Float(projectedKyiv.x), Float(projectedKyiv.y))
        ]

        guard let renderCommandEncoder = mtlCommandBuffer.makeRenderCommandEncoder(descriptor: mtlRenderPassDescriptor) else {
            fatalError("Could not create render command encoder from render pass descriptor.")
        }

        let projectionMatrix = parameters.projectionMatrix.map(\.floatValue)
        let vertices = zip(positions, colors).map(VertexData.init)
        let viewport = MTLViewport(
            originX: 0,
            originY: 0,
            width: parameters.width,
            height: parameters.height,
            znear: 0,
            zfar: 1
        )

        renderCommandEncoder.label = "Custom Layer"
        renderCommandEncoder.pushDebugGroup("Custom Layer")
        renderCommandEncoder.setDepthStencilState(depthStencilState)
        renderCommandEncoder.setRenderPipelineState(pipelineState)
        renderCommandEncoder.setVertexBytes(
            vertices,
            length: MemoryLayout<VertexData>.size * vertices.count,
            index: Int(VertexInputIndexVertices.rawValue)
        )
        renderCommandEncoder.setVertexBytes(
            projectionMatrix,
            length: MemoryLayout<simd_float4x4>.size,
            index: Int(VertexInputIndexTransformation.rawValue)
        )
        renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)

        renderCommandEncoder.setViewport(viewport)
        renderCommandEncoder.popDebugGroup()
        renderCommandEncoder.endEncoding()
    }

    func renderingWillEnd() {
        // Unimplemented
    }
}
