//
//  CommunityItem.swift
//  PetSpot
//
//  Created by Bernardo Neto on 12/11/2026.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

enum CommunityService {

    private static let db = Firestore.firestore()

    // MARK: - Coleção

    private static var itemsCollection: CollectionReference {
        db.collection("communityItems")
    }

    // MARK: - Criar publicação ou alerta

    @discardableResult
    static func addItem(_ newItem: CommunityItem) async throws -> CommunityItem {

        guard let user = Auth.auth().currentUser else {
            throw CommunityServiceError.notAuthenticated
        }

        try validateItem(newItem)

        let document = itemsCollection.document()

        var item = newItem
        item.id = document.documentID
        item.authorId = user.uid
        item.createdAt = Date()
        item.likesCount = 0
        item.commentsCount = 0
        item.isResolved = false

        try await document.setData(item.firestoreData)

        return item
    }

    // MARK: - Carregar publicações

    static func fetchItems() async throws -> [CommunityItem] {

        guard Auth.auth().currentUser != nil else {
            throw CommunityServiceError.notAuthenticated
        }

        let snapshot = try await itemsCollection
            .order(by: "createdAt", descending: true)
            .getDocuments()

        return snapshot.documents.compactMap { document in
            CommunityItem(
                id: document.documentID,
                data: document.data()
            )
        }
    }

    // MARK: - Ouvir alterações em tempo real

    @discardableResult
    static func listenToItems(
        onUpdate: @escaping (Result<[CommunityItem], Error>) -> Void
    ) -> ListenerRegistration {

        itemsCollection
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in

                if let error {
                    DispatchQueue.main.async {
                        onUpdate(.failure(error))
                    }
                    return
                }

                guard let documents = snapshot?.documents else {
                    DispatchQueue.main.async {
                        onUpdate(.success([]))
                    }
                    return
                }

                let items = documents.compactMap { document in
                    CommunityItem(
                        id: document.documentID,
                        data: document.data()
                    )
                }

                DispatchQueue.main.async {
                    onUpdate(.success(items))
                }
            }
    }

    // MARK: - Atualizar publicação

    static func updateItem(_ item: CommunityItem) async throws {

        guard let user = Auth.auth().currentUser else {
            throw CommunityServiceError.notAuthenticated
        }

        try validateItem(item)

        let document = itemsCollection.document(item.id)

        let snapshot = try await document.getDocument()

        guard
            let data = snapshot.data(),
            let authorId = data["authorId"] as? String
        else {
            throw CommunityServiceError.itemNotFound
        }

        guard authorId == user.uid else {
            throw CommunityServiceError.unauthorized
        }

        try await document.setData(item.firestoreData)
    }

    // MARK: - Apagar publicação

    static func deleteItem(_ item: CommunityItem) async throws {

        guard let user = Auth.auth().currentUser else {
            throw CommunityServiceError.notAuthenticated
        }

        let document = itemsCollection.document(item.id)

        let snapshot = try await document.getDocument()

        guard
            let data = snapshot.data(),
            let authorId = data["authorId"] as? String
        else {
            throw CommunityServiceError.itemNotFound
        }

        guard authorId == user.uid else {
            throw CommunityServiceError.unauthorized
        }

        try await document.delete()
    }

    // MARK: - Validação

    private static func validateItem(
        _ item: CommunityItem
    ) throws {

        if item.type == .post {
            let content = item.content.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

            guard !content.isEmpty else {
                throw CommunityServiceError.emptyContent
            }
        }

        if item.type == .alert {

            guard item.category == .lostPets else {
                throw CommunityServiceError.invalidAlertCategory
            }

            let petName = item.petName?.trimmingCharacters(
                in: .whitespacesAndNewlines
            ) ?? ""

            let description = item.petDescription?.trimmingCharacters(
                in: .whitespacesAndNewlines
            ) ?? ""

            let location = item.location?.trimmingCharacters(
                in: .whitespacesAndNewlines
            ) ?? ""

            let contact = item.contact?.trimmingCharacters(
                in: .whitespacesAndNewlines
            ) ?? ""

            guard
                !petName.isEmpty,
                !description.isEmpty,
                !location.isEmpty,
                !contact.isEmpty
            else {
                throw CommunityServiceError.missingAlertInformation
            }
        }
    }
}

// MARK: - Erros

enum CommunityServiceError: LocalizedError {

    case notAuthenticated
    case unauthorized
    case itemNotFound
    case emptyContent
    case invalidAlertCategory
    case missingAlertInformation

    var errorDescription: String? {
        switch self {

        case .notAuthenticated:
            return "Não existe nenhum utilizador autenticado."

        case .unauthorized:
            return "Não tens autorização para alterar esta publicação."

        case .itemNotFound:
            return "A publicação não foi encontrada."

        case .emptyContent:
            return "Escreve uma mensagem antes de publicar."

        case .invalidAlertCategory:
            return "Os alertas têm de pertencer à categoria Pets Perdidos."

        case .missingAlertInformation:
            return "Preenche o nome do animal, a descrição, a localização e o contacto."
        }
    }
}
