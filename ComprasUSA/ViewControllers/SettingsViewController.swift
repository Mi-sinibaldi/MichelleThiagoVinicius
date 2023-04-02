//
//  SettingsViewController.swift
//  ComprasUSA
//
//  Created by Thiago on 02/04/23.
//

import UIKit
import CoreData

class SettingsViewController: UIViewController {

    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var iofTextField: UITextField!
    @IBOutlet weak var stateTableView: UITableView!
    
    var states: [StateEntity] = [] {
        didSet {
            DispatchQueue.main.async {
                self.stateTableView.reloadData()
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.stateTableView.delegate = self
        self.stateTableView.dataSource = self
        
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
        self.priceTextField.text = defaults.string(forKey: "price")
        self.iofTextField.text = defaults.string(forKey: "iof")
        
        self.stateTableView.reloadData()
    }
    
    private func retrieveStates() {
        let fetchRequest: NSFetchRequest<StateEntity> = StateEntity.fetchRequest()
        
        do {
            self.states = try context.fetch(fetchRequest)
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
            let tax = Double(fields[1].text ?? "0") ?? 0.0
            
            self.saveNewState(name: state, tax: tax)
        })
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func editState(indexPath: Int, name: String, tax: Double) {
        let state = self.states[indexPath]
        state.tax = tax
        state.name = name
        
        if StateValidator.isValid(state, on: self) {
            do {
                try context.save()
                retrieveStates()
            } catch let error as NSError {
                print("Error on save product. \(error), \(error.userInfo)")
            }
        } else {
            context.rollback()
        }
    }
    
    private func saveNewState(name: String, tax: Double) {
        let state = StateEntity(context: self.context)
        state.tax = tax
        state.name = name
        
        if StateValidator.isValid(state, on: self) {
            do {
                try context.save()
                retrieveStates()
                navigationController?.popViewController(animated: true)
            } catch let error as NSError {
                print("Error on save product. \(error), \(error.userInfo)")
            }
        } else {
            context.rollback()
        }
    }
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return states.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StateId", for: indexPath) as? SettingsStateTableView else {
            return UITableViewCell()
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(rowTapped(_:)))
        cell.addGestureRecognizer(tapGesture)
                
        let state = states[indexPath.row]
        
        cell.setName?.text = state.name
        cell.setTaxa?.text = String(state.tax)
        cell.tag = indexPath.row
        
        return cell
    }
        
    @objc func rowTapped(_ sender: UITapGestureRecognizer) {
        guard let row = sender.view as? SettingsStateTableView else {
            return
        }
        
        let alertController = UIAlertController(title: "Editar Estado", message: "", preferredStyle: .alert)
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Nome do estado"
            textField.text = row.setName.text
        }
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Imposto"
            textField.text = row.setTaxa.text
        }
        
        let saveAction = UIAlertAction(title: "Salvar", style: .default, handler: { alert -> Void in
            guard let fields = alertController.textFields, fields.count > 1 else { return }
            let indexPath = IndexPath(row: row.tag, section: 0)
            
            let state = fields[0].text ?? ""
            let tax = Double(fields[1].text ?? "0") ?? 0.0
            
            self.editState(indexPath: indexPath.row, name: state, tax: tax)
        })
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
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
