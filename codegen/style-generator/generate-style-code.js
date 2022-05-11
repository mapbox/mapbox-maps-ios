#!/usr/bin/env node
'use strict';

const fs = require('fs');
const ejs = require('ejs');
const style = require('./../vendor/mapbox-maps-stylegen/style-parser');
const _ = require('lodash');
require('./../vendor/mapbox-maps-stylegen/style-code');
require('./../vendor/mapbox-maps-stylegen/type-utils');

// Template processing //

// Swift Light
const lightSwift = ejs.compile(fs.readFileSync('style-generator/templates/Light.swift.ejs', 'utf8'), { strict: true });
writeIfModified(`../mapbox-maps-ios/Sources/MapboxMaps/Style/Generated/Light/Light.swift`, lightSwift({ properties: style.lightProperties }));

// Swift Layers
const layerSwift = ejs.compile(fs.readFileSync('style-generator/templates/Layer.swift.ejs', 'utf8'), { strict: true });
for (const layer of style.layers) {
  writeIfModified(`../mapbox-maps-ios/Sources/MapboxMaps/Style/Generated/Layers/${camelize(layer.type)}Layer.swift`, layerSwift(layer));
}

const layerTestsSwift = ejs.compile(fs.readFileSync('style-generator/templates/LayerTests.swift.ejs', 'utf8'), { strict: true });
for (const layer of style.layers) {
  writeIfModified(`../mapbox-maps-ios/Tests/MapboxMapsTests/Style/Generated/Layers/${camelize(layer.type)}LayerTests.swift`, layerTestsSwift(layer));
}

const layerIntegrationTestsSwift = ejs.compile(fs.readFileSync('style-generator/templates/LayerIntegrationTests.swift.ejs', 'utf8'), { strict: true });
for (const layer of style.layers) {
  writeIfModified(`../mapbox-maps-ios/Tests/MapboxMapsTests/Style/Generated/IntegrationTests/Layers/${camelize(layer.type)}LayerIntegrationTests.swift`, layerIntegrationTestsSwift(layer));
}

// Swift Sources

const sourceSwift = ejs.compile(fs.readFileSync('style-generator/templates/Sources.swift.ejs', 'utf8'), {strict: true});
for (const source of style.sources) {
  writeIfModified(`../mapbox-maps-ios/Sources/MapboxMaps/Style/Generated/Sources/${camelizeWithUndercoreRemoved(swiftSanitize(source.name))}Source.swift`, sourceSwift(source));
}

const sourceTestsSwift = ejs.compile(fs.readFileSync('style-generator/templates/SourcesTests.swift.ejs', 'utf8'), {strict: true});
for (const source of style.sources) {
  writeIfModified(`../mapbox-maps-ios/Tests/MapboxMapsTests/Style/Generated/Sources/${camelizeWithUndercoreRemoved(swiftSanitize(source.name))}SourceTests.swift`, sourceTestsSwift(source));
}

const sourceIntegrationTestsSwift = ejs.compile(fs.readFileSync('style-generator/templates/SourceIntegrationTests.swift.ejs', 'utf8'), { strict: true });
for (const source of style.sources) {
  writeIfModified(`../mapbox-maps-ios/Tests/MapboxMapsTests/Style/Generated/IntegrationTests/Sources/${camelizeWithUndercoreRemoved(swiftSanitize(source.name))}SourceIntegrationTests.swift`, sourceIntegrationTestsSwift(source));
}

const sourcePropertiesSwift = ejs.compile(fs.readFileSync('style-generator/templates/SourceProperties.swift.ejs', 'utf8'), {strict: true});
writeIfModified(`../mapbox-maps-ios/Sources/MapboxMaps/Style/Generated/Sources/SourceProperties.swift`, sourcePropertiesSwift(style.sourceEnumProperties));

// Swift Enums
const enumPropertySwiftTemplate = ejs.compile(fs.readFileSync('style-generator/templates/Enums.swift.ejs', 'utf8'), { strict: true });
writeIfModified(
  `../mapbox-maps-ios/Sources/MapboxMaps/Style/Generated/Enums/Enums.swift`,
  enumPropertySwiftTemplate({ properties: style.enumProperties })
);

const enumPropertySwiftTestTemplate = ejs.compile(fs.readFileSync('style-generator/templates/EnumsTestFixtures.swift.ejs', 'utf8'), { strict: true });
writeIfModified(
  `../mapbox-maps-ios/Tests/MapboxMapsTests/Style/Fixtures/Enums+Fixtures.swift`,
  enumPropertySwiftTestTemplate({ properties: style.enumProperties })
);

// Swift Expressions
const expressionSwift = ejs.compile(fs.readFileSync('style-generator/templates/Expressions.swift.ejs', 'utf8'), { strict: true });
writeIfModified(`../mapbox-maps-ios/Sources/MapboxMaps/Style/Generated/Expressions/AllExpressions.swift`, expressionSwift({ expressions: style.expressions }));

// Swift Terrain
const terrainSwift = ejs.compile(fs.readFileSync('style-generator/templates/Terrain.swift.ejs', 'utf8'), { strict: true });
writeIfModified(`../mapbox-maps-ios/Sources/MapboxMaps/Style/Generated/Terrain.swift`, terrainSwift({ properties: style.terrainProperties }));

// Swift Atmosphere
const atmosphereSwift = ejs.compile(fs.readFileSync('style-generator/templates/Atmosphere.swift.ejs', 'utf8'), { strict: true });
writeIfModified(`../mapbox-maps-ios/Sources/MapboxMaps/Style/Generated/Atmosphere.swift`, atmosphereSwift({ properties: style.atmosphereProperties }));
