//
//  ProductTableViewCell.swift
//  ComprasUSA
//
//  Created by Vinícius Furukawa Carvalho on 18/03/23.
//

import UIKit

final class ProductTableViewCell: UITableViewCell {
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var paymentType: UILabel!
    @IBOutlet weak var state: UILabel!
    @IBOutlet weak var price: UILabel!
}
