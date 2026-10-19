//
//  ReminderManager.swift
//  PetSpot
//
//  Created by Bernardo on 19/10/2026.
//

import Foundation
import EventKit

class ReminderManager: ObservableObject {
    private let eventStore = EKEventStore()

    /// Pede acesso e adiciona o lembrete na app Lembretes oficial do iOS
    func addReminder(title: String, dueDate: Date, notes: String?, completion: @escaping (String?) -> Void) {
        if #available(iOS 17.0, *) {
            eventStore.requestFullAccessToReminders { granted, error in
                guard granted else {
                    DispatchQueue.main.async { completion(nil) }
                    return
                }
                self.createEKReminder(title: title, dueDate: dueDate, notes: notes, completion: completion)
            }
        } else {
            eventStore.requestAccess(to: .reminder) { granted, error in
                guard granted else {
                    DispatchQueue.main.async { completion(nil) }
                    return
                }
                self.createEKReminder(title: title, dueDate: dueDate, notes: notes, completion: completion)
            }
        }
    }

    private func createEKReminder(title: String, dueDate: Date, notes: String?, completion: @escaping (String?) -> Void) {
        let reminder = EKReminder(eventStore: eventStore)
        reminder.title = title
        reminder.notes = notes
        reminder.calendar = eventStore.defaultCalendarForNewReminders()

        // Adiciona alarme/notificação na data especificada
        let alarm = EKAlarm(absoluteDate: dueDate)
        reminder.addAlarm(alarm)
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
        reminder.dueDateComponents = components

        do {
            try eventStore.save(reminder, commit: true)
            let identifier = reminder.calendarItemIdentifier
            DispatchQueue.main.async {
                completion(identifier)
            }
        } catch {
            print("Erro ao guardar lembrete no EventKit: \(error.localizedDescription)")
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }
}
