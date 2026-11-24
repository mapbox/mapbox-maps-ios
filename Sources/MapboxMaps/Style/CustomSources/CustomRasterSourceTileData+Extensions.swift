internal import MapboxCoreMaps_Private
@_spi(Marshalling) @_spi(Internal) import MapboxCoreMaps // Attribution reviewed and approved
import UIKit

extension CustomRasterSourceTileData {
    /// Raster content of the tile. If an empty image is provided then the tile gets removed from the map.
    public var image: UIImage? {
        __image.flatMap {
            UIImage(mbmImage: MBXImage.Marshaller.toSwift($0))
        }
    }

    /// Creates a raster source tile data.
    /// - Parameters:
    ///    - tileId: Cannonical tile id.
    ///    - image: Raster content of the tile.
    public convenience init(tileId: CanonicalTileID, image: UIImage?) {
        let coreImage = image.flatMap { CoreMapsImage(uiImage: $0) }
        let objcImage: MapboxCoreMaps_Private.__MBXImage? = coreImage.map { MBXImage.Marshaller.toObjc($0) }
        self.init(tileId: tileId, image: objcImage)
    }
}
