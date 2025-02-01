import Foundation
import RxSwift
import RxCocoa
import CoreLocation

class MainMapViewModel: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let disposeBag = DisposeBag()
    
    private let _locationSubject = BehaviorSubject<CLLocationCoordinate2D?>(value: nil)
    var locationObservable: Observable<CLLocationCoordinate2D?> {
        return _locationSubject.asObservable()
    }

    override init() {
        super.init()
        setupLocationManager()
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let coordinate = location.coordinate
        _locationSubject.onNext(coordinate)
    }
}
