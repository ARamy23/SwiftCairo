//
//  ChatLog Handlers.swift
//  SwiftCairo
//
//  Created by Ahmed Ramy on 5/19/18.
//  Copyright © 2018 Ahmed Ramy. All rights reserved.
//

import FirebaseAuth
import SVProgressHUD
import MobileCoreServices
import AVFoundation

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
        let userMessagesRef = SharedData.sharedInstance.usersMessagesRef.child(uid!).child(sendeeID!)
        
        messagesRef.childByAutoId().updateChildValues(values) { error, ref in
            if error != nil
            {
                print(error!)
                return
            }
            let messageId = ref.key
            userMessagesRef.updateChildValues([messageId: 1])
            
            let sendeeRef = SharedData.sharedInstance.usersMessagesRef.child(sendeeID!).child(uid!)
            sendeeRef.updateChildValues([messageId: 1])
        }
        inputTextField.text = ""
    }
    
    func handleUploadImage()
    {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func handleMessagesObservation()
    {
        print("Observing")
        let usersMessagesRef = SharedData.sharedInstance.usersMessagesRef
        usersMessagesRef.child(SharedData.sharedInstance.uid!).child((user?.ID)!).observe(.childAdded) { (snapshot) in
            let messageId = snapshot.key
            DispatchQueue.main.async {
                print(messageId)
            }
            let messagesRef = SharedData.sharedInstance.messagesRef
            messagesRef.child(messageId).observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String: Any] else { print("Couldnt parse");return; }
                let message = Message(dictionary: dictionary)
                
                self.messages.append(message)
                
                DispatchQueue.main.async {
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToItem(at: IndexPath(item: self.messages.count - 1, section: 0), at: .bottom, animated: true)
                }
            })
        }
    }
}

extension ChatLogViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage
        {
            uploadToFirebaseStorage(with: editedImage) { (imageURL) in
                self.handleSending(image: editedImage, withURL: imageURL)
            }
        }
        else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage
        {
            //get the original Image if we you can't get UIImage from the Picker
            uploadToFirebaseStorage(with: originalImage) { (imageURL) in
                self.handleSending(image: originalImage, withURL: imageURL)
            }
        }
        else if let videoURL = info[UIImagePickerControllerMediaURL] as? URL
        {
            uploadToFirebaseStorage(with: videoURL)
        }
        else
        {
            SVProgressHUD.showError(withStatus: "Couldn't Retrieve Image!")
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    private func uploadToFirebaseStorage(with image: UIImage,_ completionBlock: @escaping ((_ imageURL: String) -> ()))
    {
        
        let imageName = NSUUID().uuidString
        let imagesRef = SharedData.sharedInstance.messagesImagesRef.child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.2)
        {
            imagesRef.putData(uploadData, metadata: nil) { (metadata, error) in
                if error != nil
                {
                    print(error!.localizedDescription)
                    SVProgressHUD.showError(withStatus: error!.localizedDescription)
                    return
                }
                
                if let imageURL = metadata?.downloadURL()?.absoluteString
                {
                    completionBlock(imageURL)
                }
            }
        }
    }
    
    private func uploadToFirebaseStorage(with video: URL)
    {
        let filename = NSUUID().uuidString
        let storageRef = SharedData.sharedInstance.storageRef
        let uploadTask = storageRef.child("Messages-Videos").child(filename).putFile(from: video, metadata: nil) { (metadata, error) in
            if error != nil
            {
                SVProgressHUD.showError(withStatus: error?.localizedDescription)
                return
            }
            
            if let videoDownloadURLString = metadata?.downloadURL()?.absoluteString
            {
                if let thumbnail = self.getThumbnailImage(outOf: video)
                {
                    self.uploadToFirebaseStorage(with: thumbnail) { (imageURL) in
                        
                        self.handleSending(video: videoDownloadURLString, thumbnail: thumbnail, thumbnailURL: imageURL)
                    }
                    SVProgressHUD.showSuccess(withStatus: "Video Uploaded Successfully!")
                }
            }
        }
        uploadTask.observe(.progress) { (snapshot) in
            SVProgressHUD.showProgress(Float(snapshot.progress!.fractionCompleted))
        }
    }
    
    private func getThumbnailImage(outOf url: URL) -> UIImage?
    {
        let asset = AVAsset(url: url)
        let assetGenerator = AVAssetImageGenerator(asset: asset)
        
        do
        {
            let thumbnailCGImage = try assetGenerator.copyCGImage(at: CMTime(seconds: 1, preferredTimescale: 60), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
        }
        catch let error
        {
            SVProgressHUD.showError(withStatus: error.localizedDescription)
        }
        
        return nil
    }
    
    private func handleSending(image: UIImage, withURL url: String)
    {
        let sendeeID = user?.ID
        let uid = SharedData.sharedInstance.uid
        let timestamp = String(Date().timeIntervalSinceReferenceDate)
        
        let values: [String: Any] = ["ImageURL": url,
                      "To": sendeeID,
                      "From": uid,
                      "Timestamp": timestamp,
                      "ImageWidth": image.size.width,
                      "ImageHeight": image.size.height]
        let messagesRef = SharedData.sharedInstance.messagesRef
        
        //Declared here to avoid retain cycles
        let userMessagesRef = SharedData.sharedInstance.usersMessagesRef.child(uid!).child(sendeeID!)
        
        messagesRef.childByAutoId().updateChildValues(values) { error, ref in
            if error != nil
            {
                print(error!)
                return
            }
            let messageId = ref.key
            userMessagesRef.updateChildValues([messageId: 1])
            
            let sendeeRef = SharedData.sharedInstance.usersMessagesRef.child(sendeeID!).child(uid!)
            sendeeRef.updateChildValues([messageId: 1])
        }
    }
    
    private func handleSending(video url: String, thumbnail image: UIImage, thumbnailURL: String)
    {
        let sendeeID = user?.ID
        let uid = SharedData.sharedInstance.uid
        let timestamp = String(Date().timeIntervalSinceReferenceDate)
        
        let values: [String: Any] = ["VideoURL": url,
                                     "To": sendeeID,
                                     "From": uid,
                                     "Timestamp": timestamp,
                                     "ImageWidth": image.size.width,
                                     "ImageHeight": image.size.height,
                                     "ImageURL": thumbnailURL]
        
        let messagesRef = SharedData.sharedInstance.messagesRef
        
        //Declared here to avoid retain cycles
        let userMessagesRef = SharedData.sharedInstance.usersMessagesRef.child(uid!).child(sendeeID!)
        let sendeeRef = SharedData.sharedInstance.usersMessagesRef.child(sendeeID!).child(uid!)
        
        messagesRef.childByAutoId().updateChildValues(values) { error, ref in
            if error != nil
            {
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
                print(error!)
                return
            }
            let messageId = ref.key
            userMessagesRef.updateChildValues([messageId: 1])
            
            sendeeRef.updateChildValues([messageId: 1])
        }
    }
}
