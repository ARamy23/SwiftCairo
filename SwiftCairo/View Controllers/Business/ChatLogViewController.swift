//
//  ChatLogViewController.swift
//  SwiftCairo
//
//  Created by Ahmed Ramy on 5/15/18.
//  Copyright © 2018 Ahmed Ramy. All rights reserved.
//

import UIKit
import Kingfisher
import FirebaseAuth
import SVProgressHUD

class ChatLogViewController: UIViewController, UITextFieldDelegate, SBCardPopupContent
{
    //MARK:- Popup setup
    var popupViewController: SBCardPopupViewController?
    var allowsTapToDismissPopupCard: Bool = true
    var allowsSwipeToDismissPopupCard: Bool = false
    
    static func create(user: SwiftyCairoer) -> UIViewController
    {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ChatLogViewController") as! ChatLogViewController
        storyboard.user = user
        
        return storyboard
    }

    //MARK:- Model
    var user: SwiftyCairoer?
    {
        didSet
        {
            observeMessages()
        }
    }
    var messages = [Message]()
    {
        didSet
        {
            print(messages.count)
        }
    }
    
    //MARK:- Outlets
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var contactProfilePictureImageView: UIImageView!
    @IBOutlet weak var messagesCollectionView: UICollectionView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        messagesCollectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        messagesCollectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
        messagesCollectionView.alwaysBounceVertical = true
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        messagesCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    fileprivate func observeMessages()
    {
        print("Observing")
        let usersMessagesRef = SharedData.sharedInstance.usersMessagesRef
        usersMessagesRef.child(SharedData.sharedInstance.uid!).observe(.childAdded) { (snapshot) in
            let messageId = snapshot.key
            DispatchQueue.main.async {
                print(messageId)
            }
            let messagesRef = SharedData.sharedInstance.messagesRef
            messagesRef.child(messageId).observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String: AnyObject] else { print("Couldnt parse");return; }
                
                let senderID = dictionary["From"] as? String
                let sendeeID = dictionary["To"] as? String
                let timestamp = dictionary["Timestamp"] as? String
                let messageText = dictionary["Text"] as? String
                
                let message = Message(From: senderID, To: sendeeID, Timestamp: timestamp, Text: messageText)
                
                if message.chatIdPartner() == self.user?.ID
                {
                    self.messages.append(message)
                    
                    DispatchQueue.main.async {
                        self.messagesCollectionView.reloadData()
                    }
                }
            })
        }
    }
    
    fileprivate func setupGestureRecognizers()
    {
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    fileprivate func setupUI()
    {
        contactProfilePictureImageView.kf.setImage(with: URL(string: (user?.profilePictureImageURL)!))
        setupGestureRecognizers()
        inputTextField.delegate = self
        messagesCollectionView.register(cellWithClass: ChatMessageCell.self)
    }
    
    @IBAction func didTapSendButton(_ sender: Any)
    {
        handleSend()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
}

extension ChatLogViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: ChatMessageCell.self, for: indexPath)!
        cell.textView.text = messages[indexPath.item].Text
        cell.bubbleWidthAnchor?.constant = estimateFrameFor(text: messages[indexPath.item].Text!).width + 32
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        
        if let text = messages[indexPath.item].Text
        {
            height = estimateFrameFor(text: text).height + 20 // 20 is added to avoid clipping
        }
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    private func estimateFrameFor(text: String) -> CGRect
    {
        let size = CGSize(width: 200, height: 1000)
        return NSString(string: text).boundingRect(with: size,
                                            options: NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin),
                                            attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 16)],
                                            context: nil)
    }
}
