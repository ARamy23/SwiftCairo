//
//  Register Handlers.swift
//  SwiftCairo
//
//  Created by Ahmed Ramy on 5/14/18.
//  Copyright © 2018 Ahmed Ramy. All rights reserved.
//

import FirebaseAuth
import SVProgressHUD


extension RegisterPopupViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    func handleRegister()
    {
        let username = usernameTextField.text!
        let email = emailTextField.text!
        let password = passwordTextField.text!
        let confirmPassword = passwordConfirmationTextField.text!
        let userPic = userProfileImageView.image! //We don't need to check this since we have a default userImage
        
        if isInputValid(username: username, email: email, password: password, confirmPassword: confirmPassword)
        {
            SVProgressHUD.show(withStatus: "Registering You UP!")
            
            Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                if error != nil
                {
                    SVProgressHUD.showError(withStatus: error?.localizedDescription)
                    return
                }
                else // if registeration is a success
                {
                    SVProgressHUD.dismiss()
                    self.handleRegisteringUserIntoDB(uid: (user?.uid)!, username: username, email: email)
                    self.handleUserImageStorage(uid: (user?.uid)!, userPic: userPic)
                    self.setEssentialUserDefaults(username: username, email: email, password: password)
                    self.performSegue(withIdentifier: Navigation.goToMainView.rawValue, sender: self)
                }
            })
            
        }
        else //if input is not valid (isInputValid() -> false)
        {
            return
        }
    }
    
    
    
    fileprivate func isUsernameValid(username: String) -> Bool
    {
        if (username.isEmpty)
        {
            SVProgressHUD.showError(withStatus: "Username can't be left Empty!")
            return false
        }
        
        return true
    }
    
    fileprivate func isEmailValid(email: String) -> Bool
    {
        if (email.isEmpty)
        {
            SVProgressHUD.showError(withStatus: "Email can't be left Empty!")
            return false
        }
        
        if !(email.isEmail)
        {
            SVProgressHUD.showError(withStatus: "Email is badly written!")
            return false
        }
        
        return true
    }
    
    fileprivate func isPasswordValid(password: String, confirmPassword: String) -> Bool
    {
        if (password.isEmpty)
        {
            SVProgressHUD.showError(withStatus: "Password can't be left empty!")
            return false
        }
        
        if (confirmPassword.isEmpty)
        {
            SVProgressHUD.showError(withStatus: "Password Confirmation can't be left empty!")
            return false
        }
        
        if (password != confirmPassword)
        {
            SVProgressHUD.showError(withStatus: "Passwords doesn't match!")
            return false
        }
        
        return true
    }
    
    fileprivate func isInputValid(username: String, email: String, password: String, confirmPassword: String) -> Bool
    {
        if isUsernameValid(username: username) &&
            isEmailValid(email: email) &&
            isPasswordValid(password: password, confirmPassword: confirmPassword)
        {
            return true
        }
        else {return false}
    }
    
    
    @objc func handlePickingUserImage()
    {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    fileprivate func convertUserPicToPNGRepData(userPic: UIImage?) -> Data?
    {
        return UIImagePNGRepresentation(userPic ?? #imageLiteral(resourceName: "User Image"))
    }
    
    fileprivate func handleUserImageStorage(uid: String, userPic: UIImage)
    {
        let uploadData = UIImageJPEGRepresentation(userPic, 0.1) //Reduce image quality to reduce network usage for profile pictures
        
        if uploadData != nil
        {
            let storageRef = SharedData.sharedInstance.storageRef

            storageRef.child("UsersImages/\(uid)/ProfilePicture.jpg").putData(uploadData!, metadata: nil) { (metadata, error) in
                if error != nil
                {
                    SVProgressHUD.showError(withStatus: error?.localizedDescription)
                }
                else
                {
                    let userRef = SharedData.sharedInstance.usersRef.child(uid)
                    userRef.updateChildValues(["ProfileImage": metadata?.downloadURL()?.absoluteString ?? "nothing"])
                    UserDefaults.standard.set(metadata?.downloadURL(), forKey: UDefaults.userImageURL.rawValue)
                    
                }
            }
        }
    }
    
    func handleRegisteringUserIntoDB(uid: String, username: String, email: String)
    {
        let registerationDictionary = ["Name": username,
                                       "Email": email]
        let userRef = SharedData.sharedInstance.usersRef.child(uid)
            userRef.updateChildValues(registerationDictionary) { (error, dbRef) in
                
                if error != nil
                {
                    SVProgressHUD.showError(withStatus: error?.localizedDescription)
                    return
                }

                let username = registerationDictionary["Name"]
                SVProgressHUD.showInfo(withStatus: "Welcome To The Club, \(username ?? "Brother") 🖖")
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage
        {
            userProfileImageView.image = editedImage
        }
        else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage
        {
            //get the original Image if we you can't get UIImage from the Picker
            userProfileImageView.image = originalImage
        }
        else
        {
            SVProgressHUD.showError(withStatus: "Couldn't Retrieve Image!")
        }
        
        dismiss(animated: true, completion: nil)
    }
}
