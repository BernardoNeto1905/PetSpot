//
//  CommunityService.swift
//  PetSpot
//
//  Created by Bernardo Neto on 12/11/2026.
//


import Foundation
import FirebaseFirestore

// MARK: - Tipo de conteúdo

enum CommunityItemType: String, CaseIterable, Identifiable {
    case post = "post"
    case alert = "alert"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .post:
            return "Publicação"
        case .alert:
            return "Alerta"
        }
    }
}

// MARK: - Categoria

enum CommunityCategory: String, CaseIterable, Identifiable {
    case general = "Geral"
    case lostPets = "Pets Perdidos"
    case meetups = "Encontros"
    case tips = "Dicas"

    var id: String { rawValue }
}

// MARK: - Modelo da Community

struct CommunityItem: Identifiable, Equatable {

    var id: String
    var type: CommunityItemType
    var category: CommunityCategory

    // Autor
    var authorId: String
    var authorName: String

    // Conteúdo
    var content: String
    var imageURL: String?

    // Animal associado
    var petID: String?
    var petName: String?
    var petType: String?
    var petDescription: String?

    // Informações de localização e contacto
    var location: String?
    var lastSeenDate: Date?
    var contact: String?

    // Informação adicional
    var createdAt: Date
    var likesCount: Int
    var commentsCount: Int
    var isResolved: Bool

    init(
        id: String = UUID().uuidString,
        type: CommunityItemType,
        category: CommunityCategory,
        authorId: String,
        authorName: String,
        content: String,
        imageURL: String? = nil,
        petID: String? = nil,
        petName: String? = nil,
        petType: String? = nil,
        petDescription: String? = nil,
        location: String? = nil,
        lastSeenDate: Date? = nil,
        contact: String? = nil,
        createdAt: Date = Date(),
        likesCount: Int = 0,
        commentsCount: Int = 0,
        isResolved: Bool = false
    ) {
        self.id = id
        self.type = type
        self.category = category
        self.authorId = authorId
        self.authorName = authorName
        self.content = content
        self.imageURL = imageURL
        self.petID = petID
        self.petName = petName
        self.petType = petType
        self.petDescription = petDescription
        self.location = location
        self.lastSeenDate = lastSeenDate
        self.contact = contact
        self.createdAt = createdAt
        self.likesCount = likesCount
        self.commentsCount = commentsCount
        self.isResolved = isResolved
    }

    // MARK: - Converter documento Firestore para modelo

    init?(id: String, data: [String: Any]) {

        guard
            let typeString = data["type"] as? String,
            let type = CommunityItemType(rawValue: typeString),
            let categoryString = data["category"] as? String,
            let category = CommunityCategory(rawValue: categoryString),
            let authorId = data["authorId"] as? String,
            let authorName = data["authorName"] as? String,
            let content = data["content"] as? String
        else {
            return nil
        }

        self.id = id
        self.type = type
        self.category = category
        self.authorId = authorId
        self.authorName = authorName
        self.content = content

        self.imageURL = data["imageURL"] as? String

        self.petID = data["petID"] as? String
        self.petName = data["petName"] as? String
        self.petType = data["petType"] as? String
        self.petDescription = data["petDescription"] as? String

        self.location = data["location"] as? String
        self.contact = data["contact"] as? String

        if let timestamp = data["lastSeenDate"] as? Timestamp {
            self.lastSeenDate = timestamp.dateValue()
        } else {
            self.lastSeenDate = data["lastSeenDate"] as? Date
        }

        if let timestamp = data["createdAt"] as? Timestamp {
            self.createdAt = timestamp.dateValue()
        } else if let date = data["createdAt"] as? Date {
            self.createdAt = date
        } else {
            self.createdAt = Date()
        }

        self.likesCount = data["likesCount"] as? Int ?? 0
        self.commentsCount = data["commentsCount"] as? Int ?? 0
        self.isResolved = data["isResolved"] as? Bool ?? false
    }

    // MARK: - Converter modelo para Firestore

    var firestoreData: [String: Any] {
        [
            "id": id,
            "type": type.rawValue,
            "category": category.rawValue,
            "authorId": authorId,
            "authorName": authorName,
            "content": content,
            "imageURL": imageURL as Any? ?? NSNull(),
            "petID": petID as Any? ?? NSNull(),
            "petName": petName as Any? ?? NSNull(),
            "petType": petType as Any? ?? NSNull(),
            "petDescription": petDescription as Any? ?? NSNull(),
            "location": location as Any? ?? NSNull(),
            "lastSeenDate": lastSeenDate as Any? ?? NSNull(),
            "contact": contact as Any? ?? NSNull(),
            "createdAt": createdAt,
            "likesCount": likesCount,
            "commentsCount": commentsCount,
            "isResolved": isResolved
        ]
    }
}
