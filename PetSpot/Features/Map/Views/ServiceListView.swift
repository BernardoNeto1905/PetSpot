//
//  ServiceListView.swift
//  PetSpot
//
//  Created by Bernardo on 10/10/2026.
//

import SwiftUI

struct ServiceListView: View {
    var viewModel: MapViewModel
    var spots: [PetSpotElement]
    
    // Gestor de localização para permitir recarregar a lista na posição atual
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        VStack {
            if spots.isEmpty && !viewModel.isLoading {
                ContentUnavailableView(
                    "Nenhum serviço encontrado",
                    systemImage: "mappin.slash",
                    description: Text("Tenta ajustar os filtros ou pesquisar noutra área.")
                )
            } else {
                List(spots) { spot in
                    HStack(spacing: 16) {
                        Image(systemName: iconForCategory(spot.category))
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(colorForCategory(spot.category))
                            .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(spot.name)
                                .font(.headline)
                            
                            Text(translatedCategory(spot.category))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.plain)
                .refreshable {
                    // Recarrega os dados com as coordenadas atuais do GPS
                    if let location = locationManager.userLocation {
                        await viewModel.loadPetSpots()
                    } else {
                        await viewModel.loadPetSpots()
                    }
                }
            }
        }
    }
    
    // Suporte para termos em Português e Inglês (OSM / Overpass)
    private func iconForCategory(_ category: String) -> String {
        let cat = category.lowercased()
        if cat.contains("vet") || cat.contains("veterinary") { return "cross.vial.fill" }
        if cat.contains("parque") || cat.contains("park") || cat.contains("dog_park") { return "leaf.fill" }
        return "bag.fill"
    }
    
    private func colorForCategory(_ category: String) -> Color {
        let cat = category.lowercased()
        if cat.contains("vet") || cat.contains("veterinary") { return .red }
        if cat.contains("parque") || cat.contains("park") || cat.contains("dog_park") { return .green }
        return .orange
    }
    
    // Traduz as tags brutas do OSM para nomes amigáveis em Português
    private func translatedCategory(_ category: String) -> String {
        let cat = category.lowercased()
        if cat.contains("vet") || cat.contains("veterinary") { return "Veterinário" }
        if cat.contains("parque") || cat.contains("park") || cat.contains("dog_park") { return "Parque Canino" }
        if cat.contains("grooming") { return "Tosquias & Banhos" }
        if cat.contains("pet") || cat.contains("shop") || cat.contains("loja") { return "Loja de Animais" }
        return category.capitalized
    }
}
