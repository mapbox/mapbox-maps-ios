import Foundation

extension URL {
    func appendingSuffixToLastPathComponent(_ suffix: String) -> URL {
        return self .deletingLastPathComponent()
            .appendingPathComponent(
                self.deletingPathExtension()
                    .lastPathComponent
                    .appending(suffix)
            )
            .appendingPathExtension(self.pathExtension)

    }
}
