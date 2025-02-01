import UIKit
import RxSwift
import GoogleMaps
import CoreLocation

class MainMapViewController: UIViewController {
    
    private let viewModel: MainMapViewModel
    
    private let disposeBag = DisposeBag()
    
    var mapView: GMSMapView!
    var marker: GMSMarker!
    
    init(viewModel: MainMapViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMapView()
        bindViewModel()
    }
    
    private func setupMapView() {
        let initialLatitude: Double = -33.86
        let initialLongitude: Double = 151.20
        
        let options = GMSMapViewOptions()
        options.camera = GMSCameraPosition.camera(
            withLatitude: initialLatitude,
            longitude: initialLongitude,
            zoom: 15.0
        )
        options.frame = self.view.bounds

        mapView = GMSMapView(options: options)
        self.view.addSubview(mapView)
        
        marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: initialLatitude, longitude: initialLongitude)
        marker.title = "Current Location"
        marker.map = mapView
    }

    private func bindViewModel() {
        viewModel.locationObservable
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] coordinate in
                guard let self = self else { return }

                self.marker.position = coordinate

                let cameraUpdate = GMSCameraUpdate.setTarget(coordinate, zoom: 15.0)
                self.mapView.animate(with: cameraUpdate)
            })
            .disposed(by: disposeBag)
    }
}
