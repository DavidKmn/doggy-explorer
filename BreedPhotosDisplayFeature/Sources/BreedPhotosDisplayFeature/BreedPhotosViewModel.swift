//
//  BreedPhotosViewModel.swift
//  doggy-explorer
//
//  Created by David Kaufman on 12/05/2021.
//

import Foundation
import Combine
import ApiClient
import ImageRetrievalClient

public struct BreedPhotoModel: Equatable, Hashable {
    public static func == (lhs: BreedPhotoModel, rhs: BreedPhotoModel) -> Bool {
        lhs.url == rhs.url
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
    
    init(url: URL, task: AnyPublisher<CrossPlatformImage, ImageRetrievalClient.Error>) {
        self.url = url
        self.task = task
    }
    
    private let url: URL
    let task: AnyPublisher<CrossPlatformImage, ImageRetrievalClient.Error>
}

public enum BreedPhotosState: Equatable {
    case initial(breedName: String)
    
    case loadingImageUrls
    case failedToLoadImageUrls
    
    case loadedImageUrls([String])
    
    case preparedModels([BreedPhotoModel])
}

extension BreedPhotosState {
    var loadQuery: Bool {
        guard case .loadingImageUrls = self else { return false }
        return true
    }
}

public enum BreedPhotosEvent {
    case onViewDidLoad
    case downloadPhotoUrlsResponse(Result<[String], ApiClient.Error>)
    case prepareImageDownloads([BreedPhotoModel])
}

public struct BreedPhotosSideEffects {
    public init(
        api: ApiClient,
        imageRetrievalClient: ImageRetrievalClient
    ) {
        self.api = api
        self.imageRetrievalClient = imageRetrievalClient
    }
    
    private let api: ApiClient
    private let imageRetrievalClient: ImageRetrievalClient
    
    func downloadBreedImageURLs(breedName: String, count: Int) -> AnyPublisher<BreedPhotosEvent, Never> {
        api.fetchPhotoUrlsForBreed(breedName, count)
            .convertToResult()
            .map(BreedPhotosEvent.downloadPhotoUrlsResponse)
            .eraseToAnyPublisher()
    }
    
    func downloadImage(url: URL) -> AnyPublisher<CrossPlatformImage, ImageRetrievalClient.Error> {
        imageRetrievalClient.getImage(url)
            .eraseToAnyPublisher()
    }
}

public typealias BreedPhotosReducer = (inout BreedPhotosState, BreedPhotosEvent) -> Void

public final class BreedPhotosViewModel: ObservableObject {
    
    @Published private(set) var state: BreedPhotosState
    private var cancellables = Set<AnyCancellable>()
    
    private let sideEffects: BreedPhotosSideEffects
    private let reducer: BreedPhotosReducer
    
    private let breedName: String
    private let photosCount: Int
    
    public init(
        breedName: String,
        initialState: BreedPhotosState,
        photosCount: Int = 10,
        reducer: @escaping BreedPhotosReducer,
        sideEffects: BreedPhotosSideEffects
    ) {
        self.state = initialState
        self.breedName = breedName
        self.photosCount = photosCount
        self.reducer = reducer
        self.sideEffects = sideEffects
        start().store(in: &cancellables)
    }
    
    private func start() -> AnyCancellable {
        $state
            .removeDuplicates()
            .flatMap({ [sideEffects, breedName, photosCount] s -> AnyPublisher<BreedPhotosEvent, Never> in
                switch s {
                case .initial, .failedToLoadImageUrls, .preparedModels: return Empty().eraseToAnyPublisher()
                case .loadingImageUrls:
                    return sideEffects.downloadBreedImageURLs(breedName: breedName, count: photosCount)
                case .loadedImageUrls(let urlInfos):
                    let models: [BreedPhotoModel] = urlInfos.compactMap({ URL(string: $0) }).uniqued().map({ BreedPhotoModel(url: $0, task: sideEffects.downloadImage(url: $0)) })
                    return Just(BreedPhotosEvent.prepareImageDownloads(models)).eraseToAnyPublisher()
                }
            })
            .sink(receiveValue: { [weak self] e in
                self?.accept(event: e)
            })
    }

    func accept(event: BreedPhotosEvent) {
        reducer(&state, event)
    }
}

extension BreedPhotosState {
    public static func reduce(state: inout Self, event: BreedPhotosEvent) {
        switch event {
        case .onViewDidLoad:
            state = .loadingImageUrls
        case .downloadPhotoUrlsResponse(.success(let imageInfo)):
            state = .loadedImageUrls(imageInfo)
        case .downloadPhotoUrlsResponse(.failure(let error)):
            debugPrint(error) // Since time is taken into consideration not handling error now
            state = .failedToLoadImageUrls
        case .prepareImageDownloads(let models):
            state = .preparedModels(models)
        }
    }
}

extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}

extension Publisher {
    func convertToResult() -> AnyPublisher<Result<Output, Failure>, Never> {
        self.map(Result.success)
            .catch { Just(.failure($0)) }
            .eraseToAnyPublisher()
    }
}
