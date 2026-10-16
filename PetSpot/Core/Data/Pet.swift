//
//  Pet.swift
//  PetSpot
//
//  Created by Bernardo on 10/10/2026.
//

import Foundation
import SwiftData

@Model
final class Pet {
    var id: UUID
    var name: String
    var breed: String
    var birthDate: Date
    var microchipNumber: String
    var nextVaccineDate: Date?
    var medicationNotes: String?
    
    // Construtor
    init(
        id: UUID = UUID(),
        name: String,
        breed: String,
        birthDate: Date,
        microchipNumber: String,
        nextVaccineDate: Date? = nil,
        medicationNotes: String? = nil
    ) {
        self.id = id
        self.name = name
        self.breed = breed
        self.birthDate = birthDate
        self.microchipNumber = microchipNumber
        self.nextVaccineDate = nextVaccineDate
        self.medicationNotes = medicationNotes
    }
    
    // Idade calculada automaticamente
    var ageString: String {
        let components = Calendar.current.dateComponents([.year, .month], from: birthDate, to: Date())
        let years = components.year ?? 0
        let months = components.month ?? 0
        
        if years > 0 {
            return "\(years) ano\(years > 1 ? "s" : "")"
        } else {
            return "\(months) m\(months > 1 ? "eses" : "ês")"
        }
    }
}

