//
//  MainTabView.swift
//  PetSpot
//
//  Created by Bernardo on 10/10/2026.
//

import SwiftUI
import Combine

struct MainTabView: View {

    @Binding var isAuthenticated: Bool

    // Instâncias partilhadas por toda a navegação principal
    @StateObject private var mapViewModel = MapViewModel()
    @StateObject private var locationManager = LocationManager()

    var body: some View {

        TabView {

            // Separador 1
            PetListView()
                .tabItem {
                    Label("Os Meus Pets", systemImage: "pawprint.fill")
                }

            // Separador 2
            MapServicesView(viewModel: mapViewModel)
                .tabItem {
                    Label("Mapa", systemImage: "map.fill")
                }

            // Separador 3
            ScheduleView()
                .tabItem {
                    Label("Agenda", systemImage: "calendar")
                }

            // Separador 4
            CommunityView()
                .tabItem {
                    Label("Comunidade", systemImage: "person.3.fill")
                }

            // Separador 5
            ProfileView(isAuthenticated: $isAuthenticated)
                .tabItem {
                    Label("Perfil", systemImage: "person.crop.circle.fill")
                }
        }

        // Carregar serviços assim que a localização estiver disponível
        .onReceive(
            locationManager.$userLocation.compactMap { $0 }
        ) { location in

            Task { @MainActor in

                await mapViewModel.loadPetSpots(
                    latitude: location.latitude,
                    longitude: location.longitude
                )
            }
        }
    }
}
