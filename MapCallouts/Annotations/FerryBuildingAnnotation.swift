/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The custom MKAnnotation object representing the Ferry Building.
*/

import MapKit

class FerryBuildingAnnotation: NSObject, MKAnnotation {
    
    // This property must be key-value observable, which the `@objc dynamic` attributes provide.
    @objc dynamic var coordinate = CLLocationCoordinate2D(latitude: 37.808_333, longitude: -122.415_556)
    
    var title: String? = NSLocalizedString("FERRY_BUILDING_TITLE", comment: "Ferry Building annotation")
}
