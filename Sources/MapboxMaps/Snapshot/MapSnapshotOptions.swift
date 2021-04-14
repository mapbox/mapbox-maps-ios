import Foundation

extension MapSnapshotOptions {
    public convenience init(size: CGSize,
                            resourceOptions: ResourceOptions,
                            pixelRatio: CGFloat = UIScreen.main.scale,
                            localFontFamily: String? = nil) {
        self.init(__size: Size(width: Float(size.width), height: Float(size.height)),
                  pixelRatio: Float(pixelRatio),
                  glyphsRasterizationOptions: nil,
                  resourceOptions: resourceOptions)
    }

    public var size: CGSize {
        CGSize(width: CGFloat(__size.width), height: CGFloat(__size.height))
    }
}
