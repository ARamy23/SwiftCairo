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
    let ImageURL: String?
    let VideoURL: String?
    let ImageWidth: NSNumber?
    let ImageHeight: NSNumber?
    
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
    
    init(dictionary: [String: Any]) {
        From = dictionary["From"] as? String
        To = dictionary["To"] as? String
        Timestamp = dictionary["Timestamp"] as? String
        Text = dictionary["Text"] as? String
        ImageURL = dictionary["ImageURL"] as? String
        VideoURL = dictionary["VideoURL"] as? String
        ImageWidth = dictionary["ImageWidth"] as? NSNumber
        ImageHeight = dictionary["ImageHeight"] as? NSNumber
        
    }
}
