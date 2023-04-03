//
//  ShoppingSummaryViewController.swift
//  ComprasUSA
//
//  Created by Vinícius Furukawa Carvalho on 18/03/23.
//

import UIKit
import CoreData

class ShoppingSummaryViewController: UIViewController {
    
    @IBOutlet weak var brlTotalLabel: UILabel!
    @IBOutlet weak var dollarTotalLabel: UILabel!
    
    var products: [Product] = []
    var iof: Double = 1
    var dollar: Double = 1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.retrieveConfigurations()
        self.retrieveProducts()
        self.calculateSummary()
    }
    
    private func calculateSummary() {
        var dollarTotal: Double = 0;
        var brlTotal: Double = 0;
        
        for product in products {
            dollarTotal += product.price
            brlTotal += calculateTotalBrl(price: product.price,
                                          stateTax: product.state?.tax ?? 1,
                                          hasIOF: product.isCreditCard)
        }
        
        showValues(dollar: dollarTotal, brl: brlTotal)
    }
    
    private func calculateTotalBrl(price: Double, stateTax: Double, hasIOF: Bool) -> Double {
        let iof = hasIOF ? self.iof / 100.0 : 0
        let usTax = stateTax / 100.0
        return price * (1.0 + usTax) * self.dollar * (1.0 + iof)
    }
    
    private func showValues(dollar: Double, brl: Double) {
        dollarTotalLabel.text = String(format: "%.3f", dollar)
        brlTotalLabel.text = String(format: "%.4f", brl)
    }
    
    private func retrieveConfigurations() {
        let defaults = UserDefaults.standard
        
        if let dollar = defaults.string(forKey: "dollar") {
            self.dollar = Double(dollar) ?? 3.2
        }
        
        if let iof = defaults.string(forKey: "iof") {
            self.iof = Double(iof) ?? 6.38
        }
    }
    
    private func retrieveProducts() {
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        
        do {
            products = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not retrieve products. \(error), \(error.userInfo)")
        }
    }

}
