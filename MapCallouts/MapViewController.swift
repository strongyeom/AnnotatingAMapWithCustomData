/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The primary view controller containing the `MKMapView`, as well as adding and removing `MKMarkerAnnotationView` through its toolbar.
*/

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet private weak var mapView: MKMapView!
    
    // 버튼을 누를때 마다 담기는 어노테이션들
    private var allAnnotations: [MKAnnotation]?
    
    private var displayedAnnotations: [MKAnnotation]? {
        willSet {
            if let currentAnnotations = displayedAnnotations {
                // 기존의 데이터를 제거
                mapView.removeAnnotations(currentAnnotations)
            }
        }
        didSet {
            if let newAnnotations = displayedAnnotations {
                
                // 데이터를 추가
                // 처음 화면이 로드되었을때 모든 어노테이션 담김
                print("didSet 되고나서 담기는 newAnnotations : \(newAnnotations)")
                mapView.addAnnotations(newAnnotations)
            }
            // 로드되었을때 all 버튼 눌리니까 didSet 적용되면서 모든 어노테이션 보여지고, 설정한 위치,Span 값이 보여짐
            centerMapOnSanFrancisco()
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        // TalbeView register하는것이랑 비슷함
        registerMapAnnotationViews()
        
        // 화면이 로드되었을때 보여주고 싶은 어노테이션 설정
        // CustomAnnotation의 title, subtitle, imageName을 설정할 수있음
        let flowerAnnotation = CustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: 37.772_623, longitude: -122.460_217))
        flowerAnnotation.title = NSLocalizedString("FLOWERS_TITLE", comment: "Flower annotation")
        flowerAnnotation.imageName = "conservatory_of_flowers"
        
        // 모든 어노테이션을 배열안에 담아서 화면이 로드되었을때 보여줌
        allAnnotations = [SanFranciscoAnnotation(), BridgeAnnotation(), FerryBuildingAnnotation(), flowerAnnotation]
        
        // Dispaly all annotations on the map.
        // 화면이 처음 로드되었을때 all 버튼 눌러 모든 뷰 보여주기
        showAllAnnotations(self)
    }
    
    /// Register the annotation views with the `mapView` so the system can create and efficently reuse the annotation views.
    /// - Tag: RegisterAnnotationViews
    private func registerMapAnnotationViews() {
        // MKMarkerAnnotationView 자체를 등록하고 어떤 어노테이션을 재사용할 것인지 설정
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(BridgeAnnotation.self))
        // CustomAnnotationView를 사용하여 커스텀 어노테이션을 만들 수 있음
        mapView.register(CustomAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(CustomAnnotation.self))
        mapView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(SanFranciscoAnnotation.self))
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(FerryBuildingAnnotation.self))
    }
    
    private func centerMapOnSanFrancisco() {
        // span 숫자가 크면 더 멀어지고 숫자가 작아지면 가까워짐 }
        // 미터 기반으로도 만들 수 있음 MKCoordinateRegion(center: <#T##CLLocationCoordinate2D#>, latitudinalMeters: <#T##CLLocationDistance#>, longitudinalMeters: <#T##CLLocationDistance#>)
        let span = MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
  
        // 센프란시스코 위치
        let center = CLLocationCoordinate2D(latitude: 37.786_996, longitude: -122.440_100)
        // mapView에 설정한 위치와 span을 적용
        mapView.setRegion(MKCoordinateRegion(center: center, span: span), animated: true)
    }
    
    // MARK: - Button Actions
    
    private func displayOne(_ annotationType: AnyClass) {
        // allAnnotations의 앞에서부터 해당 클래스(SanFranciscoAnnotation(), BridgeAnnotation(), FerryBuildingAnnotation())가 있는지 확인후 Bool 값 리턴
        let annotation = allAnnotations?.first { (annotation) -> Bool in
            return annotation.isKind(of: annotationType)
        }
        print("어떤 클래스가 담기는지 확인 : \(annotation)")
        if let oneAnnotation = annotation {
            displayedAnnotations = [oneAnnotation]
        } else {
            // 없어도 되기는 하지만 에러처리 때문에 빈 배열을 넣어주는거 같음
            displayedAnnotations = []
        }
    }

    @IBAction private func showOnlySanFranciscoAnnotation(_ sender: Any) {
        // User tapped "City" button in the bottom toolbar
        displayOne(SanFranciscoAnnotation.self)
    }
    
    @IBAction private func showOnlyBridgeAnnotation(_ sender: Any) {
        // User tapped "Bridge" button in the bottom toolbar
        displayOne(BridgeAnnotation.self)
    }
    
    @IBAction private func showOnlyFlowerAnnotation(_ sender: Any) {
        // User tapped "Flower" button in the bottom toolbar
        displayOne(CustomAnnotation.self)
    }
    
    @IBAction private func showOnlyFerryBuildingAnnotation(_ sender: Any) {
        // User tapped "Ferry" button in the bottom toolbar
        displayOne(FerryBuildingAnnotation.self)
    }
    
    @IBAction private func showAllAnnotations(_ sender: Any) {
        // User tapped "All" button in the bottom toolbar
        displayedAnnotations = allAnnotations
    }
}

