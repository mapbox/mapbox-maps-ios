//
//  SkyLayerExample.swift
//  Examples
//
//  Created by Jordan on 5/25/21.
//

import MapboxMaps

@objc(SkyLayerExample)
class SkyLayerExample: UIViewController, ExampleProtocol {
    internal var mapView: MapView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.addSubview(mapView)
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         // The below line is used for internal testing purposes only.
        finish()
    }
}
