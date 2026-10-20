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
    
    // Filtra os pontos de interesse de acordo com o filtro selecionado
    var filteredSpots: [PetSpotElement] {
        switch selectedFilter {
        case .all:
            return viewModel.petSpots
        case .vet:
            return viewModel.petSpots.filter { $0.category.lowercased().contains("vet") }
        case .park:
            return viewModel.petSpots.filter { 
                let cat = $0.category.lowercased()
                return cat.contains("parque") || cat.contains("park") || cat.contains("dog_park")
             }
        case .shop:
            return viewModel.petSpots.filter { 
                let cat = $0.category.lowercased()
                return cat.contains("loja") || cat.contains("grooming") || cat.contains("pet") || cat.contains("shop")
             }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 1. Alternador entre Mapa e Lista
                Picker("Modo de Visualização", selection: $viewMode) {
                    Label("Mapa", systemImage: "map.fill").tag(ViewMode.map)
                    Label("Lista", systemImage: "list.bullet").tag(ViewMode.list)
                }
                .pickerStyle(.segmented)
                .padding([.horizontal, .top])
                
                // 2. Filtros Rápidos (Horizontal Scroll)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(ServiceFilter.allCases) { filter in
                            Button(action: {
                                selectedFilter = filter
                            }) {
                                Text(filter.rawValue)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedFilter == filter ? Color.accentColor : Color(.secondarySystemBackground))
                                    .foregroundColor(selectedFilter == filter ? .white : .primary)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }
                
                // 3. Apresentação do Mapa ou da Lista
                ZStack {
                    switch viewMode {
                    case .map:
                        ContentView(viewModel: viewModel, spots: filteredSpots)
                    case .list:
                        ServiceListView(viewModel: viewModel, spots: filteredSpots)
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
            .onChance(of: locationManager.userLocation) { newLocation in
                if let Location = newLocation {
                    Task {
                        await viewModel.loadPetSpots(latitude: userLocation.latitude, longitude: userLocation.longitude)
                    }
                }
            }
            .task {
                if let location = locationManager.userLocation {
                    await viewModel.loadPetSpots(latitude: location.latitude, longitude: location.longitude)
                }else{
                    await viewModel.loadPetSpots(latitude: 38.7223, longitude: -9.1393)
                }
            }
        }
    }
}
