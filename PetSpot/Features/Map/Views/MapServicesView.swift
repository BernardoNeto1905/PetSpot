//
//  MapServicesView.swift
//  PetSpot
//
//  Created by Bernardo on 11/10/2026.
//

import SwiftUI
import MapKit

struct MapServicesView: View {

    @ObservedObject var viewModel: MapViewModel

    @State private var viewMode: ViewMode = .map
    @State private var selectedFilter: ServiceFilter = .all
    @State private var selectedSpot: PetSpotElement? = nil
    @State private var centerTrigger = false

    enum ViewMode {
        case map
        case list
    }

    enum ServiceFilter: String, CaseIterable, Identifiable {
        case all = "Todos"
        case park = "Parques"
        case vet = "Veterinários"
        case shop = "Lojas"

        var id: String { self.rawValue }
    }

    // Filtrar os serviços com base nas categorias selecionadas
    var filteredSpots: [PetSpotElement] {
        let spots = viewModel.petSpots

        switch selectedFilter {
        case .all:
            return spots
        case .park:
            return spots.filter {
                let cat = $0.category.lowercased()
                return cat.contains("parque") || cat.contains("park") || cat.contains("dog_park")
            }
        case .vet:
            return spots.filter {
                let cat = $0.category.lowercased()
                return cat.contains("vet") || cat.contains("veterinary")
            }
        case .shop:
            return spots.filter {
                let cat = $0.category.lowercased()
                return cat.contains("loja") || cat.contains("shop") || cat.contains("pet") || cat.contains("grooming")
            }
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            
            // 1. Conteúdo de Fundo (Mapa ou Lista a ocupar o ecrã todo)
            Group {
                switch viewMode {
                case .map:
                    ContentView(viewModel: viewModel, spots: filteredSpots, selectedSpot: $selectedSpot, centerTrigger: $centerTrigger)
                        .ignoresSafeArea()
                case .list:
                    ServiceListView(viewModel: viewModel, spots: filteredSpots)
                        .padding(.top, 110) // Espaço para não ficar por baixo dos filtros flutuantes
                }
            }

            // Indicador de carregamento global
            if viewModel.isLoading {
                ProgressView("A carregar serviços...")
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .padding(.top, 150)
            }

            // 2. Elementos Flutuantes do Topo (Filtros e Seletor)
            VStack(spacing: 0) {
                filterScrollView
                headerControlsView
                    .padding(.top, 10)
            }
            .background(
                // Gradiente subtil opcional para destacar os filtros do mapa por trás, ou podes remover se preferires limpo
                LinearGradient(
                    colors: [Color(.systemBackground).opacity(0.85), Color(.systemBackground).opacity(0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                .frame(height: 140)
            )

            // 3. Cartão Flutuante Inferior (Apenas visível no Mapa quando selecionas um pin)
            VStack {
                Spacer()
                spotDetailCardView
            }
        }
    }

    // MARK: - Subviews Flutuantes

    private var filterScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(ServiceFilter.allCases) { filter in
                    Button {
                        selectedFilter = filter
                    } label: {
                        Text(filter.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                selectedFilter == filter
                                ? Color.green
                                : Color(.systemBackground)
                            )
                            .foregroundColor(
                                selectedFilter == filter
                                ? .white
                                : .primary
                            )
                            .cornerRadius(24)
                            .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
    }

    private var headerControlsView: some View {
        HStack {
            // Pílula informativa de serviços próximos
            HStack(spacing: 6) {
                Image(systemName: "location.fill")
                    .font(.caption)
                    .foregroundColor(.green)
                Text("\(filteredSpots.count) serviços perto de ti")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)

            Spacer()

            // Seletor Mapa / Lista
            HStack(spacing: 0) {
                Button {
                    viewMode = .map
                } label: {
                    Text("Mapa")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(viewMode == .map ? Color.green : Color.clear)
                        .foregroundColor(viewMode == .map ? .white : .primary)
                        .cornerRadius(18)
                }

                Button {
                    viewMode = .list
                } label: {
                    Text("Lista")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(viewMode == .list ? Color.green : Color.clear)
                        .foregroundColor(viewMode == .list ? .white : .primary)
                        .cornerRadius(18)
                }
            }
            .padding(4)
            .background(Color(.systemBackground))
            .cornerRadius(22)
            .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
        }
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private var spotDetailCardView: some View {
        if let spot = selectedSpot, viewMode == .map {
            VStack(alignment: .leading, spacing: 12) {
                Capsule()
                    .fill(Color.secondary.opacity(0.3))
                    .frame(width: 36, height: 4)
                    .frame(maxWidth: .infinity, alignment: .center)

                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(spot.name)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)

                        Text(spot.category)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()

                    Text("Disponível")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.green.opacity(0.15))
                        .foregroundColor(.green)
                        .cornerRadius(12)
                }

                HStack(spacing: 12) {
                    Button(action: {}) {
                        Label("Ligar", systemImage: "phone.fill")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                    }

                    Button(action: {}) {
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
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 32,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 32
                )
            )
            .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: -5)
            .transition(.move(edge: .bottom))
            .animation(.spring(), value: selectedSpot != nil)
        }
    }
}
