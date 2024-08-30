import Foundation

extension RasterArraySource {
    /// The description of the raster data layers and the bands contained within the tiles.
    @_documentation(visibility: public)
    @_spi(Experimental) public struct RasterDataLayer: Equatable, Codable, Sendable {
        /// Identifier of the data layer fetched from tiles.
        @_documentation(visibility: public)
        public let layerId: String

        /// An array of bands found in the data layer.
        @_documentation(visibility: public)
        public let bands: [String]
    }
}
