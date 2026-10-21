//
//  AuthView.swift
//  PetSpot
//
//  Created by Bernardo on 20/10/2026.
//

import SwiftUI
import SwiftData

struct AuthView: View {
    @Binding var isAuthenticated: Bool

    @Environment(\.modelContext) private var modelContext

    @AppStorage("currentUserID")
    private var currentUserID = ""

    @AppStorage("currentUserName")
    private var currentUserName = "Utilizador"

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var isSignUp = false

    @State private var showAlert = false
    @State private var alertMessage = ""

    private let petSpotGreen = Color(
        red: 0.0,
        green: 0.68,
        blue: 0.42
    )

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {

                    // Logótipo
                    HStack(spacing: 8) {
                        Image(systemName: "pawprint.circle.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(petSpotGreen)

                        Text("PetSpot")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(petSpotGreen)
                    }
                    .padding(.top, 20)

                    VStack(spacing: 6) {
                        Text(
                            isSignUp
                            ? "Cria a tua conta"
                            : "Bem-vindo ao PetSpot"
                        )
                        .font(.title2.bold())

                        Text(
                            "Cuidar do teu melhor amigo nunca foi tão fácil."
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    }

                    VStack(spacing: 12) {

                        if isSignUp {
                            inputField(
                                icon: "person",
                                placeholder: "Nome Completo",
                                text: $name
                            )
                        }

                        inputField(
                            icon: "envelope",
                            placeholder: "E-mail",
                            text: $email
                        )

                        HStack(spacing: 12) {
                            Image(systemName: "lock")
                                .foregroundStyle(.gray)
                                .frame(width: 20)

                            Group {
                                if isPasswordVisible {
                                    TextField(
                                        "Palavra-passe",
                                        text: $password
                                    )
                                } else {
                                    SecureField(
                                        "Palavra-passe",
                                        text: $password
                                    )
                                }
                            }
                            .textContentType(
                                isSignUp ? .newPassword : .password
                            )

                            Button {
                                isPasswordVisible.toggle()
                            } label: {
                                Image(
                                    systemName: isPasswordVisible
                                    ? "eye"
                                    : "eye.slash"
                                )
                                .foregroundStyle(.gray)
                            }
                        }
                        .padding()
                        .background(fieldBorder)

                    }

                    Button {
                        handleAuthentication()
                    } label: {
                        Text(
                            isSignUp
                            ? "Criar Conta"
                            : "Iniciar Sessão"
                        )
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(petSpotGreen)
                        .clipShape(Capsule())
                    }

                    HStack(spacing: 4) {
                        Text(
                            isSignUp
                            ? "Já tens conta no PetSpot?"
                            : "Ainda não tens conta no PetSpot?"
                        )
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)

                        Button(
                            isSignUp
                            ? "Inicia Sessão"
                            : "Regista-te"
                        ) {
                            withAnimation {
                                isSignUp.toggle()
                                password = ""
                            }
                        }
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(petSpotGreen)
                    }
                }
                .padding(.horizontal, 24)
            }
            .alert("PetSpot", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
    }

    private var fieldBorder: some View {
        RoundedRectangle(cornerRadius: 14)
            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
    }

    private func inputField(
        icon: String,
        placeholder: String,
        text: Binding<String>
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.gray)
                .frame(width: 20)

            TextField(placeholder, text: text)
                .autocorrectionDisabled()
        }
        .padding()
        .background(fieldBorder)
    }

    // MARK: - Autenticação

    private func handleAuthentication() {
        do {
            let user: User

            if isSignUp {
                user = try LocalAuthService.register(
                    name: name,
                    email: email,
                    password: password,
                    context: modelContext
                )
            } else {
                user = try LocalAuthService.login(
                    email: email,
                    password: password,
                    context: modelContext
                )
            }

            // Guardar sessão do utilizador autenticado
            currentUserID = user.id
            currentUserName = user.name

            password = ""
            isAuthenticated = true

        } catch {
            alertMessage = error.localizedDescription
            showAlert = true
        }
    }
}
