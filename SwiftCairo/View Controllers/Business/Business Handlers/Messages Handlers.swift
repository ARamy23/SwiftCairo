//
//  Messages Handlers.swift
//  SwiftCairo
//
//  Created by Ahmed Ramy on 5/19/18.
//  Copyright © 2018 Ahmed Ramy. All rights reserved.
//

import SVProgressHUD
import FirebaseAuth

extension MessagesViewController
{
    func handleUserMessagesObservation()
    {
        guard let uid = SharedData.sharedInstance.uid else { return }

        let userMessagesRef = SharedData.sharedInstance.usersMessagesRef.child(uid)
        
        userMessagesRef.observe(.childAdded) { (snapshot) in
            let userId = snapshot.key
            userMessagesRef.child(userId).observe(.childAdded, with: { (snapshot) in
                userMessagesRef.observeSingleEvent(of: .value) { (snapshot) in
                    if let dictionary = snapshot.value as? [String: AnyObject]
                    {
                        let senderID = dictionary["From"] as? String
                        let sendeeID = dictionary["To"] as? String
                        
                        let currentUserID = Auth.auth().currentUser?.uid
                        
                        if currentUserID == senderID || currentUserID == sendeeID
                        {
                            let message = Message(dictionary: dictionary)
                            
                            self.messages.append(message)
                            
                            
                            DispatchQueue.main.async
                                {
                                    ///Without the DispatchQueue.main there would be a crash because of the background thread trying to display something in the UI which is the
                                    self.messagesTableView.reloadData()
                                    SVProgressHUD.dismiss()
                                    
                            }
                        }
                        
                        
                    }
                }

            }, withCancel: nil)
            
            userMessagesRef.child(userId).observe(.childRemoved, with: { (snapshot) in
                self.messagesDictionary.removeValue(forKey: snapshot.key)
                self.attemptReloadTableView()
            })
        }
    }
    
    @objc fileprivate func handleReloadTableView() {
        
        self.messages = Array(self.messagesDictionary.values)
        self.messages.sort(by: { (message1, message2) -> Bool in
            return (message1.Timestamp?.double())! > (message2.Timestamp?.double())!
        })
        
        DispatchQueue.main.async
            {
                ///Without the DispatchQueue.main there would be a crash because of the background thread trying to display something in the UI which is the
                self.messagesTableView.reloadData()
                SVProgressHUD.dismiss()
                
        }
    }
    
    fileprivate func attemptReloadTableView()
    {
        self.timer?.invalidate()
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTableView), userInfo: nil, repeats: false)
    }
    
    func handleMessagesObservation()
    {
        let messagesRef = SharedData.sharedInstance.messagesRef
        
        if willViewAppear
        {
            SVProgressHUD.show(withStatus: "Retrieving Messages")
            messagesRef.observe(.childAdded, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject]
                {
                    let senderID = dictionary["From"] as? String
                    let sendeeID = dictionary["To"] as? String
                    
                    let currentUserID = Auth.auth().currentUser?.uid
                    
                    if currentUserID == senderID || currentUserID == sendeeID
                    {
                        let message = Message(dictionary: dictionary)
                        if let chatPartnerID = message.chatIdPartner()
                        {
                            self.messagesDictionary[chatPartnerID] = message
                        }
                        
                        self.attemptReloadTableView()
                    }
                    
                    
                }
                else
                {
                    DispatchQueue.main.async
                    {
                        SVProgressHUD.showError(withStatus: "No Messages Found")
                    }
                }
            })
            {
                (error) in
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
            
        }
        else if !willViewAppear
        {
            messagesRef.removeAllObservers()
        }
    }
}
