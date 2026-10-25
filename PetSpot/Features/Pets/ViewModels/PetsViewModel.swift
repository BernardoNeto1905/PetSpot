
//
//  PetsViewModel.swift
//  PetSpot
//
//  Created by Bernardo on 10/10/2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class PetsViewModel {

    var pets: [Pet] = []
    var selectedPet: Pet?
    var isAddingPet = false
    var isEditingPet = false

    var isLoading = false
    var errorMessage: String?

    func loadPets() async {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            pets = try await PetService.fetchPets()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deletePet(_ pet: Pet) async {
        errorMessage = nil

        do {
            try await PetService.deletePet(pet)

            pets.removeAll { $0.id == pet.id }

            if selectedPet?.id == pet.id {
                selectedPet = nil
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Avisos de vacinação

    func isVaccineUrgent(for pet: Pet) -> Bool {
        guard let vaccineDate = pet.nextVaccineDate else {
            return false
        }

        let today = Calendar.current.startOfDay(for: Date())
        let vaccineDay = Calendar.current.startOfDay(for: vaccineDate)

        guard vaccineDay >= today else {
            return false
        }

        let daysUntilVaccine = Calendar.current.dateComponents(
            [.day],
            from: today,
            to: vaccineDay
        ).day ?? 0

        return daysUntilVaccine <= 30
    }
}
