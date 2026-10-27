//
//  EditProfileView.swift
//  PetSpot
//
//  Created by Calvin Calvo on 27/10/2026.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss

    let onProfileUpdated: (String, String) -> Void

    @State private var name = ""
    @State private var email = ""

    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var successMessage: String?

    private let petSpotGreen = Color(
        red: 0.0,
        green: 0.68,
        blue: 0.42
    )

    private var currentEmail: String {
        Auth.auth().currentUser?.email ?? ""
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(spacing: 12) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 90, height: 90)
                            .foregroundStyle(petSpotGreen)

                        Text("Editar perfil")
                            .font(.title2.bold())

                        Text("Atualiza os teus dados pessoais.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .listRowBackground(Color.clear)
                }

                Section("Dados pessoais") {
                    TextField("Nome completo", text: $name)
                        .textContentType(.name)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()

                    TextField("Endereço de email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                Section {
                    Button {
                        Task {
                            await saveProfile()
                        }
                    } label: {
                        HStack {
                            Spacer()

                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Guardar alterações")
                                    .fontWeight(.semibold)
                            }

                            Spacer()
                        }
                        .foregroundStyle(.white)
                        .padding(.vertical, 8)
                        .background(petSpotGreen)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(isLoading)
                    .listRowBackground(Color.clear)
                }

                if let successMessage {
                    Section {
                        Text(successMessage)
                            .foregroundStyle(.green)
                    }
                }
            }
            .navigationTitle("Editar perfil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .disabled(isLoading)
                }
            }
            .task {
                loadCurrentProfile()
            }
            .alert(
                "Não foi possível guardar",
                isPresented: Binding(
                    get: { errorMessage != nil },
                    set: { if !$0 { errorMessage = nil } }
                )
            ) {
                Button("OK", role: .cancel) {
                    errorMessage = nil
                }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    // MARK: - Carregar dados atuais

    private func loadCurrentProfile() {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "Não existe uma sessão iniciada."
            return
        }

        name = user.displayName ?? ""
        email = user.email ?? ""
    }

    // MARK: - Guardar alterações

    @MainActor
    private func saveProfile() async {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "Não existe uma sessão iniciada."
            return
        }

        let cleanName = name.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let cleanEmail = email.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).lowercased()

        guard !cleanName.isEmpty else {
            errorMessage = "Introduz o teu nome."
            return
        }

        guard cleanEmail.contains("@"),
              cleanEmail.contains(".") else {
            errorMessage = "Introduz um endereço de email válido."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            // Atualizar o nome no Firebase Authentication.
            let profileChange = user.createProfileChangeRequest()
            profileChange.displayName = cleanName
            try await profileChange.commitChanges()

            // Atualizar o email, apenas se tiver sido alterado.
            if cleanEmail != (user.email ?? "").lowercased() {
                try await user.updateEmail(to: cleanEmail)
            }

            // Atualizar os dados guardados no Firestore.
            try await Firestore.firestore()
                .collection("users")
                .document(user.uid)
                .setData([
                    "name": cleanName,
                    "email": cleanEmail
                ], merge: true)

            // Informar o perfil principal das alterações.
            onProfileUpdated(cleanName, cleanEmail)

            dismiss()
        } catch {
            errorMessage = friendlyErrorMessage(error)
        }
    }

    // MARK: - Mensagens de erro

    private func friendlyErrorMessage(_ error: Error) -> String {
        let nsError = error as NSError

        if nsError.domain == AuthErrorDomain,
           nsError.code == AuthErrorCode.requiresRecentLogin.rawValue {
            return """
            Por segurança, tens de iniciar sessão novamente \
            antes de alterar o email.
            """
        }

        if nsError.domain == AuthErrorDomain,
           nsError.code == AuthErrorCode.emailAlreadyInUse.rawValue {
            return "Este endereço de email já está associado a outra conta."
        }

        if nsError.domain == AuthErrorDomain,
           nsError.code == AuthErrorCode.invalidEmail.rawValue {
            return "O endereço de email não é válido."
        }

        return error.localizedDescription
    }
}
