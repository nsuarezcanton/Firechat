//
//  UserCell.swift
//  Firechat
//
//  Created by Nicolas Suarez-Canton Trueba on 12/15/16.
//  Copyright © 2016 Nicolas Suarez-Canton Trueba. All rights reserved.
//

import UIKit
import Firebase
import SwiftDate

class UserCell: UITableViewCell {
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "loading_image_icon")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.lightGray
        label.textAlignment = NSTextAlignment.right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var message: Message? {
        didSet {
            setUpNameAndProfileImage()
            
            detailTextLabel?.text = message?.text
            // This seems dangerous!!
            timeLabel.text = formatDateFrom(timestamp: (message?.timestamp)!)
        }
    }
    
    private func setUpNameAndProfileImage() {
        let chatPartnerId: String?
        
        if message?.fromId == FIRAuth.auth()?.currentUser?.uid {
            chatPartnerId = message?.toId
        } else {
            chatPartnerId = message?.fromId
        }
        
        
        if let id = chatPartnerId {
            let userReference = FIRDatabase.database().reference().child("users").child(id)
            userReference.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.textLabel?.text = dictionary["name"] as? String
                    
                    if let profileImageUrl = dictionary["profileImageUrl"] as? String {
                        self.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
                    }
                }
            })
        }
    }
    
    func formatDateFrom (timestamp: String) -> String {
        let now = DateInRegion()
        let parsedTimestamp = try! DateInRegion(string: timestamp, format: .iso8601(options: .withInternetDateTime), fromRegion: nil)
        
        if now.day > parsedTimestamp.day {
            return parsedTimestamp.string(dateStyle: .short, timeStyle: .none)
        }
        
        return parsedTimestamp.string(dateStyle: .none, timeStyle: .short)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Full Length separator view
        self.preservesSuperviewLayoutMargins = false
        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
        
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        addSubview(timeLabel)
        
        setUpProfileImageView()
        setUpTimeLabel()
    }
    
    func setUpProfileImageView() {
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
    }
    
    func setUpTimeLabel() {
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8).isActive = true
        timeLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 200).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: textLabel!.heightAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
