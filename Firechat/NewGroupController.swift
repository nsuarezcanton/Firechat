//
//  NewGroupController.swift
//  Firechat
//
//  Created by Nicolas Suarez-Canton Trueba on 1/11/17.
//  Copyright © 2017 Nicolas Suarez-Canton Trueba. All rights reserved.
//

import UIKit

class NewGroupController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    var messagesController: MessagesController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancelNewGroup))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Set", style: .plain, target: self, action: #selector(handleSetGroup))
        
        view.backgroundColor = UIColor.white
        view.addSubview(groupNameInputContainerView)
        view.addSubview(groupImageView)
        
        setGroupNameInputContainerView()
        setGroupImageView()
        
        self.groupNameInput.delegate = self;
    }
    
    func handleSetGroup (){
        // This function should take care of checking the form validity
        // Either directly or through helper functions
        showSelectGroupMembersController()
        
    }
    
    func showSelectGroupMembersController () {
        let selectGroupMembersController = SelectGroupMembersController()
        // This will allow for showing group messages from MessagesController
        selectGroupMembersController.messagesController = self.messagesController
        selectGroupMembersController.newGroupController = self
        
        let navController = UINavigationController(rootViewController: selectGroupMembersController)
        present(navController, animated: true, completion: nil)
    }
    
    // VIEWS
    let groupNameInputContainerView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    func setGroupNameInputContainerView() {
        // Need X, Y, Width and Height Constraints
        groupNameInputContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        groupNameInputContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        groupNameInputContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 3/4).isActive = true
        
        groupNameInputContainerView.addSubview(groupNameInput)
        groupNameInputContainerView.addSubview(groupLabel)
        
        setGroupNameInput()
        setGroupNameLabel()
        
    }
    
    // Input for entering Group Name
    let groupNameInput: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter group name..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        textField.layer.cornerRadius = 5
        textField.layer.masksToBounds = true
        
        return textField
    }()
    
    // Tappable image that prompts the user to pick a picture for the group being created
    lazy var groupImageView: UIImageView = {
        let imageView = UIImageView()
//        imageView.image = UIImage(named: "add_profile_image_icon")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 5
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = UIColor.gray
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSelectGroupImageView))
        
        imageView.addGestureRecognizer(tapRecognizer)
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    
    func setGroupNameInput() {
        groupNameInput.topAnchor.constraint(equalTo: groupNameInputContainerView.topAnchor).isActive = true
        groupNameInput.rightAnchor.constraint(equalTo: groupNameInputContainerView.rightAnchor).isActive = true
        groupNameInput.centerYAnchor.constraint(equalTo: groupNameInputContainerView.centerYAnchor).isActive = true
        groupNameInput.widthAnchor.constraint(equalTo: groupNameInputContainerView.widthAnchor, multiplier: 3/4).isActive = true
    }
    
    func setGroupNameLabel () {
        groupLabel.topAnchor.constraint(equalTo: groupNameInputContainerView.topAnchor).isActive = true
        groupLabel.leftAnchor.constraint(equalTo: groupNameInputContainerView.leftAnchor).isActive = true
        groupLabel.centerYAnchor.constraint(equalTo: groupNameInputContainerView.centerYAnchor).isActive = true
        groupLabel.widthAnchor.constraint(equalTo: groupNameInputContainerView.widthAnchor, multiplier: 1/4).isActive = true
    }
    
    func setGroupImageView() {
        groupImageView.bottomAnchor.constraint(equalTo: groupNameInputContainerView.topAnchor, constant: -24).isActive = true
        groupImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        groupImageView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        groupImageView.heightAnchor.constraint(equalToConstant: 120).isActive = true
    }
    
    // Closes keyboard upon pressing return.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    // Label to show next to group name
    let groupLabel: UILabel = {
        let label = UILabel()
        label.text = "Group"
        label.textColor = UIColor.black
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(r: 100, g: 100, b: 100)
        
        return label
    }()
    
    // HANDLERS
    // Handler for selecting an image for the group
    func handleSelectGroupImageView() {
        let groupImagePicker = UIImagePickerController()
        
        groupImagePicker.delegate = self
        groupImagePicker.allowsEditing = true
        
        present(groupImagePicker, animated: true, completion: nil)
    }
    
    // Handler for when user decines agains creating a group
    func handleCancelNewGroup () {
        dismiss(animated: true, completion: nil)
    }
}
