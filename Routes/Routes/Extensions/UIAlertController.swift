//
//  UIAlertController.swift
//  Routes
//
//  Created by Alina on 22.01.2022.
//

import UIKit

extension ViewController {
    
    func showAddAddressAlert(title: String, placeholder: String, completionHandler: @escaping (String) -> Void) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let alertOk = UIAlertAction(title: "OK", style: .default) { action in
            let tfText = alertController.textFields?.first
            guard let text = tfText?.text else { return }
            completionHandler(text)
        }
        let alertCancel = UIAlertAction(title: "Cancel", style: .default) { (_) in
        }
        
        alertController.addTextField{ (text) in
            text.placeholder = placeholder
        }
        
        alertController.addAction(alertOk)
        alertController.addAction(alertCancel)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func showErrorAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertOk = UIAlertAction(title: "OK", style: .default)
        
        alertController.addAction(alertOk)
        present(alertController, animated: true, completion: nil)
    }
}
