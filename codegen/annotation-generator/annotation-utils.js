global.testPropertyForType = function testPropertyForType(type) {
  switch (type) {
    case 'point':
      return { type: "number", name: "text-size" };
    case 'circle':
      return { type: "number", name: "circle-radius" };
    case 'polygon':
      return { type: "number", name: "fill-opacity" };
    case 'polyline':
      return { type: "number", name: "line-width" };
    default:
      throw new Error(`unknown type ${type}`);
  }
}

global.expectedValue = function expectedValue(property) {
  switch (property.type) {
    case 'boolean':
    case 'string':
    case 'formatted':
    case 'enum':
    case 'color':
    case 'number':
      return `value`;
    case 'resolvedImage':
      return `.name(value)`
    case 'array':
      if (property.value === "number") {
        return `.constant(value.map { Double(Float($0)) })`;
      } else {
        return `value`;
      }
    default:
      throw new Error(`unknown type for ${property.name}. Property type = ${property.type}`);
  }
}

global.assertions = function assertions(property) {
  switch (property.type) {
    case 'boolean':
    case 'string':
    case 'formatted':
    case 'enum':
    case 'color':
    case 'resolvedImage':
      return `XCTAssertEqual(actualValue, ${expectedValue(property)})`;
    case 'number':
      return `XCTAssertEqual(actualValue, ${expectedValue(property)}, accuracy: 0.1)`;
    case 'array':
      if (property.value === "number") {
        return `for (actual, expected) in zip(actualValue, value) {
                XCTAssertEqual(actual, expected, accuracy: 0.1)
            }`;
      } else {
        return `XCTAssertEqual(actualValue, ${expectedValue(property)})`;
      }
    default:
      throw new Error(`unknown type for ${property.name}. Property type = ${property.type}`);
  }
}

global.testLayerForType = function testLayerForType(type) {
  switch (type) {
    case 'point':
      return { name: "symbol" };
    case 'circle':
      return { name: "circle" };
    case 'polygon':
      return { name: "fill" };
    case 'polyline':
      return { name: "line" };
    default:
      throw new Error(`unknown type ${type}`);
  }
}

global.elementPropertyForArray = function elementPropertyForArray(property, i) {
  let elementProperty;
  if (property.value === "string") {
    elementProperty = {type: property.value};
  } else if (property.value === "number") {
    elementProperty = {type: property.value};
    if (typeof property.minimum !== 'undefined') {
      elementProperty["minimum"] = property.minimum[i]
    }
    if (typeof property.maximum !== 'undefined') {
      elementProperty["maximum"] = property.maximum[i]
    }
  } else if (property.value === "enum") {
    elementProperty = {type: property.value, name: property.name};
  } else {
    elementProperty = property.value;
  }
  return elementProperty;
}

global.randomElement = function randomElement(property) {
  switch (property.type) {
    case 'boolean':
      return `Bool.random()`;
    case 'string':
    case 'formatted':
    case 'resolvedImage':
      return `String.randomASCII(withLength: .random(in: 0...100))`;
    case 'number':
      const minimum = (typeof property.minimum !== 'undefined') ? property.minimum : -100000;
      const maximum = (typeof property.maximum !== 'undefined') ? property.maximum : 100000;
      return `Double.random(in: ${minimum}...${maximum})`;
    case 'array':
      let elements = [];
      if (typeof property.length !== 'undefined') {
        for (var i=0; i<property.length; i++) {
          let elementProperty = elementPropertyForArray(property, i);
          elements.push(randomElement(elementProperty));
        }
        return `[${elements.join(", ")}]${property.name == 'line-trim-offset' ? '.sorted()' : ''}`;
      } else {
        let elementProperty = elementPropertyForArray(property);
        return `Array.random(withLength: .random(in: 0...10), generator: { ${randomElement(elementProperty)} })`;
      }
    case 'enum':
        return `${propertySwiftType(property)}.random()`;
    case 'color':
      return `StyleColor.random()`;
    default:
      throw new Error(`unknown type for ${property.name}. Property type = ${property.type}`);
  }
}

global.defaultValueConstant = function defaultValueConstant(property, originalType) {
  if (property.name === "text-field") {
    return `.expression(Exp(.format) {
            ""
            FormatOptions()
        })`;
  }

  const layerPropertyDefaultValue = `StyleManager.layerPropertyDefaultValue(for: .${originalType}, property: "${property.name}").value`
  switch (property.type) {
    case 'boolean':
      return `.constant((${layerPropertyDefaultValue} as! NSNumber).boolValue)`;
    case 'string':
      return `.constant(${layerPropertyDefaultValue} as! String)`;
    case 'formatted':
      return `.constant((${layerPropertyDefaultValue} as! [Any]).enumerated().compactMap { (idx, element) in (idx % 2) == 1 ? element as? String : nil }.joined())`;
    case 'resolvedImage':
      return `.constant(.name(${layerPropertyDefaultValue} as! String))`
    case 'number':
      return `.constant((${layerPropertyDefaultValue} as! NSNumber).doubleValue)`;
    case 'array':
      return `.constant(${layerPropertyDefaultValue} as! ${propertySwiftType(property)})`;
    case 'enum':
      return `.constant(${propertySwiftType(property)}(rawValue: ${layerPropertyDefaultValue} as! String))`;
    case 'color':
      return `.constant(try! JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: ${layerPropertyDefaultValue} as! [Any], options: [])))`;
    default:
      throw new Error(`unknown type for ${property.name}. Property type = ${property.type}`);
  }
}

global.defaultValue = function defaultValue(property, originalType) {
  if (property.name === "text-field") {
    return `.expression(Exp(.format) {
          ""
          FormatOptions()
      })`;
  }

  const layerPropertyDefaultValue = `StyleManager.layerPropertyDefaultValue(for: .${originalType}, property: "${property.name}").value`
  switch (property.type) {
    case 'boolean':
      return `${layerPropertyDefaultValue} as! Bool`;
    case 'string':
      return `${layerPropertyDefaultValue} as! String`;
    case 'formatted':
      return `${layerPropertyDefaultValue} as! [Any]).enumerated().compactMap { (idx, element) in (idx % 2) == 1 ? element as? String : nil }.joined()`;
    case 'resolvedImage':
      return `.name(${layerPropertyDefaultValue} as! String)`
    case 'number':
      return `${layerPropertyDefaultValue} as! Double`;
    case 'array':
      return `${layerPropertyDefaultValue} as! ${propertySwiftType(property)}`;
    case 'enum':
      return `${layerPropertyDefaultValue} as! String`;
    case 'color':
      return `try! JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: ${layerPropertyDefaultValue} as! [Any], options: []))`;
    default:
      throw new Error(`unknown type for ${property.name}. Property type = ${property.type}`);
  }
}
