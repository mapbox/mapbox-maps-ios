#!/usr/bin/env node
'use strict';

const fs = require('fs');
const ejs = require('ejs');
const _ = require('lodash');
const path = require('path');
require('./../vendor/mapbox-maps-stylegen/style-code');
require('./../vendor/mapbox-maps-stylegen/type-utils');
require('./../annotation-generator/annotation-utils');

const generatePremiumApis = process.argv.slice(2).includes("--private-api");
const style = _.cloneDeep(require('./../vendor/mapbox-maps-stylegen/style-parser')(generatePremiumApis));
const publicStyle = require('./../vendor/mapbox-maps-stylegen/style-parser')(false);
const baseDirectory = generatePremiumApis ? '../private' : '../mapbox-maps-ios'


// Template processing //

for (const layer of style.layers) {
    layer.orignalType = layer.type
    if (layer.type === "symbol") {
        layer.type = "point"
        for (const property of layer.properties) {
            if (property.name == "text-font") {
                property['property-type'] = 'constant'
                break;
            }
        }
    } else if (layer.type === "circle") {
        layer.type = "circle"
    } else if (layer.type === "fill") {
        layer.type = "polygon"
    } else if (layer.type === "line") {
        layer.type = "polyline"
    }
}

const generatePrivateLayer = function (filename, layer, callback) {
    let publicLayer = publicStyle.layers.filter(publicLayer => publicLayer.type === layer.type)
    if (publicLayer === undefined) {
        callback(new Error(`No private layer found for ${layer.type}`), null);
    }

    renderAnnotationTemplate(filename, layer, callback);
};

const renderAnnotationTemplate = function renderAnnotationTemplate(filename, layer, callback) {
    ejs.renderFile(`annotation-generator/templates/${filename}.swift.ejs`, layer, { strict: true }, callback);
}

const render = function render(filename, layer, filePath) {
    renderAnnotationTemplate(filename, layer, function (err, str) {
        if (err) console.log(err);

        if (generatePremiumApis) {
            generatePrivateLayer(filename, layer, function (err, privateStr) {
                if (err) console.log(err);

                if (str !== privateStr) {
                    writeIfModified(`${baseDirectory}/${filePath}${camelize(layer.type)}${filename}.swift`, str);
                }
            });
        } else {
            writeIfModified(`${baseDirectory}/${filePath}${camelize(layer.type)}${filename}.swift`, str);
        }
    });
};

for (const layer of style.layers) {
    if (layer.orignalType === "symbol" || layer.orignalType === "circle" || layer.orignalType === "fill" || layer.orignalType === "line") {
        render('AnnotationGroup', layer, "Sources/MapboxMaps/SwiftUI/Annotations/Generated/")
        render('AnnotationManager', layer, "Sources/MapboxMaps/Annotations/Generated/");
        render('Annotation', layer, "Sources/MapboxMaps/Annotations/Generated/");
        render('AnnotationIntegrationTests', layer, "Tests/MapboxMapsTests/Annotations/Generated/");
        render('AnnotationTests', layer, "Tests/MapboxMapsTests/Annotations/Generated/");
        render('AnnotationManagerTests', layer, "Tests/MapboxMapsTests/Annotations/Generated/");
    }
}
