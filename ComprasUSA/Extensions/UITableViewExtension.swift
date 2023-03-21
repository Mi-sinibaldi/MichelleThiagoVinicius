//
//  UITableViewExtension.swift
//  ComprasUSA
//
//  Created by Vinícius Furukawa Carvalho on 18/03/23.
//

import UIKit

extension UITableView {

    func isEmpty() {
        let emptyListMessage = createLabelEmptyList()
        config(background: emptyListMessage, separator: .none)
    }

    func hasContent() {
        config()
    }
    
    private func config(background: UILabel? = nil, separator: UITableViewCell.SeparatorStyle = .singleLine) {
        self.backgroundView = background
        self.separatorStyle = separator
    }
    
    private func createLabelEmptyList() -> UILabel{
        let emptyListLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        emptyListLabel.text = "Sua lista está vazia!"
        emptyListLabel.textColor = .gray
        emptyListLabel.numberOfLines = 0
        emptyListLabel.textAlignment = .center
        emptyListLabel.font = UIFont(name: emptyListLabel.font.familyName, size: 20)
        emptyListLabel.sizeToFit()
        
        return emptyListLabel
    }
}
