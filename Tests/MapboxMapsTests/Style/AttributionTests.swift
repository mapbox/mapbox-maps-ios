import XCTest
@_spi(Internal) @testable import MapboxMaps
import Foundation
import Network
import UIKit

class AttributionTests: XCTestCase {

    // Verifies that `Attribution.parse` performs no outbound network IO.
    //
    // The parser only processes operator-controlled attribution strings, so
    // any network access reachable from this code path would be an
    // information-disclosure channel for whoever hosts the tileset. The test
    // binds a local listener and asserts no connection is ever established
    // for an `<img src=...>` inside attribution markup. Requires the
    // `NSAllowsLocalNetworking` ATS exemption on `MapboxTestHost`'s Info.plist.
    func testAttributionParseDoesNotPerformNetworkIO() throws {
        let listener = try NWListener(using: .tcp, on: .any)
        let hit = expectation(description: "Attribution parser must not perform network IO")
        hit.isInverted = true
        listener.newConnectionHandler = { conn in
            conn.start(queue: .global())
            conn.receive(minimumIncompleteLength: 1, maximumLength: 8192) { data, _, _, _ in
                if let data, let s = String(data: data, encoding: .utf8), s.hasPrefix("GET /") {
                    hit.fulfill()
                }
                conn.send(
                    content: Data("HTTP/1.1 200 OK\r\nContent-Length: 0\r\nConnection: close\r\n\r\n".utf8),
                    completion: .contentProcessed { _ in conn.cancel() }
                )
            }
        }
        addTeardownBlock { listener.cancel() }

        let bound = expectation(description: "listener bound")
        listener.stateUpdateHandler = { state in
            if case .ready = state { bound.fulfill() }
        }
        listener.start(queue: .global())
        wait(for: [bound], timeout: 5)
        let port = try XCTUnwrap(listener.port?.rawValue, "listener.port was nil")

        _ = Attribution.parse(["<img src=\"http://127.0.0.1:\(port)/probe?uid=\(UUID().uuidString)\">"])
        // 3 s is generous: on the pre-fix code (same test with isInverted = false
        // as a PoC) the listener observed `GET /probe` in roughly 0.7 s, so any
        // value above ~1.5 s would already bite. We pick 3 s for CI headroom.
        wait(for: [hit], timeout: 3)
    }

