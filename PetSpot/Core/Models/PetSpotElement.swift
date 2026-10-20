//
//  PetSpotElement.swift
//  PetSpot
//
//  Created by Bernardo on 16/10/2026.
//

import Foundation
import CoreLocation

// Estrutura que representa a resposta raiz da Overpass API
struct OverpassResponse: Codable {
    let elements: [PetSpotElement]
}

// Estrutura do elemento retornado pelo OpenStreetMap
struct PetSpotElement: Codable, Identifiable {
    let id: Int
    let lat: Double?
    let lon: Double?
    let tags: [String: String]?
    
    // Propriedades computadas para facilitar o uso na interface
    var name: String {
        tags?["name"] ?? "Local sem nome"
    }
    
    var category: String {
        if let amenity = tags?["amenity"] {
            return amenity == "veterinary" ? "Veterinário" : amenity
        }
        if let leisure = tags?["leisure"] {
            return leisure == "dog_park" ? "Parque para Cães" : leisure
        }
        if let shop = tags?["shop"] {
            return shop == "pet" ? "Loja de Animais" : shop
        }
        return "Serviço para Animais"
    }
    
    var coordinate: CLLocationCoordinate2D? {
        guard let lat = lat, let lon = lon else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}
