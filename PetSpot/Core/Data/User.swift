//
//  User.swift
//  PetSpot
//
//  Created by Calvin Calvo on 21/10/2026.
//

import Foundation
import SwiftData

@Model
final class User {
    @Attribute(.unique) var id: String
    @Attribute(.unique) var email: String

    var name: String
    var profileImageName: String?
    var createAt: Date

    var passwordHash: String
    var passwordSalt: String

    init(
        id: String = UUID().uuidString,
        name: String,
        email: String,
        profileImageName: String? = nil,
        createAt: Date = .now,
        passwordHash: String,
        passwordSalt: String
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.profileImageName = profileImageName
        self.createAt = createAt
        self.passwordHash = passwordHash
        self.passwordSalt = passwordSalt
    }
}

