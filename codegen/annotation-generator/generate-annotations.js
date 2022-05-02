#!/usr/bin/env node
'use strict';

const fs = require('fs');
const ejs = require('ejs');
const _ = require('lodash');
const path = require('path');
const style = require('./../vendor/mapbox-maps-stylegen/style-parser');
require('./../vendor/mapbox-maps-stylegen/style-code');
require('./../vendor/mapbox-maps-stylegen/type-utils');

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

const render = function render(filename, layer, basePath) {
  ejs.renderFile(`annotation-generator/templates/${filename}.swift.ejs`, layer, {strict: true}, function(err, str){
    if (err) console.log(err);
    writeIfModified(`${basePath}${camelize(layer.type)}${filename}.swift`, str);
  });
};

for (const layer of style.layers) {
  if(layer.orignalType === "symbol" || layer.orignalType === "circle" || layer.orignalType === "fill" || layer.orignalType === "line"){
    render('AnnotationManager', layer, "../mapbox-maps-ios/Sources/MapboxMaps/Annotations/Generated/");
    render('Annotation', layer, "../mapbox-maps-ios/Sources/MapboxMaps/Annotations/Generated/");
    render('AnnotationIntegrationTests', layer, "../mapbox-maps-ios/Tests/MapboxMapsTests/Annotations/Generated/");
    render('AnnotationTests', layer, "../mapbox-maps-ios/Tests/MapboxMapsTests/Annotations/Generated/");
  }
}