//
//  Login Handlers.swift
//  SwiftCairo
//
//  Created by Ahmed Ramy on 5/14/18.
//  Copyright © 2018 Ahmed Ramy. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import SVProgressHUD

extension LoginPopupViewController
{
    
    private func handleUserDefaults(user: User,email: String, password: String)
    {
        fetchCurrentUserUsername()
        UserDefaults.standard.set(email, forKey: UDefaults.Email.rawValue)
        UserDefaults.standard.set(password, forKey: UDefaults.Password.rawValue)
        UserDefaults.standard.set(true, forKey: UDefaults.hasAlreadyLogged.rawValue)
    }
    
    private func fetchCurrentUserUsername()
    {
        let currentUserRef = SharedData.sharedInstance.currentUserRef

        currentUserRef.observe(.value) { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]
            {
                let username = dictionary["Name"] as! String
                UserDefaults.standard.set(username, forKey: UDefaults.Username.rawValue)
            }
        }
    }
    
    func handleLogin(email: String, password: String)
    {
        SVProgressHUD.show(withStatus: "Logging you IN!")
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil
            {
                SVProgressHUD.showError(withStatus: error?.localizedDescription)
                return
            }
            else
            {
                SVProgressHUD.dismiss()
                SVProgressHUD.showInfo(withStatus: "Welcome Back!")
                self.handleUserDefaults(user: user!, email: email, password: password)
                self.performSegue(withIdentifier: Navigation.goToMainView.rawValue, sender: self)
            }
        })
    }
    
}

