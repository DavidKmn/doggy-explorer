//
//  UICollectionView+Ext.swift
//  doggy-explorer
//
//  Created by David Kaufman on 12/05/2021.
//

import UIKit


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
