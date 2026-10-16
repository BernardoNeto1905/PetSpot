//
//  MapViewModel.swift
//  PetSpot
//
//  Created by Bernardo on 09/10/2026.
//
import Foundation
import CoreLocation

@Observable
class MapViewModel {
    var petSpots: [PetSpotElement] = []
    var isLoading = false
    var errorMessage: String? = nil
    
    private let osmService = OSMService()
    
    // Exemplo: Coordenadas do centro de Lisboa (ou podes usar a localização atual do utilizador)
    var currentCoordinate = CLLocationCoordinate2D(latitude: 38.7223, longitude: -9.1393)
    
    @MainActor
    func loadPetSpots() async {
        isLoading = true
        errorMessage = nil
        
        do {
            petSpots = try await osmService.fetchPetSpots(near: currentCoordinate)
        } catch {
            errorMessage = "Não foi possível carregar os locais: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
