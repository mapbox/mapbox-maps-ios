# Maps SDK for iOS Conventions

1. **Deprecations**
    1. Deprecated symbols should be annotated with `@available`. This will
       generate a build warning for any customers who use the deprecated API
       and will help us communicate what they should do instead. Customers who
       treat warnings as errors will have broken builds, which we consider an
       acceptable tradeoff relative to the communication benefit.
    2. Exclude deprecated symbols from the generated documentation by adding
       `:nodoc:` to the documentation comment and omitting any top-level symbols
       from the [Jazzy config file](https://github.com/mapbox/mapbox-maps-ios/blob/main/scripts/doc-generation/.jazzy.yaml).
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
4. **Experimental APIs**
    1. Significant new APIs are typically considered experimental when they are
       first introduced. This means that the APIs are considered production-
       ready, but are subject to change without triggering a major version bump.
       After one or more customers successfully adopts the new APIs, the
       experimental designation is removed.
    2. Experimental APIs are marked with the `@_spi(Experimental)` attribute. To
       use them, developers must add the same attribute to their import
       statement: `@_spi(Experimental) import MapboxMaps`.
    3. APIs annotated with `@_spi` APIs are only included in XCFrameworks if the
       project is [configured](https://github.com/mapbox/mapbox-maps-ios/pull/854)
       with `SWIFT_EMIT_PRIVATE_MODULE_INTERFACE = YES`.
5. **Restricted APIs**
    1. Some customers have special permission to use the SDK in ways that are
       typically not allowed. For example, there are customers who are allowed
       to hide the Mapbox logo.
    2. The APIs that enable these behaviors are marked with the
       `@_spi(Restricted)` attribute. To use them, developers must add the same
       attribute to their import statement: `@_spi(Restricted) import MapboxMaps`.
6. **Metrics APIs**
    1. Our internal SDK performance metrics need to measure certain aspects of
       the SDK that are typically fully encapsulated and not available through
       its public API. The APIs that expose these values are marked with the
       `@_spi(Metrics)` attribute. To use them, our metrics project adds the
       same attribute to its import statement:
       `@_spi(Metrics) import MapboxMaps`. These APIs are not intended for use
       by external developers.
7. **Private GL Native and Common APIs**
    1. GL Native and Common expose certain APIs that are needed by the iOS SDK
       but are not designed for use by developers. These APIs are added to a
       separate module in the same dependency that is suffixed with the string
       `_Private`. For example, in the MapboxCommon dependency, there is a
       public module, `MapboxCommon` and a private module `MapboxCommon_Private`.
    2. When the SDK imports the private module to use its APIs, the import
       statement is marked with the `@_implementationOnly` attribute. This
       causes the compiler to emit an error if any symbols from the private
       module are accidentally exposed in the SDK's public API. Attempting to
       import the private module without the `@_implementationOnly` attribute
       will emit a warning about the attribute being applied inconsistently
       throughtout the SDK.
