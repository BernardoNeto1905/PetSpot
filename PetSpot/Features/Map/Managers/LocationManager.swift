//
//  LocationManager.swift
//  PetSpot
//
//  Created by Bernardo on 19/10/2026.
//


import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    private let manager = CLLocationManager()

    @Published var userLocation: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus?
    @Published var locationError: String?

    override init() {
        super.init()

        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = 100

        authorizationStatus = manager.authorizationStatus

        manager.requestWhenInUseAuthorization()
    }

    // Atualização do estado de autorização
    func locationManagerDidChangeAuthorization(
        _ manager: CLLocationManager
    ) {

        authorizationStatus = manager.authorizationStatus

        switch manager.authorizationStatus {

        case .authorizedAlways, .authorizedWhenInUse:
            locationError = nil
            manager.requestLocation()

        case .denied:
            locationError = "A localização foi recusada. Ativa-a nas definições do iPhone."

        case .restricted:
            locationError = "A localização está restringida neste dispositivo."

        case .notDetermined:
            break

        @unknown default:
            locationError = "Não foi possível determinar a autorização da localização."
        }
    }

    // Receber a localização
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {

        guard let location = locations.last else {
            return
        }

        userLocation = location.coordinate
        locationError = nil
    }

    // Tratar erros do GPS
    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {

        locationError = error.localizedDescription

        print("Erro de localização: \(error.localizedDescription)")
    }
}
