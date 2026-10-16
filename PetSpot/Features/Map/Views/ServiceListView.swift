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
                            
                            Text(spot.category)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.plain)
                .refreshable {
                    await viewModel.loadPetSpots()
                }
            }
        }
    }
    
    private func iconForCategory(_ category: String) -> String {
        if category.lowercased().contains("vet") { return "cross.vial.fill" }
        if category.lowercased().contains("parque") || category.lowercased().contains("park") { return "leaf.fill" }
        return "bag.fill"
    }
    
    private func colorForCategory(_ category: String) -> Color {
        if category.lowercased().contains("vet") { return .red }
        if category.lowercased().contains("parque") || category.lowercased().contains("park") { return .green }
        return .orange
    }
}
