//
//  ApiClient.swift
//  doggy-explorer
//
//  Created by David Kaufman on 12/05/2021.
//

import Foundation
import Combine

extension ApiClient {
    public static let mock = Self(
        fetchAllBreeds: {
            return Just(ListAllBreedsResponse.init(
                message: ["affenpinscher": [],
                          "african": [],
                          "airedale": [],
                          "akita": [],
                          "appenzeller": [],
                          "australian": [
                            "shepherd"
                          ]],
                status: .success
            ))
            .map({ (resp) -> [Breed] in
                return resp.message.map { (breedName, subBreeds) in
                    Breed(name: breedName, subBreedNames: subBreeds)
                }
            })
            .setFailureType(to: ApiClient.Error.self)
            .delay(for: .microseconds(500), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
        },
        fetchPhotoUrlsForBreed: { breedName, count in
            Just(
                (0..<count).map({ idx in
                    return "https://picsum.photos/500?random=\(idx)"
                })
            )
            .setFailureType(to: ApiClient.Error.self)
            .delay(for: .microseconds(500), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
        }
    )
}

