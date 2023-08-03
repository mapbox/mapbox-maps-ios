#!/usr/bin/env node
'use strict';

const fs = require('fs');
const ejs = require('ejs');
const _ = require('lodash');
require('./../vendor/mapbox-maps-stylegen/style-code');
require('./../vendor/mapbox-maps-stylegen/type-utils');
const styleParser = require('./../vendor/mapbox-maps-stylegen/style-parser');

const privateStyle = _.cloneDeep(styleParser(true));
const publicStyle = styleParser(false);

const writeIfNotMatch = function (fileName, template, privateParamenters, publicParameters) {
    if (template === undefined) { return; }

    const privateContent = template(privateParamenters);
    let publicContent = null

    if (publicParameters) {
        publicContent = template(publicParameters);
        writeIfModified(`../mapbox-maps-ios/${fileName}`, publicContent);
    }

    if (publicContent !== privateContent)  {
        writeIfModified(`../private/${fileName}`, privateContent);
    }
};

const findPublicStyleProperty = (styleKey, key, styleProperty) => {
    return publicStyle[styleKey].find(publicProperty => publicProperty[key] === styleProperty[key]);
};

const compileTemplate = templateName => templateName === undefined ? undefined : ejs.compile(fs.readFileSync(`style-generator/templates/${templateName}`, 'utf8'), { strict: true });

class StyleTemplate {
    constructor({ key, templateName, testsTemplateName, integrationTestsTemplateName, folderPath, propertyKeyToCompare, wrapInArray = false }) {
        this.key = key
        this.template = compileTemplate(templateName);
        this.testsTemplate = compileTemplate(testsTemplateName);
        this.integrationTestsTemplate = compileTemplate(integrationTestsTemplateName);
        this.folderPath = folderPath;
        this.propertyKeyToCompare = propertyKeyToCompare;
        this.wrapInArray = wrapInArray;
    }

    styleProperties(style) {
        // Wrap single elements in an array so that we can iterate over them as other arrays
        // There are some cases where we want to wrap in an array (e.g. `sourceEnumProperties`)
        return this.wrapInArray ? [style[this.key]] : style[this.key]
    }

    fileName(styleProperty) {
        let swiftyName = swiftSanitize(styleProperty[this.propertyKeyToCompare] || this.key)
        return this.folderPath(camelize(swiftyName));
    }
}

const templatesRegistry = [
    new StyleTemplate({
        key: 'lights',
        templateName: 'Light.swift.ejs',
        folderPath: name => `Light/${name}Light.swift`,
        testsTemplateName: 'LightTests.swift.ejs',
        propertyKeyToCompare: 'name'
    }),
    new StyleTemplate({
        key: 'layers',
        templateName: 'Layer.swift.ejs',
        testsTemplateName: 'LayerTests.swift.ejs',
        integrationTestsTemplateName: 'LayerIntegrationTests.swift.ejs',
        folderPath: name => `Layers/${name}Layer.swift`,
        propertyKeyToCompare: 'type',
    }),
    new StyleTemplate({
        key: 'sources',
        templateName: 'Sources.swift.ejs',
        testsTemplateName: 'SourcesTests.swift.ejs',
        integrationTestsTemplateName: 'SourceIntegrationTests.swift.ejs',
        propertyKeyToCompare: 'name',
        folderPath: name => `Sources/${name}Source.swift`,
    }),
    new StyleTemplate({
        key: 'sourceEnumProperties',
        templateName: 'SourceProperties.swift.ejs',
        folderPath: name => 'Sources/SourceProperties.swift',
        wrapInArray: true
    }),
    new StyleTemplate({
        key: 'enumProperties',
        templateName: 'Properties.swift.ejs',
        testsTemplateName: 'PropertiesTestFixtures.swift.ejs',
        folderPath: name => 'Properties/Properties.swift',
        wrapInArray: true
    }),
    new StyleTemplate({
        key: 'expressions',
        templateName: 'Expressions.swift.ejs',
        folderPath: name => 'Expressions/AllExpressions.swift',
        wrapInArray: true
    }),
    new StyleTemplate({
        key: 'terrainProperties',
        templateName: 'Terrain.swift.ejs',
        folderPath: name => 'Terrain.swift',
        wrapInArray: true
    }),
    new StyleTemplate({
        key: 'atmosphereProperties',
        templateName: 'Atmosphere.swift.ejs',
        folderPath: name => 'Atmosphere.swift',
        wrapInArray: true
    }),
];

const baseOutputPath = `Sources/MapboxMaps/Style/Generated`;
const baseOutputPathTests = `Tests/MapboxMapsTests/Style/Generated`;

for (const template of Object.values(templatesRegistry)) {
    for (const styleProperty of template.styleProperties(privateStyle)) {
        let publicValue = template.wrapInArray ? publicStyle[template.key] : findPublicStyleProperty(template.key, template.propertyKeyToCompare, styleProperty);
        let fileName = template.fileName(styleProperty);

        writeIfNotMatch(`${baseOutputPath}/${fileName}`, template.template, styleProperty, publicValue)
        writeIfNotMatch(`${baseOutputPathTests}/${fileName.replace(/\.swift$/, 'Tests.swift')}`, template.testsTemplate, styleProperty, publicValue);
        writeIfNotMatch(`${baseOutputPathTests}/IntegrationTests/${fileName.replace(/\.swift$/, 'IntegrationTests.swift')}`, template.integrationTestsTemplate, styleProperty, publicValue);
    }
}
