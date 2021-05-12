//
//  ApiClient+Live.swift
//  doggy-explorer
//
//  Created by David Kaufman on 12/05/2021.
//

import Foundation
import Combine
import ApiClient

extension URL {
    public init(_ string: StaticString) {
        guard let url = URL(string: "\(string)") else {
            preconditionFailure("Invalid static URL string: \(string)")
        }
        
        self = url
    }
}

extension ApiClient {
    private static func fetchRandomImageUrl(baseUrl: URL, breed: String) -> AnyPublisher<String, ApiClient.Error> {
        URLSession.shared.dataTaskPublisher(for: baseUrl.appendingPathComponent("/breed/\(breed)/images/random"))
            .map(\.data)
            .decode(type: RandomImageInfoForBreedResponse.self, decoder: decoder)
            .mapToApiError()
            .flatMap({ data -> Result<String, ApiClient.Error>.Publisher in
                if data.status == .success {
                    return .init(.success(data.url))
                }
                return .init(.failure(ApiClient.Error.badStatus))
            })
            .eraseToAnyPublisher()
    }
    
    
    public static func live(baseUrl: URL = URL("https://dog.ceo/api")) -> Self {
        return .init(
            fetchAllBreeds: {
                URLSession.shared.dataTaskPublisher(for: baseUrl.appendingPathComponent("/breeds/list/all"))
                    .map(\.data)
                    .decode(type: ListAllBreedsResponse.self, decoder: decoder)
                    .mapToApiError()
                    .flatMap({ data -> Result<[Breed], ApiClient.Error>.Publisher in
                        if data.status == .success {
                            return .init(.success(data.message.map { (breedName, subBreeds) in
                                Breed(name: breedName, subBreedNames: subBreeds)
                            }))
                        }
                        return .init(.failure(ApiClient.Error.badStatus))
                    })
                    .eraseToAnyPublisher()
            },
            fetchPhotoUrlsForBreed: { breed, count in
                Publishers.Sequence(sequence: (0..<count).map { (_) in
                    return fetchRandomImageUrl(baseUrl: baseUrl, breed: breed)
                })
                .flatMap { $0 }
                .collect()
                .eraseToAnyPublisher()
            }
        )
    }
}

private let decoder = JSONDecoder()
