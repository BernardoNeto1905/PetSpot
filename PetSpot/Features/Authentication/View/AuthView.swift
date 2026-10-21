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
    
    @State private var name = ""
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
                        
                        // Campo Nome (Visível apenas ao Criar Conta / Registo)
                        if isSignUp {
                            HStack(spacing: 12) {
                                Image(systemName: "person")
                                    .foregroundColor(.gray)
                                    .frame(width: 20)
                                
                                TextField("Nome Completo", text: $name)
                                    .textInputAutocapitalization(.words)
                                    .autocorrectionDisabled()
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                        
                        // Campo E-mail
                        HStack(spacing: 12) {
                            Image(systemName: "envelope")
                                .foregroundColor(.gray)
                                .frame(width: 20)
                            
                            TextField("E-mail", text: $email)
                            #if os(iOS)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                            #endif
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
                                    
                                    // Tenta obter o nome da conta Apple ou usa um fallback amigável
                                    let appleName = [appleIDCredential.fullName?.givenName, appleIDCredential.fullName?.familyName]
                                        .compactMap { $0 }
                                        .joined(separator: " ")
                                    
                                    let finalName = appleName.isEmpty ? (name.isEmpty ? "Utilizador" : name) : appleName
                                    
                                    saveUserSession(name: finalName, email: userEmail)
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
                        let googleName = name.isEmpty ? "Utilizador Google" : name
                        saveUserSession(name: googleName, email: "utilizador@google.com")
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
        let displayName = name.trimmingCharacters(in: .whitespaces).isEmpty ? "Utilizador" : name
        
        let newUser = User(id: UUID().uuidString,
                           name: displayName,
                           email: email,
                           profileImageName: nil,
                           createAt: Foundation.Date.now)
        
        modelContext.insert(newUser)
        try? modelContext.save()
        
        currentUserName = displayName
        
        DispatchQueue.main.async {
            isAuthenticated = true
        }
    }
    
    // Login por E-mail
    private func handleCustomLogin() {
        if isSignUp {
            // No registo, usa o nome do campo se preenchido, caso contrário extrai do e-mail
            let finalName = name.trimmingCharacters(in: .whitespaces).isEmpty ?
                (email.components(separatedBy: "@").first?.capitalized ?? "Utilizador") : name
            saveUserSession(name: finalName, email: email)
        } else {
            // No login tradicional, extrai o nome do e-mail ou usa "Utilizador"
            let extractedName = email.components(separatedBy: "@").first?.capitalized ?? "Utilizador"
            saveUserSession(name: extractedName, email: email)
        }
    }
}
