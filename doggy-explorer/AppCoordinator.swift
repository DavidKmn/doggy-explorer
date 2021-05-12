//
//  AppCoordinator.swift
//  doggy-explorer
//
//  Created by David Kaufman on 12/05/2021.
//

import UIKit
import Combine
import ApiClient
import ApiClientLive
import ImageRetrievalClient
import ImageRetrievalClientLive
import BreedPhotosDisplayFeature
import BreedsListFeature

struct Environment {
    var apiClient: ApiClient
    var imageRetrievalClient: ImageRetrievalClient
}

extension Environment {
    static let mock = Self(
        apiClient: .mock,
        imageRetrievalClient: .mock
    )
}

extension Environment {
    static let live = Self(
        apiClient: .live(),
        imageRetrievalClient: .live
    )
}

final class AppCoordinator {
    private var cancellables: Set<AnyCancellable> = .init()
    private var navigationController: UINavigationController = .init()
    private var window: UIWindow?
    
    private let environment = Environment.live

    func start(windowScene: UIWindowScene) {
        window = UIWindow(windowScene: windowScene)
        setupNavController()
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    private func setupNavController() {
        let textAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.label,
            NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .largeTitle)
        ]
        navigationController.navigationBar.largeTitleTextAttributes = textAttributes
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationItem.largeTitleDisplayMode = .automatic
        
        navigationController.navigationBar.barTintColor = UIColor.systemBackground
        
        startBreedListModule()
    }
    
    private func pushBreedPhotosModule(breedName: String) {
        let breedPhotosViewModel = BreedPhotosViewModel.init(
            breedName: breedName,
            initialState: .initial(breedName: breedName),
            reducer: BreedPhotosState.reduce,
            sideEffects: BreedPhotosSideEffects.init(
                api: environment.apiClient,
                imageRetrievalClient: environment.imageRetrievalClient
            )
        )
        let photosVC = BreedPhotosViewController(viewModel: breedPhotosViewModel)
        navigationController.pushViewController(photosVC, animated: true)
    }
    
    private func startBreedListModule() {
        let breedListViewModel = BreedListViewModel.init(
            reducer: BreedsListState.reduce(state:event:),
            sideEffects: .init(api: .live())
        )
        breedListViewModel
            .$state
            .compactMap({ $0.breedNameSelected })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (breed) in
                self?.pushBreedPhotosModule(breedName: breed)
            }
            .store(in: &cancellables)
        
        let breedListViewController = BreedListViewController(viewModel: breedListViewModel)
        navigationController.viewControllers = [breedListViewController]
    }
}

fileprivate extension BreedsListState {
    var breedNameSelected: String? {
        if case .loaded(let data, let indexToNavigateTo) = self {
            if let idx = indexToNavigateTo {
                return data[idx].name
            }
        }
        return nil
    }
}
