//
//  BreedListTableViewCell.swift
//  doggy-explorer
//
//  Created by David Kaufman on 12/05/2021.
//

import UIKit

final class BreedsListTableViewCell: UITableViewCell {
    
    private let cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.backgroundColor = UIColor.secondarySystemBackground
        return view
    }()
    
    private let breedLabel: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.font = UIFont.preferredFont(forTextStyle: .title1)
        lbl.textColor = UIColor.label
        return lbl
    }()
    
    private let subBreedsLabel: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.font = UIFont.preferredFont(forTextStyle: .title2)
        lbl.textColor = UIColor.secondaryLabel
        return lbl
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(with breed: Breed) {
        breedLabel.text = breed.name.capitalized
        if !breed.subBreedNames.isEmpty {
            subBreedsLabel.isHidden = false
            subBreedsLabel.text = breed.subBreedNames.map({ $0.capitalized }).joined(separator: ", ")
        } else {
            subBreedsLabel.isHidden = true
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        breedLabel.text = nil
        subBreedsLabel.text = nil
    }
    
    private func setupUI() {
        contentView.backgroundColor = .systemBackground
        
        contentView.addSubview(cardView)
        cardView.layer.applyDropShadow()
        cardView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
        
        let sv = UIStackView(arrangedSubviews: [breedLabel, subBreedsLabel])
        sv.axis = .vertical
        contentView.addSubview(sv)
        sv.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sv.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 10),
            sv.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -10),
            sv.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 10),
            sv.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -10)
        ])
        
    }
}

