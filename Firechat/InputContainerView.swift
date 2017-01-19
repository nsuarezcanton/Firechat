//
//  InputContainerView.swift
//  Firechat
//
//  Created by Nicolas Suarez-Canton Trueba on 1/18/17.
//  Copyright © 2017 Nicolas Suarez-Canton Trueba. All rights reserved.
//

import UIKit

class InputContainerView: UIView, UITextFieldDelegate {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame : frame)
        self.frame = CGRect(x: 0, y: 0, width: frame.width, height: 50)
        self.backgroundColor = UIColor.white
        self.addSubview(uploadImageView)
        self.addSubview(sendButton)
        self.addSubview(inputTextField)
        self.addSubview(inputSeparatorLine)
        setUpUploadImageView()
        setUpSendButton()
        setUpInputTextField()
        setUpInputSeparatorLine()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    let uploadImageView: UIImageView = {
        let uploadImageView = UIImageView()
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.image = UIImage(named: "upload_image_icon")
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
//        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
        return uploadImageView
    }()
    
    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        //button.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        return button
    }()
    
    let inputSeparatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    func setUpUploadImageView() {
        uploadImageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
    
    func setUpSendButton() {
        sendButton.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }
    
    func setUpInputTextField() {
        self.inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8).isActive = true
        self.inputTextField.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.inputTextField.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        self.inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
    }
    
    func setUpInputSeparatorLine() {
        inputSeparatorLine.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        inputSeparatorLine.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        inputSeparatorLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        inputSeparatorLine.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
    }

}

