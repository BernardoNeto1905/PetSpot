//
//  MapViewModel.swift
//  PetSpot
//
//  Created by Bernardo on 09/10/2026.
//
import Foundation
import CoreLocation

@MainActor
class MapViewModel: ObservableObject {
    @Published var petSpots: [PetSpotElement] = []
    @Published var isLoading = false
    
    func loadPetSpots(latitude: Double, longitude: Double) async {
        self.isLoading = true
        defer { self.isLoading = false }

        let query = """
        [out:json][timeout:25];
        (
          node["amenity"="veterinary"](around:5000,\(latitude),\(longitude));
          node["leisure"="dog_park"](around:5000,\(latitude),\(longitude));
          node["shop"="pet"](around:5000,\(latitude),\(longitude));
        );
        out body;
        >;
        out skel qt;
        """

        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://overpass-api.de/api/interpreter?data=\(encodedQuery)") else {
            print("URL inválido para a Overpass API")
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: url)
            // Process the data to extract pet spots

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Erro na resposta da API")
                return
            }

            let decoder = try JSONDecoder().decode(OverpassRemote.self, from: data)

            self.petSpots = decodedResponse.elements.map { element in
                let category = element.tags?["amenity"] ?? element.tags?["leisure"] ?? element.tags?["shop"] ?? "Serviço"
                let name = element.tags?["name"] ?? "Serviço Pet"
                return PetSpotElement(id: element.id, name: name, category: category, lat: element.lat, lon: element.lon)
            }

        } catch {
            print("Erro ao carregar locais do OpenStreetMap: \(error.localizedDescription)")
        }
    }
}
