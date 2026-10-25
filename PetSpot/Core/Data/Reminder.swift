//
//  Reminder.swift
//  PetSpot
//
//  Created by Bernardo on 13/10/2026.
//

import Foundation

struct Reminder: Identifiable, Codable, Equatable {
    var id: String
    var title: String
    var date: Date
    var notes: String
    var isCompleted: Bool
    var category: String

    var syncWithiOSReminders: Bool
    var iosReminderIdentifier: String?

    // ID do animal associado ao lembrete no Firestore.
    var petID: String?

    init(
        id: String = UUID().uuidString,
        title: String,
        date: Date,
        notes: String = "",
        isCompleted: Bool = false,
        category: String = "Geral",
        syncWithiOSReminders: Bool = false,
        iosReminderIdentifier: String? = nil,
        petID: String? = nil
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.notes = notes
        self.isCompleted = isCompleted
        self.category = category
        self.syncWithiOSReminders = syncWithiOSReminders
        self.iosReminderIdentifier = iosReminderIdentifier
        self.petID = petID
    }
}
