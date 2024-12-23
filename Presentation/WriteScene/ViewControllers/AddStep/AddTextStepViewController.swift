import UIKit
import RxSwift
import CoreLocation
import GoogleMaps

class AddTextStepViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let textView = UITextView()
    
    private let locationManager = CLLocationManager()
    
    private let locationSwitch: UISwitch = {
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
        view.isHidden = true
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let centerMarker: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "mappin.and.ellipse"))
        imageView.tintColor = .red
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var mapView: GMSMapView!
    
    private var selectedLocation: CLLocationCoordinate2D?
    
    var onSave: ((_ step: Step, _ completion: @escaping (Result<Void, Error>) -> Void) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupBinding()
        setupMapView()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func setupNavigationBar() {
        
        let saveBarButton = UIBarButtonItem(
            image: UIImage(systemName: "checkmark.circle"),
            style: .plain,
            target: self,
            action: #selector(saveButtonTapped)
        )
        
        navigationItem.rightBarButtonItem = saveBarButton
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.cornerRadius = 8
        textView.font = .systemFont(ofSize: 16)
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        let locationStack = UIStackView(arrangedSubviews: [locationLabel, locationSwitch])
        locationStack.axis = .horizontal
        locationStack.spacing = 8
        locationStack.translatesAutoresizingMaskIntoConstraints = false
        mapContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(textView)
        view.addSubview(locationStack)
        view.addSubview(mapContainerView)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.heightAnchor.constraint(equalToConstant: 200),
            
            locationStack.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 16),
            locationStack.leadingAnchor.constraint(equalTo: textView.leadingAnchor),
            
            mapContainerView.topAnchor.constraint(equalTo: locationStack.bottomAnchor, constant: 16),
            mapContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mapContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            mapContainerView.heightAnchor.constraint(equalToConstant: 300),
        ])
    }
    
    private func setupBinding() {
        locationSwitch.rx.isOn
            .subscribe(onNext: { [weak self] isOn in
                self?.mapContainerView.isHidden = !isOn
            })
            .disposed(by: disposeBag)
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
    
    @objc private func saveButtonTapped() {
        guard !textView.text.isEmpty else {
            showAlert(message: "텍스트를 입력해주세요")
            return
        }
        
        onSave?(Step(id: nil, type: .text(textView.text), location: selectedLocation)) { r in
            switch r {
            case .success(()):
                DispatchQueue.main.async {
                    self.handleSubmitSuccess()
                }
            case .failure(let error):
                print("AddTextStepViewController : \(error)")
                DispatchQueue.main.async {
                    self.showAlert(message: "통신 오류")
                }
            }
            
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true, completion: nil)
    }
    
    private func handleSubmitSuccess() {
        let alert = UIAlertController(title: "알림", message: "저장 완료", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}

extension AddTextStepViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        selectedLocation = position.target
    }
}

extension AddTextStepViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
        case .denied, .restricted:
            print("Location permission denied")
        case .notDetermined:
            print("Location permission not determined yet")
        @unknown default:
            print("Unknown authorization status")
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
