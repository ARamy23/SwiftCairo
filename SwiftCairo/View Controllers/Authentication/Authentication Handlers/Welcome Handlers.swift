//
//  Welcome Handlers.swift
//  SwiftCairo
//
//  Created by Ahmed Ramy on 5/14/18.
//  Copyright © 2018 Ahmed Ramy. All rights reserved.
//

import FirebaseAuth
import SVProgressHUD

extension WelcomeViewController
{
    func handleAutoLogin()
    {
        if UserDefaults.standard.bool(forKey: UDefaults.hasAlreadyLogged.rawValue)
        {
            let email = UserDefaults.standard.string(forKey: UDefaults.Email.rawValue)
            let password = UserDefaults.standard.string(forKey: UDefaults.Password.rawValue)
            SVProgressHUD.show()
            Auth.auth().signIn(withEmail: email!, password: password!) { (user, error) in
                SVProgressHUD.dismiss()
                if error != nil
                {
                    SVProgressHUD.showError(withStatus: error?.localizedDescription)
                    
                    //Clear the UserDefaults in case of autologging in failure
                    ///Which is maybe not possible unless the user is deleted from the db
                    clearUserDefaults()
                }
                else
                {
                    SVProgressHUD.showInfo(withStatus: "Welcome Back!")
                    self.performSegue(withIdentifier: Navigation.goToMainView.rawValue, sender: self)
                }
            }
        }
    }
}