extension MapViewController: MKMapViewDelegate {

    /// Called whent he user taps the disclosure button in the bridge callout.
    // calloutTapped을 통해 화면 전환 할 수 있음
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        // This illustrates how to detect which annotation type was tapped on for its callout.
        // 어떤 휴형의 탭이 되었는지 감지하는 방법을 설명 우리가 BridgeAnnotation을 callout 했기때문에 해당 인지 확인
        if let annotation = view.annotation, annotation.isKind(of: BridgeAnnotation.self) {
            print("Tapped Golden Gate Bridge annotation accessory view")
            
            // 화면 전환
            if let detailNavController = storyboard?.instantiateViewController(withIdentifier: "DetailNavController") {
                detailNavController.modalPresentationStyle = .popover
                let presentationController = detailNavController.popoverPresentationController
                presentationController?.permittedArrowDirections = .any
                
                // Anchor the popover to the button that triggered the popover.
                presentationController?.sourceRect = control.frame
                presentationController?.sourceView = control
                
                present(detailNavController, animated: true, completion: nil)
            }
        }
    }
    
    /// The map view asks `mapView(_:viewFor:)` for an appropiate annotation view for a specific annotation.
    /// - Tag: CreateAnnotationViews
    // viewFor : 어노테이션을 커스터마이징 할 수 있게 해줌
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // 현재 위치 표시도 일종의 어노테이션이기 때문에, 이 처리를 안하게 되면, 유저의 위치 어노테이션도 변경 된다.
        guard !annotation.isKind(of: MKUserLocation.self) else {
            return nil
        }
        
        var annotationView: MKAnnotationView?
        
        // 유형별로 다운 캐스팅이 되면 CustomAnnotationView를 생성
        if let annotation = annotation as? BridgeAnnotation {
            annotationView = setupBridgeAnnotationView(for: annotation, on: mapView)
        } else if let annotation = annotation as? CustomAnnotation {
            annotationView = setupCustomAnnotationView(for: annotation, on: mapView)
        } else if let annotation = annotation as? SanFranciscoAnnotation {
            annotationView = setupSanFranciscoAnnotationView(for: annotation, on: mapView)
        } else if let annotation = annotation as? FerryBuildingAnnotation {
            annotationView = setupFerryBuildingAnnotationView(for: annotation, on: mapView)
        }
        
        return annotationView
    }
    
    
    /// The map view asks `mapView(_:viewFor:)` for an appropiate annotation view for a specific annotation. The annotation
    /// should be configured as needed before returning it to the system for display.
    /// - Tag: ConfigureAnnotationViews
    // 식별자를 갖고 AnnotationView를 생성⬇️⬇️⬇️⬇️
    private func setupSanFranciscoAnnotationView(for annotation: SanFranciscoAnnotation, on mapView: MKMapView) -> MKAnnotationView {
        let reuseIdentifier = NSStringFromClass(SanFranciscoAnnotation.self)
        let flagAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier, for: annotation)
        
        flagAnnotationView.canShowCallout = true
        
        // Provide the annotation view's image.
        let image = #imageLiteral(resourceName: "flag")
        flagAnnotationView.image = image
        
        // Provide the left image icon for the annotation.
        flagAnnotationView.leftCalloutAccessoryView = UIImageView(image: #imageLiteral(resourceName: "sf_icon"))
        
        // Offset the flag annotation so that the flag pole rests on the map coordinate.
        // flagAnnotationView을 지도에서 x,y축으로 일정거리 이동한다 왜냐? 마크지점와 겹쳐져 있기 때문에
        let offset = CGPoint(x: image.size.width / 2, y: -(image.size.height / 2) )
        flagAnnotationView.centerOffset = offset
        
        return flagAnnotationView
    }
    
    /// Create an annotation view for the Golden Gate Bridge, customize the color, and add a button to the callout.
    /// - Tag: CalloutButton
    private func setupBridgeAnnotationView(for annotation: BridgeAnnotation, on mapView: MKMapView) -> MKAnnotationView {
        let identifier = NSStringFromClass(BridgeAnnotation.self)
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier, for: annotation)
        
        // 재사용하는 어노테이션이 마커어노테이션이면 다운 캐스팅 필요
        if let markerAnnotationView = view as? MKMarkerAnnotationView {
            // 마커가 찍힐때 애니메이션
            markerAnnotationView.animatesWhenAdded = true
            // 콜아웃 보여주기
            markerAnnotationView.canShowCallout = true
            // 마커의 색상 변경
            markerAnnotationView.markerTintColor = UIColor(named: "internationalOrange")
            
            /*
             Add a detail disclosure button to the callout, which will open a new view controller or a popover.
             When the detail disclosure button is tapped, use mapView(_:annotationView:calloutAccessoryControlTapped:)
             to determine which annotation was tapped.
             If you need to handle additional UIControl events, such as `.touchUpOutside`, you can call
             `addTarget(_:action:for:)` on the button to add those events.
             */
            
            let rightButton = UIButton(type: .detailDisclosure)
            // 콜아웃의 오른쪽에 버튼을 만들어준다.
            markerAnnotationView.rightCalloutAccessoryView = rightButton
        }
        
        return view
    }
    
    // 커스텀 어노테이션이면 만들어둔 CustomAnnotationView를 불러올 수 있다.
    private func setupCustomAnnotationView(for annotation: CustomAnnotation, on mapView: MKMapView) -> MKAnnotationView {
        return mapView.dequeueReusableAnnotationView(withIdentifier: NSStringFromClass(CustomAnnotation.self), for: annotation)
    }
    
    /// Create an annotation view for the Ferry Building, and add an image to the callout.
    /// - Tag: CalloutImage
    private func setupFerryBuildingAnnotationView(for annotation: FerryBuildingAnnotation, on mapView: MKMapView) -> MKAnnotationView {
        let identifier = NSStringFromClass(FerryBuildingAnnotation.self)
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier, for: annotation)
        if let markerAnnotationView = view as? MKMarkerAnnotationView {
            markerAnnotationView.animatesWhenAdded = true
            markerAnnotationView.canShowCallout = true
            markerAnnotationView.markerTintColor = UIColor.purple
            
            // Provide an image view to use as the accessory view's detail view.
            markerAnnotationView.detailCalloutAccessoryView = UIImageView(image: #imageLiteral(resourceName: "ferry_building"))
        }
        
        return view
    }
}
