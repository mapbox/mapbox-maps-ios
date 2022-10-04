#!/usr/bin/env node
'use strict';

const fs = require('fs');
const ejs = require('ejs');
const _ = require('lodash');
const path = require('path');
require('./../vendor/mapbox-maps-stylegen/style-code');
require('./../vendor/mapbox-maps-stylegen/type-utils');

const generatePremiumApis = process.argv.slice(2).includes("--private-api");
const style = require('./../vendor/mapbox-maps-stylegen/style-parser')(generatePremiumApis);
const baseDirectory = generatePremiumApis ? '../mapbox-maps-ios-private' : '../mapbox-maps-ios'

// Template processing //

for (const layer of style.layers) {
  layer.orignalType = layer.type
  if(layer.type === "symbol") {
    layer.type = "point"
    for (const property of layer.properties) {
      if (property.name == "text-font"){
            property['property-type'] = 'constant'
            break;
      }
    }
  } else if(layer.type === "circle") {
    layer.type = "circle"
  }else if(layer.type === "fill") {
    layer.type = "polygon"
  }else if(layer.type === "line") {
    layer.type = "polyline"
  }
}

const render = function render(filename, layer, filePath) {
  ejs.renderFile(`annotation-generator/templates/${filename}.swift.ejs`, layer, {strict: true}, function(err, str){
    if (err) console.log(err);
    writeIfModified(`${baseDirectory}/${filePath}${camelize(layer.type)}${filename}.swift`, str);
  });
};

for (const layer of style.layers) {
  if(layer.orignalType === "symbol" || layer.orignalType === "circle" || layer.orignalType === "fill" || layer.orignalType === "line"){
    render('AnnotationManager', layer, "Sources/MapboxMaps/Annotations/Generated/");
    render('Annotation', layer, "Sources/MapboxMaps/Annotations/Generated/");
    render('AnnotationIntegrationTests', layer, "Tests/MapboxMapsTests/Annotations/Generated/");
    render('AnnotationTests', layer, "Tests/MapboxMapsTests/Annotations/Generated/");
    render('AnnotationManagerTests', layer, "Tests/MapboxMapsTests/Annotations/Generated/");
  }
}