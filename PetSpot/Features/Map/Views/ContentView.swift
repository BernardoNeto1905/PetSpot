//
//  ContentView.swift
//  PetSpot
//
//  Created by Bernardo on 09/10/2026.
//

import SwiftUI
import MapKit

struct ContentView: View {

    var viewModel: MapViewModel
    var spots: [PetSpotElement]

    @Binding var selectedSpot: PetSpotElement?
    @Binding var centerTrigger: Bool

    @State private var cameraPosition: MapCameraPosition = .userLocation(
        fallback: .region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: 38.7223,
                    longitude: -9.1393
                ),
                span: MKCoordinateSpan(
                    latitudeDelta: 0.05,
                    longitudeDelta: 0.05
                )
            )
        )
    )

    var body: some View {

        Map(position: $cameraPosition) {

            UserAnnotation()

            ForEach(spots) { spot in

                if let lat = spot.lat, let lon = spot.lon {

                    Annotation(
                        spot.name,
                        coordinate: CLLocationCoordinate2D(
                            latitude: lat,
                            longitude: lon
                        )
                    ) {

                        Button {
                            selectedSpot = spot
                        } label: {

                            VStack(spacing: 0) {

                                Image(systemName: iconForCategory(spot.category))
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(colorForCategory(spot.category))
                                    .clipShape(Circle())
                                    .shadow(radius: 3)

                                Image(systemName: "arrowtriangle.down.fill")
                                    .font(.caption2)
                                    .foregroundColor(colorForCategory(spot.category))
                                    .offset(y: -3)
                            }
                        }
                    }
                }
            }
        }
        .mapControls {
            MapUserLocationButton()
        }
        .mapControlVisibility(.visible)
    }

    private func iconForCategory(_ category: String) -> String {

        if category.lowercased().contains("vet") {
            return "cross.vial.fill"
        }

        if category.lowercased().contains("parque") ||
            category.lowercased().contains("park") {
            return "leaf.fill"
        }

        return "bag.fill"
    }

    private func colorForCategory(_ category: String) -> Color {

        if category.lowercased().contains("vet") {
            return .red
        }

        if category.lowercased().contains("parque") ||
            category.lowercased().contains("park") {
            return .green
        }

        return .orange
    }
}
