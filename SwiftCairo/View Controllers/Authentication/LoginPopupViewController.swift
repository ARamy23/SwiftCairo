//
//  LoginViewController.swift
//  SwiftCairo
//
//  Created by Ahmed Ramy on 5/13/18.
//  Copyright © 2018 Ahmed Ramy. All rights reserved.
//

import UIKit
import SVProgressHUD

class LoginPopupViewController: UIViewController, SBCardPopupContent{
    
    var popupViewController: SBCardPopupViewController?
    
    var allowsTapToDismissPopupCard: Bool = true
    
    var allowsSwipeToDismissPopupCard: Bool = true
    
    static func create() -> UIViewController
    {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginPopupViewController") as! LoginPopupViewController
        
        return storyboard
    }
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func didTapLoginButton(_ sender: Any)
    {
        guard let email = emailTextField.text, let password = passwordTextField.text else {SVProgressHUD.showError(withStatus: "Form is not Complete"); return;}
        handleLogin(email: email, password: password)
        
    }
    
}
