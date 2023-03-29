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
    @IBOutlet weak var switchProduct: UISwitch!
    @IBOutlet weak var imageProduct: UIImageView!
    
    private var states: [StateEntity] = [] {
        didSet {
            stateSelector.reloadAllComponents()
        }
    }
    
    private var image: UIImage? {
        didSet {
            self.imageProduct.image = image
            self.imageProduct.setNeedsDisplay()
        }
    }
    
    private var selectedState: NSManagedObject?
    
    private let stateSelector = ToolbarPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTap()
        
        self.stateProduct.inputView = stateSelector
        self.stateProduct.inputAccessoryView = stateSelector.toolbar
        
        self.stateSelector.delegate = self
        self.stateSelector.dataSource = self
        self.stateSelector.toolbarDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.retrieveStates()
    }
    
    // MARK: - Button and ImageView tap action
    
    @objc private func productImageTapped() {
        self.present(imagePicker(), animated: true, completion: nil)
    }
    
    @IBAction func createProduct(_ sender: Any) {
        let product = createProductEntity()
        
        if ProductValidator.isValid(product, on: self) {
            do {
                try context.save()
                navigationController?.popViewController(animated: true)
            } catch let error as NSError {
                print("Error on save product. \(error), \(error.userInfo)")
            }
        } else {
            context.rollback()
        }
    }
    
    // MARK: - CoreData functions
    
    private func createProductEntity() -> ProductEntity {
        let product = ProductEntity(context: self.context)
        
        product.isCreditCard = switchProduct.isOn
        product.name = nameProduct.text
        product.image = image?.pngData()
        product.price = Double(valueProduct.text ?? "") ?? -1.0
        product.state = selectedState as? StateEntity
        
        return product
    }
    
    private func retrieveStates() {
        let fetchRequest: NSFetchRequest<StateEntity> = StateEntity.fetchRequest()
        
        do {
            self.states = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Failed to retrieve states. \(error), \(error.userInfo)")
        }
    }
    
    // MARK: - Image picker
    
    private func imagePicker() -> UIAlertController {
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
        
        return action
    }
    
    // MARK: - General configurations
    
    private func configureTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.productImageTapped))
        self.imageProduct.addGestureRecognizer(tapGesture)
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
        let row = stateSelector.selectedRow(inComponent: 0)
        stateSelector.selectRow(row, inComponent: 0, animated: false)
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
