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

    func loadPetSpots(latitude: Double, longitude: Double) async {
        isLoading = true
        defer { isLoading = false }

        let query = """
        [out:json][timeout:25];
        (
          node["amenity"="veterinary"](around:5000,\(latitude),\(longitude));
          node["leisure"="dog_park"](around:5000,\(latitude),\(longitude));
          node["shop"="pet"](around:5000,\(latitude),\(longitude));
        );
        out body;
        """

        guard let url = URL(
            string: "https://overpass-api.de/api/interpreter"
        ) else {
            print("URL inválido para a Overpass API")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(
            "application/x-www-form-urlencoded",
            forHTTPHeaderField: "Content-Type"
        )

        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "data", value: query)
        ]

        request.httpBody = components.percentEncodedQuery?
            .data(using: .utf8)

        do {
            let (data, response) = try await URLSession.shared.data(
                for: request
            )

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print("Erro na resposta da API")
                return
            }

            let decodedResponse = try JSONDecoder().decode(
                OverpassResponse.self,
                from: data
            )

            petSpots = decodedResponse.elements

            print("Serviços carregados: \(petSpots.count)")

        } catch {
            print(
                "Erro ao carregar locais do OpenStreetMap: \(error.localizedDescription)"
            )
        }
    }
}
