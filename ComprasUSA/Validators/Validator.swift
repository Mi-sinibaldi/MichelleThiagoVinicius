//
//  Validator.swift
//  ComprasUSA
//
//  Created by Vinícius Furukawa Carvalho on 23/03/23.
//

import UIKit

protocol Validator {
    associatedtype E

    static func isValid(_ entity: E, on: UIViewController) -> Bool
}
