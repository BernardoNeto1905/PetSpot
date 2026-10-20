//
//  AuthView.swift
//  PetSpot
//
//  Created by Bernardo on 20/10/2026.
//

import SwiftUI
import AuthenticationServices
import SwiftData

struct AuthView: View {
    @Binding var isAuthenticated: Bool
    
    @Environment(\.modelContext) private var modelContext
    @AppStorage("currentUserName") private var currentUserName: String = "Utilizador"
    
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var isSignUp = false
    
    // Cor verde principal do PetSpot
    private let petSpotGreen = Color(red: 0.0, green: 0.68, blue: 0.42)

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    // 1. Cabeçalho com Logótipo
                    HStack(spacing: 8) {
                        Image(systemName: "pawprint.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(petSpotGreen)
                        
                        Text("PetSpot")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(petSpotGreen)
                    }
                    .padding(.top, 10)
                    
                    // 2. Título e Subtítulo
                    VStack(spacing: 6) {
                        Text(isSignUp ? "Cria a tua conta" : "Bem-vindo ao PetSpot")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Cuidar do teu melhor amigo nunca foi tão fácil.")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    // 3. Campos de Texto
                    VStack(spacing: 12) {
                        // Campo E-mail
                        HStack(spacing: 12) {
                            Image(systemName: "envelope")
                                .foregroundColor(.gray)
                                .frame(width: 20)
                            
                            TextField("E-mail", text: $email)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        
                        // Campo Palavra-passe
                        HStack(spacing: 12) {
                            Image(systemName: "lock")
                                .foregroundColor(.gray)
                                .frame(width: 20)
                            
                            if isPasswordVisible {
                                TextField("Palavra-passe", text: $password)
                            } else {
                                SecureField("Palavra-passe", text: $password)
                            }
                            
                            Button(action: { isPasswordVisible.toggle() }) {
                                Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        
                        // Esqueceu-se da palavra-passe?
                        if !isSignUp {
                            HStack {
                                Spacer()
                                Button("Esqueceu-se da palavra-passe?") {
                                    // Ação para recuperar palavra-passe
                                }
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(petSpotGreen)
                            }
                        }
                    }
                    
                    // 4. Botão Principal "Iniciar Sessão / Criar Conta"
                    Button(action: handleCustomLogin) {
                        Text(isSignUp ? "Criar Conta" : "Iniciar Sessão")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(petSpotGreen)
                            .cornerRadius(26)
                    }
                    .padding(.top, 4)
                    
                    // 5. Divisória "ou continuar com"
                    HStack {
                        VStack { Divider() }
                        Text("ou continuar com")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                        VStack { Divider() }
                    }
                    .padding(.vertical, 4)
                    
                    // 6. Sign in with Apple
                    SignInWithAppleButton(
                        .continue,
                        onRequest: { request in
                            request.requestedScopes = [.fullName, .email]
                        },
                        onCompletion: { result in
                            switch result {
                            case .success(let authorization):
                                if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                                    let userEmail = appleIDCredential.email ?? email
                                    let givenName = appleIDCredential.fullName?.givenName ?? "Maria"
                                    
                                    // Guarda o utilizador no SwiftData e AppStorage
                                    saveUserSession(name: givenName, email: userEmail)
                                }
                            case .failure(let error):
                                print("Erro no Sign in with Apple: \(error.localizedDescription)")
                            }
                        }
                    )
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 50)
                    .cornerRadius(25)

                    // 7. Continuar com o Google
                    Button(action: {
                        saveUserSession(name: "Maria", email: "maria@google.com")
                    }) {
                        HStack(spacing: 10) {
                            Text("G").font(.system(size: 18, weight: .bold)).foregroundColor(.blue)
                            Text("Continuar com o Google").font(.system(size: 15, weight: .semibold)).foregroundColor(.black)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(RoundedRectangle(cornerRadius: 25).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    }
                    
                    // 8. Rodapé (Regista-te / Entrar)
                    HStack(spacing: 4) {
                        Text(isSignUp ? "Já tens conta no PetSpot?" : "Ainda não tens conta no PetSpot?")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                        
                        Button(isSignUp ? "Inicia Sessão" : "Regista-te") {
                            withAnimation {
                                isSignUp.toggle()
                            }
                        }
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(petSpotGreen)
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 24)
            }
        }
    }
    
    // Método auxiliar para criar/salvar o User e ativar a sessão
    private func saveUserSession(name: String, email: String) {
        let displayName = name.isEmpty ? "Maria" : name
        let newUser = User(name: displayName, email: email)
        modelContext.insert(newUser)
        try? modelContext.save()
        
        currentUserName = displayName
        
        DispatchQueue.main.async {
            isAuthenticated = true
        }
    }
    
    // Login por E-mail
    private func handleCustomLogin() {
        let extractedName = email.components(separatedBy: "@").first?.capitalized ?? "Maria"
        saveUserSession(name: extractedName, email: email)
    }
}