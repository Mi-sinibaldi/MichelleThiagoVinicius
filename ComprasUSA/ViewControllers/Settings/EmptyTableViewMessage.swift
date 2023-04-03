//
//  EmptyTableViewMessage.swift
//  ComprasUSA
//
//  Created by Vinícius Furukawa Carvalho on 30/03/23.
//

import Foundation
import UIKit

class EmptyTableViewMessage: UIView {
    let messageLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        messageLabel.text = "Lista de estados vazia."
        messageLabel.textAlignment = .center
        messageLabel.textColor = .gray
        addSubview(messageLabel)
        
        // Define as restrições do messageLabel para que ele fique centralizado na view
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        messageLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
