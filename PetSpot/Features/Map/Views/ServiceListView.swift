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
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // Título da secção
                Text("Serviços perto de ti")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                
                if spots.isEmpty && !viewModel.isLoading {
                    // Estado Vazio
                    VStack(spacing: 12) {
                        Image(systemName: "mappin.slash")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        Text("Nenhum serviço encontrado")
                            .font(.headline)
                        Text("Usa os filtros para encontrar o serviço de que o teu pet precisa.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(20)
                    .padding(.horizontal, 16)
                } else {
                    // Lista de Cartões Modernos com dados reais
                    LazyVStack(spacing: 16) {
                        ForEach(spots) { spot in
                            VStack(alignment: .leading, spacing: 12) {
                                
                                // Cabeçalho do Cartão: Nome e Categoria Real
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(spot.name)
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundColor(.primary)

                                        Text(translatedCategory(spot.category))
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                }

                                // Botões de Ação Rápida
                                HStack(spacing: 12) {
                                    Button(action: {
                                        // Ação de Ligar
                                    }) {
                                        Label("Ligar", systemImage: "phone.fill")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(Color.green)
                                            .foregroundColor(.white)
                                            .cornerRadius(16)
                                    }

                                    Button(action: {
                                        // Ação de Direções
                                    }) {
                                        Label("Obter Direções", systemImage: "location.fill")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(Color.green.opacity(0.12))
                                            .foregroundColor(.green)
                                            .cornerRadius(16)
                                    }
                                }
                            }
                            .padding(20)
                            .background(Color(.systemBackground))
                            .cornerRadius(24)
                            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
                            .padding(.horizontal, 16)
                        }
                    }
                }
            }
            .padding(.bottom, 30)
        }
        .background(Color(.systemGroupedBackground))
        .refreshable {
            if let location = locationManager.userLocation {
                await viewModel.loadPetSpots(latitude: location.latitude, longitude: location.longitude)
            } else {
                await viewModel.loadPetSpots(latitude: 38.7223, longitude: -9.1393)
            }
        }
    }
    
    private func translatedCategory(_ category: String) -> String {
        let cat = category.lowercased()
        if cat.contains("vet") || cat.contains("veterinary") { return "Veterinário" }
        if cat.contains("parque") || cat.contains("park") || cat.contains("dog_park") { return "Parque Canino" }
        if cat.contains("grooming") { return "Tosquias & Banhos" }
        if cat.contains("pet") || cat.contains("shop") || cat.contains("loja") { return "Loja de Animais" }
        return category.capitalized
    }
}
