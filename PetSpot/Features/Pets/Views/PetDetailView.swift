//
//  PetDetailView.swift
//  PetSpot
//
//  Created by Bernardo
//

import SwiftUI
import UIKit

struct PetDetailView: View {
    @State private var pet : Pet
    @State private var isEditingPet = false
    
    init(pet: Pet) {
        _pet = State(initialValue: pet)
    }
 
    @State private var selectedTab = 0
    @Environment(\.dismiss) private var dismiss

    // MARK: - Verificar se é uma cadela

    private var isFemaleDog: Bool {
        let species = pet.species
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(
                options: [.diacriticInsensitive, .caseInsensitive],
                locale: .current
            )

        let gender = pet.gender
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(
                options: [.diacriticInsensitive, .caseInsensitive],
                locale: .current
            )

        return ["cao", "cachorro", "dog"].contains(species)
            && ["femea", "feminino", "female"].contains(gender)
    }

    // MARK: - Abas disponíveis

    private var availableTabs: [(title: String, index: Int)] {
        var tabs: [(title: String, index: Int)] = [
            ("Geral", 0),
            ("Saúde & Vacinas", 1),
            ("Documentos", 2)
        ]

        if isFemaleDog {
            tabs.append(("Ciclo", 3))
        }

        return tabs
    }

    // MARK: - Largura dos títulos

    private var totalTabWidth: CGFloat {
        let spacing: CGFloat = 20

        let titlesWidth = availableTabs.reduce(CGFloat.zero) {
            $0 + $1.title.tabTitleWidth
        }

        let totalSpacing = CGFloat(max(availableTabs.count - 1, 0)) * spacing

        return titlesWidth + totalSpacing
    }

    // MARK: - Interface

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {

                // MARK: Cabeçalho do animal

                ZStack(alignment: .bottomLeading) {
                    Image("dog_placeholder")
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 320)
                        .clipped()

                    LinearGradient(
                        colors: [.clear, .black.opacity(0.7)],
                        startPoint: .center,
                        endPoint: .bottom
                    )

                    VStack(alignment: .leading, spacing: 4) {
                        Text(pet.name)
                            .font(.system(size: 34, weight: .bold))
                            .foregroundStyle(.white)

                        Text("\(pet.breed) • \(pet.ageString) • \(pet.gender)")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    .padding()
                }
                .frame(height: 320)

                // MARK: Separadores centrados

                GeometryReader { geometry in
                    let horizontalPadding: CGFloat = 16
                    let spacing: CGFloat = 20
                    let availableWidth = geometry.size.width - horizontalPadding * 2

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: spacing) {
                            ForEach(availableTabs, id: \.index) { tab in
                                TabButton(
                                    title: tab.title,
                                    isSelected: selectedTab == tab.index
                                ) {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedTab = tab.index
                                    }
                                }
                                .fixedSize(horizontal: true, vertical: false)
                            }
                        }
                        .frame(
                            minWidth: max(0, availableWidth),
                            alignment: totalTabWidth <= availableWidth
                                ? .center
                                : .leading
                        )
                        .padding(.horizontal, horizontalPadding)
                        .padding(.vertical, 12)
                    }
                    .background(Color(.systemBackground))
                }
                .frame(height: 52)

                // MARK: Conteúdo das abas

                VStack(spacing: 20) {
                    switch selectedTab {
                    case 0:
                        GeneralTab(pet: pet)

                    case 1:
                        HealthAndVaccinesTab(pet: pet)

                    case 2:
                        DocumentsTab(pet: pet)

                    case 3 where isFemaleDog:
                        ReproductiveCycleView(pet: pet)

                    default:
                        GeneralTab(pet: pet)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .padding(8)
                        .background(
                            Color(.systemBackground).opacity(0.8)
                        )
                        .clipShape(Circle())
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isEditingPet = true
                } label: {
                    Image(systemName: "pencil")
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .padding(8)
                        .background(
                            Color(.systemBackground).opacity(0.8)
                        )
                        .clipShape(Circle())
                }
            }
        }
        
        .sheet(isPresented: $isEditingPet, onDismiss: {
            Task {
                await refreshPet()
            }
        }) {
            AddPetView(pet: pet)
        }
    }
    
    @MainActor
    private func refreshPet() async {
        do {
            let updatedPets = try await PetService.fetchPets()

            if let updatedPet = updatedPets.first(
                where: { $0.id == pet.id }
            ) {
                pet = updatedPet
            }
        } catch {
            // Mantém os dados atuais se não for possível atualizar.
        }
    }
}

// MARK: - Largura de cada título

