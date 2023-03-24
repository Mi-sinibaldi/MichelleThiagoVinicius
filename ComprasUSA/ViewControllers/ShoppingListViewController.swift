//
//  ShoppingListViewController.swift
//  ComprasUSA
//
//  Created by Vinícius Furukawa Carvalho on 18/03/23.
//

import UIKit

class ShoppingListViewController: UITableViewController {

    var products: [ProductEntity] = [];

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if products.count == 0 {
            self.tableView.isEmpty()
        } else {
            self.tableView.hasContent()
        }
        return products.count
    }

}
