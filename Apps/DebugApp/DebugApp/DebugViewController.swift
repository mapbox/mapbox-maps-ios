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
    internal var runningAnimator: CameraAnimator?

    var resourceOptions: ResourceOptions {
        guard let accessToken = AccountManager.shared.accessToken else {
            fatalError("Access token not set")
        }

        let resourceOptions = ResourceOptions(accessToken: accessToken)
        return resourceOptions
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(with: view.bounds, resourceOptions: resourceOptions)
        mapView.update { (mapOptions) in
            mapOptions.location.puckType = .puck2D()
        }

        view.addSubview(mapView)

        /**
         The closure is called when style data has been loaded. This is called
         multiple times. Use the event data to determine what kind of style data
         has been loaded.
         
         When the type is `style` this event most closely matches
         `-[MGLMapViewDelegate mapView:didFinishLoadingStyle:]` in SDK versions
         prior to v10.
         */
        mapView.on(.styleDataLoaded) { (event) in
            guard let data = event.data as? [String: Any],
                  let type = data["type"] else {
                return
            }

            print("The map has finished loading style data of type = \(type)")
        }

        /**
         The closure is called during the initialization of the map view and
         after any `styleDataLoaded` events; it is called when the requested
         style has been fully loaded, including the style, specified sprite and
         source metadata.

         This event is the last opportunity to modify the layout or appearance
         of the current style before the map view is displayed to the user.
         Adding a layer at this time to the map may result in the layer being
         presented BEFORE the rest of the map has finished rendering.

         Changes to sources or layers of the current style do not cause this
         event to be emitted.
         */
        mapView.on(.styleLoaded) { (event) in
            print("The map has finished loading style ... Event = \(event)")
        }

        /**
         The closure is called whenever the map finishes loading and the map has
         rendered all visible tiles, either after the initial load OR after a
         style change has forced a reload.

         This is an ideal time to add any runtime styling or annotations to the
         map and ensures that these layers would only be shown after the map has
         been fully rendered.
         */
        mapView.on(.mapLoaded) { [weak self] (event) in
            print("The map has finished loading... Event = \(event)")
            guard let self = self else { return }
            
            try! self.mapView.__map.setStyleLayerPropertyForLayerId("country-label", property: "text-field", value: "MY_COUNTRY")
            
            let stylePropertyValue = try! self.mapView.__map.getStyleLayerProperty(forLayerId: "country-label", property: "text-field")
            
            
            do {
                print(stylePropertyValue.value)
                let layerData = try JSONSerialization.data(withJSONObject: stylePropertyValue.value)
                let textField: Value<Formatted> = try JSONDecoder().decode(Value<Formatted>.self, from: layerData)
                
                print(textField)
            } catch {
                print("Error decoding: \(error)")
            }
            
            
            
        }

        /**
         The closure is called whenever the map has failed to load. This could
         be because of a variety of reasons, including a network connection
         failure or a failure to fetch the style from the server.

         You can use the associated error message to notify the user that map
         data is unavailable.
         */
        mapView.on(.mapLoadingError) { (event) in
            guard let data = event.data as? [String: Any],
                  let type = data["type"],
                  let message = data["message"] else {
                return
            }

            print("The map failed to load.. \(type) = \(message)")
        }
    }
}


typealias Formatted = [FormattedElement]
    
enum FormattedElement: Codable {

    case format
    case substring(String)
    case formatOptions(FormatOptions)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let validString = try? container.decode(String.self), validString == Expression.Operator.format.rawValue {
            self = .format
            return
        }
        
        if let validString = try? container.decode(String.self) {
            self = .substring(validString)
            return
        }
        
        if let validOptions = try? container.decode(FormatOptions.self) {
            self = .formatOptions(validOptions)
            return
        }
                
        let context = DecodingError.Context(codingPath: decoder.codingPath,
                                            debugDescription: "Failed to decode Formatted")
        throw DecodingError.dataCorrupted(context)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .format:
            try container.encode(Expression.Operator.format.rawValue)
        case .substring(let substring):
            try container.encode(substring)
        case .formatOptions(let options):
            try container.encode(options)
        }
    }
}
    


