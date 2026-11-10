//
//  MapServicesView.swift
//  PetSpot
//
//  Created by Bernardo on 11/10/2026.
//

import SwiftUI

struct MapServicesView: View {

    @StateObject private var viewModel = MapViewModel()
    @StateObject private var locationManager = LocationManager()

    @State private var viewMode: ViewMode = .map
    @State private var selectedFilter: ServiceFilter = .all

    enum ViewMode {
        case map
        case list
    }

    enum ServiceFilter: String, CaseIterable, Identifiable {
        case all = "Todos"
        case vet = "Veterinários"
        case park = "Parques"
        case shop = "Lojas & Tosquias"

        var id: String { self.rawValue }
    }

    // Filtrar os serviços sem fazer novos pedidos à API
    var filteredSpots: [PetSpotElement] {

        switch selectedFilter {

        case .all:
            return viewModel.petSpots

        case .vet:
            return viewModel.petSpots.filter {
                $0.category.lowercased().contains("vet")
            }

        case .park:
            return viewModel.petSpots.filter {
                let cat = $0.category.lowercased()
                return cat.contains("parque") ||
                       cat.contains("park") ||
                       cat.contains("dog_park")
            }

        case .shop:
            return viewModel.petSpots.filter {
                let cat = $0.category.lowercased()
                return cat.contains("loja") ||
                       cat.contains("grooming") ||
                       cat.contains("pet") ||
                       cat.contains("shop")
            }
        }
    }

    var body: some View {

        NavigationStack {

            VStack(spacing: 0) {

                // Alternador entre Mapa e Lista
                Picker("Modo de Visualização", selection: $viewMode) {

                    Label("Mapa", systemImage: "map.fill")
                        .tag(ViewMode.map)

                    Label("Lista", systemImage: "list.bullet")
                        .tag(ViewMode.list)
                }
                .pickerStyle(.segmented)
                .padding([.horizontal, .top])

                // Filtros
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
                                    .padding(.vertical, 8)
                                    .background(
                                        selectedFilter == filter
                                        ? Color.accentColor
                                        : Color(.secondarySystemBackground)
                                    )
                                    .foregroundColor(
                                        selectedFilter == filter
                                        ? .white
                                        : .primary
                                    )
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }

                // Mapa ou Lista
                ZStack {

                    switch viewMode {

                    case .map:
                        ContentView(
                            viewModel: viewModel,
                            spots: filteredSpots
                        )

                    case .list:
                        ServiceListView(
                            viewModel: viewModel,
                            spots: filteredSpots
                        )
                    }

                    if viewModel.isLoading {

                        ProgressView("A carregar serviços...")
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                    }
                }
            }
            .navigationTitle("Mapa & Serviços 🐾")
            .navigationBarTitleDisplayMode(.inline)

            // ÚNICO ponto de carregamento dos serviços
            .onChange(
                of: locationManager.userLocation?.latitude,
                initial: true
            ) { _, _ in

                guard let location = locationManager.userLocation else {
                    return
                }

                Task {
                    await viewModel.loadPetSpots(
                        latitude: location.latitude,
                        longitude: location.longitude
                    )
                }
            }
        }
    }
}
