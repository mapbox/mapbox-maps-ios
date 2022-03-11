# Maps SDK for iOS Conventions

1. **Deprecations**
    1. To avoid breaking builds for customers whose projects treat warnings as
       errors, when introducing new deprecations in a minor version, make a note
       in the documentation comment for the deprecated symbol instead of usiung
       an asdf `@available` attribute.
    2. Exclude deprecated symbols from the generated documentation.
    3. In the documentation comment, link to the APIs that should be used
       instead.
2. **Public Protocols**
    1. Adding a requirement to a public protocol is a breaking change, so public
      protocols should only be introduced in situations where there's a reason
      for developers to implement the protocol. Objects from the SDK that
      developers use but don't implement should be expressed with concrete
      types.
3. **Internal Implementation Pattern**
    1. When a public class `A` has a method or property that returns another
       public class `B`, the concrete types become coupled. This coupling
       reduces isolation of `A` in unit tests since `B` cannot be mocked. To
       work around this limitation, we devised the "internal implementation"
       pattern (somewhat inspired by C++'s
       [PImpl pattern](https://en.cppreference.com/w/cpp/language/pimpl)).
    2. To apply the pattern, refactor `B` to be a thin wrapper around an
       internal protocol `BProtocol` that is implemented by an internal class
       `BImpl`.
    3. When testing `A`, instantiate `B` using a mock implementation `MockB`
       that implements `BProtocol`.
