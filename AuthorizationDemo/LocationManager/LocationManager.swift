import Foundation
import CoreLocation

final class LocationManager: NSObject {
    
    enum AuthorizationStatus {
        case denied
        case notDetermined
        case restricted
        case authorizedAlways
        case authorizedWhenInUse
    }
    
    enum LocationConfiguration {
        case isAlways
        case isWhenInUse
    }
    
    static let manager = LocationManager()
    
    private(set) var authorizationStatus: AuthorizationStatus?
    
    private var configuration: LocationConfiguration?
    private let locationManager = CLLocationManager()
    private var isUpdateLocation = false
    
    private override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func setConfiguration(_ configuration: LocationConfiguration) {
        self.configuration = configuration
    }
}

extension LocationManager {
    
    func registerLocationAuthorization() {
        let statau = CLLocationManager.authorizationStatus()
        switch statau {
        case .denied:
            authorizationStatus = .denied
        case .notDetermined:
            authorizationStatus = .notDetermined
            locationAuthorizationWhenIsUseOrAlways()
        case .restricted:
            authorizationStatus = .restricted
        case .authorizedWhenInUse:
            authorizationStatus = .authorizedWhenInUse
        case .authorizedAlways:
            authorizationStatus = .authorizedAlways
        }
    }
    
    private func locationAuthorizationWhenIsUseOrAlways() {
        guard let configuration = configuration else { fatalError("没有设置LocationCofiguration") }
        switch configuration {
        case .isAlways: locationManager.requestAlwaysAuthorization()
        case .isWhenInUse: locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func startUpdateLocation() {
        isUpdateLocation = true
        locationManager.startUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        if isUpdateLocation == true {
            isUpdateLocation = false
            let coordinate = location.coordinate
            NotificationCenter.default.post(name: LocationManager.locationDidUpdateNotification, object: coordinate)
        }
        manager.stopUpdatingLocation()
    }
}

extension LocationManager {
    static let locationDidUpdateNotification = Notification.Name("locationDidUpdateNotification")
}
