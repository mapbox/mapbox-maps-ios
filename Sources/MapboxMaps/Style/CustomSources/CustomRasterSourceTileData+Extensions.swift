internal import MapboxCoreMaps_Private
@_spi(Marshalling) @_spi(Internal) import MapboxCoreMaps
import UIKit

extension CustomRasterSourceTileData {
    /// Raster content of the tile. If an empty image is provided then the tile gets removed from the map.
    public var image: UIImage? { __image.flatMap { UIImage(mbmImage: MBXImage.Marshaller.toSwift($0)) } }

    /// Creates a raster source tile data.
    /// - Parameters:
    ///    - tileId: Cannonical tile id.
    ///    - image: Raster content of the tile.
    public convenience init(tileId: CanonicalTileID, image: UIImage?) {
        self.init(tileId: tileId,
                  image: image
            .flatMap { CoreMapsImage(uiImage: $0) }
            .flatMap { (image: CoreMapsImage) -> MapboxCoreMaps_Private.__MBXImage in MBXImage.Marshaller.toObjc(image) }
        )
    }
}
