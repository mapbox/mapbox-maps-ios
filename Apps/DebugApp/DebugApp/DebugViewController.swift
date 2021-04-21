import UIKit
import MapboxMaps
import Turf

/**
 NOTE: This view controller should be used as a scratchpad
 while you develop new features. Changes to this file
 should not be committed.
 */

public class DebugViewController: UIViewController {
    
    internal var mapView: MapView!
    let identifier = "geoJSON-data-source"
    var geoJSONSource = GeoJSONSource()
    var newFeatures = String()
    var originalFeatures = String()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        let resourceOptions = ResourceOptions(accessToken: "access_token")
        mapView = MapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)
        
        // Set the center coordinate and zoom level.
        let centerCoordinate = CLLocationCoordinate2DMake(35.42486791930558, 136.95556640625)
        mapView.centerCoordinate = centerCoordinate
        mapView.zoom = 3
        
        // Allow the view controller to receive information about map events.
        mapView.on(.mapLoaded) { [weak self] _ in
            guard let self = self else { return }
            
            self.originalFeatures = """
                    {
                      "type": "Feature",
                      "properties": {},
                      "geometry": {
                        "type": "Point",
                        "coordinates": [
                          [
                            136.95556640625,
                            35.42486791930558
                          ]
                        ]
                      }
                    }
                """
            
            self.newFeatures = """
                    {
                      "type": "Feature",
                      "properties": {},
                      "geometry": {
                        "type": "LineString",
                        "coordinates": [
                          [
                            136.95556640625,
                            35.42486791930558
                          ],
                          [
                            137.603759765625,
                            36.146746777814364
                          ],
                          [
                            139.273681640625,
                            36.01356058518153
                          ],
                          [
                            139.075927734375,
                            37.39634613318923
                          ],
                          [
                            140.48217773437497,
                            37.64903402157866
                          ]
                        ]
                      }
                    }
                """
            
            self.addGeoJSONSource(identifier: "source", features: self.originalFeatures as NSString)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.updateGeoJSONSource(identifier: "my-source", features: self.newFeatures as NSString)
            }
            
        }
    }
    
    public func addGeoJSONSource(identifier: String, features: NSString) -> String {
        mapView.style.addSource(source:  geoJSONSource, identifier: identifier)
        let originalFeatureDict = convertStringToDictionary(text: originalFeatures as String)
        _ = try? mapView.__map.setStyleSourcePropertyForSourceId(identifier, property: "data", value: features)
        print("here are our features: \(features)")
        //        var layer = try? CircleLayer(jsonObject: originalFeatureDict!)
        //        layer?.sourceLayer = identifier
        //        layer?.paint?.circleColor = .constant(ColorRepresentable(color: UIColor.lightGray))
        //        _ = mapView.style.addLayer(layer: layer?)
        
        return identifier
    }
    
    public func updateGeoJSONSource(identifier: String, features: NSString) {
        let newFeatureDict = convertStringToDictionary(text: newFeatures as String)
        _ = try? mapView.__map.setStyleSourcePropertyForSourceId(identifier, property: "data", value: features)
        print("here are our features: \(features)")
        //        var layer = try? LineLayer(jsonObject: newFeatureDict!)
        //        layer?.sourceLayer = identifier
        //        layer?.paint?.lineColor = .constant(ColorRepresentable(color: UIColor.lightGray))
        //        _ = mapView.style.addLayer(layer: layer as! Layer)
    }
    
    func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
                return json
            } catch {
                print("Something went wrong")
            }
        }
        return nil
    }
    
}
