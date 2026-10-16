//
//  OSMService.swift
//  PetSpot
//
//  Created by Bernardo on 09/10/2026.
//
import Foundation
import CoreLocation

enum NetworkError: Error {
    case invalidURL
    case requestFailed
    case decodingError
}

struct OSMService {
    func fetchPetSpots(near coordinate: CLLocationCoordinate2D, radiusInMeters: Int = 5000) async throws -> [PetSpotElement] {
        // 1. Query do Overpass formatada numa única linha ou limpa
        let query = """
        [out:json];
        (
          node["leisure"="dog_park"](around:\(radiusInMeters),\(coordinate.latitude),\(coordinate.longitude));
          node["amenity"="veterinary"](around:\(radiusInMeters),\(coordinate.latitude),\(coordinate.longitude));
        );
        out body;
        """
        
        // 2. Construir a URL com os parâmetros de consulta (URL Query)
        var components = URLComponents(string: "https://overpass-api.de/api/interpreter")
        components?.queryItems = [
            URLQueryItem(name: "data", value: query)
        ]
        
        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // 3. Adicionar um User-Agent (obrigatório pelas regras da Overpass API)
        request.setValue("PetSpotiOSApp/1.0", forHTTPHeaderField: "User-Agent")
        
        // 4. Executar o pedido
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.requestFailed
        }
        
        // 5. Descodificar a resposta
        do {
            let result = try JSONDecoder().decode(OverpassResponse.self, from: data)
            return result.elements
        } catch {
            print("Erro de Descodificação JSON: \(error)")
            throw NetworkError.decodingError
        }
    }
}

