
//
//  CommunityView.swift
//  PetSpot
//
//  Created by Bernardo on 16/10/2026.
//
import SwiftUI
import FirebaseFirestore

struct CommunityView: View {

    @State private var selectedFilter = "Geral"
    @State private var showingCreateView = false
    @State private var items: [CommunityItem] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var listener: ListenerRegistration?

    private let filters = [
        "Geral",
        "Pets Perdidos",
        "Encontros",
        "Dicas"
    ]

    private let petSpotGreen = Color(
        red: 0.0,
        green: 0.65,
        blue: 0.45
    )

    private var filteredItems: [CommunityItem] {
        if selectedFilter == "Geral" {
            return items
        }

        return items.filter {
            $0.category.rawValue == selectedFilter
        }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    header

                    filtersSection

                    contentSection
                }

                createButton
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showingCreateView) {
                CreateCommunityItemView { item in
                    _ = try await CommunityService.addItem(item)
                }
            }
            .alert(
                "Erro",
                isPresented: Binding(
                    get: { errorMessage != nil },
                    set: { if !$0 { errorMessage = nil } }
                )
            ) {
                Button("OK", role: .cancel) {
                    errorMessage = nil
                }
            } message: {
                Text(errorMessage ?? "Ocorreu um erro.")
            }
            .onAppear {
                startListening()
            }
            .onDisappear {
                listener?.remove()
                listener = nil
            }
        }
    }

    // MARK: - Cabeçalho

    private var header: some View {
        HStack {
            Text("Comunidade")
                .font(.system(size: 32, weight: .bold))

            Spacer()

            Image(systemName: "pawprint.fill")
                .font(.title2)
                .foregroundStyle(petSpotGreen)
                .frame(width: 46, height: 46)
                .background(petSpotGreen.opacity(0.12))
                .clipShape(Circle())
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 18)
    }

    // MARK: - Filtros

    private var filtersSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(filters, id: \.self) { filter in
                    Button {
                        selectedFilter = filter
                    } label: {
                        Text(filter)
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, 18)
                            .padding(.vertical, 10)
                            .background(
                                selectedFilter == filter
                                ? petSpotGreen
                                : Color(uiColor: .secondarySystemGroupedBackground)
                            )
                            .foregroundStyle(
                                selectedFilter == filter ? .white : .primary
                            )
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 16)
    }

    // MARK: - Conteúdo

    @ViewBuilder
    private var contentSection: some View {
        if isLoading {
            Spacer()

            ProgressView("A carregar publicações...")
                .tint(petSpotGreen)

            Spacer()
        } else if filteredItems.isEmpty {
            emptyState
        } else {
            ScrollView {
                LazyVStack(spacing: 14) {
                    ForEach(filteredItems) { item in
                        CommunityItemCardView(item: item)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .padding(.bottom, 100)
            }
        }
    }

    // MARK: - Estado vazio

    private var emptyState: some View {
        VStack(spacing: 14) {
            Spacer()

            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 42))
                .foregroundStyle(.secondary)

            Text("Ainda não existem publicações")
                .font(.headline)

            Text(
                selectedFilter == "Geral"
                ? "Sê o primeiro a partilhar algo com a comunidade."
                : "Ainda não existem publicações nesta categoria."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 30)

            Button {
                showingCreateView = true
            } label: {
                Text("Criar publicação")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 12)
                    .background(petSpotGreen)
                    .clipShape(Capsule())
            }
            .padding(.top, 4)

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Botão de criação

    private var createButton: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("Partilha com a comunidade")
                    .font(.headline)

                Text("Publicação ou alerta de animal perdido")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                showingCreateView = true
            } label: {
                Image(systemName: "plus")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(petSpotGreen)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.15), radius: 5, y: 3)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }

    // MARK: - Firestore

    private func startListening() {
        listener?.remove()
        isLoading = true

        listener = CommunityService.listenToItems { result in
            isLoading = false

            switch result {
            case .success(let fetchedItems):
                items = fetchedItems

            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
}

// MARK: - Cartão de publicação

private struct CommunityItemCardView: View {

    let item: CommunityItem

    private let petSpotGreen = Color(
        red: 0.0,
        green: 0.65,
        blue: 0.45
    )

    private var isAlert: Bool {
        item.type == .alert
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header

            if isAlert {
                alertInformation
            }

            Text(item.content)
                .font(.body)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let imageURL = item.imageURL,
               let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                    } else if phase.error != nil {
                        Image(systemName: "photo")
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 180)
                    } else {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .frame(height: 180)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            footer
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    isAlert ? Color.red.opacity(0.25) : Color.clear,
                    lineWidth: 1
                )
        }
    }

    private var header: some View {
        HStack(spacing: 10) {
            Image(systemName: isAlert ? "exclamationmark.triangle.fill" : "person.crop.circle.fill")
                .font(.title2)
                .foregroundStyle(isAlert ? .red : petSpotGreen)

            VStack(alignment: .leading, spacing: 3) {
                Text(item.authorName)
                    .font(.subheadline.weight(.semibold))

                Text(item.createdAt.formatted(.relative(presentation: .named)))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(isAlert ? "ALERTA" : item.category.rawValue.uppercased())
                .font(.caption2.weight(.bold))
                .foregroundStyle(isAlert ? .red : petSpotGreen)
                .padding(.horizontal, 9)
                .padding(.vertical, 6)
                .background(
                    (isAlert ? Color.red : petSpotGreen).opacity(0.10)
                )
                .clipShape(Capsule())
        }
    }

    private var alertInformation: some View {
        VStack(alignment: .leading, spacing: 9) {
            if let petName = item.petName {
                Label(petName, systemImage: "pawprint.fill")
                    .font(.headline)
            }

            if let petType = item.petType {
                Text("Tipo: \(petType)")
                    .font(.subheadline)
            }

            if let description = item.petDescription {
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if let location = item.location {
                Label(location, systemImage: "mappin.and.ellipse")
                    .font(.subheadline)
            }

            if let date = item.lastSeenDate {
                Label(
                    date.formatted(date: .abbreviated, time: .shortened),
                    systemImage: "clock"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            if let contact = item.contact {
                Label(contact, systemImage: "phone")
                    .font(.subheadline)
                    .foregroundStyle(petSpotGreen)
            }

            if item.isResolved {
                Label("Animal encontrado", systemImage: "checkmark.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(petSpotGreen)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var footer: some View {
        HStack(spacing: 18) {
            Label("\(item.likesCount)", systemImage: "heart")
            Label("\(item.commentsCount)", systemImage: "bubble.right")

            Spacer()

            ShareLink(
                item: shareText,
                subject: Text(isAlert ? "Alerta PetSpot" : "Publicação PetSpot")
            ) {
                Label("Partilhar", systemImage: "square.and.arrow.up")
            }
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }

    private var shareText: String {
        var text = "\(item.authorName): \(item.content)"

        if let petName = item.petName {
            text += "\nAnimal: \(petName)"
        }

        if let location = item.location {
            text += "\nLocalização: \(location)"
        }

        if let contact = item.contact {
            text += "\nContacto: \(contact)"
        }

        return text
    }
}
