//
//  UIViewControllerExtension.swift
//  ComprasUSA
//
//  Created by Vinícius Furukawa Carvalho on 23/03/23.
//

import UIKit
import CoreData

extension UIViewController {
    var context: NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
}
