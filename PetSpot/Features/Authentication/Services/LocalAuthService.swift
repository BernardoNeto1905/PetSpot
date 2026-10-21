//
//  LocalAuthService.swift
//  PetSpot
//
//  Created by Calvin Calvo on 21/10/2026.
//


import Foundation
import SwiftData
import CryptoKit
import Security

enum LocalAuthError: LocalizedError {
    case invalidEmail
    case weakPassword
    case emptyName
    case emailAlreadyExists
    case invalidCredentials
    case securityFailure

    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Introduz um email válido."
        case .weakPassword:
            return "A palavra-passe deve ter pelo menos 8 caracteres."
        case .emptyName:
            return "Introduz o teu nome."
        case .emailAlreadyExists:
            return "Já existe uma conta com este email."
        case .invalidCredentials:
            return "Email ou palavra-passe incorretos."
        case .securityFailure:
            return "Não foi possível criar as credenciais."
        }
    }
}

@MainActor
enum LocalAuthService {

    static func register(
        name: String,
        email: String,
        password: String,
        context: ModelContext
    ) throws -> User {
        let cleanName = name.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        let cleanEmail = email.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).lowercased()

        guard !cleanName.isEmpty else {
            throw LocalAuthError.emptyName
        }

        guard cleanEmail.contains("@"),
              cleanEmail.split(separator: "@").count == 2,
              cleanEmail.split(separator: "@").last?.contains(".") == true
        else {
            throw LocalAuthError.invalidEmail
        }

        guard password.count >= 8 else {
            throw LocalAuthError.weakPassword
        }

        guard try findUser(
            email: cleanEmail,
            context: context
        ) == nil else {
            throw LocalAuthError.emailAlreadyExists
        }

        var saltBytes = [UInt8](repeating: 0, count: 16)
        let status = SecRandomCopyBytes(
            kSecRandomDefault,
            saltBytes.count,
            &saltBytes
        )

        guard status == errSecSuccess else {
            throw LocalAuthError.securityFailure
        }

        let salt = Data(saltBytes)
        let hash = passwordHash(password, salt: salt)

        let user = User(
            name: cleanName,
            email: cleanEmail,
            passwordHash: hash,
            passwordSalt: salt.base64EncodedString()
        )

        context.insert(user)
        try context.save()

        return user
    }

    static func login(
        email: String,
        password: String,
        context: ModelContext
    ) throws -> User {
        let cleanEmail = email.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).lowercased()

        guard let user = try findUser(
            email: cleanEmail,
            context: context
        ),
        let salt = Data(
            base64Encoded: user.passwordSalt
        ) else {
            throw LocalAuthError.invalidCredentials
        }

        let hash = passwordHash(password, salt: salt)

        guard hash == user.passwordHash else {
            throw LocalAuthError.invalidCredentials
        }

        return user
    }

    static func findUser(
        email: String,
        context: ModelContext
    ) throws -> User? {
        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate<User> {
                $0.email == email
            }
        )

        return try context.fetch(descriptor).first
    }

    static func findUser(
        id: String,
        context: ModelContext
    ) throws -> User? {
        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate<User> {
                $0.id == id
            }
        )

        return try context.fetch(descriptor).first
    }

    private static func passwordHash(
        _ password: String,
        salt: Data
    ) -> String {
        var data = Data()
        data.append(salt)
        data.append(contentsOf: password.utf8)

        let digest = SHA256.hash(data: data)
        return Data(digest).base64EncodedString()
    }
}
