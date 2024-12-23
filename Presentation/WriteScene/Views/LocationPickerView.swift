import UIKit
import GoogleMaps
import CoreLocation
import RxSwift
import RxCocoa

class LocationPickerView: UIView {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let locationManager = CLLocationManager()
    
    let locationSwitch: UISwitch = {
        let locationSwitch = UISwitch()
        return locationSwitch
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.text = "시작 위치 설정"
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private let mapContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let centerMarker: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "mappin.and.ellipse"))
        imageView.tintColor = .red
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private(set) var mapView: GMSMapView!
    private(set) var selectedLocation: CLLocationCoordinate2D?
    
    var onLocationUpdate: ((CLLocationCoordinate2D) -> Void)?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupMapView()
        setupLocationManager()
        setupBinding()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupMapView()
        setupLocationManager()
        setupBinding()
    }
    
    // MARK: - Setup
    private func setupUI() {
        let locationStack = UIStackView(arrangedSubviews: [locationLabel, locationSwitch])
        locationStack.axis = .horizontal
        locationStack.spacing = 8
        locationStack.translatesAutoresizingMaskIntoConstraints = false
        
        mapContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(locationStack)
        addSubview(mapContainerView)
        
        NSLayoutConstraint.activate([
            locationStack.topAnchor.constraint(equalTo: topAnchor),
            locationStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            locationStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            mapContainerView.topAnchor.constraint(equalTo: locationStack.bottomAnchor, constant: 16),
            mapContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mapContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            mapContainerView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    private func setupMapView() {
        mapView = GMSMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapContainerView.addSubview(mapView)
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: mapContainerView.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: mapContainerView.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: mapContainerView.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: mapContainerView.bottomAnchor)
        ])
        
        mapContainerView.addSubview(centerMarker)
        NSLayoutConstraint.activate([
            centerMarker.centerXAnchor.constraint(equalTo: mapContainerView.centerXAnchor),
            centerMarker.centerYAnchor.constraint(equalTo: mapContainerView.centerYAnchor),
            centerMarker.widthAnchor.constraint(equalToConstant: 30),
            centerMarker.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func setupBinding() {
        locationSwitch.rx.isOn
            .subscribe(onNext: { [weak self] isOn in
                self?.mapContainerView.isHidden = !isOn
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - GMSMapViewDelegate
extension LocationPickerView: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        selectedLocation = position.target
        onLocationUpdate?(position.target)
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationPickerView: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
        case .denied, .restricted:
            print("Location permission denied")
        default:
            print("Location status unknown")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 15.0)
            mapView.animate(to: camera)
            locationManager.stopUpdatingLocation()
        }
    }
}
