//
//  Message.swift
//  SwiftCairo
//
//  Created by Ahmed Ramy on 5/17/18.
//  Copyright © 2018 Ahmed Ramy. All rights reserved.
//

import Foundation

struct Message
{
    let From: String?
    let To: String?
    let Timestamp: String?
    let Text: String?
    
    func chatIdPartner() -> String?
    {
        let chatPartnerId: String?
        if From == SharedData.sharedInstance.uid
        {
            chatPartnerId = To
        }
        else
        {
            chatPartnerId = From
        }
        
        return From == SharedData.sharedInstance.uid ? To : From 
    }
}
