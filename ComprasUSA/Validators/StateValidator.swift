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
    typealias E = StateEntity
    
    static func isValid(_ entity: StateEntity, on: UIViewController) -> Bool {
        return true
    }
}
