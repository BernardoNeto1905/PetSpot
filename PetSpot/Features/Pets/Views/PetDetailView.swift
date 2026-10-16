import SwiftUI
import SwiftData

struct PetDetailView: View {
    @Bindable var pet: Pet
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // Estado para controlar o separador interno selecionado
    @State private var selectedTab = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // Cabeçalho com Foto e Informação Básica
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
                
                // Picker (Segmented Control) para os 3 separadores
                Picker("Secção", selection: $selectedTab) {
                    Text("Saúde").tag(0)
                    Text("Documentos").tag(1)
                    Text("Diário").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Conteúdo dinâmico com base no separador ativo
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

// MARK: - Separador 1: Saúde & Vacinas
struct HealthAndVaccinesTab: View {
    @Bindable var pet: Pet
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // Cartão de Microchip
            VStack(alignment: .leading, spacing: 6) {
                Label("Número do Microchip", systemImage: "cpu")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(pet.microchipNumber.isEmpty ? "Não registado" : pet.microchipNumber)
                    .font(.headline)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            
            // Plano de Vacinação
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
                        Text("Sem data definida").foregroundColor(.gray)
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

// MARK: - Separador 2: Documentos
struct DocumentsTab: View {
    let pet: Pet
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Documentos Guardados")
                .font(.headline)
            
            // Exemplo de lista para Boletim de Vacinas / Seguro
            VStack(spacing: 12) {
                DocumentRow(title: "Boletim de Vacinas", icon: "doc.text.fill", color: .blue)
                DocumentRow(title: "Seguro de Saúde", icon: "shield.fill", color: .green)
                DocumentRow(title: "Registo Municipal", icon: "building.2.fill", color: .orange)
            }
            
            Button(action: { /* Ação para adicionar foto/PDF */ }) {
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
        HStack {
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

// MARK: - Separador 3: Diário & Rotina
struct DailyRoutineTab: View {
    @Bindable var pet: Pet
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // Medicação e Alergias
            VStack(alignment: .leading, spacing: 8) {
                Label("Medicação & Cuidados Especiais", systemImage: "pills.fill")
                    .font(.headline)
                
                Text(pet.medicationNotes ?? "Sem notas de medicação ou alergias registadas.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
    }
}
