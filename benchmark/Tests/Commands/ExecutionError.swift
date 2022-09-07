import Foundation

enum ExecutionError: Error {
    case cannotFindMapboxMap
    case resourceFileNotFound
    case unsupportedResourceFile
}
