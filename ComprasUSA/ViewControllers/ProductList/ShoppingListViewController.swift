//
//  ShoppingListViewController.swift
//  ComprasUSA
//
//  Created by Vinícius Furukawa Carvalho on 18/03/23.
//

import UIKit
import CoreData

class ShoppingListViewController: UITableViewController {

    var products: [Product] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.retrieveProducts()
    }
    
    // MARK: - Table functions
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProductId", for: indexPath) as? ProductTableViewCell else {
            return UITableViewCell()
        }
        
        let product = products[indexPath.row]
        
        cell.name?.text = product.name!
        cell.price?.text = String(product.price)
        
        if let imageData = product.image {
            cell.productImage?.image = UIImage(data: imageData)
        } else {
            cell.productImage?.image = UIImage(named: "bag.fill.badge.plus")
        }
        
        if product.isCreditCard {
            cell.paymentType?.text = "Cartão"
        } else {
            cell.paymentType?.text = "Outro"
        }
        
        if let state = product.state {
            cell.state?.text = state.name
        } else {
            cell.state?.text = ""
        }
                
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteProductBy(indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if products.count == 0 {
            self.tableView.isEmpty()
        } else {
            self.tableView.hasContent()
        }
        return products.count
    }
    
    // MARK: - CoreData functions
    
    private func deleteProductBy(_ indexPath: IndexPath) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        let product = self.products[indexPath.row]
        context.delete(product)
        
        do {
            try context.save()
            self.products.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        } catch let error as NSError {
            print("Could not delete product. \(error), \(error.userInfo)")
        }
    }
    
    private func retrieveProducts() {
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        
        do {
            products = try context.fetch(fetchRequest)
            tableView.reloadData()
        } catch let error as NSError {
            print("Could not retrieve products. \(error), \(error.userInfo)")
        }
    }
}
