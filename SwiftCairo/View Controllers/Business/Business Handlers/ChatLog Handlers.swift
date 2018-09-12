//
//  ChatLog Handlers.swift
//  SwiftCairo
//
//  Created by Ahmed Ramy on 5/19/18.
//  Copyright © 2018 Ahmed Ramy. All rights reserved.
//

import FirebaseAuth

extension ChatLogViewController
{
    func handleSend()
    {
        let text = inputTextField.text!
        let sendeeID = user?.ID
        let uid = SharedData.sharedInstance.uid
        let timestamp = String(Date().timeIntervalSinceReferenceDate)
        
        let values = ["Text": text,
                      "To": sendeeID,
                      "From": uid,
                      "Timestamp": timestamp]
        let messagesRef = SharedData.sharedInstance.messagesRef
        
        //Declared here to avoid retain cycles
        let userMessagesRef = SharedData.sharedInstance.usersMessagesRef.child(uid!)
        
        messagesRef.childByAutoId().updateChildValues(values) { error, ref in
            if error != nil
            {
                print(error!)
                return
            }
            let messageId = ref.key
            userMessagesRef.updateChildValues([messageId: 1])
            
            let sendeeRef = SharedData.sharedInstance.usersMessagesRef.child(sendeeID!)
            sendeeRef.updateChildValues([messageId: 1])
        }
        inputTextField.text = ""
    }
}
