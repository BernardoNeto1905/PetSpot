import SwiftUI
import SwiftData

struct PetListView: View {
    // Procura automática no SwiftData
    @Query private var pets: [Pet]
    @Environment(\.modelContext) private var modelContext
    
    // Estado para saber qual o pet no carrossel
    @State private var selectedPetID: UUID?
    @State private var showAddPetSheet = false
    
    var selectedPet: Pet? {
        pets.first(where: { $0.id == selectedPetID }) ?? pets.first
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    if pets.isEmpty {
                        // Estado Vazio
                        ContentUnavailableView(
                            "Sem Animais",
                            systemImage: "pawprint.fill",
                            description: Text("Adiciona o teu primeiro animal para começar a gerir a saúde e rotina.")
                        )
                        .padding(.top, 40)
                    } else {
                        // 1. CARROSSEL HORIZONTAL
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(pets) { pet in
                                    PetCardView(pet: pet, isSelected: pet.id == selectedPet?.id)
                                        .onTapGesture {
                                            withAnimation(.spring()) {
                                                selectedPetID = pet.id
                                            }
                                        }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // 2. FICHA RESUMIDA DO PET SELECIONADO
                        if let pet = selectedPet {
                            PetSummaryCard(pet: pet)
                                .padding(.horizontal)
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Os Meus Pets 🐾")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showAddPetSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showAddPetSheet) {
                AddPetView()
            }
            .onAppear {
                if selectedPetID == nil {
                    selectedPetID = pets.first?.id
                }
            }
        }
    }
}

// MARK: - Cartão do Animal
struct PetCardView: View {
    let pet: Pet
    let isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: "pawprint.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(isSelected ? .white : .accentColor)
            
            Text(pet.name)
                .font(.headline)
                .foregroundColor(isSelected ? .white : .primary)
            
            Text("\(pet.breed) • \(pet.ageString)")
                .font(.caption)
                .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
            
        }
        .padding()
        .frame(width: 180, alignment: .leading)
        .background(isSelected ? Color.accentColor : Color(.secondarySystemBackground))
        .cornerRadius(16)
        .shadow(color: isSelected ? .accentColor.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
    }
    
}

// MARK: - Cartão de Resumo
struct PetSummaryCard: View {
    let pet: Pet
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Resumo de Saúde")
                .font(.title3)
                .bold()
            
            HStack {
                Label("Microchip", systemImage: "cpu")
                    .foregroundColor(.secondary)
                Spacer()
                Text(pet.microchipNumber.isEmpty ? "Não registado" : pet.microchipNumber)
                    .bold()
            }
            
            Divider()
            
            HStack {
                Label("Próxima Vacina", systemImage: "cross.vial.fill")
                    .foregroundColor(.secondary)
                Spacer()
                if let vaccineDate = pet.nextVaccineDate {
                    Text(vaccineDate.formatted(date: .abbreviated, time: .omitted))
                        .bold()
                        .foregroundColor(.blue)
                } else {
                    Text("Sem agendamento")
                        .foregroundColor(.gray)
                }
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 6) {
                Label("Medicação & Desparasitação", systemImage: "pills.fill")
                    .foregroundColor(.secondary)
                
                Text(pet.medicationNotes ?? "Nenhuma indicação registada.")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .padding(.top, 2)
            }
            
            NavigationLink(destination: PetDetailView(pet: pet)) {
                HStack {
                    Text("Ver Ficha Completa")
                    Image(systemName: "chevron.right")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor.opacity(0.1))
                .foregroundColor(.accentColor)
                .cornerRadius(12)
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}
