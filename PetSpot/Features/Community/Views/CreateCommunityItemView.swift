//
//  CreateCommunityItemView.swift
//  PetSpot
//
//  Created by Bernardo Neto on 12/11/2026.
//

import SwiftUI
import FirebaseAuth

struct CreateCommunityItemView: View {

    @Environment(\.dismiss) private var dismiss

    @AppStorage("currentUserName")
    private var currentUserName = "Utilizador"

    let onSave: (CommunityItem) async throws -> Void

    @State private var selectedType: CommunityItemType = .post
    @State private var selectedCategory: CommunityCategory = .general

    @State private var content = ""

    // Informação do animal perdido
    @State private var petName = ""
    @State private var petType = "Cão"
    @State private var petDescription = ""
    @State private var location = ""
    @State private var lastSeenDate = Date()
    @State private var contact = ""

    @State private var isSaving = false
    @State private var errorMessage: String?

    private let petTypes = ["Cão", "Gato", "Outro"]

    private let normalCategories: [CommunityCategory] = [
        .general,
        .meetups,
        .tips
    ]

    private let petSpotGreen = Color(
        red: 0.0,
        green: 0.65,
        blue: 0.45
    )

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    typeSection

                    if selectedType == .post {
                        postSection
                    } else {
                        alertSection
                    }

                    publishButton
                }
                .padding(20)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Nova publicação")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .foregroundStyle(petSpotGreen)
                    .disabled(isSaving)
                }
            }
            .alert("Não foi possível publicar", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {
                    errorMessage = nil
                }
            } message: {
                Text(errorMessage ?? "Ocorreu um erro.")
            }
        }
    }

    // MARK: - Tipo de publicação

    private var typeSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("O que pretendes partilhar?")
                .font(.headline)

            Picker("Tipo de publicação", selection: $selectedType) {
                ForEach(CommunityItemType.allCases) { type in
                    Text(type.title).tag(type)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedType) { _, newValue in
                if newValue == .alert {
                    selectedCategory = .lostPets
                } else {
                    selectedCategory = .general
                }
            }

            HStack(spacing: 10) {
                Image(systemName: selectedType == .alert
                      ? "exclamationmark.triangle.fill"
                      : "text.bubble.fill")
                    .font(.title2)
                    .foregroundStyle(selectedType == .alert ? .red : petSpotGreen)

                Text(
                    selectedType == .alert
                    ? "Partilha informações sobre um animal desaparecido."
                    : "Partilha uma experiência, uma pergunta ou uma dica com a comunidade."
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Publicação normal

    private var postSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            sectionTitle("Detalhes da publicação", icon: "text.alignleft")

            VStack(alignment: .leading, spacing: 8) {
                fieldLabel("Categoria")

                Picker("Categoria", selection: $selectedCategory) {
                    ForEach(normalCategories) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                .pickerStyle(.menu)
                .tint(petSpotGreen)
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            VStack(alignment: .leading, spacing: 8) {
                fieldLabel("O que queres partilhar?")

                TextField(
                    "Escreve aqui a tua publicação...",
                    text: $content,
                    axis: .vertical
                )
                .lineLimit(5...9)
                .padding(14)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground).opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Alerta de animal perdido

    private var alertSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            sectionTitle("Informações do animal", icon: "pawprint.fill")

            VStack(alignment: .leading, spacing: 8) {
                fieldLabel("Nome do animal *")

                TextField("Ex.: Bobi", text: $petName)
                    .textFieldStyle(.plain)
                    .padding(14)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            VStack(alignment: .leading, spacing: 8) {
                fieldLabel("Tipo de animal *")

                Picker("Tipo de animal", selection: $petType) {
                    ForEach(petTypes, id: \.self) { type in
                        Text(type).tag(type)
                    }
                }
                .pickerStyle(.segmented)
            }

            VStack(alignment: .leading, spacing: 8) {
                fieldLabel("Descrição e características *")

                TextField(
                    "Raça, cor, tamanho, coleira ou outras características...",
                    text: $petDescription,
                    axis: .vertical
                )
                .lineLimit(3...6)
                .padding(14)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Divider()

            sectionTitle("Último avistamento", icon: "mappin.and.ellipse")

            VStack(alignment: .leading, spacing: 8) {
                fieldLabel("Localização *")

                TextField(
                    "Ex.: Parque da Paz, Almada",
                    text: $location
                )
                .textContentType(.fullStreetAddress)
                .padding(14)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            VStack(alignment: .leading, spacing: 8) {
                fieldLabel("Data e hora")

                DatePicker(
                    "Última vez visto",
                    selection: $lastSeenDate,
                    in: ...Date(),
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.compact)
                .tint(petSpotGreen)
            }

            Divider()

            sectionTitle("Contacto", icon: "phone.fill")

            VStack(alignment: .leading, spacing: 8) {
                fieldLabel("Contacto para ajudar *")

                TextField("Email ou número de telefone", text: $contact)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(14)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Label(
                "O contacto ficará visível para as pessoas que consultarem o alerta.",
                systemImage: "info.circle"
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground).opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Botão publicar

    private var publishButton: some View {
        Button {
            Task {
                await publishItem()
            }
        } label: {
            HStack(spacing: 10) {
                if isSaving {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "paperplane.fill")
                }

                Text(isSaving ? "A publicar..." : "Publicar")
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(petSpotGreen)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(isSaving)
    }

    // MARK: - Publicar no Firestore

    @MainActor
    private func publishItem() async {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "Tens de iniciar sessão para publicar."
            return
        }

        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                || selectedType == .alert else {
            errorMessage = "Escreve o conteúdo da publicação."
            return
        }

        if selectedType == .alert {
            guard
                !petName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                !petDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                !location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                !contact.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            else {
                errorMessage = "Preenche todos os campos obrigatórios do alerta."
                return
            }
        }

        let item = CommunityItem(
            type: selectedType,
            category: selectedType == .alert ? .lostPets : selectedCategory,
            authorId: user.uid,
            authorName: currentUserName,
            content: selectedType == .alert
                ? "Alerta de animal perdido: \(petName.trimmingCharacters(in: .whitespacesAndNewlines))"
                : content.trimmingCharacters(in: .whitespacesAndNewlines),            petName: selectedType == .alert ? petName : nil,
            petType: selectedType == .alert ? petType : nil,
            petDescription: selectedType == .alert ? petDescription : nil,
            location: selectedType == .alert ? location : nil,
            lastSeenDate: selectedType == .alert ? lastSeenDate : nil,
            contact: selectedType == .alert ? contact : nil
        )

        isSaving = true

        do {
            try await onSave(item)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }

        isSaving = false
    }

    // MARK: - Componentes auxiliares

    private func sectionTitle(_ title: String, icon: String) -> some View {
        Label(title, systemImage: icon)
            .font(.headline)
            .foregroundStyle(.primary)
    }

    private func fieldLabel(_ title: String) -> some View {
        Text(title)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(.secondary)
    }
}
