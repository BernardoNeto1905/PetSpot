//
//  Pet.swift
//  PetSpot
//
//  Created by Bernardo on 10/10/2026.
//

import Foundation
import FirebaseFirestore

struct Pet: Identifiable, Codable, Equatable {

    var id: String
    var name: String
    var species: String
    var breed: String
    var birthDate: Date
    var gender: String
    var microchipNumber: String
    var nextVaccineDate: Date?
    var medicationNotes: String?
    var userId: String

    init(
        id: String = UUID().uuidString,
        name: String,
        species: String,
        breed: String,
        birthDate: Date,
        gender: String,
        microchipNumber: String,
        nextVaccineDate: Date? = nil,
        medicationNotes: String? = nil,
        userId: String
    ) {
        self.id = id
        self.name = name
        self.species = species
        self.breed = breed
        self.birthDate = birthDate
        self.gender = gender
        self.microchipNumber = microchipNumber
        self.nextVaccineDate = nextVaccineDate
        self.medicationNotes = medicationNotes
        self.userId = userId
    }

    // MARK: - Idade

    var ageString: String {
        let components = Calendar.current.dateComponents(
            [.year, .month],
            from: birthDate,
            to: Date()
        )

        let years = max(0, components.year ?? 0)
        let months = max(0, components.month ?? 0)

        if years > 0 {
            return "\(years) ano\(years > 1 ? "s" : "")"
        } else {
            return "\(months) \(months == 1 ? "mês" : "meses")"
        }
    }
}
