//
//  ProductValidator.swift
//  ComprasUSA
//
//  Created by Vinícius Furukawa Carvalho on 23/03/23.
//

import Foundation
import UIKit

class ProductValidator: Validator {
    typealias E = ProductEntity
    
    static func isValid(_ entity: ProductEntity, on: UIViewController) -> Bool {
        guard let name =  entity.name, !name.isEmpty else {
            Alert.showAlert(message: "Por favor informe o nome do produto.", viewController: on)
            return false
        }

        guard let _ = entity.image else {
            Alert.showAlert(message: "Por favor insira uma foto do produto.", viewController: on)
            return false
        }
        
        guard let _ = entity.state else {
            Alert.showAlert(message: "Por favor selecione o estado do produto.", viewController: on)
            return false
        }
        
        if entity.price <= 0.0 {
            Alert.showAlert(message: "Por favor informe o preço valido para o produto", viewController: on)
            return false
        }
        
        return true
    }
}
