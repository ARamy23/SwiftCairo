//
//  RegisterPopupViewController.swift
//  SwiftCairo
//
//  Created by Ahmed Ramy on 5/12/18.
//  Copyright © 2018 Ahmed Ramy. All rights reserved.
//

import UIKit
import FirebaseAuth
import SVProgressHUD

class RegisterPopupViewController: UIViewController, SBCardPopupContent {
    var popupViewController: SBCardPopupViewController?
    
    var allowsTapToDismissPopupCard: Bool = true
    
    var allowsSwipeToDismissPopupCard: Bool = true
    
    static func create() -> UIViewController
    {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "RegisterPopupViewController") as! RegisterPopupViewController
        
        return storyboard
    }

    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmationTextField: UITextField!
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGestureRecognizers()
        customizeUI()
        
    }
    
    fileprivate func setupGestureRecognizers()
    {
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    //Calls this function when the tap is recognized.
    @objc private func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    fileprivate func customizeUserProfileImage()
    {
        userProfileImageView.layer.cornerRadius = userProfileImageView.frame.height / 2
        userProfileImageView.layer.borderWidth = 0.75
        userProfileImageView.layer.borderColor = #colorLiteral(red: 0.983099997, green: 0.5982919885, blue: 0.03144000097, alpha: 1)
    }
    
    fileprivate func customizeContainerView()
    {
        containerView.layer.cornerRadius = 10
        containerView.layer.borderColor = #colorLiteral(red: 0.983099997, green: 0.5982919885, blue: 0.03144000097, alpha: 1)
        containerView.layer.borderWidth = 1
    }
    
    fileprivate func customizeUI()
    {
        customizeUserProfileImage()
        customizeContainerView()
    }
    
    func setEssentialUserDefaults(username: String, email: String, password: String)
    {
        UserDefaults.standard.set(username, forKey: UDefaults.Username.rawValue)
        UserDefaults.standard.set(email, forKey: UDefaults.Email.rawValue)
        UserDefaults.standard.set(password, forKey: UDefaults.Password.rawValue)
        UserDefaults.standard.set(true, forKey: UDefaults.hasAlreadyLogged.rawValue)
    }
    
    
    @IBAction func didTapPickAProfileImage(_ sender: Any)
    {
        handlePickingUserImage()
    }
    
    @IBAction func didTapRegisterButton(_ sender: Any)
    {
        handleRegister()
    }
    
}
