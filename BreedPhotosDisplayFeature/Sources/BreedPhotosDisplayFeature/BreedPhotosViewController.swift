//
//  BreedPhotosViewController.swift
//  doggy-explorer
//
//  Created by David Kaufman on 12/05/2021.
//

import UIKit
import Combine

private func createLayout() -> UICollectionViewCompositionalLayout {
    let photoItem = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1.0)))
    photoItem.contentInsets = .init(top: 2, leading: 2, bottom: 2, trailing: 2)

    let smallPhotoItem = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalWidth(1/3)))
    smallPhotoItem.contentInsets = .init(top: 0, leading: 2, bottom: 0, trailing: 2)

    let photoGroup = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1/3)), subitem: smallPhotoItem, count: 3)

    let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(500)), subitems: [photoItem, photoGroup])

    return .init(section: NSCollectionLayoutSection(group: group))
}

public final class BreedPhotosViewController: UIViewController {
    
    private lazy var collectionView: UICollectionView = { [unowned self] in
        let cv = UICollectionView(frame: view.frame, collectionViewLayout: createLayout())
        cv.showsVerticalScrollIndicator = false
        cv.backgroundColor = UIColor.systemBackground
        cv.register(cellClass: BreedPhotosCollectionViewCell.self)
        return cv
    }()
    
    private let viewModel: BreedPhotosViewModel
    private var cancellables: Set<AnyCancellable> = []

    public init(viewModel: BreedPhotosViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Int, BreedPhotoModel>
    private var dataSource: DataSource!
    
    private func setupCollectionDataSource() {
        self.dataSource = DataSource.init(collectionView: collectionView) { (collectionView, indexPath, model) -> UICollectionViewCell? in
            let cell: BreedPhotosCollectionViewCell = collectionView.dequeReusableCell(forIndexPath: indexPath)
            cell.set(with: .loading)
            cell.cancellable = model.task
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { (completion) in
                    switch completion {
                    case .finished: ()
                    case .failure:
                        cell.set(with: .failed)
                    }
                }, receiveValue: { (image) in
                    cell.set(with: .loaded(image))
                })
            return cell
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionDataSource()
        bindViewModel()
        viewModel.accept(event: .onViewDidLoad)
    }
    
    private let somethingWentWrongImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "oops"))
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        navigationController?.navigationBar.tintColor = UIColor.label
        view.addSubview(collectionView)
        
        view.addSubview(somethingWentWrongImageView)
        somethingWentWrongImageView.frame = CGRect(x: 0, y: 0, width: view.frame.width - 20, height: view.frame.width - 20)
        somethingWentWrongImageView.center = view.center
    }
    
    private func bindViewModel() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.somethingWentWrongImageView.isHidden = true

                switch state {
                case .initial(breedName: let name):
                    self?.navigationItem.title = name.capitalized
                case .preparedModels(let models):
                    if !models.isEmpty {
                        self?.updateDataSource(with: models)
                    } else {
                        // could show something to the user to let them know we have no images for this breed
                    }
                case .failedToLoadImageUrls:
                    self?.somethingWentWrongImageView.isHidden = false
                default: ()
                }
            }
            .store(in: &cancellables)
    }

    
    private func updateDataSource(with models: [BreedPhotoModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, BreedPhotoModel>()
        snapshot.appendSections([1])
        snapshot.appendItems(models, toSection: 1)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension UICollectionReusableView {
    public class var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UICollectionView {
    
    public func dequeReusableCell<Cell: UICollectionViewCell>(forIndexPath indexPath: IndexPath) -> Cell {
        return dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier, for: indexPath) as! Cell
    }
    
    public func register(cellClass: AnyClass) {
        self.register(cellClass, forCellWithReuseIdentifier: ((cellClass) as! UICollectionViewCell.Type).reuseIdentifier)
    }
    
}
