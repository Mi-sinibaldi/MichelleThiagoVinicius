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
        return true
    }
}
