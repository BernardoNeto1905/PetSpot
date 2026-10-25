//
//  PetDetailView.swift
//  PetSpot
//
//  Created by Bernardo
//

import SwiftUI

struct PetDetailView: View {
    let pet: Pet
    @State private var selectedTab = 1 // 1 corresponde a "Saúde & Vacinas"
    @Environment(\.dismiss) var dismiss // Para o botão de voltar funcionar corretamente

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // MARK: - Hero Header com Imagem
                ZStack(alignment: .bottomLeading) {
                    // Imagem de fundo (substitui por pet.imageName se usares URLs)
                    Image("dog_placeholder") // Podes trocar por uma propriedade do teu modelo Pet
                        .resizable()
                        .scaledToFill()
                        .frame(height: 320)
                        .clipped()

                    // Gradiente para legibilidade do texto
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.7)],
                        startPoint: .center,
                        endPoint: .bottom
                    )

                    // Informações do Pet sobre a imagem
                    VStack(alignment: .leading, spacing: 4) {
                        Text(pet.name)
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.white)

                        Text("\(pet.breed) • \(pet.ageString) • \(pet.gender)")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding()
                }
                .frame(height: 320)

                // MARK: - Abas Deslizantes (Sem a aba Diário, que foi para o Geral)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 24) {
                        TabButton(title: "Geral", isSelected: selectedTab == 0) { selectedTab = 0 }
                        TabButton(title: "Saúde & Vacinas", isSelected: selectedTab == 1) { selectedTab = 1 }
                        TabButton(title: "Documentos", isSelected: selectedTab == 2) { selectedTab = 2 }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
                .background(Color(.systemBackground))

                // MARK: - Conteúdo da Aba Selecionada
                VStack(spacing: 20) {
                    switch selectedTab {
                    case 0:
                        GeneralTab(pet: pet)
                    case 1:
                        HealthAndVaccinesTab(pet: pet)
                    case 2:
                        DocumentsTab(pet: pet)
                    default:
                        EmptyView()
                    }
                }
                .padding()
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss() // Faz voltar à página anterior da lista
                }) {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(8)
                        .background(Color(.systemBackground).opacity(0.8))
                        .clipShape(Circle())
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "pencil")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(8)
                        .background(Color(.systemBackground).opacity(0.8))
                        .clipShape(Circle())
                }
            }
        }
    }
}

// MARK: - Componente para o Botão das Tabs
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
                    .foregroundColor(isSelected ? Color(.systemGreen) : .secondary)

                Rectangle()
                    .fill(isSelected ? Color(.systemGreen) : Color.clear)
                    .frame(height: 3)
                    .cornerRadius(1.5)
            }
        }
    }
}

// MARK: - Aba Geral (Com o Diário/Notas no final)
struct GeneralTab: View {
    let pet: Pet

    var body: some View {
        VStack(spacing: 16) {
            // Informações gerais do pet (podes personalizar com mais detalhes se necessário)
            VStack(alignment: .leading, spacing: 12) {
                Text("Informações do Animal")
                    .font(.headline)
                    .fontWeight(.bold)

                HStack {
                    Text("Raça:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(pet.breed)
                        .fontWeight(.medium)
                }

                Divider()

                HStack {
                    Text("Idade:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(pet.ageString)
                        .fontWeight(.medium)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(16)

            // Diário / Notas de Medicação e Cuidados Especiais (movido para aqui)
            VStack(alignment: .leading, spacing: 8) {
                Label("Diário, Medicação & Cuidados Especiais", systemImage: "book.closed.fill")
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(pet.medicationNotes ?? "Sem notas de diário, medicação ou alergias registadas.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(16)
        }
    }
}

// MARK: - Aba de Saúde & Vacinas
struct HealthAndVaccinesTab: View {
    let pet: Pet

    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: "cpu")
                        .foregroundColor(.green)
                    Text("Microchip #\(pet.microchipNumber.isEmpty ? "Não registado" : pet.microchipNumber)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }

                HStack(spacing: 12) {
                    Image(systemName: "scalemass")
                        .foregroundColor(.green)
                    Text("Peso: 28.5 kg")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }

                HStack(spacing: 12) {
                    Image(systemName: "drop")
                        .foregroundColor(.green)
                    Text("Grupo Sanguíneo: DEA 1.1")
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
                        .foregroundColor(.orange)
                        .padding(10)
                        .background(Color.orange.opacity(0.15))
                        .cornerRadius(12)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Vacina da Raiva")
                            .font(.subheadline)
                            .fontWeight(.bold)
                        Text("Vence em 15 dias")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }

                Spacer()

                Button(action: {}) {
                    Text("Agendar")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                }
            }
            .padding()
            .background(Color(.systemOrange).opacity(0.1))
            .cornerRadius(16)

            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Historial clínico")
                        .font(.headline)
                        .fontWeight(.bold)
                    Spacer()
                    Text("2026")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                VStack(alignment: .leading, spacing: 0) {
                    ClinicalRow(
                        icon: "stethoscope",
                        title: "Consulta de rotina",
                        subtitle: "Dr.ª Ana Costa · Check-up sem alterações",
                        date: "22 Set",
                        isLast: false
                    )
                    ClinicalRow(
                        icon: "pill",
                        title: "Desparasitação interna",
                        subtitle: "Milbemax · 1 comprimido a cada 3 meses",
                        date: "10 Ago",
                        isLast: false
                    )
                    ClinicalRow(
                        icon: "cross.vial",
                        title: "Vacinação polivalente",
                        subtitle: "Reforço anual · Próxima dose em jun. 2027",
                        date: "14 Jun",
                        isLast: true
                    )
                }
            }
            .padding()
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
                .foregroundColor(.green)
                .cornerRadius(16)
            }
            .padding(.top, 8)
        }
    }
}

// MARK: - Linha do Historial Clínico
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
                    .foregroundColor(.green)
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
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(date)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.bottom, isLast ? 0 : 12)
    }
}

// MARK: - Aba de Documentos
struct DocumentsTab: View {
    let pet: Pet
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Documentos Guardados")
                .font(.headline)

            VStack(spacing: 12) {
                DocumentRow(title: "Boletim de Vacinas", icon: "doc.text.fill", color: .blue)
                DocumentRow(title: "Seguro de Saúde", icon: "shield.fill", color: .green)
                DocumentRow(title: "Registo Municipal", icon: "building.2.fill", color: .orange)
            }

            Button(action: {}) {
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
