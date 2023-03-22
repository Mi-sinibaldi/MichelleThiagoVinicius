//
//  Repository.swift
//  ComprasUSA
//
//  Created by Vinícius Furukawa Carvalho on 21/03/23.
//

import Foundation
import UIKit
import CoreData

protocol RepositoryAdapter {
    func toData() -> [String: Any]
    static func fromData(_ dataSet: [NSManagedObject]) -> Any
}

enum EntityName: String {
    case PRODUCT = "ProductEntity"
    case STATE = "StateEntity"
}

class Repository<E> where E: RepositoryAdapter {
    
    var entityName: String
    var appDelegate: AppDelegate
    var context: NSManagedObjectContext

    init (_ entityName: EntityName) {
        self.entityName = entityName.rawValue
        self.appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.context = appDelegate.persistentContainer.viewContext
    }
    
    func save(data: E) {
        let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: self.context)
        let newEntry = NSManagedObject(entity: entity!, insertInto: self.context)
        
        for (key, value) in data.toData() {
            newEntry.setValue(value, forKey: key)
        }
        
        do {
          try context.save()
         } catch {
          print("Error on saving.")
        }
    }
    
    func findAll() -> [E] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        var result = [NSManagedObject]()
        
        do {
            let records = try self.context.fetch(request)
            if let records = records as? [NSManagedObject] {
                result = records
            }
        } catch {
            print("Failed to retrieve data.")
        }
        
        return E.fromData(result) as! [E];
    }
    
    func deleteBy(entity: NSManagedObject) {
        self.context.delete(entity)
        
        do {
            try context.save()
        } catch {
            print("Failed to delete data.")
        }
    }
}
