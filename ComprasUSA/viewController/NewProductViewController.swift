//
//  NewProductViewController.swift
//  ComprasUSA
//
//  Created by Michelle Sinibaldi on 18/03/23.
//

import Foundation
import UIKit
import CoreData

class NewProductViewController: UIViewController {
    
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productName: UITextField!
    @IBOutlet weak var productState: UITextField!
    @IBOutlet weak var productSwitchCard: UISwitch!
    @IBOutlet weak var productPrice: UITextField!
    
    private var states: [NSManagedObject] = [] {
        didSet {
            statePicker.reloadAllComponents()
        }
    }
    
    private var selectedState: NSManagedObject?
    
    private var image: UIImage? {
        didSet {
            self.productImageView.image = image
            self.productImageView.setNeedsDisplay()
        }
    }
    
    private let statePicker = ToolbarPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.changeProductPicture))
        self.productImageView.addGestureRecognizer(tap)
        
        self.productState.inputView = statePicker
        self.productState.inputAccessoryView = statePicker.toolbar
        
        self.statePicker.delegate = self
        self.statePicker.dataSource = self
        self.statePicker.toolbarDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.fetchStates()
    }
    
    private func fetchStates() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "State")
        
        do {
            self.states = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    @objc private func changeProductPicture() {
        let action = UIAlertController(title: "Adicionar Foto",
                                       message: "De onde você quer escolher a imagem?",
                                       preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let photoLibrary = UIAlertAction(title: "Biblioteca de fotos", style: .default) { _ in
                let imagePicker = UIImagePickerController()
                imagePicker.sourceType = .photoLibrary
                imagePicker.allowsEditing = true
                imagePicker.delegate = self
                self.present(imagePicker, animated: true)
            }
            action.addAction(photoLibrary)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let camera = UIAlertAction(title: "Câmera", style: .default) { _ in
                let imagePicker = UIImagePickerController()
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = true
                imagePicker.delegate = self
                self.present(imagePicker, animated: true)
            }
            action.addAction(camera)
        }
        
        let cancel = UIAlertAction(title: "Cancelar", style: .cancel)
        action.addAction(cancel)
        
        self.present(action, animated: true, completion: nil)
    }
    
    func showAlert(message: String)  {
        let alert = UIAlertController(title: "Dados inválidos", message: "\(message)", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func validateProduct(_ product: Product) -> Bool {
        
        guard let name =  product.name, !name.isEmpty else {
            showAlert(message: "O nome do produto não pode ser vazio!")
            return false
        }

        guard let _ = product.photo else {
            showAlert(message: "Imagem do produto não pode ser vazio!")
            return false
        }
        
        guard let _ = product.state else {
            showAlert(message: "Selecione ou adicinone um estado")
            return false
        }

        guard let _ = product.price else {
            showAlert(message: "Preço do produto não pode ser vazio!")
            return false
        }

        return true
    }
    
    @IBAction func submitNewProduct(_ sender: Any) {
        let product = Product(context: self.context)
        
        product.creditCard = productSwitchCard.isOn
        product.name = productName.text
        product.photo = image?.pngData()
        product.price = Decimal(string: productPrice.text ?? "0" ) as NSDecimalNumber?
        product.state = selectedState as? State
        
        if validateProduct(product) {
            do {
                try context.save()
                navigationController?.popViewController(animated: true)
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        } else {
            context.rollback()
        }
    }
}

extension NewProductViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let presentedController = self.presentedViewController, presentedController is UIImagePickerController {
            presentedController.dismiss(animated: true, completion: nil)
        }
        
        guard let image = info[.editedImage] as? UIImage else {
            print("Imagem não encontrada")
            return
        }
        
        self.image = image
    }
    
}

extension NewProductViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return states.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return states[row].value(forKeyPath: "name") as? String
    }
}

extension NewProductViewController: ToolbarPickerViewDelegate {
    func didTapDone(tag: Int) {
        let row = statePicker.selectedRow(inComponent: 0)
        statePicker.selectRow(row, inComponent: 0, animated: false)
        if states.count - 1 >= row {
            productState.text = states[row].value(forKeyPath: "name") as? String
        }
        
        selectedState = states[row]
        
        self.view.endEditing(true)
    }
    
    func didTapCancel(tag: Int) {
        productState.text = selectedState?.value(forKeyPath: "name") as? String
        
        self.view.endEditing(true)
    }
}
