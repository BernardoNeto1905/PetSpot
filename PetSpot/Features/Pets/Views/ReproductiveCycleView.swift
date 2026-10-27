//
//  ReproductiveCycleView.swift
//  PetSpot
//
//  Created by Calvin Calvo on 27/10/2026.
//

import SwiftUI

struct ReproductiveCycleView: View {
    let pet: Pet

    @State private var lastCycleDate = Date()

    private var estimatedNextCycle: Date {
        Calendar.current.date(
            byAdding: .month,
            value: 6,
            to: lastCycleDate
        ) ?? lastCycleDate
    }

    private var estimatedEndDate: Date {
        Calendar.current.date(
            byAdding: .day,
            value: 21,
            to: lastCycleDate
        ) ?? lastCycleDate
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_PT")
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Cabeçalho

            VStack(alignment: .leading, spacing: 6) {
                Label(
                    "Ciclo reprodutivo",
                    systemImage: "calendar"
                )
                .font(.title2.bold())
                .foregroundStyle(.primary)

                Text("Acompanha o ciclo de \(pet.name).")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Registo do último cio

            VStack(alignment: .leading, spacing: 12) {
                Label(
                    "Último cio",
                    systemImage: "calendar.badge.clock"
                )
                .font(.headline)

                DatePicker(
                    "Data de início",
                    selection: $lastCycleDate,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)

                Text(
                    "Seleciona a data em que começou o último cio."
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            // Estimativa do próximo ciclo

            VStack(alignment: .leading, spacing: 12) {
                Label(
                    "Próximo cio estimado",
                    systemImage: "calendar.badge.plus"
                )
                .font(.headline)

                Text(dateFormatter.string(from: estimatedNextCycle))
                    .font(.title3.bold())
                    .foregroundStyle(.green)

                Text(
                    "Esta estimativa considera um intervalo aproximado de seis meses. "
                    + "O intervalo real varia de cadela para cadela."
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.green.opacity(0.10))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            // Duração aproximada

            VStack(alignment: .leading, spacing: 10) {
                Label(
                    "Duração indicativa",
                    systemImage: "clock"
                )
                .font(.headline)

                HStack {
                    Text("Início registado")
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text(dateFormatter.string(from: lastCycleDate))
                        .multilineTextAlignment(.trailing)
                }
                .font(.subheadline)

                Divider()

                HStack {
                    Text("Fim indicativo")
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text(dateFormatter.string(from: estimatedEndDate))
                        .multilineTextAlignment(.trailing)
                }
                .font(.subheadline)

                Text(
                    "A duração é apenas indicativa. Não representa uma previsão clínica."
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            // Nota informativa

            Label {
                Text(
                    "Se notares alterações no ciclo ou sinais que te preocupem, "
                    + "consulta um médico veterinário."
                )
                .font(.footnote)
                .foregroundStyle(.secondary)
            } icon: {
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(.green)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

