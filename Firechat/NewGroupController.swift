//
//  NewGroupController.swift
//  Firechat
//
//  Created by Nicolas Suarez-Canton Trueba on 1/11/17.
//  Copyright © 2017 Nicolas Suarez-Canton Trueba. All rights reserved.
//

import UIKit

class NewGroupController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancelNewGroup))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Set", style: .plain, target: self, action: nil)
        
        view.backgroundColor = UIColor.white
        view.addSubview(groupTextField)
        view.addSubview(groupImageView)
        
        setUpGroupNameInput()
        setProfileImageView()
    }
    
    let groupTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Group Name"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = UIColor.lightGray
        return textField
    }()
    
    lazy var groupImageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "add_profile_image_icon")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 60
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = UIColor.gray
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSelectGroupImageView))
        
        imageView.addGestureRecognizer(tapRecognizer)
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    
    func handleSelectGroupImageView() {
        
        let groupImagePicker = UIImagePickerController()
        
        groupImagePicker.delegate = self
        groupImagePicker.allowsEditing = true
        
        present(groupImagePicker, animated: true, completion: nil)
    }
    
    func handleCancelNewGroup () {
        dismiss(animated: true, completion: nil)
    }
    
    func setUpGroupNameInput (){
        groupTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        groupTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        groupTextField.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        // TODO - ADD HEIGHT Anchor
    }
    
    func setProfileImageView() {
        // Need X, Y, width, height constraints
        groupImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        groupImageView.bottomAnchor.constraint(equalTo: groupTextField.topAnchor, constant: -24
            ).isActive = true
        groupImageView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        groupImageView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        
    }
}
