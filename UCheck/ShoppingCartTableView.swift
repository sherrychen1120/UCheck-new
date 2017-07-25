//
//  ShoppingCartTableView.swift
//  UCheck
//
//  Created by Sherry Chen on 7/23/17.
//
//

import UIKit

class ShoppingCartTableView: UITableView, CustomCellUpdater {

    func updateTableView() {
        self.reloadData()
    }
}
