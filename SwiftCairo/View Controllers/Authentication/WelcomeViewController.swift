//
//  WelcomeViewController.swift
//  SwiftCairo
//
//  Created by Ahmed Ramy on 5/12/18.
//  Copyright © 2018 Ahmed Ramy. All rights reserved.
//

import UIKit
import FirebaseAuth
import SVProgressHUD

class WelcomeViewController: UIViewController
{

    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        handleAutoLogin()
    }
    
    @IBAction func didTapLoginButton(_ sender: Any)
    {
        let popup = LoginPopupViewController.create()
        let sbPopup = SBCardPopupViewController(contentViewController: popup)
        sbPopup.show(onViewController: self)
    }
    
    @IBAction func didTapRegisterButton(_ sender: Any)
    {
        let popup = RegisterPopupViewController.create()
        let sbPopup = SBCardPopupViewController(contentViewController: popup)
        sbPopup.show(onViewController: self)
    }
    
}

