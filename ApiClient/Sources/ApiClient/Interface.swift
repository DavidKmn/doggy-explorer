//
//  ApiClient+Interface.swift
//  doggy-explorer
//
//  Created by David Kaufman on 12/05/2021.
//

import Foundation
import Combine

public struct ListAllBreedsResponse: Decodable {
    public let message: [String: [String]]
    public let status: Status
}

public struct RandomImageInfoForBreedResponse: Equatable, Decodable {
    public let url: String
    public let status: Status
    
    private enum CodingKeys: String, CodingKey {
        case url = "message"
        case status
    }
}

public struct RandomImagesInfoForBreedResponse: Equatable, Decodable {
    public let urls: [String]
    public let status: Status
    
    private enum CodingKeys: String, CodingKey {
        case urls = "message"
        case status
    }
}

public enum Status: String, Equatable, Decodable {
    case success
    case failure
}


public struct ApiClient {
    public init(
        fetchAllBreeds: @escaping () -> AnyPublisher<[ApiClient.Breed], ApiClient.Error>,
        fetchPhotoUrlsForBreed: @escaping (String, Int) -> AnyPublisher<[ApiClient.PhotoURL], ApiClient.Error>
    ) {
        self.fetchAllBreeds = fetchAllBreeds
        self.fetchPhotoUrlsForBreed = fetchPhotoUrlsForBreed
    }
    
    public var fetchAllBreeds: () -> AnyPublisher<[Breed], Error>
    public var fetchPhotoUrlsForBreed: (_ breedName: String, _ count: Int) -> AnyPublisher<[PhotoURL], Error>
    
    public struct Breed {
        public init(
            name: String,
            subBreedNames: [ApiClient.Breed.SubBreedName]
        ) {
            self.name = name
            self.subBreedNames = subBreedNames
        }
        
        public typealias SubBreedName = String
        public let name: String
        public let subBreedNames: [SubBreedName]
    }
    
    public typealias PhotoURL = String
    
    public enum Error: Swift.Error {
        case badStatus
        case urlError(URLError)
        case decoding(Swift.Error)
        case unknown(Swift.Error)
    }
}

extension Publisher {
    public func mapToApiError() -> Publishers.MapError<Self, ApiClient.Error> {
        mapError({ (error)  in
            switch error {
            case is Swift.DecodingError:
                return .decoding(error)
            case let urlError as URLError:
                return .urlError(urlError)
            default:
                assertionFailure()
                return .unknown(error)
            }
        })
    }
}
