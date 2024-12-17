import UIKit
import GoogleMaps
import RxSwift

class StepMissionViewController: UIViewController {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let mapView = GMSMapView()
    private let radiusSlider = UISlider()
    private let saveButton = UIButton(type: .system)
    private var selectedLocation: CLLocationCoordinate2D?
    private var selectedRadius: Double = 100.0 // 기본 반경 값
    
    var onSave: ((Step) -> Void)?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        title = "이동 미션 추가"
        
        // MapView 설정
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.isMyLocationEnabled = true
        
        // 반경 슬라이더 설정
        radiusSlider.minimumValue = 50
        radiusSlider.maximumValue = 1000
        radiusSlider.value = Float(selectedRadius)
        radiusSlider.translatesAutoresizingMaskIntoConstraints = false
        
        // Save 버튼
        saveButton.setTitle("Save", for: .normal)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        // UI 추가
        view.addSubview(mapView)
        view.addSubview(radiusSlider)
        view.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.heightAnchor.constraint(equalToConstant: 400),
            
            radiusSlider.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 16),
            radiusSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            radiusSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            saveButton.topAnchor.constraint(equalTo: radiusSlider.bottomAnchor, constant: 20),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        // Marker 이벤트 추가
        mapView.delegate = self
    }
    
    private func setupBindings() {
        // 반경 슬라이더 값 변경 시 이벤트
        radiusSlider.rx.value
            .subscribe(onNext: { [weak self] value in
                self?.selectedRadius = Double(value)
                self?.updateCircleOverlay()
            })
            .disposed(by: disposeBag)
        
        // Save 버튼 탭 이벤트
        saveButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self, let location = self.selectedLocation else {
                    self?.showAlert("위치를 선택해주세요.")
                    return
                }
                self.onSave?(Step(id: nil, type: .mission(location: location, radius: selectedRadius)))
                self.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
    
    private func updateCircleOverlay() {
        guard let location = selectedLocation else { return }
        mapView.clear() // 기존 오버레이 제거
        let marker = GMSMarker(position: location)
        marker.map = mapView
        
        let circle = GMSCircle(position: location, radius: selectedRadius)
        circle.fillColor = UIColor.red.withAlphaComponent(0.2)
        circle.strokeColor = .red
        circle.strokeWidth = 1
        circle.map = mapView
    }
    
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - GMSMapViewDelegate
extension StepMissionViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        selectedLocation = coordinate
        updateCircleOverlay()
    }
}
