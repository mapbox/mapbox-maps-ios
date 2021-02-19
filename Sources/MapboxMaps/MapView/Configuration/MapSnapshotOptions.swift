import Foundation

public extension MapSnapshotOptions {
    convenience init(size: CGSize,
                     resourceOptions: ResourceOptions,
                     pixelRatio: CGFloat = UIScreen.main.scale,
                     localFontFamily: String? = nil) {
        self.init(__size: Size(width: Float(size.width), height: Float(size.height)),
                  pixelRatio: Float(pixelRatio),
                  glyphsRasterizationOptions: nil,
                  resourceOptions: resourceOptions)
    }

    static func localFontFamilyNameFromMainBundle() -> String? {
        let infoDictionaryObject = Bundle.mapbox.object(forInfoDictionaryKey: "MBXIdeographicFontFamilyName")

        if infoDictionaryObject is String {
            return infoDictionaryObject as? String
        } else if infoDictionaryObject is [String],
            let infoDictionaryObjectArray = infoDictionaryObject as? [String] {
            return infoDictionaryObjectArray.joined(separator: "\n")
        }

        return nil
    }

    var size: CGSize {
        CGSize(width: CGFloat(__size.width), height: CGFloat(__size.height))
    }
}
