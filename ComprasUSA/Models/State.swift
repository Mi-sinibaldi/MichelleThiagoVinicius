//
//  State.swift
//  ComprasUSA
//
//  Created by Vinícius Furukawa Carvalho on 21/03/23.
//

import Foundation
import CoreData

class State: RepositoryAdapter {
    
    var name: String = ""
    var tax: Double = 0.0
    
    func toData() -> [String : Any] {
        return [
            "tax": self.tax,
            "name": self.name
        ]
    }
    
    static func fromData(_ dataSet: [NSManagedObject]) -> Any {
        var stateList: [State] = []
        
        for data in dataSet {
            let state = State()
            state.name = data.value(forKey: "name") as! String
            state.tax = data.value(forKey: "tax") as! Double
            
            stateList.append(state)
        }
        
        return stateList
    }
}
