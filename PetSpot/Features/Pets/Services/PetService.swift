//
//  PetService.swift
//  PetSpot
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

enum PetService {

    private static let db = Firestore.firestore()

    private static func petsCollection(for userId: String) -> CollectionReference {
        db.collection("users")
            .document(userId)
            .collection("pets")
    }

    // MARK: - Adicionar animal

    static func addPet(
        name: String,
        species: String,
        breed: String,
        birthDate: Date,
        gender: String,
        microchipNumber: String,
        nextVaccineDate: Date?,
        medicationNotes: String?
    ) async throws -> Pet {

        guard let userId = Auth.auth().currentUser?.uid else {
            throw PetServiceError.notAuthenticated
        }

        let pet = Pet(
            name: name,
            species: species,
            breed: breed,
            birthDate: birthDate,
            gender: gender,
            microchipNumber: microchipNumber,
            nextVaccineDate: nextVaccineDate,
            medicationNotes: medicationNotes,
            userId: userId
        )

        try petsCollection(for: userId)
            .document(pet.id)
            .setData(from: pet)

        return pet
    }

    // MARK: - Obter animais

    static func fetchPets() async throws -> [Pet] {

        guard let userId = Auth.auth().currentUser?.uid else {
            throw PetServiceError.notAuthenticated
        }

        let snapshot = try await petsCollection(for: userId).getDocuments()

        return try snapshot.documents.map { document in
            try document.data(as: Pet.self)
        }
    }

    // MARK: - Editar animal

    static func updatePet(_ pet: Pet) async throws {

        guard let userId = Auth.auth().currentUser?.uid else {
            throw PetServiceError.notAuthenticated
        }

        guard pet.userId == userId else {
            throw PetServiceError.unauthorized
        }

        try petsCollection(for: userId)
            .document(pet.id)
            .setData(from: pet)
    }

    // MARK: - Eliminar animal

    static func deletePet(_ pet: Pet) async throws {

        guard let userId = Auth.auth().currentUser?.uid else {
            throw PetServiceError.notAuthenticated
        }

        guard pet.userId == userId else {
            throw PetServiceError.unauthorized
        }

        try await petsCollection(for: userId)
            .document(pet.id)
            .delete()
    }
}

// MARK: - Erros

enum PetServiceError: LocalizedError {

    case notAuthenticated
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Não existe nenhum utilizador autenticado."
        case .unauthorized:
            return "Não tens autorização para alterar este animal."
        }
    }
}