private extension String {
    var tabTitleWidth: CGFloat {
        let font = UIFont.systemFont(ofSize: 15, weight: .regular)

        return (self as NSString)
            .size(withAttributes: [.font: font])
            .width + 2
    }
}

// MARK: - Botão das abas

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundStyle(
                        isSelected ? Color.green : Color.secondary
                    )
                    .fixedSize(horizontal: true, vertical: false)

                Rectangle()
                    .fill(isSelected ? Color.green : Color.clear)
                    .frame(height: 3)
                    .cornerRadius(1.5)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Aba Geral

struct GeneralTab: View {
    let pet: Pet

    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Informações do Animal")
                    .font(.headline)
                    .fontWeight(.bold)

                HStack {
                    Text("Raça:")
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text(pet.breed)
                        .fontWeight(.medium)
                }

                Divider()

                HStack {
                    Text("Idade:")
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text(pet.ageString)
                        .fontWeight(.medium)
                }

                Divider()

                HStack {
                    Text("Sexo:")
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text(pet.gender)
                        .fontWeight(.medium)
                }

                Divider()

                HStack {
                    Text("Espécie:")
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text(pet.species)
                        .fontWeight(.medium)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(16)

            VStack(alignment: .leading, spacing: 8) {
                Label(
                    "Diário, Medicação & Cuidados Especiais",
                    systemImage: "book.closed.fill"
                )
                .font(.headline)
                .foregroundStyle(.primary)

                Text(
                    pet.medicationNotes
                    ?? "Sem notas de diário, medicação ou alergias registadas."
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(16)
        }
    }
}

// MARK: - Aba Saúde & Vacinas

struct HealthAndVaccinesTab: View {
    let pet: Pet

    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: "cpu")
                        .foregroundStyle(.green)

                    let microchipText = pet.microchipNumber.isEmpty
                        ? "Não registado"
                        : pet.microchipNumber

                    Text("Microchip #\(microchipText)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }

                HStack(spacing: 12) {
                    Image(systemName: "scalemass")
                        .foregroundStyle(.green)

                    Text("Peso: Não registado")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }

                HStack(spacing: 12) {
                    Image(systemName: "drop")
                        .foregroundStyle(.green)

                    Text("Grupo Sanguíneo: Não registado")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(16)

            HStack {
                HStack(spacing: 12) {
                    Image(systemName: "cross.case.fill")
                        .font(.title2)
                        .foregroundStyle(.orange)
                        .padding(10)
                        .background(Color.orange.opacity(0.15))
                        .cornerRadius(12)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Vacinas")
                            .font(.subheadline)
                            .fontWeight(.bold)

                        Text("Regista e acompanha as vacinas do teu animal.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer(minLength: 0)
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(16)

            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Historial clínico")
                        .font(.headline)
                        .fontWeight(.bold)

                    Spacer()

                    Text("Registos")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Text("Ainda não existem registos clínicos apresentados nesta secção.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(16)

            Button(action: {}) {
                HStack {
                    Image(systemName: "arrow.down.doc")

                    Text("Descarregar PDF")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green.opacity(0.15))
                .foregroundStyle(.green)
                .cornerRadius(16)
            }
            .padding(.top, 8)
        }
    }
}

// MARK: - Linha do historial clínico

struct ClinicalRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let date: String
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 0) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(.green)
                    .padding(8)
                    .background(Color.green.opacity(0.15))
                    .clipShape(Circle())

                if !isLast {
                    Rectangle()
                        .fill(Color.green.opacity(0.3))
                        .frame(width: 2, height: 35)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(date)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.bottom, isLast ? 0 : 12)
    }
}

// MARK: - Aba Documentos

struct DocumentsTab: View {
    let pet: Pet

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Documentos Guardados")
                .font(.headline)

            VStack(spacing: 12) {
                DocumentRow(
                    title: "Boletim de Vacinas",
                    icon: "doc.text.fill",
                    color: .blue
                )

                DocumentRow(
                    title: "Seguro de Saúde",
                    icon: "shield.fill",
                    color: .green
                )

                DocumentRow(
                    title: "Registo Municipal",
                    icon: "building.2.fill",
                    color: .orange
                )
            }

            Button(action: {}) {
                Label(
                    "Adicionar Documento",
                    systemImage: "doc.badge.plus"
                )
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundStyle(.white)
                .cornerRadius(12)
            }
            .padding(.top, 8)
        }
    }
}

// MARK: - Linha de documento

struct DocumentRow: View {
    let title: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.title3)

            Text(title)
                .font(.subheadline)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.gray)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}
