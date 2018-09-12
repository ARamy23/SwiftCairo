//
//  UserCell.swift
//  SwiftCairo
//
//  Created by Ahmed Ramy on 5/17/18.
//  Copyright © 2018 Ahmed Ramy. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell
{
    var message: Message?
    {
        didSet
        {
            //Setting up the message text
            detailTextLabel?.text = message?.Text
            let currentDateTime = Date(timeIntervalSinceReferenceDate: Double((message?.Timestamp)!)!)
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            formatter.dateStyle = .none
            let currentDateTimeString = formatter.string(from: currentDateTime)
            timestampLabel.text = currentDateTimeString
            
            //Setting up the contact image and name
            setupContactImageAndName()
        }
    }
    
    fileprivate func setupContactImageAndName()
    {
        if let id = message?.chatIdPartner()
        {
            SharedData.sharedInstance.usersRef.child(id).observeSingleEvent(of: .value) { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject]
                {
                    self.textLabel?.text = dictionary["Name"] as? String
                    let profileImageURL = dictionary["ProfileImage"] as? String
                    
                    self.profilePictureImageView.kf.setImage(with: URL(string: profileImageURL!), placeholder: #imageLiteral(resourceName: "User Image"), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
                }
            }
        }
    }
    
    let profilePictureImageView: UIImageView =
    {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "User Image")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let timestampLabel: UILabel =
    {
       let label = UILabel()
        label.text = "HH:MM:SS"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.textAlignment = .right
        return label
    }()
    
    override func layoutSubviews() {
        ///x = 56 becuase the image takes 8px from left + having 40 (48 until the image trailing) which makes it
        ///8 px away from the image from the right, you can run the app to see
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 56, y: textLabel!.frame.origin.y - 2, width: textLabel!.width, height: textLabel!.height)
        detailTextLabel?.frame = CGRect(x: 56, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.width, height: detailTextLabel!.height)
    }
    
    fileprivate func setupProfilePicture()
    {
        addSubview(profilePictureImageView)
        
        ///IOS 9+ Constraints Anchors
        
        profilePictureImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profilePictureImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profilePictureImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profilePictureImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        profilePictureImageView.layer.cornerRadius = 20
        profilePictureImageView.layer.borderWidth = 1
        profilePictureImageView.layer.borderColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        profilePictureImageView.clipsToBounds = true
    }
    
    fileprivate func setupTimestampLabel()
    {
        addSubview(timestampLabel)
        
        ///IOS 9+ Constraints Anchors
        
        timestampLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20).isActive = true
        timestampLabel.centerYAnchor.constraint(equalTo: (textLabel?.centerYAnchor)!).isActive = true
        timestampLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
        timestampLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timestampLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
        
    }
    
    fileprivate func setupUIForCell()
    {
        detailTextLabel?.textColor = .darkGray 
        setupProfilePicture()
        setupTimestampLabel()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        setupUIForCell()
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
