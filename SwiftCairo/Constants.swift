//
//  Constants.swift
//  SwiftCairo
//
//  Created by Ahmed Ramy on 5/12/18.
//  Copyright © 2018 Ahmed Ramy. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth


enum Constants: String
{
    case dbURL = "https://swiftcairo-4ever.firebaseio.com/"
    case dbStorageURL = "gs://swiftcairo-4ever.appspot.com"
}

enum Navigation: String
{
    case goToMainView = "goToMainView"
    case goToContacts = "goToContacts"
    case goToChatLog = "goToChatLog"
}

enum UDefaults: String
{
    case Username = "Username"
    case Email = "Email"
    case Password = "Password"
    case hasAlreadyLogged = "hasAlreadyLogged"
    case userImageURL = "userImageURL"
}

struct SharedData
{
    static let sharedInstance = SharedData()
    
    let mainRef = Database.database().reference(fromURL: Constants.dbURL.rawValue)
    let usersRef = Database.database().reference(fromURL: Constants.dbURL.rawValue).child("Users")
    let storageRef = Storage.storage().reference()
    let messagesRef = Database.database().reference(fromURL: Constants.dbURL.rawValue).child("Messages")
    let usersMessagesRef = Database.database().reference(fromURL: Constants.dbURL.rawValue).child("Users-Messages")
    let uid = Auth.auth().currentUser?.uid
    let currentUserRef = Database.database().reference(fromURL: Constants.dbURL.rawValue).child("Users").child((Auth.auth().currentUser?.uid)!)
    private init()
    {
        
    }
}

//MARK:- Global Functions

public func clearUserDefaults()
{
    let domain = Bundle.main.bundleIdentifier!
    UserDefaults.standard.removePersistentDomain(forName: domain)
    UserDefaults.standard.synchronize()
}
