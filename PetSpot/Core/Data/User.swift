//
//  User.swift
//  PetSpot
//
//  Created by Calvin Calvo on 21/10/2026.
//
import Foundation
import SwiftData

@Model
final class User{
    @Attribute(.unique) var id: String
    var name: String
    var email: String
    var profileImageName: String?
    var createAt: Date
    
    init(id: String, name: String, email: String, profileImageName: String? = nil, createAt: Date) {
        self.id = id
        self.name = name
        self.email = email
        self.profileImageName = profileImageName
        self.createAt = createAt
    }
}
