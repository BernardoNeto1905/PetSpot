//
//  LocalNotificationService.swift
//  PetSpot
//
//  Created by Calvin Calvo on 26/10/2026.
//


import Foundation
import UserNotifications

final class LocalNotificationService {

    static let shared = LocalNotificationService()

    private let notificationCenter = UNUserNotificationCenter.current()

    private init() {}

    // MARK: - Pedir autorização

    func requestPermission() async throws -> Bool {
        return try await notificationCenter.requestAuthorization(
            options: [.alert, .sound, .badge]
        )
    }

    // MARK: - Consultar autorização

    func checkPermission() async -> UNAuthorizationStatus {
        let settings = await notificationCenter.notificationSettings()
        return settings.authorizationStatus
    }

    // MARK: - Agendar notificação

    func scheduleNotification(
        id: String,
        title: String,
        body: String,
        date: Date
    ) async throws {

        guard date > Date() else {
            throw LocalNotificationError.dateInPast
        }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        )

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: trigger
        )

        // Substituir uma notificação anterior com o mesmo identificador.
        notificationCenter.removePendingNotificationRequests(
            withIdentifiers: [id]
        )

        try await notificationCenter.add(request)
    }

    // MARK: - Cancelar uma notificação

    func cancelNotification(id: String) {
        notificationCenter.removePendingNotificationRequests(
            withIdentifiers: [id]
        )
    }

    // MARK: - Cancelar todas as notificações pendentes

    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
    }

    // MARK: - Consultar notificações pendentes

    func pendingNotifications() async -> [UNNotificationRequest] {
        return await notificationCenter.pendingNotificationRequests()
    }
}

// MARK: - Erros

enum LocalNotificationError: LocalizedError {
    case dateInPast

    var errorDescription: String? {
        switch self {
        case .dateInPast:
            return "A data da notificação tem de ser futura."
        }
    }
}
