
//
//  ReminderManager.swift
//  PetSpot
//
//  Created by Bernardo on 19/10/2026.
//

import Foundation
import EventKit
import Combine

final class ReminderManager: ObservableObject {

    private let eventStore = EKEventStore()

    /// Pede autorização e cria um lembrete na app Lembretes do iOS.
    func addReminder(
        title: String,
        dueDate: Date,
        notes: String?,
        completion: @escaping (String?) -> Void
    ) {
        if #available(iOS 17.0, *) {
            eventStore.requestFullAccessToReminders { [weak self] granted, error in

                guard granted else {
                    print(
                        "❌ Acesso aos Lembretes recusado: " +
                        (error?.localizedDescription ?? "Sem autorização.")
                    )

                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }

                guard let self else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }

                self.createEKReminder(
                    title: title,
                    dueDate: dueDate,
                    notes: notes,
                    completion: completion
                )
            }
        } else {
            eventStore.requestAccess(to: .reminder) {
                [weak self] granted, error in

                guard granted else {
                    print(
                        "❌ Acesso aos Lembretes recusado: " +
                        (error?.localizedDescription ?? "Sem autorização.")
                    )

                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }

                guard let self else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }

                self.createEKReminder(
                    title: title,
                    dueDate: dueDate,
                    notes: notes,
                    completion: completion
                )
            }
        }
    }

    private func createEKReminder(
        title: String,
        dueDate: Date,
        notes: String?,
        completion: @escaping (String?) -> Void
    ) {
        guard let calendar = eventStore.defaultCalendarForNewReminders() else {
            print("❌ Não foi encontrada uma lista de Lembretes.")

            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }

        let reminder = EKReminder(eventStore: eventStore)

        reminder.title = title
        reminder.notes = notes
        reminder.calendar = calendar

        reminder.dueDateComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: dueDate
        )

        reminder.addAlarm(EKAlarm(absoluteDate: dueDate))

        do {
            try eventStore.save(reminder, commit: true)

            let identifier = reminder.calendarItemIdentifier

            print("✅ Lembrete criado na app Lembretes.")
            print("📋 Título: \(title)")
            print("📅 Data: \(dueDate)")
            print("🆔 Identificador: \(identifier)")

            DispatchQueue.main.async {
                completion(identifier)
            }
        } catch {
            print(
                "❌ Erro ao guardar no EventKit: " +
                error.localizedDescription
            )

            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }
}
