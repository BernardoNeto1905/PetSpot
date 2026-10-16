//
//  MainTabView.swift
//  PetSpot
//
//  Created by Bernardo on 10/10/2026.
//


import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            // Separador 1
            PetListView()
                .tabItem {
                    Label("Os Meus Pets", systemImage: "pawprint.fill")
                }
            
            // Separador 2 (O mapa OSM que construímos)
            MapServicesView()
                .tabItem {
                    Label("Mapa", systemImage: "map.fill")
                }
            
            // Separador 3
            Text("Agenda & Lembretes")
                .tabItem {
                    Label("Agenda", systemImage: "calendar")
                }
            
            // Separador 4
            Text("Comunidade")
                .tabItem {
                    Label("Comunidade", systemImage: "person.3.fill")
                }
        }
    }
}
