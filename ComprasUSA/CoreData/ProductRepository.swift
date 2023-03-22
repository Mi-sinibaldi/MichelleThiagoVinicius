//
//  ProductRepository.swift
//  ComprasUSA
//
//  Created by Vinícius Furukawa Carvalho on 21/03/23.
//

import Foundation

class ProductRepository: Repository<Product> {
    
    init() {
        super.init(.PRODUCT)
    }
}
