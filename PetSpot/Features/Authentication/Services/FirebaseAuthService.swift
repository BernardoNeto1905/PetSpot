//
//  FirebaseAuthService.swift
//  PetSpot
//
//  Created by Calvin Calvo on 22/10/2026.
//


import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
enum FirebaseAuthService {

    static func register(
        name: String,
        email: String,
        password: String
    ) async throws -> FirebaseAuth.User {

        let cleanName = name.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let cleanEmail = email.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).lowercased()

        guard !cleanName.isEmpty else {
            throw AuthValidationError.emptyName
        }

        guard password.count >= 8 else {
            throw AuthValidationError.weakPassword
        }

        let result = try await Auth.auth().createUser(
            withEmail: cleanEmail,
            password: password
        )

        let user = result.user

        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = cleanName
        try await changeRequest.commitChanges()

        try await Firestore.firestore()
            .collection("users")
            .document(user.uid)
            .setData([
                "name": cleanName,
                "email": cleanEmail,
                "createdAt": FieldValue.serverTimestamp()
            ])
        
        PushNotificationService.shared.syncTokenForCurrentUser()

        return user
    }

    static func login(
        email: String,
        password: String
    ) async throws -> FirebaseAuth.User {

        let result = try await Auth.auth().signIn(
            withEmail: email.trimmingCharacters(
                in: .whitespacesAndNewlines
            ),
            password: password
        )
        
        PushNotificationService.shared.syncTokenForCurrentUser()

        return result.user
    }

    static func logout() throws {
        try Auth.auth().signOut()
    }
}

enum AuthValidationError: LocalizedError {
    case emptyName
    case weakPassword

    var errorDescription: String? {
        switch self {
        case .emptyName:
            return "Introduz o teu nome."
        case .weakPassword:
            return "A palavra-passe deve ter pelo menos 8 caracteres."
        }
    }
}
