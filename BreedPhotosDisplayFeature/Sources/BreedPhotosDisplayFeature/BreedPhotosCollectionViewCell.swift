//
//  BreedPhotosCollectionViewCell.swift
//  doggy-explorer
//
//  Created by David Kaufman on 12/05/2021.
//

import UIKit
import Combine
import iOSUIComponents

final class BreedPhotosCollectionViewCell: UICollectionViewCell {
    
    private let cardView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 12
        view.backgroundColor = UIColor.secondarySystemBackground
        return view
    }()
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    private let loadingView = ActivityIndicatorLoadingView(style: .large, color: .systemGray)
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        cancellable?.cancel()
        cancellable = nil
        loadingView.stop()
    }
    
    enum State {
        case loading
        case loaded(UIImage)
        case failed
    }
    
    func set(with state: State) {
        switch state {
        case .loading:
            loadingView.start()
            imageView.image = nil
        case .loaded(let image):
            loadingView.stop()
            imageView.image = image
        case .failed:
            loadingView.stop()
            imageView.image = UIImage(named: "oops")
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var cancellable: Cancellable?
    
    private func setupUI() {
        contentView.backgroundColor = .systemBackground

        contentView.addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])

        cardView.addSubview(loadingView)
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: contentView.topAnchor),
            loadingView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            loadingView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        
        cardView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: cardView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor)
        ])
    }
}
