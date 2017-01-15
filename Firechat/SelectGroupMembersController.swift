//
//  SelectGroupMembersController.swift
//  Firechat
//
//  Created by Nicolas Suarez-Canton Trueba on 1/12/17.
//  Copyright © 2017 Nicolas Suarez-Canton Trueba. All rights reserved.
//

import UIKit
import Firebase

class SelectGroupMembersController: UITableViewController {

    let cellId = "cellId"
    var users = [User]()
    var selectedUsers = [User]()
    var groupName: String?
    
    var newGroupController: NewGroupController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancelNewGroup))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(handleCreateNewGroup))
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        tableView.tableFooterView = UIView()

        tableView.isEditing = true
        tableView.allowsMultipleSelectionDuringEditing = true
        
        fetchUser()
    }
    
    func fetchUser() {
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            if let userDictionaty = snapshot.value as? [String: AnyObject] {
                let user = User()
                user.id = snapshot.key
                user.setValuesForKeys(userDictionaty)
                self.users.append(user)
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            }
        }, withCancel: nil)
    }
    
    func handleCancelNewGroup () {
        dismiss(animated: true, completion: nil)
    }
    
    func handleCreateNewGroup () {
        // Upon tapping create, the instance variable selected users sshould contain the users of our new group.
        // Not incredibly pleased with this set up, but it'll do for now.
        if !selectedUsers.isEmpty{
            dismiss(animated: true) {
                self.newGroupController?.dismiss(animated: false, completion: {
                    self.messagesController?.showGroupChatLogControllerFor(users: self.selectedUsers)
                })
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        
        if let profileImageUrl = user.profileImageUrl {
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    var messagesController: MessagesController?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Retrieve user at selected row.
        let user = self.users[indexPath.row]
        
        // If the user isn't in the list of selected users, add it.
        if !selectedUsers.contains(user) {
            selectedUsers.append(user)
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        
        // Retrieve user at de-selected row.
        let user = self.users[indexPath.row]
        
        // If the user is in the list of selected users, remove it.
        if selectedUsers.contains(user) {
            if let index = selectedUsers.index(of: user) {
                selectedUsers.remove(at: index)
            }
        }
    }
}
