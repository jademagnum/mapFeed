//
//  UnblockUserViewController.swift
//  MapFeed
//
//  Created by Jade Thomason on 5/4/18.
//  Copyright © 2018 Jade Thomason. All rights reserved.
//

import UIKit

class UnblockUserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let cloudKitManager: CloudKitManager = {
        return CloudKitManager()
    }()
    
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var firstLastNameLabel: UILabel!
    @IBOutlet weak var websiteLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    
    @IBOutlet weak var blockedUserTableView: UITableView!
    
    var blockedUsers: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        blockedUserTableView.delegate = self
        blockedUserTableView.dataSource = self
        
        guard let blockedUsers = UserController.shared.currentUser?.blockedUserRefs else { return }
        UserController.shared.fetchBlockedUsers(blockedUserReferences: blockedUsers) { (blockedUsers) in
            self.blockedUsers = blockedUsers
            DispatchQueue.main.async {
                self.blockedUserTableView.reloadData()
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blockedUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "blockedUserCell", for: indexPath) as? BlockedTableViewCell else { return UITableViewCell() }
        let blockedUser = blockedUsers[indexPath.row]

        
        cell.usernameLabel.text = blockedUser.username
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let actionSheetController = UIAlertController(title: "Are you sure you want to unblock this douchebag?", message: "I mean, he never really changed.  This was the third time you guys broke up.  You deserve better.", preferredStyle: .alert)
        
        let firstAction = UIAlertAction(title: "Unblock", style: .default) { (report) in
            
            let blockedUser = self.blockedUsers[indexPath.row].cloudKitRecordID?.recordName
            guard let blockedUserRef = UserController.shared.currentUser?.blockedUserRefs.filter({$0.recordID.recordName == blockedUser}).first,
            let index = UserController.shared.currentUser?.blockedUserRefs.index(of: blockedUserRef) else { return }
            
            UserController.shared.currentUser?.blockedUserRefs.remove(at: index)
            //remove from blockedUsers array
            // Save the user back to cloudkit
            
            guard let currentUser = UserController.shared.currentUser else { return }
            
            UserController.shared.updateCurrentUserBlockedUser(blockedUserRefs: currentUser.blockedUserRefs, completion: { (success) in
                if success {
                    DispatchQueue.main.async {
                        tableView.reloadData()
                    }
                }
            })
            
    
            
//            guard let currentUser = UserController.shared.currentUser else { return }
//            let userRecord = currentUser.cloudKitRecord
//
//            self.cloudKitManager.modifyRecords([userRecord], perRecordCompletion: nil) { (records, error) in
//                if let error = error {
//                    print("\(#function), \(error), \(error.localizedDescription)")
//                    self.completion(false); return
//                } else {
//                    print("Blocked a user")
//                    self.completion(true)
//                }
//            }
            
            tableView.reloadData()
            

            
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (cancel) in
        }
        actionSheetController.addAction(firstAction)
        actionSheetController.addAction(cancelAction)
        
        present(actionSheetController, animated: true, completion: nil)
    }
}










