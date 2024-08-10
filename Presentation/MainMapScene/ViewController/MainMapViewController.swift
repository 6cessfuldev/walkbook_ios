import UIKit
import RxSwift
import GoogleMaps

class MainMapViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let options = GMSMapViewOptions()
               options.camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
               options.frame = self.view.bounds

               let mapView = GMSMapView(options: options)
               self.view.addSubview(mapView)

               // Creates a marker in the center of the map.
               let marker = GMSMarker()
               marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
               marker.title = "Sydney"
               marker.snippet = "Australia"
               marker.map = mapView
    }
}
