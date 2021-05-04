import UIKit
import MapboxMaps

@objc(CustomLayerExample)

public class CustomLayerExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    var depthStencilState: MTLDepthStencilState!
    var pipelineState: MTLRenderPipelineState!

    override public func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        mapView.on(.styleLoaded) { [weak self] _ in
            self?.addCustomLayer()
        }
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         // The below line is used for internal testing purposes only.
        finish()
    }

    internal func addCustomLayer() {
        // Position the custom layer above the water layer and below all other layers.
        let layerPosition = LayerPosition(above: "water", below: nil, at: nil)

        try! mapView.style.addCustomLayer(
            withId: "Custom",
            layerHost: self,
            layerPosition: layerPosition)
    }
}

extension CustomLayerExample: CustomLayerHost {
    public func renderingWillStart(_ metalDevice: MTLDevice, colorPixelFormat: UInt, depthStencilPixelFormat: UInt) {

        let compileOptions = MTLCompileOptions()

        var library: MTLLibrary

        do {
            library = try metalDevice.makeLibrary(source: metalShaderProgram,
                                                  options: compileOptions)
        } catch {
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
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].format = .float2
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.layouts[0].stepRate = 1
        vertexDescriptor.layouts[0].stepFunction = .perVertex
        vertexDescriptor.layouts[0].stride = MemoryLayout<simd_float2>.size

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
        colorAttachment?.destinationRGBBlendFactor = colorAttachment?.destinationRGBBlendFactor ?? .oneMinusSourceAlpha

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

    public func render(_ parameters: CustomLayerRenderParameters, mtlCommandBuffer: MTLCommandBuffer, mtlRenderPassDescriptor: MTLRenderPassDescriptor) {

        let vertices = [
            simd_float2(0, 0.5),
            simd_float2(0.5, -0.5),
            simd_float2(-0.5, -0.5)
        ]

        guard let renderCommandEncoder = mtlCommandBuffer.makeRenderCommandEncoder(descriptor: mtlRenderPassDescriptor) else {
            fatalError("Could not create render command encoder from render pass descriptor.")
        }

        renderCommandEncoder.label = "Custom Layer"
        renderCommandEncoder.pushDebugGroup("Custom Layer")
        renderCommandEncoder.setDepthStencilState(depthStencilState)
        renderCommandEncoder.setRenderPipelineState(pipelineState)
        renderCommandEncoder.setVertexBytes(vertices, length: MemoryLayout<simd_float2>.size * vertices.count, index: 0)
        renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        renderCommandEncoder.popDebugGroup()
        renderCommandEncoder.endEncoding()
    }

    public func renderingWillEnd() {
        // Unimplemented
    }
}

extension CustomLayerExample {
    // The Metal shader program, written in the
    // [Metal Shader Language](https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf) format.
    var metalShaderProgram: String {
        return """
        #include <metal_stdlib>
        #include <simd/simd.h>
        using namespace metal;
        struct vertexShader_in
        {
            float2 a_pos [[attribute(0)]];
        };
        struct vertexShader_out
        {
            float4 gl_Position [[position]];
        };
        vertex vertexShader_out vertexShader(vertexShader_in in [[stage_in]])
        {
            return { float4(in.a_pos, 1.0, 1.0) };
        }
        struct fragmentShader_out
        {
            float4 mbgl_FragColor [[color(0)]];
        };
        fragment fragmentShader_out fragmentShader()
        {
            return { float4(0, 0.5, 0, 0.5) };
        }
        """
    }
}
