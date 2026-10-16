//
//  PetsViewModel.swift
//  PetSpot
//
//  Created by Bernardo on 10/10/2026.
//

import Foundation
import SwiftData

@Observable
class PetsViewModel {
    var selectedPet: Pet?
    var isAddingPet = false
    var isEditingPet = false
    
    // Regra de negócio: verifica se a vacina está prestes a expirar (nos próximos 30 dias)
    func isVaccineUrgent(for pet: Pet) -> Bool {
        guard let vaccineDate = pet.nextVaccineDate else { return false }
        let daysUntilVaccine = Calendar.current.dateComponents([.day], from: Date(), to: vaccineDate).day ?? 0
        return daysUntilVaccine <= 30
    }
    
    // Elimina um pet da base de dados do SwiftData
    func deletePet(_ pet: Pet, context: ModelContext) {
        context.delete(pet)
        try? context.save()
        if selectedPet?.id == pet.id {
            selectedPet = nil
        }
    }
}
