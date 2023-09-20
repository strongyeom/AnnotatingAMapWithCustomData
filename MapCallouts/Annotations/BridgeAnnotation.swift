/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The custom MKAnnotation object representing the Golden Gate Bridge.
*/

import UIKit
import MapKit

class BridgeAnnotation: NSObject, MKAnnotation {
  
    // coordinate 프로퍼티는 (key,value) 해야하기 때문에 동적 디스패치를 제공함 - 애플 공식 문서
    @objc dynamic var coordinate = CLLocationCoordinate2D(latitude: 37.810_000, longitude: -122.477_450)
    
 
    // callout를 true로 했을때 나오는 어노테이션 title
    // comment: title에 대한 주석임
    var title: String? = NSLocalizedString("BRIDGE_TITLE", comment: "Bridge annotation")
    
    // 어노테이션이 화면에 보여질때는 title만 필요하기때문에 현재 MKMarkerAnnotationView.self로 되어있기 때문에 사용되지 않는다.
    var subtitle: String? = NSLocalizedString("BRIDGE_SUBTITLE", comment: "Bridge annotation")
}