    // End-to-end variant of `testAttributionParseDoesNotPerformNetworkIO`:
    // drives the full `Snapshotter.start(...)` path (the zero-interaction
    // attack surface from the original MAPSIOS-2192 PoC) against a style
    // whose source `attribution` points an `<img src=...>` at a local
    // listener. Asserts no outbound connection is ever made.
    //
    // This is the parse-level test's structural twin — if anything inside
    // the snapshot pipeline ever re-introduces an HTML importer above
    // `Attribution.parse`, this test bites where the parse-level one
    // cannot.
    func testSnapshotterDoesNotPerformAttributionNetworkIO() throws {
        try guardForMetalDevice()
        MapboxMapsOptions.dataPath = try temporaryCacheDirectory()

        let listener = try NWListener(using: .tcp, on: .any)
        let hit = expectation(description: "Snapshotter must not fetch attribution subresources")
        hit.isInverted = true
        listener.newConnectionHandler = { conn in
            conn.start(queue: .global())
            conn.receive(minimumIncompleteLength: 1, maximumLength: 8192) { data, _, _, _ in
                if let data, let s = String(data: data, encoding: .utf8), s.hasPrefix("GET /") {
                    hit.fulfill()
                }
                conn.send(
                    content: Data("HTTP/1.1 200 OK\r\nContent-Length: 0\r\nConnection: close\r\n\r\n".utf8),
                    completion: .contentProcessed { _ in conn.cancel() }
                )
            }
        }
        addTeardownBlock { listener.cancel() }

        let bound = expectation(description: "listener bound")
        listener.stateUpdateHandler = { state in
            if case .ready = state { bound.fulfill() }
        }
        listener.start(queue: .global())
        wait(for: [bound], timeout: 5)
        let port = try XCTUnwrap(listener.port?.rawValue, "listener.port was nil")

        // Background-only style with an unused source that carries a
        // malicious attribution. We don't care whether the snapshot pipeline
        // actually surfaces this source's attribution into
        // `snapshot.attributions()` — the security invariant we are
        // asserting is "no outbound connection to the attacker endpoint
        // ever, period", regardless of which code path the C++ side
        // chooses to evaluate the attribution string.
        let probe = "http://127.0.0.1:\(port)/probe?uid=\(UUID().uuidString)"
        let styleJSON = #"""
        {
            "version": 8,
            "sources": {
                "evil": {
                    "type": "vector",
                    "tiles": [],
                    "attribution": "<img src=\"\#(probe)\">"
                }
            },
            "layers": [{
                "id": "bg",
                "type": "background",
                "paint": { "background-color": "white" }
            }]
        }
        """#

        let snapshotter = Snapshotter(options: MapSnapshotOptions(size: CGSize(width: 64, height: 64), pixelRatio: 2))
        snapshotter.styleJSON = styleJSON

        // Kick off the snapshot, then wait the full inverted-expectation window.
        // 5 s mirrors the parse-level test's headroom (~0.7 s observed exfil
        // on the pre-fix code) and is short enough to not stretch CI.
        snapshotter.start(overlayHandler: nil) { _ in }
        wait(for: [hit], timeout: 5)
    }

    override func tearDownWithError() throws {
        let clearDataExpectation = expectation(description: "Clear map data")
        MapboxMapsOptions.clearData { _ in
            clearDataExpectation.fulfill()
        }
        wait(for: [clearDataExpectation], timeout: 10.0)
        MapboxMapsOptions.tileStore = nil
        try super.tearDownWithError()
    }

    func testActionableAttributionParsing() {
        let attributionsHTML = """
  <a href=\"https://www.mapbox.com/about/maps/\" target=\"_blank\" title=\"Mapbox\" aria-label=\"Mapbox\" role=\"listitem\">&copy; Mapbox</a>
<a href=\"https://www.openstreetmap.org/about/\" target=\"_blank\" title=\"OpenStreetMap\" aria-label=\"OpenStreetMap\" role=\"listitem\">&copy; OpenStreetMap</a>
"""
        let attributions = Attribution.parse([attributionsHTML])

        XCTAssertEqual(attributions.count, 2)
        XCTAssertEqual(attributions[0].title, "Mapbox")
        XCTAssertEqual(attributions[0].kind, .actionable(URL(string: "https://www.mapbox.com/about/maps/")!))
        XCTAssertEqual(attributions[1].title, "OpenStreetMap")
        XCTAssertEqual(attributions[1].kind, .actionable(URL(string: "https://www.openstreetmap.org/about/")!))
    }

    func testFeedbackAttributionParsing() throws {
        let attributionsHTML = """
<a class=\"mapbox-improve-map\" href=\"https://www.mapbox.com/\" target=\"_blank\" title=\"Improve this map\" aria-label=\"Improve this map\" role=\"listitem\">Improve this map</a>
<a class=\"mapbox-improve-map\" href=\"https://www.mapbox.com/feedback/\" target=\"_blank\" title=\"Attribution 1\" aria-label=\"Attribution 3\" role=\"listitem\">Attribution 1</a>
<a class=\"mapbox-improve-map\" href=\"https://www.mapbox.com/map-feedback/\" target=\"_blank\" title=\"Attribution 2\" aria-label=\"Attribution 2\" role=\"listitem\">Attribution 2</a>
<a class=\"mapbox-improve-map\" href=\"https://apps.mapbox.com/feedback/\" target=\"_blank\" title=\"Attribution 3\" aria-label=\"Attribution 3\" role=\"listitem\">Attribution 3</a>
"""
        let attributions = Attribution.parse([attributionsHTML])

        XCTAssertEqual(attributions.count, 4)
        XCTAssertEqual(attributions[0].title, "Improve this map")
        XCTAssertEqual(attributions[0].kind, .feedback)
        XCTAssertEqual(attributions[1].title, "Attribution 1")
        XCTAssertEqual(attributions[1].kind, .feedback)
        XCTAssertEqual(attributions[2].title, "Attribution 2")
        XCTAssertEqual(attributions[2].kind, .feedback)
        XCTAssertEqual(attributions[3].title, "Attribution 3")
        XCTAssertEqual(attributions[3].kind, .feedback)
    }

    func testPlainTextAttributionParsing() throws {
        let attributionString = String.testConstantAlphanumeric(withLength: 10).trimmingCharacters(in: .whitespacesAndNewlines)
        let attributions = Attribution.parse([attributionString])

        let attribution = try XCTUnwrap(attributions.first)
        XCTAssertEqual(attribution.title, attributionString)
        XCTAssertEqual(attribution.kind, .nonActionable)
    }

    func testDuplicateAttributionParsing() {
        let attributionsHTML = """
  <a href=\"https://www.mapbox.com/about/maps/\" target=\"_blank\" title=\"Mapbox\" aria-label=\"Mapbox\" role=\"listitem\">&copy; Mapbox</a>
  <a href=\"https://www.mapbox.com/about/maps/\" target=\"_blank\" title=\"Mapbox\" aria-label=\"Mapbox\" role=\"listitem\">&copy; Mapbox</a>
"""
        let attributions = Attribution.parse([attributionsHTML])

        XCTAssertEqual(attributions.count, 1)
        XCTAssertEqual(attributions[0].title, "Mapbox")
        XCTAssertEqual(attributions[0].kind, .actionable(URL(string: "https://www.mapbox.com/about/maps/")!))
    }

    func testAttributionAbbreviation() {
        let attributionsHTML = """
  <a href=\"https://www.mapbox.com/about/maps/\" target=\"_blank\" title=\"Mapbox\" aria-label=\"Mapbox\" role=\"listitem\">&copy; Mapbox</a> <a href=\"https://www.openstreetmap.org/about/\" target=\"_blank\" title=\"OpenStreetMap\" aria-label=\"OpenStreetMap\" role=\"listitem\">&copy; OpenStreetMap</a>
"""
        let attributions = Attribution.parse([attributionsHTML])

        XCTAssertEqual(attributions.count, 2)
        XCTAssertEqual(attributions[0].titleAbbreviation, "Mapbox")
        XCTAssertEqual(attributions[1].titleAbbreviation, "OSM")
    }

    // MARK: - MAPSIOS-2192 regression coverage

    func testAttributionRejectsNonWebSchemes() {
        let html = """
<a href=\"javascript:alert(1)\">js</a> \
<a href=\"data:text/html,<script>1</script>\">data</a> \
<a href=\"file:///etc/passwd\">file</a> \
<a href=\"https://valid.example/\">https</a>
"""
        let attributions = Attribution.parse([html])

        XCTAssertEqual(attributions.count, 4)
        XCTAssertEqual(attributions[0].kind, .nonActionable)
        XCTAssertEqual(attributions[1].kind, .nonActionable)
        XCTAssertEqual(attributions[2].kind, .nonActionable)
        XCTAssertEqual(attributions[3].kind, .actionable(URL(string: "https://valid.example/")!))
    }

    func testAttributionRejectsMaliciousImg() {
        // An <img> outside of any anchor must never become an actionable Attribution
        // and must not trigger any network activity (the new regex parser has no
        // network code path at all — this is a structural assertion verified by
        // grepping for `import WebKit` / `fromHTML` in the production sources).
        let attributions = Attribution.parse(["<img src=\"http://127.0.0.1:1/leak\">"])
        XCTAssertTrue(attributions.allSatisfy { $0.kind == .nonActionable })
    }

    func testAttributionMixedHTMLAndText() {
        let html = "prefix <a href=\"https://a.example/\">A</a> middle <a href=\"https://b.example/\">B</a> suffix"
        let attributions = Attribution.parse([html])

        XCTAssertEqual(attributions.count, 2)
        XCTAssertEqual(attributions[0].title, "A")
        XCTAssertEqual(attributions[0].kind, .actionable(URL(string: "https://a.example/")!))
        XCTAssertEqual(attributions[1].title, "B")
        XCTAssertEqual(attributions[1].kind, .actionable(URL(string: "https://b.example/")!))
    }

    func testAttributionHardCapRejectsHugeInput() {
        let huge = String(repeating: "<a href=\"https://x/\">x</a>", count: 4096)
        XCTAssertEqual(Attribution.parse([huge]), [])
    }

    // <img> *inside* an anchor must not surface as an actionable Attribution.
    // The anchor body becomes empty after `stripTags`, so the title-empty
    // guard drops it. A second anchor with real text alongside the <img>
    // confirms the text path still works and the img is just discarded.
    func testAttributionDropsImgInsideAnchor() {
        let html = """
<a href=\"https://safe.example/\"><img src=\"http://attacker.example/leak\"></a> \
<a href=\"https://safe.example/2\"><img src=\"http://attacker.example/leak2\"> Safe</a>
"""
        let attributions = Attribution.parse([html])

        XCTAssertEqual(attributions.count, 1)
        XCTAssertEqual(attributions[0].title, "Safe")
        XCTAssertEqual(attributions[0].kind, .actionable(URL(string: "https://safe.example/2")!))
    }

    // Documents the intentional invariant: unquoted `href` does not match
    // `anchorRegex`, so the whole string falls into the plain-text path and
    // becomes a single `.nonActionable` Attribution. This means
    // `javascript:alert(1)` and friends can never reach the URL opener via
    // an unquoted-href anchor — without the parser having to know anything
    // about URL schemes for that case (the scheme allow-list handles the
    // quoted case).
    func testAttributionUnquotedHrefBecomesPlainText() {
        let html = "<a href=javascript:alert(1)>click</a>"
        let attributions = Attribution.parse([html])

        XCTAssertEqual(attributions.count, 1)
        XCTAssertEqual(attributions[0].title, "click")
        XCTAssertEqual(attributions[0].kind, .nonActionable)
    }

    // `&amp;` inside the href must be decoded before `URL(string:)` parses
    // the value, otherwise `?a=1&amp;b=2` would either fail to parse or
    // round-trip with a literal `&amp;` in the query.
    func testAttributionDecodesAmpersandEntityInHref() {
        let html = "<a href=\"https://example.com/?a=1&amp;b=2\">Example</a>"
        let attributions = Attribution.parse([html])

        XCTAssertEqual(attributions.count, 1)
        XCTAssertEqual(attributions[0].title, "Example")
        XCTAssertEqual(attributions[0].kind, .actionable(URL(string: "https://example.com/?a=1&b=2")!))
    }

    // `isWebScheme` lowercases the scheme before comparing, so anchors
    // with uppercase scheme like `HTTPS://…` must still be actionable.
    func testAttributionAcceptsUppercaseScheme() {
        let html = "<a href=\"HTTPS://example.com/\">x</a>"
        let attributions = Attribution.parse([html])

        XCTAssertEqual(attributions.count, 1)
        XCTAssertEqual(attributions[0].title, "x")
        guard case .actionable(let url) = attributions[0].kind else {
            XCTFail("Expected actionable, got \(attributions[0].kind)")
            return
        }
        XCTAssertEqual(url.scheme?.lowercased(), "https")
        XCTAssertEqual(url.host, "example.com")
    }

    func testFeedbackSnapshotTitle() {
        let attribution = Attribution(title: "Improve this map", url: URL(string: "http://mapbox.com/")!)

        XCTAssertEqual(attribution.kind, .feedback)

        Attribution.Style.allCases.forEach { style in
            XCTAssertNil(attribution.snapshotTitle(for: style))
        }
    }

    func testOSMSnapshotTitle() {
        let url = URL(string: "http://mapbox.com/")!
        let attribution = Attribution(title: "OpenStreetMap", url: url)

        XCTAssertEqual(attribution.kind, .actionable(url))

        XCTAssertEqual(attribution.snapshotTitle(for: .regular), "OpenStreetMap")
        XCTAssertEqual(attribution.snapshotTitle(for: .abbreviated), "OSM")
        XCTAssertNil(attribution.snapshotTitle(for: .none))
    }

    func testNonOSMSnapshotTitle() {
        let attributionTitle = String.testConstantASCII(withLength: 10)
        let attribution = Attribution(title: attributionTitle, url: nil)

        XCTAssertEqual(attribution.kind, .nonActionable)

        XCTAssertEqual(attribution.snapshotTitle(for: .regular), attributionTitle)
        XCTAssertEqual(attribution.snapshotTitle(for: .abbreviated), attributionTitle)
        XCTAssertNil(attribution.snapshotTitle(for: .none))
    }

    func testAttributionFeedbackURL() throws {
        let cameraOptions = CameraOptions(center: CLLocationCoordinate2D(latitude: 1, longitude: 2), zoom: 3, bearing: 4, pitch: 5)
        let mapInitOptions = MapInitOptions(cameraOptions: cameraOptions)
        let metadataPath = Bundle.mapboxMaps.url(forResource: "MapboxMaps", withExtension: "json")!
        let data = try! Data(contentsOf: metadataPath)
        let metadata = try! JSONDecoder().decode(MapboxMapsMetadata.self, from: data)
        let expectedURL = try XCTUnwrap(URL(string: "https://apps.mapbox.com/feedback/?referrer=\(Bundle.main.bundleIdentifier!)&owner=mapbox&id=standard&access_token=test-token&map_sdk_version=\(metadata.version)#/2.00000/1.00000/3.00/4.0/5"))

        let mapView = MapView(frame: .zero, mapInitOptions: mapInitOptions)
        let url = mapView.mapboxMap.mapboxFeedbackURL(accessToken: "test-token")

        XCTAssertEqual(expectedURL, url)
    }
}
