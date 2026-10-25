//
//  ReminderService.swift
//  PetSpot
//
//  Created by Calvin Calvo on 24/10/2026.
//


import Foundation
import FirebaseAuth
import FirebaseFirestore

enum ReminderService {

    private static let db = Firestore.firestore()
    
    private static func remindersCollection() throws -> CollectionReference {
        guard let userID = Auth.auth().currentUser?.uid else {
            throw ReminderServiceError.notAuthenticated
        }

        return db.collection("users")
            .document(userID)
            .collection("reminders")
    }

    // MARK: - Adicionar lembrete

    @discardableResult
    static func addReminder(
        title: String,
        date: Date,
        notes: String = "",
        category: String = "Geral",
        petID: String? = nil,
        syncWithiOSReminders: Bool = false,
        iosReminderIdentifier: String? = nil
    ) async throws -> Reminder {

        let cleanTitle = title.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !cleanTitle.isEmpty else {
            throw ReminderServiceError.emptyTitle
        }

        let collection = try remindersCollection()
        let document = collection.document()

        let reminder = Reminder(
            id: document.documentID,
            title: cleanTitle,
            date: date,
            notes: notes,
            isCompleted: false,
            category: category,
            syncWithiOSReminders: syncWithiOSReminders,
            iosReminderIdentifier: iosReminderIdentifier,
            petID: petID
        )

        try await document.setData([
            "id": reminder.id,
            "title": reminder.title,
            "date": reminder.date,
            "notes": reminder.notes,
            "isCompleted": reminder.isCompleted,
            "category": reminder.category,
            "syncWithiOSReminders": reminder.syncWithiOSReminders,
            "iosReminderIdentifier": reminder.iosReminderIdentifier as Any? ?? NSNull(),
            "petID": reminder.petID as Any? ?? NSNull(),
            "createdAt": FieldValue.serverTimestamp()
        ])

        return reminder
    }

    // MARK: - Obter lembretes

    static func fetchReminders() async throws -> [Reminder] {
        let snapshot = try await remindersCollection()
            .order(by: "date", descending: false)
            .getDocuments()

        return snapshot.documents.compactMap { document in
            let data = document.data()

            guard
                let title = data["title"] as? String,
                let timestamp = data["date"] as? Timestamp
            else {
                return nil
            }

            return Reminder(
                id: document.documentID,
                title: title,
                date: timestamp.dateValue(),
                notes: data["notes"] as? String ?? "",
                isCompleted: data["isCompleted"] as? Bool ?? false,
                category: data["category"] as? String ?? "Geral",
                syncWithiOSReminders: data["syncWithiOSReminders"] as? Bool ?? false,
                iosReminderIdentifier: data["iosReminderIdentifier"] as? String,
                petID: data["petID"] as? String
            )
        }
    }

    // MARK: - Atualizar lembrete

    static func updateReminder(_ reminder: Reminder) async throws {
        try await remindersCollection()
            .document(reminder.id)
            .updateData([
                "title": reminder.title,
                "date": reminder.date,
                "notes": reminder.notes,
                "isCompleted": reminder.isCompleted,
                "category": reminder.category,
                "syncWithiOSReminders": reminder.syncWithiOSReminders,
                "iosReminderIdentifier": reminder.iosReminderIdentifier as Any? ?? NSNull(),
                "petID": reminder.petID as Any? ?? NSNull()
            ])
    }

    // MARK: - Concluir / reabrir lembrete

    static func setCompleted(
        reminderID: String,
        isCompleted: Bool
    ) async throws {
        try await remindersCollection()
            .document(reminderID)
            .updateData([
                "isCompleted": isCompleted
            ])
    }

    // MARK: - Guardar ID do lembrete do iPhone

    static func updateIOSReminderIdentifier(
        reminderID: String,
        identifier: String?
    ) async throws {
        try await remindersCollection()
            .document(reminderID)
            .updateData([
                "iosReminderIdentifier": identifier as Any? ?? NSNull()
            ])
    }

    // MARK: - Apagar lembrete

    static func deleteReminder(id: String) async throws {
        try await remindersCollection()
            .document(id)
            .delete()
    }
}

// MARK: - Erros

enum ReminderServiceError: LocalizedError {
    case notAuthenticated
    case emptyTitle

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Tens de iniciar sessão para gerir os lembretes."
        case .emptyTitle:
            return "O título do lembrete não pode estar vazio."
        }
    }
}
