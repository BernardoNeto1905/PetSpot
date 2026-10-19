//
//  Reminder.swift
//  PetSpot
//
//  Created by Bernardo on 13/10/2026.
//

import Foundation
import SwiftData
 
@Model
final class Reminder {
    var id: UUID
    var title: String
    var date: Date
    var notes: String
    var isCompleted: Bool
    var category: String // Ex: "Vacina", "Consulta", "Desparasitação", "Outro"
    
    var syncWithiOSReminders: Bool
    var iosReminderIdentifier: String? // Guarda o ID do EventKit
    
    // Relação opcional com o Pet
    var pet: Pet?

    init(
        id: UUID = UUID(),
        title: String,
        date: Date,
        notes: String = "",
        isCompleted: Bool = false,
        category: String = "Geral",
        syncWithiOSReminders: Bool = false,
        iosReminderIdentifier: String? = nil,
        pet: Pet? = nil
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.notes = notes
        self.isCompleted = isCompleted
        self.category = category
        self.syncWithiOSReminders = syncWithiOSReminders
        self.iosReminderIdentifier = iosReminderIdentifier
        self.pet = pet
    }
}
