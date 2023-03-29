//
//  Alert.swift
//  ComprasUSA
//
//  Created by Vinícius Furukawa Carvalho on 23/03/23.
//

import Foundation
import UIKit

class Alert {
        
    static func showAlert(message: String, viewController: UIViewController) {
        let alertController = UIAlertController(title: "Ops!", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        viewController.present(alertController, animated: true, completion: nil)
    }    
}
