//
//  ViewController.swift
//  doggy-explorer
//
//  Created by David Kaufman on 12/05/2021.
//

import UIKit


extension UITableViewCell {

    public static var reuseIdentifier: String {
        return String(describing: self)
    }
    
}

extension UITableView {
    
    public func dequeReusableCell<Cell: UITableViewCell>(forIndexPath indexPath: IndexPath) -> Cell {
        return dequeueReusableCell(withIdentifier: Cell.reuseIdentifier, for: indexPath) as! Cell
    }
    
    public func register(cellClass: AnyClass) {
        self.register(cellClass, forCellReuseIdentifier: (cellClass as! UITableViewCell.Type).reuseIdentifier)
    }
    
}
