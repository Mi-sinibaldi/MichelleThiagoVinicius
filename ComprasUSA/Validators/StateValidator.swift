//
//  StateValidator.swift
//  ComprasUSA
//
//  Created by Vinícius Furukawa Carvalho on 23/03/23.
//

import Foundation
import CoreData
import UIKit

class StateValidator: Validator {
    typealias E = State
    
    static func isValid(_ entity: State, on: UIViewController) -> Bool {
        
        guard let name = entity.name, !name.isEmpty else {
            Alert.showAlert(message: "Por favor um nome válido.", viewController: on)
            return false
        }
        
        if entity.tax <= 0.0 {
            Alert.showAlert(message: "Por favor insira uma taxa valida.", viewController: on)
            return false
        }
        
        return true
    }
}
