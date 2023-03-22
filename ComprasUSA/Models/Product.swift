//
//  Product.swift
//  ComprasUSA
//
//  Created by Vinícius Furukawa Carvalho on 18/03/23.
//

import UIKit
import CoreData

class Product: RepositoryAdapter {
    
    var name: String = ""
    var isCreditCard: Bool = false
    var state: String = ""
    var price: Double = 0.0
    var image: UIImage = UIImage(named: "bag.fill.badge.plus")!
    
    func toData() -> [String : Any] {
        return [
            "price": self.price,
            "name": self.name,
            "isCreditCard": self.isCreditCard,
            "image": self.image.pngData()!
        ]
    }
    
    static func fromData(_ dataSet: [NSManagedObject]) -> Any {
        var productList: [Product] = []
        
        for data in dataSet {
            let product = Product()
            product.price = data.value(forKey: "price") as! Double
            product.name = data.value(forKey: "name") as! String
            product.isCreditCard = data.value(forKey: "isCreditCard") as! Bool
            product.image = UIImage(data: data.value(forKey: "image") as! Data)!
            
            productList.append(product)
        }
        
        return productList
    }
}
