//
//  ChatViewController.swift
//  SwiftCairo
//
//  Created by Ahmed Ramy on 5/14/18.
//  Copyright © 2018 Ahmed Ramy. All rights reserved.
//

import UIKit
import Kingfisher
import SVProgressHUD
import FirebaseAuth

class MessagesViewController: UIViewController {

    @IBOutlet weak var messagesTableView: UITableView!
    
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    var users = [SwiftyCairoer]()
    
    var willViewAppear = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        handleMessagesObservation()
        setupUI()
    }
    
    
    override func viewWillDisappear(_ animated: Bool)
    {
        if((navigationController?.navigationBar.topItem?.rightBarButtonItems?.count)! > 1)
        {
            navigationController?.navigationBar.topItem?.rightBarButtonItems?.pop()
        }
        
        if willViewAppear
        {
            willViewAppear = false
        }
        handleMessagesObservation()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        updateUI()
        if !willViewAppear
        {
            willViewAppear = true
        }
        handleMessagesObservation()
    }
    
    private func updateUI()
    {
        updateNavBar()
    }
    
    private func updateNavBar()
    {
        setupUserImageInNavBar()
        if (navigationController?.navigationBar.topItem?.rightBarButtonItems?.count)! <= 1
        {
            let newMessageButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(goToContacts))
            navigationController?.navigationBar.topItem?.rightBarButtonItems?.append(newMessageButton)
        }
    }
    
    fileprivate func setupUserImageInNavBar()
    {
        if let userImageURL = UserDefaults.standard.url(forKey: UDefaults.userImageURL.rawValue)
        {
            let titleView = UIView()
            titleView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            let profilePicImageView = UIImageView()
            profilePicImageView.frame = titleView.frame
            profilePicImageView.cornerRadius = 20 //make it a circle
            profilePicImageView.kf.setImage(with: userImageURL, placeholder: #imageLiteral(resourceName: "User Image"), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
            profilePicImageView.translatesAutoresizingMaskIntoConstraints = true
            titleView.addSubview(profilePicImageView)
            navigationController?.navigationBar.topItem?.titleView = titleView
        }
        else if let username = UserDefaults.standard.string(forKey: UDefaults.Username.rawValue)
        {
            navigationController?.navigationBar.topItem?.title = username
        }
        else
        {
            navigationController?.navigationBar.topItem?.title = "Hall Of Messages"
        }
    }
    
    func showChatLogControllerFor(user: SwiftyCairoer)
    {
        let popup = ChatLogViewController.create(user: user)
        let sbPopup = SBCardPopupViewController(contentViewController: popup)
        sbPopup.show(onViewController: self)
        
    }
    
    fileprivate func setupNavBar()
    {
       setupUserImageInNavBar()
        let newMessageButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(goToContacts))
        navigationController?.navigationBar.topItem?.rightBarButtonItems?.append(newMessageButton)
    }
    
    private func setupUI()
    {
        setupMessagesTableView()
        setupNavBar()
        setupDatasource()
    }
    
    private func setupDatasource()
    {
        messages.removeAll()
    }
    
    private func setupMessagesTableView()
    {
        messagesTableView.register(cellWithClass: UserCell.self)
    }

    @objc func goToContacts()
    {
        performSegue(withIdentifier: Navigation.goToContacts.rawValue, sender: self)
    }
}

extension MessagesViewController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = messagesTableView.dequeueReusableCell(withClass: UserCell.self, for: indexPath)
        cell?.message = messages[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatIdPartner() else {
            return
        }
        
        let user = SharedData.sharedInstance.usersRef.child(chatPartnerId)
        user.observeSingleEvent(of: .value) { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]
            {
                let userID = chatPartnerId
                let username = dictionary["Name"] as? String
                let email = dictionary["Email"] as? String
                let image = dictionary["ProfileImage"] as? String
                
                let user = SwiftyCairoer(ID: userID, Name: username!, Email: email!, profilePictureImageURL: image ?? "User Image")
                print(self.messages.forEach { $0.Text })
                self.showChatLogControllerFor(user: user)
            }
        }
    }
}
