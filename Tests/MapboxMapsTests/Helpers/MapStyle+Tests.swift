import MapboxMaps

extension MapStyle {
    static let  featuresetTestsStyle = MapStyle(json: styleJSON)
}

private let styleJSON = """
{
    "version": 8,
    "imports": [
        {
            "id": "nested",
            "url": "",
            "config": {},
            "data": {
                "version": 8,
                "featuresets": {
                    "poi" : {
                        "selectors": [
                            {
                                "layer": "poi-label-1",
                                "properties": {
                                    "type": [ "get", "type" ],
                                    "name": [ "get", "name" ],
                                    "class": "poi"
                                },
                                "featureNamespace": "A"
                            }
                        ]
                    }
                },
                "sources": {
                    "geojson": {
                        "type": "geojson",
                        "data": {
                            "type": "FeatureCollection",
                            "features": [
                                {
                                    "type": "Feature",
                                    "properties": {
                                        "filter": "true",
                                        "name": "nest1",
                                        "type": "A"
                                    },
                                    "geometry": {
                                        "type": "Point",
                                        "coordinates": [ 0.01, 0.01 ]
                                    },
                                    "id": 11
                                },
                                {
                                    "type": "Feature",
                                    "properties": {
                                        "name": "nest2",
                                        "type": "B"
                                    },
                                    "geometry": {
                                        "type": "Point",
                                        "coordinates": [ 0.01, 0.01 ]
                                    },
                                    "id": 12
                                },
                                {
                                    "type": "Feature",
                                    "properties": {
                                        "name": "nest3",
                                        "type": "B"
                                    },
                                    "geometry": {
                                        "type": "Point",
                                        "coordinates": [ -0.05, -0.05 ]
                                    },
                                    "id": 13
                                }
                            ]
                        }
                    }
                },
                "layers": [
                    {
                        "id": "poi-label-1",
                        "type": "circle",
                        "source": "geojson",
                        "paint": {
                            "circle-radius": 5,
                            "circle-color": "red"
                        }
                    }
                ]
            }
        }
    ],
    "sources": {
        "geojson": {
            "type": "geojson",
            "promoteId": "foo",
            "data": {
                "type": "FeatureCollection",
                "features": [
                    {
                        "type": "Feature",
                        "properties": {
                            "foo": 1
                        },
                        "geometry": {
                            "type": "Point",
                            "coordinates": [
                                0,
                                0
                            ]
                        }
                    }
                ]
            }
        },
        "geojson-2": {
            "type": "geojson",
            "promoteId": "bar",
            "data": {
                "type": "FeatureCollection",
                "features": [
                    {
                        "type": "Feature",
                        "properties": {
                            "bar": 1
                        },
                        "geometry": {
                            "type": "Point",
                            "coordinates": [ 0.01, 0.01 ]
                        }
                    },
                    {
                        "type": "Feature",
                        "properties": {
                            "bar": 2,
                            "filter": true,
                            "name": "qux"
                        },
                        "geometry": {
                            "type": "Point",
                            "coordinates": [ 0.01, 0.01 ]
                        }
                    }
                ]
            }
        }
    },
    "layers": [
        {
            "id": "background",
            "type": "background",
            "background-color": "green"
        },
        {
            "id": "circle-1",
            "type": "circle",
            "source": "geojson",
            "paint": {
                "circle-radius": 5,
                "circle-color": "black"
            }
        },
        {
            "id": "circle-2",
            "type": "circle",
            "source": "geojson-2",
            "paint": {
                "circle-radius": 3,
                "circle-color": "blue"
            }
        }
    ]
}
"""
