//
//  ContactsViewController.swift
//  SwiftCairo
//
//  Created by Ahmed Ramy on 5/14/18.
//  Copyright © 2018 Ahmed Ramy. All rights reserved.
//

import UIKit
import SVProgressHUD
import FirebaseAuth
import FirebaseDatabase
import Kingfisher

class ContactsViewController: UIViewController
{
    @IBOutlet weak var contactsTableView: UITableView!
    
    var users = [SwiftyCairoer]()
    var chatViewController: MessagesViewController?
    
    fileprivate func setupContactsTableView() {
        let currentUserUID = SharedData.sharedInstance.uid!
        fetchUsersExceptCurrent(uid: currentUserUID)
        contactsTableView.register(UserCell.self, forCellReuseIdentifier: "cellID")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        setupContactsTableView()
    }
    
    private func setupUI()
    {
        navigationController?.navigationBar.topItem?.title = "The Companions"
        //Yes that's another Easter Egg ... ;)
    }
    
    private func fetchUsersExceptCurrent(uid: String)
    {
        let usersRef = SharedData.sharedInstance.usersRef
        
        usersRef.observe(.value) { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]
            {
                for (key, _) in dictionary
                {
                    if key != uid ///*if current uid  != current user's uid*///
                    {
                        let userDictionary = dictionary[key] as? [String: AnyObject]
                        let userID = key
                        let username = userDictionary!["Name"] as? String
                        let email = userDictionary!["Email"] as? String
                        let image = userDictionary!["ProfileImage"] as? String
                        
                        let user = SwiftyCairoer(ID: userID, Name: username!, Email: email!, profilePictureImageURL: image ?? "User Image")
                        self.users.append(user)
                    }
                }
                
                DispatchQueue.main.async
                {
                    self.contactsTableView.reloadData()
                }
                
                
            }
        }
    }
    
}

extension ContactsViewController: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return users.count
    }
    
    fileprivate func setup(cell: UserCell?, for row: Int)
    {
        let user = users[row]
        cell?.textLabel?.text = user.Name
        cell?.detailTextLabel?.text = user.Email
        cell?.profilePictureImageView.kf.setImage(with: URL(string: user.profilePictureImageURL!), placeholder: #imageLiteral(resourceName: "User Image")
            , options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //hack of the day
        //let cell =  UITableViewCell(style: .subtitle, reuseIdentifier: "cellID")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath) as? UserCell
        setup(cell: cell, for: indexPath.row)
        return cell ?? UITableViewCell(style: .subtitle, reuseIdentifier: "CellID")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let popup = ChatLogViewController.create(user: users[indexPath.row])
        let sbPopup = SBCardPopupViewController(contentViewController: popup)
        sbPopup.show(onViewController: self)
    }
    
}


