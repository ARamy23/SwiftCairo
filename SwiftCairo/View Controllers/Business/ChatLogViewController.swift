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
import AVFoundation
import MobileCoreServices

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
            handleMessagesObservation()
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
    
    //MARK:- Helping Vars
    var zoomInStartFrame: CGRect?
    var blackBG: UIView!
    var toBeZoomedImageView: UIImageView?
    
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
    
    @IBAction func didTapSendImageButton(_ sender: Any)
    {
        handleUploadImage()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if messages.count > 0
        {
        messagesCollectionView.scrollToItem(at: IndexPath(item: messages.count - 1, section: 0), at: .top, animated: true)
        }
    }
    
}

extension ChatLogViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: ChatMessageCell.self, for: indexPath)!
        let message = messages[indexPath.item]
        cell.message = message
        cell.textView.text = message.Text
        cell.senderType = (message.From == SharedData.sharedInstance.uid) ? .currentUser : .anotherUser
        cell.profilePictureImageView.image = contactProfilePictureImageView.image
        if let text = message.Text
        {
            cell.bubbleWidthAnchor?.constant = estimateFrameFor(text: text).width + 32
            cell.messageImageView.isHidden = true
            cell.textView.isHidden = false
            cell.playButton.isHidden = true
        }
        else if let videoURL = message.VideoURL?.url, let messageImageURL = message.ImageURL?.url
        {
            cell.messageImageView.download(from: messageImageURL)
            cell.playButton.isHidden = false
        }
        else if let messageImageURL = message.ImageURL?.url
        {
            cell.messageImageView.download(from: messageImageURL)
            cell.messageImageView.isHidden = false
            cell.bubbleWidthAnchor?.constant = 200
            cell.textView.isHidden = true
            cell.playButton.isHidden = true
        }
        cell.chatLogController = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ChatMessageCell
        
        if messages[indexPath.item].ImageURL != nil, messages[indexPath.item].VideoURL == nil
        {
            performZoomInForStarting(imageView: cell.messageImageView)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        let message = messages[indexPath.item]
        if let text = message.Text
        {
            height = estimateFrameFor(text: text).height + 20 // 20 is added to avoid clipping
        }
        else if message.ImageURL != nil
        {
            height = CGFloat(message.ImageHeight!.floatValue / message.ImageWidth!.floatValue * 200)
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
    
    func performZoomInForStarting(imageView: UIImageView)
    {
        if let startingFrame = imageView.superview?.convert(imageView.frame, to: nil)
        {
            self.toBeZoomedImageView = imageView
            self.toBeZoomedImageView?.isHidden = true
            let zoomingImageView = UIImageView(frame: startingFrame)
            zoomInStartFrame = startingFrame
            zoomingImageView.backgroundColor = .black
            zoomingImageView.image = imageView.image
            zoomingImageView.isUserInteractionEnabled = true
            zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(performZoomOut(_:))))
            zoomingImageView.layer.masksToBounds = true
            zoomingImageView.clipsToBounds = true

            zoomingImageView.layer.cornerRadius = 0
            if let keyWindow = UIApplication.shared.keyWindow
            {
                blackBG = UIView(frame: keyWindow.frame)
                blackBG.backgroundColor = .black
                keyWindow.addSubview(blackBG)
                blackBG.alpha = 0
                keyWindow.addSubview(zoomingImageView)
                
                let animation = CABasicAnimation(keyPath:"cornerRadius")
                animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
                animation.fromValue = imageView.layer.cornerRadius
                animation.toValue = 0
                animation.duration = 0.5
                zoomingImageView.layer.add(animation, forKey: "cornerRadius")
                
                let height = startingFrame.height / startingFrame.width * keyWindow.width
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                    self.blackBG.alpha = 1
                    zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                    zoomingImageView.center = keyWindow.center
                }, completion: nil)
            }
        }
        
    }
    
    @objc func performZoomOut(_ gesture: UITapGestureRecognizer)
    {
        if let zoomingImageView = gesture.view as? UIImageView
        {
            zoomingImageView.layer.masksToBounds = true
            zoomingImageView.clipsToBounds = true
            zoomingImageView.layer.cornerRadius = 16
            let animation = CABasicAnimation(keyPath:"cornerRadius")
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            animation.fromValue = 0
            animation.toValue = zoomingImageView.layer.cornerRadius
            animation.duration = 0.5
            zoomingImageView.layer.add(animation, forKey: "cornerRadius")
            zoomingImageView.layer.cornerRadius = zoomingImageView.layer.cornerRadius
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                zoomingImageView.frame = self.zoomInStartFrame!
                self.blackBG.alpha = 0
            }, completion: {
                _ in
                zoomingImageView.removeFromSuperview()
                self.toBeZoomedImageView?.isHidden = false
            })
            
            
        }
    }
}
