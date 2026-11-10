//
//  MapViewModel.swift
//  PetSpot
//
//  Created by Bernardo on 09/10/2026.
//
import Foundation
import CoreLocation
import Combine

@MainActor
class MapViewModel: ObservableObject {

    @Published var petSpots: [PetSpotElement] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let osmService = OSMService()

    private var lastRequestedCoordinate: CLLocationCoordinate2D?

    func loadPetSpots(
        latitude: Double,
        longitude: Double
    ) async {

        // Evitar pedidos simultâneos
        guard !isLoading else {
            return
        }

        let coordinate = CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude
        )

        // Evitar consultas repetidas para a mesma localização
        if let last = lastRequestedCoordinate {

            let oldLocation = CLLocation(
                latitude: last.latitude,
                longitude: last.longitude
            )

            let newLocation = CLLocation(
                latitude: latitude,
                longitude: longitude
            )

            if oldLocation.distance(from: newLocation) < 500,
               !petSpots.isEmpty {
                return
            }
        }

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {

            let results = try await osmService.fetchPetSpots(
                near: coordinate,
                radiusInMeters: 5000
            )

            petSpots = results
            lastRequestedCoordinate = coordinate

            print("Serviços carregados: \(results.count)")

        } catch is CancellationError {

            print("Pedido cancelado.")

        } catch {

            errorMessage = error.localizedDescription

            print(
                "Erro ao carregar locais do OpenStreetMap: \(error.localizedDescription)"
            )
        }
    }
}
