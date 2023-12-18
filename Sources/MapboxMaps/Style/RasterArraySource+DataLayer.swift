import Foundation

extension RasterArraySource {
    /// The description of the raster data layers and the bands contained within the tiles.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    @_spi(Experimental) public struct RasterDataLayer: Equatable, Codable {
        /// Identifier of the data layer fetched from tiles.
#if swift(>=5.8)
        @_documentation(visibility: public)
#endif
        public let layerId: String

        /// An array of bands found in the data layer.
#if swift(>=5.8)
        @_documentation(visibility: public)
#endif
        public let bands: [String]

        internal init(layerId: String, bands: [String]) {
            self.layerId = layerId
            self.bands = bands
        }
    }
}
