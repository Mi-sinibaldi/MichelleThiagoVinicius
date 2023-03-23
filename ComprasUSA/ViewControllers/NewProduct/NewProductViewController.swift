//
//  NewProductViewController.swift
//  ComprasUSA
//
//  Created by Vinícius Furukawa Carvalho on 18/03/23.
//

import UIKit
import CoreData
import AVFoundation

class NewProductViewController: UIViewController {
    
    @IBOutlet weak var nameProduct: UITextField!
    @IBOutlet weak var stateProduct: UITextField!
    @IBOutlet weak var valueProduct: UITextField!
    @IBOutlet weak var imageProduct: UIImageView!
    @IBOutlet weak var switchProduct: UISwitch!
    
    private var states: [NSManagedObject] = [] {
          didSet {
              statePicker.reloadAllComponents()
          }
      }
    
        private var image: UIImage? {
            didSet {
                self.imageProduct.image = image
                self.imageProduct.setNeedsDisplay()
            }
        }
        
    private var selectedState: NSManagedObject?
    
    private let statePicker = ToolbarPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: self, action: #selector(self.changeProductPicture))
               self.imageProduct.addGestureRecognizer(tap)
               
               self.stateProduct.inputView = statePicker
               self.stateProduct.inputAccessoryView = statePicker.toolbar
               
               self.statePicker.delegate = self
               self.statePicker.dataSource = self
               self.statePicker.toolbarDelegate = self
        
    }
    
    // opens device camera and gallery
    @objc private func changeProductPicture() {
            let action = UIAlertController(title: "Adicionar Imagem",
                                           message: "De onde você quer escolher a imagem do produto?",
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
    
    override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
          
          self.fetchStates()
      }
      
      private func fetchStates() {
          guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
          
          let managedContext = appDelegate.persistentContainer.viewContext
          
          let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "StateEntity")
          
          do {
              self.states = try managedContext.fetch(fetchRequest)
          } catch let error as NSError {
              print("Could not fetch. \(error), \(error.userInfo)")
          }
      }
    
    func showAlert(message: String)  {
            let alert = UIAlertController(title: "Dados inválidos", message: "\(message)", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            
        }
    
    func verifyProduct(_ product: Product) -> Bool {
            
            guard let name =  product.name, !name.isEmpty else {
                showAlert(message: "Nome do produto é obrigatório!")
                return false
            }

            guard let _ = product.image else {
                showAlert(message: "Imagem do produto é obrigatório!")
                return false
            }
            
            guard let _ = product.state else {
                showAlert(message: "Selecione ou adicinone um estado")
                return false
            }

            guard let _ = product.price else {
                showAlert(message: "Preço do produto é obrigatório!")
                return false
            }

            return true
        }
    
    
    @IBAction func sendNewProduct(_ sender: Any) {
        
        let product = Product(context: self.context)
        
                product.isCreditCard = switchProduct.isOn
                product.name = nameProduct.text
                product.image = image?.pngData()
                product.price = Decimal(string: valueProduct.text ?? "0" ) as NSDecimalNumber?
                product.state = selectedState as? StateEntity
                
                if verifyProduct(product) {
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
            stateProduct.text = states[row].value(forKeyPath: "name") as? String
        }
        
        selectedState = states[row]
        
        self.view.endEditing(true)
    }
    
    func didTapCancel(tag: Int) {
        stateProduct.text = selectedState?.value(forKeyPath: "name") as? String
        
        self.view.endEditing(true)
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
