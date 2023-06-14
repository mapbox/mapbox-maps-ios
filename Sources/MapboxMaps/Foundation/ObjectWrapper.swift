/// Helper class to wrap any subject as a reference type, so it can be compared by identity (`===`).
internal class ObjectWrapper<T> {
    var subject: T
    init(subject: T) {
        self.subject = subject
    }
}
