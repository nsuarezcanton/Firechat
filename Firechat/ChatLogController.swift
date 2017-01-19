//
//  ChatLogController.swift
//  Firechat
//
//  Created by Nicolas Suarez-Canton Trueba on 12/13/16.
//  Copyright © 2016 Nicolas Suarez-Canton Trueba. All rights reserved.
//

import UIKit
import Firebase
import SwiftDate

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var user: User?{
        didSet{
            navigationItem.title = user?.name
            
            observeMessages()
        }
    }
    
    var messages = [Message]()
    
    func observeMessages() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid, let toId = user?.id else
        {
            return
        }
        
        let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(uid).child(toId)
    
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            
            let messagesRef = FIRDatabase.database().reference().child("messages").child(snapshot.key)
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let messageDictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                
                let message = Message()
                message.setValuesForKeys(messageDictionary)

                self.messages.append(message)
                DispatchQueue.main.async(execute: {
                    self.collectionView?.reloadData()
                    self.scrollToBottom()
                })
            })
            
        }, withCancel: nil)
    }
    
    private func scrollToBottom() {
        let lastSectionIndex = (collectionView?.numberOfSections)! - 1
        let lastItemIndex = (collectionView?.numberOfItems(inSection: lastSectionIndex))! - 1
        let indexPath = NSIndexPath(item: lastItemIndex, section: lastSectionIndex)
        
        collectionView!.scrollToItem(at: indexPath as IndexPath, at: UICollectionViewScrollPosition.bottom, animated: true)
    }
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.contentInset = UIEdgeInsetsMake(8, 0, 8, 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.alwaysBounceVertical = true
        
        collectionView?.keyboardDismissMode = .interactive
    }
    
    func handleUploadTap() {
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage{
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            uploadToFirebaseStorage(image: selectedImage)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    private func uploadToFirebaseStorage(image: UIImage) {
        let imageName = NSUUID().uuidString
        let storageRef = FIRStorage.storage().reference().child("message-images").child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
            storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print("Failed:", error!)
                }
                
                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    self.sendMessageWith(imageUrl: imageUrl)
                }
            })
        }
    }
    
    private func sendMessageWith(imageUrl: String) {
        let dbRef = FIRDatabase.database().reference().child("messages")
        let childRef = dbRef.childByAutoId()
        
        let toId = user!.id!
        let fromId = FIRAuth.auth()!.currentUser!.uid
        
        let now = DateInRegion()
        let timestamp = now.string(format: .iso8601(options: [.withInternetDateTime]))
        
        
        let values = ["imageUrl": imageUrl, "toId": toId, "fromId": fromId, "timestamp": timestamp] as [String : Any]
        
        childRef.updateChildValues(values) { (error, childRef) in
            if error != nil {
                print(error!)
                return
            }
            
            self.inputContainerView.inputTextField.text = ""
            
            let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(fromId).child(toId)
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId: 1])
            
            let recipientUserMessagesRef = FIRDatabase.database().reference().child("user-messages").child(toId).child(fromId)
            recipientUserMessagesRef.updateChildValues([messageId: 1])
            
        }
    }
    
    lazy var inputContainerView: InputContainerView = {
        let view = InputContainerView()
        view.sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        view.uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
        return view
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        let message = messages[indexPath.item]
        cell.textView.text = message.text
        
        setUpCell(cell: cell, message: message)
        
        if let text = message.text {
            cell.bubbleWidthAnchor?.constant = getEstimatedFrameForText(text: text).width + 32
        }
        
        return cell
    }
    
    private func setUpCell(cell: ChatMessageCell, message: Message) {
        
        if let profilImageUrl = self.user?.profileImageUrl {
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profilImageUrl)
        }

        if message.fromId == FIRAuth.auth()?.currentUser?.uid {
            cell.bubbleView.backgroundColor = ChatMessageCell.primaryBubbleColor
            cell.textView.textColor = UIColor.white
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            cell.profileImageView.isHidden = true
        } else {
            cell.bubbleView.backgroundColor = ChatMessageCell.secondaryBubbleColor
            cell.textView.textColor = UIColor.black
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
            cell.profileImageView.isHidden = false
        }
        
        if let messageImageUrl = message.imageUrl {
            cell.messageImageView.loadImageUsingCacheWithUrlString(urlString: messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.backgroundColor = UIColor.clear
        } else {
            cell.messageImageView.isHidden = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var cellHeight: CGFloat = 80
        
        if let text = messages[indexPath.item].text {
            // Adds pixels to prevent text from being cut off
            cellHeight = getEstimatedFrameForText(text: text).height + 20
        }
        
        let screenWidth = UIScreen.main.bounds.width
        return CGSize(width: screenWidth, height: cellHeight)
    }
    
    private func getEstimatedFrameForText(text: String) -> CGRect {
        // Height can be arbitrarily large
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    func handleSend() {
        let dbRef = FIRDatabase.database().reference().child("messages")
        let childRef = dbRef.childByAutoId()
        
        let toId = user!.id!
        let fromId = FIRAuth.auth()!.currentUser!.uid
        
        let now = DateInRegion()
        let timestamp = now.string(format: .iso8601(options: [.withInternetDateTime]))
        
        if inputContainerView.inputTextField.text != "" {
            
            let values = ["text": inputContainerView.inputTextField.text!, "toId": toId, "fromId": fromId, "timestamp": timestamp] as [String : Any]
            
            childRef.updateChildValues(values) { (error, childRef) in
                if error != nil {
                    print(error!)
                    return
                }
                
                self.inputContainerView.inputTextField.text = ""
                
                let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(fromId).child(toId)
                let messageId = childRef.key
                userMessagesRef.updateChildValues([messageId: 1])
                
                let recipientUserMessagesRef = FIRDatabase.database().reference().child("user-messages").child(toId).child(fromId)
                recipientUserMessagesRef.updateChildValues([messageId: 1])
                
            }
        }
    }
}
