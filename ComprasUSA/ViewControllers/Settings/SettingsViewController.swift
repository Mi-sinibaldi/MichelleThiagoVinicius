//
//  SettingsViewController.swift
//  ComprasUSA
//
//  Created by Vinícius Furukawa Carvalho on 18/03/23.
//

import UIKit
import CoreData

class SettingsViewController: UIViewController {

    @IBOutlet weak var dollarExchangeRate: UITextField!
    @IBOutlet weak var rateSettings: UITextField!
    @IBOutlet weak var statesTableView: UITableView!
    
    var states: [NSManagedObject] = [] {
        didSet {
            DispatchQueue.main.async {
                self.statesTableView.reloadData()
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.statesTableView.delegate = self
        self.statesTableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.defaultsChanged),
                                               name: UserDefaults.didChangeNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.retrieveStates()
        
        UserDefaults.standard.synchronize()
        self.updateScreenFields()
    }

    @objc func defaultsChanged() {
        self.updateScreenFields()
    }
    
    private func updateScreenFields() {
        let defaults = UserDefaults.standard
        self.dollarExchangeRate.text = defaults.string(forKey: "dollar_exchange_rate")
        self.rateSettings.text = defaults.string(forKey: "rate_Settings")
        
        self.statesTableView.reloadData()
    }
    
    private func retrieveStates() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "StateEntity")
        
        do {
            self.states = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Failed to retrieve states. \(error), \(error.userInfo)")
        }
    }
    
    @IBAction func addState(_ sender: Any) {
        let alertController = UIAlertController(title: "Adicionar Estado", message: "", preferredStyle: .alert)
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Nome do estado"
        }
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Imposto"
        }
        
        let saveAction = UIAlertAction(title: "Adicionar", style: .default, handler: { alert -> Void in
            guard let fields = alertController.textFields, fields.count > 1 else { return }
            
            let state = fields[0].text ?? ""
            let rate = Double(fields[1].text ?? "0") ?? 0.0
            
            self.saveNewState(name: state, rate: rate)
        })
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func saveNewState(name: String, rate: Double) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        guard let entity = NSEntityDescription.entity(forEntityName: "StateId", in: context) else { return }
        let state = NSManagedObject(entity: entity, insertInto: context)
        
        state.setValue(name, forKeyPath: "name")
        state.setValue(rate, forKeyPath: "rate")
        
        do {
            try context.save()
            self.states.append(state)
        } catch let error as NSError {
            print("Unable to save state. \(error), \(error.userInfo)")
        }
    }
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        states.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StateId", for: indexPath) as? SettingsStateTableView else {
            return UITableViewCell()
        }
        
        let state = states[indexPath.row]
        
        cell.state?.text = state.value(forKeyPath: "name") as? String
        cell.rate?.text = String(state.value(forKeyPath: "rate") as? Double ?? 0.0)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let context = appDelegate.persistentContainer.viewContext
            
            let state = self.states[indexPath.row]
            context.delete(state)
            
            let fetchRequest: NSFetchRequest<ProductEntity> = ProductEntity.fetchRequest()
            let predicate = NSPredicate(format: "state == %@", state)
            fetchRequest.predicate = predicate
            
            do {
                let products = try context.fetch(fetchRequest)
                for product in products {
                    context.delete(product)
                }
            } catch let error as NSError {
                print("Could not find products associated to state. \(error), \(error.userInfo)")
            }
            
            do {
                try context.save()
                self.states.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
}
