//
//  OSMService.swift
//  PetSpot
//
//  Created by Bernardo on 09/10/2026.
//
import Foundation
import CoreLocation

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválido para a Overpass API."
        case .invalidResponse:
            return "Resposta inválida do servidor."
        case .httpError(let code):
            return "Erro HTTP: \(code)."
        case .decodingError:
            return "Não foi possível interpretar os dados recebidos."
        }
    }
}

struct OSMService {

    private let endpoint =
        "https://overpass-api.de/api/interpreter"

    func fetchPetSpots(
        near coordinate: CLLocationCoordinate2D,
        radiusInMeters: Int = 5000
    ) async throws -> [PetSpotElement] {

        let query = """
        [out:json][timeout:25];
        (
          node["amenity"="veterinary"](around:\(radiusInMeters),\(coordinate.latitude),\(coordinate.longitude));
          node["leisure"="dog_park"](around:\(radiusInMeters),\(coordinate.latitude),\(coordinate.longitude));
          node["shop"="pet"](around:\(radiusInMeters),\(coordinate.latitude),\(coordinate.longitude));
        );
        out body;
        """

        guard let url = URL(string: endpoint) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 40

        request.setValue(
            "application/x-www-form-urlencoded",
            forHTTPHeaderField: "Content-Type"
        )

        request.setValue(
            "PetSpot/1.0",
            forHTTPHeaderField: "User-Agent"
        )

        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "data", value: query)
        ]

        request.httpBody = components.percentEncodedQuery?
            .data(using: .utf8)

        // Máximo de 3 tentativas
        for attempt in 0..<3 {

            try Task.checkCancellation()

            do {
                let (data, response) = try await URLSession.shared.data(
                    for: request
                )

                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }

                if httpResponse.statusCode == 200 {
                    do {
                        let result = try JSONDecoder().decode(
                            OverpassResponse.self,
                            from: data
                        )

                        return result.elements

                    } catch {
                        print("Erro de descodificação: \(error)")
                        throw NetworkError.decodingError
                    }
                }

                // Erros temporários do servidor
                let retryableCodes = [429, 502, 503, 504]

                if retryableCodes.contains(httpResponse.statusCode),
                   attempt < 2 {

                    let delay = UInt64(2 * (1 << attempt))

                    print(
                        "Overpass indisponível (HTTP \(httpResponse.statusCode)). Nova tentativa em \(delay) segundos."
                    )

                    try await Task.sleep(
                        nanoseconds: delay * 1_000_000_000
                    )

                    continue
                }

                throw NetworkError.httpError(httpResponse.statusCode)

            } catch is CancellationError {
                throw CancellationError()

            } catch let error as NetworkError {
                throw error

            } catch let error as URLError {

                let retryableErrors: [URLError.Code] = [
                    .timedOut,
                    .cannotConnectToHost,
                    .networkConnectionLost,
                    .notConnectedToInternet,
                    .dnsLookupFailed
                ]

                if retryableErrors.contains(error.code),
                   attempt < 2 {

                    let delay = UInt64(2 * (1 << attempt))

                    print(
                        "Erro de ligação. Nova tentativa em \(delay) segundos."
                    )

                    try await Task.sleep(
                        nanoseconds: delay * 1_000_000_000
                    )

                    continue
                }

                throw error
            }
        }

        throw NetworkError.invalidResponse
    }
}
