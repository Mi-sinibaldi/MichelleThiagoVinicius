//
//  NewProductViewController.swift
//  ComprasUSA
//
//  Created by Vinícius Furukawa Carvalho on 18/03/23.
//

import UIKit

class NewProductViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func clicked(_ sender: Any) {
        
        //let stateRepository = StateRepository()
        
        /*
        //WRITE
         
        let s1 = State()
        s1.name = "SP"
        s1.tax = 99.9
        
        let s2 = State()
        s2.name = "RJ"
        s2.tax = 66.6
        
        stateRepository.save(data: s1)
        stateRepository.save(data: s2)
        
        
        //READ
        let allStates = stateRepository.findAll()
        for state in allStates {
            print("\(state.name) - \(state.tax)")
        }
         
         lendo um pouco mais sobre coredata por esse link: https://medium.com/@meggsila/core-data-relationship-in-swift-5-made-simple-f51e19b28326
         vi que isso tudo já existe de forma automagica! Basta injetar o context nas entities.
        */
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
