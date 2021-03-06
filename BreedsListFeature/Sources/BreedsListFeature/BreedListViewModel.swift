//
//  BreedListInteractor.swift
//  doggy-explorer
//
//  Created by David Kaufman on 12/05/2021.
//

import Foundation
import Combine
import ApiClient

public struct Breed {
    public let name: String
    public let subBreedNames: [SubBreedName]
    public typealias SubBreedName = String
}

public enum BreedsListState {
    case initial(moduleTitle: String)
    case loading
    case failed
    case loaded([Breed], navigatedTo: Int?)
}

extension BreedsListState {
    var loadQuery: Bool {
        guard case .loading = self else { return false }
        return true
    }
}

public enum BreedsListEvent {
    case onViewDidLoad
    case onViewWillAppear
    case onDidSelectBreedAtIndex(Int)
    case downloadBreedsResponse(Result<[Breed], ApiClient.Error>)
}

public struct BreedsListSideEffects {
    public let api: ApiClient
    
    public init(api: ApiClient) {
        self.api = api
    }
    
    func downloadAllBreeds() -> AnyPublisher<BreedsListEvent, Never> {
        api.fetchAllBreeds()
            .convertToResult()
            .map({ BreedsListEvent.downloadBreedsResponse($0.toDomain()) })
            .eraseToAnyPublisher()
    }
}

extension Result where Success == [ApiClient.Breed], Failure == ApiClient.Error {
    func toDomain() -> Result<[Breed], ApiClient.Error>  {
        map({ $0.map { (apiBreed)  in
            Breed.init(name: apiBreed.name, subBreedNames: apiBreed.subBreedNames)
        }})
    }
}

public typealias BreedListReducer = (inout BreedsListState, BreedsListEvent) -> Void

public final class BreedListViewModel: ObservableObject {
    
    @Published public private(set) var state: BreedsListState
    private var cancellables = Set<AnyCancellable>()
    
    private let sideEffects: BreedsListSideEffects
    private let reducer: BreedListReducer
    
    public init(
        initialState: BreedsListState = .initial(moduleTitle: "Breeds 🐕"),
        reducer: @escaping BreedListReducer,
        sideEffects: BreedsListSideEffects
    ) {
        self.state = initialState
        self.reducer = reducer
        self.sideEffects = sideEffects
        start().store(in: &cancellables)
    }
    
    private func start() -> AnyCancellable {
        $state
            .map(\.loadQuery)
            .removeDuplicates()
            .filter({ $0 == true })
            .map { _ in () }
            .flatMap({ [sideEffects] _ in
                sideEffects.downloadAllBreeds()
            })
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] e in
                self?.accept(event: e)
            })
    }
    
    func accept(event: BreedsListEvent) {
        reducer(&state, event)
    }
}

extension BreedsListState {
    public static func reduce(state: inout Self, event: BreedsListEvent) {
        switch event {
        case .onViewDidLoad:
            state = .loading
        case .onViewWillAppear:
            if case .loaded(let data, _) = state {
                state = .loaded(data, navigatedTo: nil)
            }
        case .onDidSelectBreedAtIndex(let index):
            if case .loaded(let data, _) = state {
                state = .loaded(data, navigatedTo: index)
            } else {
                assertionFailure()
            }
        case .downloadBreedsResponse(.success(let breeds)):
            state = .loaded(breeds.sorted(by: { $0.name < $1.name }), navigatedTo: nil)
        case .downloadBreedsResponse(.failure(let error)):
            debugPrint(error) // Since time is taken into consideration not handling error now
            state = .failed
        }
    }
}

extension Publisher {
    func convertToResult() -> AnyPublisher<Result<Output, Failure>, Never> {
        self.map(Result.success)
            .catch { Just(.failure($0)) }
            .eraseToAnyPublisher()
    }
}
