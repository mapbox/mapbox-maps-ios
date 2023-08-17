import Foundation

enum ExecutionError: Error {
    case cannotFindRootViewController
    case cannotFindMapboxMap
    case resourceFileNotFound
    case unsupportedResourceFile
}
