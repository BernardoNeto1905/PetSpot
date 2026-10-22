//
//  FirebasePetServie.swift
//  PetSpot
//
//  Created by Calvin Calvo on 22/10/2026.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

enum FirebasePetService {

    static func addPet(
        name: String,
        breed: String,
        birthDate: Date,
        microchipNumber: String,
        nextVaccineDate: Date?,
        medicationNotes: String?
    ) async throws {

        guard let userId = Auth.auth().currentUser?.uid else {
            throw PetServiceError.notAuthenticated
        }

        let petId = UUID().uuidString

        let data: [String: Any] = [
            "id": petId,
            "name": name,
            "breed": breed,
            "birthDate": Timestamp(date: birthDate),
            "microchipNumber": microchipNumber,
            "nextVaccineDate": nextVaccineDate.map {
                Timestamp(date: $0)
            } ?? NSNull(),
            "medicationNotes": medicationNotes ?? "",
            "createdAt": FieldValue.serverTimestamp()
        ]

        try await Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("pets")
            .document(petId)
            .setData(data)
    }
}

enum PetServiceError: LocalizedError {
    case notAuthenticated

    var errorDescription: String? {
        "É necessário iniciar sessão para guardar um animal."
    }
}
