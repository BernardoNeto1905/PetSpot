
import SwiftUI

struct PetDetailView: View {
    let pet: Pet
    @State private var selectedTab = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Image(systemName: "pawprint.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 90, height: 90)
                        .foregroundColor(.accentColor)

                    Text(pet.name)
                        .font(.largeTitle)
                        .bold()

                    Text("\(pet.breed) • \(pet.ageString)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)

                Picker("Secção", selection: $selectedTab) {
                    Text("Saúde").tag(0)
                    Text("Documentos").tag(1)
                    Text("Diário").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                Group {
                    switch selectedTab {
                    case 0:
                        HealthAndVaccinesTab(pet: pet)
                    case 1:
                        DocumentsTab(pet: pet)
                    case 2:
                        DailyRoutineTab(pet: pet)
                    default:
                        EmptyView()
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Ficha do Pet")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct HealthAndVaccinesTab: View {
    let pet: Pet

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Label("Número do Microchip", systemImage: "cpu")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(pet.microchipNumber.isEmpty
                     ? "Não registado"
                     : pet.microchipNumber)
                    .font(.headline)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)

            VStack(alignment: .leading, spacing: 12) {
                Label("Plano de Vacinação", systemImage: "cross.vial.fill")
                    .font(.headline)

                HStack {
                    Text("Próxima Vacina:")
                    Spacer()

                    if let date = pet.nextVaccineDate {
                        Text(date.formatted(date: .long, time: .omitted))
                            .bold()
                    } else {
                        Text("Sem data definida")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
    }
}

struct DocumentsTab: View {
    let pet: Pet

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Documentos Guardados")
                .font(.headline)

            VStack(spacing: 12) {
                DocumentRow(title: "Boletim de Vacinas",
                            icon: "doc.text.fill", color: .blue)
                DocumentRow(title: "Seguro de Saúde",
                            icon: "shield.fill", color: .green)
                DocumentRow(title: "Registo Municipal",
                            icon: "building.2.fill", color: .orange)
            }

            Button(action: {
                // Implementar futuramente a adição de documentos.
            }) {
                Label("Adicionar Documento", systemImage: "doc.badge.plus")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.top, 8)
        }
    }
}

struct DocumentRow: View {
    let title: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)

            Text(title)
                .font(.subheadline)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct DailyRoutineTab: View {
    let pet: Pet

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Medicação & Cuidados Especiais",
                  systemImage: "pills.fill")
                .font(.headline)

            Text(pet.medicationNotes ??
                 "Sem notas de medicação ou alergias registadas.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}
