//
//  MainTabBarController.swift
//  SwiftCairo
//
//  Created by Ahmed Ramy on 5/13/18.
//  Copyright © 2018 Ahmed Ramy. All rights reserved.
//

import UIKit
import FirebaseAuth
import SVProgressHUD

class MainTabBarController: UITabBarController {

    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    fileprivate func returnToRootView()
    {
        //return to the Welcome Screen
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapLogOut(_ sender: Any)
    {
        do
        {
            try Auth.auth().signOut()
        }
        catch
        {
            SVProgressHUD.showError(withStatus: error.localizedDescription)
            return
        }
        clearUserDefaults()
        returnToRootView()
    }
}
