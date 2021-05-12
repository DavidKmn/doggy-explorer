//
//  ActivityIndicatorLoadingView.swift
//  doggy-explorer
//
//  Created by David Kaufman on 12/05/2021.
//

import UIKit

final class ActivityIndicatorLoadingView: UIView {
    
    init(style: UIActivityIndicatorView.Style, color: UIColor = .white) {
        activityIndicator = UIActivityIndicatorView(style: style)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = color
        super.init(frame: .zero)
        setup()
    }
    
    private let activityIndicator: UIActivityIndicatorView
    
    private func setup() {
        addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        stop()
    }
            
    func start() {
        isHidden = false
        activityIndicator.startAnimating()
    }
    
    func stop() {
        isHidden = true
        activityIndicator.stopAnimating()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

