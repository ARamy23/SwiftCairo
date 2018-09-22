//
//  ChatMessageCell.swift
//  SwiftCairo
//
//  Created by ScaRiLiX on 9/10/18.
//  Copyright © 2018 Ahmed Ramy. All rights reserved.
//

import UIKit
import AVFoundation

class ChatMessageCell: UICollectionViewCell {
    
    enum SenderType
    {
        case currentUser
        case anotherUser
    }
    
    var senderType: SenderType = .currentUser
    {
        didSet
        {
            if senderType == .currentUser
            {
                bubbleView.backgroundColor = UIColor(red: 0, green: 137, blue: 249)
                textView.textColor = .white
                bubbleRightAnchor?.isActive = true
                bubbleLeftAnchor?.isActive = false
                profilePictureImageView.isHidden = true
            }
            else
            {
                bubbleView.backgroundColor = .lightGray
                textView.textColor = .black
                bubbleRightAnchor?.isActive = false
                bubbleLeftAnchor?.isActive = true
                profilePictureImageView.isHidden = false
            }
        }
    }
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.text = "SAMPLE TEXT FOR NOW"
        tv.font = UIFont.systemFont(ofSize: 17)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .clear
        tv.textColor = .white
        tv.isEditable = false
        return tv
    }()
    
    let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0, green: 137, blue: 249)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    let profilePictureImageView: UIImageView =
    {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "User Image")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let messageImageView: UIImageView =
    {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "User Image")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleZoomTap(gesture:)))
        tapGesture.cancelsTouchesInView = false
        imageView.addGestureRecognizer(tapGesture)
        return imageView
    }()
    
    lazy var playButton: UIButton =
    {
       let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "Play"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleVideoPlaying), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var activityIndicatorView: UIActivityIndicatorView =
    {
       let aiv = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.hidesWhenStopped = true
        return aiv
    }()
    
    var message: Message!
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleRightAnchor: NSLayoutConstraint?
    var bubbleLeftAnchor: NSLayoutConstraint?
    var chatLogController: ChatLogViewController?
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    
    @objc func handleZoomTap(gesture: UITapGestureRecognizer)
    {
        if let imageView = gesture.view as? UIImageView
        {
            chatLogController?.performZoomInForStarting(imageView: imageView)
        }
    }
    
    @objc func handleVideoPlaying()
    {
        if let videoURL = message.VideoURL?.url
        {
            player = AVPlayer(url: videoURL)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer!.frame = bubbleView.bounds
            bubbleView.layer.addSublayer(playerLayer!)
            
            player!.play()
            activityIndicatorView.startAnimating()
            playButton.isHidden = true
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playerLayer?.removeFromSuperlayer()
        player?.pause()
        activityIndicatorView.stopAnimating()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(profilePictureImageView)
        
        bubbleView.addSubview(messageImageView)
        
        messageImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        messageImageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
        messageImageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
        
        bubbleView.addSubview(playButton)
        bubbleView.addSubview(activityIndicatorView)
        
        activityIndicatorView.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        activityIndicatorView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        activityIndicatorView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        playButton.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true 
        
        profilePictureImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profilePictureImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        profilePictureImageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        profilePictureImageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        bubbleRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        bubbleRightAnchor?.isActive = true
        
        bubbleLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profilePictureImageView.rightAnchor, constant: 8)
        
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor!.isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Init(coder:) has not been implemented")
    }
    
}
