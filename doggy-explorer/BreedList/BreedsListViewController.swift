//
//  BreedsListViewController.swift
//  doggy-explorer
//
//  Created by David Kaufman on 12/05/2021.
//

import Foundation
import UIKit
import Combine

final class BreedListViewController: UIViewController {
    
    private var dataSource: [Breed] = []
    private let viewModel: BreedListViewModel
    private var cancellables: Set<AnyCancellable> = []

    init(viewModel: BreedListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    private lazy var tableView: UITableView = { [unowned self] in
        let tv = UITableView(frame: view.frame, style: .plain)
        tv.showsVerticalScrollIndicator = false
        tv.separatorStyle = .none
        tv.register(cellClass: BreedListTableViewCell.self)
        tv.backgroundColor = UIColor.systemBackground
        tv.dataSource = self
        tv.delegate = self
        return tv
    }()
    
    private let loadingView = ActivityIndicatorLoadingView(style: .large, color: .systemGray)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.accept(event: .onViewDidLoad)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.accept(event: .onViewWillAppear)
    }
    
    private let somethingWentWrongImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "oops"))
        iv.contentMode = .scaleAspectFill
        return iv
    }()

    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
                
        view.addSubview(loadingView)
        loadingView.frame = view.frame
        
        view.addSubview(somethingWentWrongImageView)
        somethingWentWrongImageView.frame = CGRect(x: 0, y: 0, width: view.frame.width - 20, height: view.frame.width - 20)
        somethingWentWrongImageView.center = view.center
    }
    
    private func bindViewModel() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.update($0) }
            .store(in: &cancellables)
    }

}

extension BreedListViewController {
    func update(_ state: BreedListState) {
        somethingWentWrongImageView.isHidden = true
        switch state {
        case .initial(moduleTitle: let title):
            navigationItem.title = title.capitalized
            dataSource = []
            loadingView.start()
            tableView.reloadData()
        case .loading:
            loadingView.start()
        case .failed:
            somethingWentWrongImageView.isHidden = false
        case .loaded(let data, _):
            dataSource = data
            tableView.reloadData()
            loadingView.stop()
        }
    }
}

extension BreedListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.accept(event: .onDidSelectBreedAtIndex(indexPath.row))
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: BreedListTableViewCell = tableView.dequeReusableCell(forIndexPath: indexPath)
        cell.set(with: dataSource[indexPath.row])
        return cell
    }
}


