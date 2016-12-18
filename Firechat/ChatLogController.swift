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

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {
    
    var user: User?{
        didSet{
            navigationItem.title = user?.name
            
            observeMessages()
        }
    }
    
    var messages = [Message]()
    
    func observeMessages() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(uid)
    
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            
            let messagesRef = FIRDatabase.database().reference().child("messages").child(snapshot.key)
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let messageDictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                
                let message = Message()
                message.setValuesForKeys(messageDictionary)
                
                if message.getChatPartnerId() == self.user?.id {
                    self.messages.append(message)
                    DispatchQueue.main.async(execute: {
                        self.collectionView?.reloadData()
                    })
                }
            })
            
        }, withCancel: nil)
    }
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.alwaysBounceVertical = true
        setUpInputComponents()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        let message = messages[indexPath.item]
        cell.textView.text = message.text
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 80)
    }
    
    func setUpInputComponents() {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor.white
        
        view.addSubview(containerView)
        
        // Need X, Y, Width and Height
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        
        containerView.addSubview(sendButton)
        // Need X, Y, Width and Height
        sendButton.rightAnchor
            .constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        containerView.addSubview(inputTextField)
        
        inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        
        let inputSeparatorLine = UIView()
        inputSeparatorLine.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        inputSeparatorLine.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(inputSeparatorLine)
        
        inputSeparatorLine.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        inputSeparatorLine.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        inputSeparatorLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        inputSeparatorLine.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
    }
    
    func handleSend() {
        let dbRef = FIRDatabase.database().reference().child("messages")
        let childRef = dbRef.childByAutoId()
        
        let toId = user!.id!
        let fromId = FIRAuth.auth()!.currentUser!.uid
        
        let now = DateInRegion()
        let timestamp = now.string(format: .iso8601(options: [.withInternetDateTime]))
        
        let values = ["text": inputTextField.text!, "toId": toId, "fromId": fromId, "timestamp": timestamp] as [String : Any]
        
        inputTextField.text = ""
        
        childRef.updateChildValues(values) { (error, childRef) in
            if error != nil {
                print(error!)
                return
            }
            
            let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(fromId)
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId: 1])
            
            let recipientUserMessagesRef = FIRDatabase.database().reference().child("user-messages").child(toId)
            recipientUserMessagesRef.updateChildValues([messageId: 1])
            
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
}
