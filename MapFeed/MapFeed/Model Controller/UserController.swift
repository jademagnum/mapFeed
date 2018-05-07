//
//  UserController.swift
//  MapFeed
//
//  Created by Jade Thomason on 4/18/18.
//  Copyright © 2018 Jade Thomason. All rights reserved.
//

import Foundation
import CloudKit
import UIKit

class UserController {
    
    static let shared = UserController()
    
    let publicDB = CKContainer.default().publicCloudDatabase
    
    let cloudKitManager: CloudKitManager = {
        return CloudKitManager()
    }()
    
    let currentUserWasSentNotification = Notification.Name("currentUserWasSet")
    
    var currentUser: User? {
        didSet {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: self.currentUserWasSentNotification, object: nil)
            }
        }
    }
    
    var users: [User] = []
    
    init() {
        fetchCurrentUser { (success) in
            if !success {
                print("fix this error handeling")
            }
        }
    }
    
    func createUserWith(username: String, email: String, completion: @escaping (_ success: Bool) -> Void) {
        CKContainer.default().fetchUserRecordID { (appleUserRecordID, error) in
            guard let appleUserRecordID = appleUserRecordID else { return }
            
            let appleUserRef = CKReference(recordID: appleUserRecordID, action: .deleteSelf)
            
            let blockUserRef = self.currentUser?.blockedUserRefs
            
            let user = User(username: username, email: email, appleUserRef: appleUserRef, blockedUserRefs: blockUserRef ?? [])
            
            let userRecord = user.cloudKitRecord
            
            CKContainer.default().publicCloudDatabase.save(userRecord) { (record, error) in
                if let error = error { print (error.localizedDescription) }
                
                guard let record = record, let currentUser = User(cloudKitRecord: record) else { completion(false); return }
                self.currentUser = currentUser
                completion(true)
            }
        }
    }
    
    func fetchCurrentUser(completion: @escaping (_ success: Bool) -> Void = { _ in }) {
        CKContainer.default().fetchUserRecordID { (appleRecordID, error) in
            
            if let error = error { print(error.localizedDescription) }
            
            guard let appleRecordID = appleRecordID else { completion(false); return }
            
            let appleUserReference = CKReference(recordID: appleRecordID, action: .deleteSelf)
            
            let predicate = NSPredicate(format: "appleUserRef == %@", appleUserReference)
            
            self.cloudKitManager.fetchRecordsWithType(User.typeKey, predicate: predicate, recordFetchedBlock: nil, completion: { (records, error) in
                if let error = error { print(error.localizedDescription) }
                guard let currentUserRecord = records?.first else { completion(false); return}
                let currentUser = User(cloudKitRecord: currentUserRecord)
                self.currentUser = currentUser
                completion(true)
            })
        }
    }
    
    func fetchBlockedUsers(blockedUserReferences: [CKReference], completion: @escaping (_ blockedUsers: [User]) -> Void = { _ in }) {
        
        var blockedUsers: [User] = []
        let dispatchGroup = DispatchGroup()
        for reference in blockedUserReferences {
            dispatchGroup.enter()
            CKContainer.default().publicCloudDatabase.fetch(withRecordID: reference.recordID) { (record, error) in
                if let error = error { print(error.localizedDescription) }
                
                guard let record = record,
                    let blockedUser = User(cloudKitRecord: record) else { dispatchGroup.leave(); return }
                
                blockedUsers.append(blockedUser)
                
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) {
            self.users = blockedUsers
            completion(self.users)
        }
    }
    
    
    
    func fetchAllUsers(completion: @escaping (_ success: Bool) -> Void = { _ in }) {
        CKContainer.default().fetchUserRecordID { (appleRecordID, error) in
            
            if let error = error { print(error.localizedDescription) }
            
            //            guard let appleRecordID = appleRecordID else { completion(false); return }
            
            let predicate = NSPredicate(value: true)
            
            self.cloudKitManager.fetchRecordsWithType(User.typeKey, predicate: predicate, recordFetchedBlock: nil, completion: { (records, error) in
                if let error = error { print(error.localizedDescription) }
                guard let records = records else { completion(false); return}
                let users = records.compactMap{User(cloudKitRecord: $0)}
                //                guard let user = self.currentUser else { return }
                let dispatchGroup = DispatchGroup()
                for user in users {
                    dispatchGroup.enter()
                    self.fetchPostsFor(user: user, completion: { (success) in
                        if !success {
                            print("Error fetching posts")
                        }
                        dispatchGroup.leave()
                    })
                }
                
                dispatchGroup.notify(queue: .main, execute: {
                    self.users = users
                    completion(true)
                })
            })
        }
    }
    
    func fetchPostsFor(user: User, completion: @escaping (_ success: Bool) -> Void) {
        guard let userRecordID = user.cloudKitRecordID else { completion(false); return }
        
        // The predicat of value Ture means everyting. (what we deleted) "expensive"
        /// This predicat is only going to get the user refs
        let userReference = CKReference(recordID: userRecordID, action: .deleteSelf)
        
        let predicate = NSPredicate(format: "userRef == %@", userReference)
        
        CloudKitManager.shared.fetchRecordsOf(type: Post.typeKey, predicate: predicate, database: publicDB) { (records, error) in
            if let error = error {
                print("Error fetching posts for user \(#file) \(#function) \(error.localizedDescription)")
                completion(false); return   
            }
            guard let records = records else { completion(false); return }
            let posts = records.compactMap({ Post(cloudKitRecord: $0, user: user) })
            user.posts = posts
            
            completion(true)
        }
    }
    
    func updateCurrentUser(username: String, email: String, firstName: String, lastName: String, bio: String, link: URL, completion: @escaping (_ success: Bool) -> Void ) {
        
        guard let currentUser = currentUser else { completion(false); return }
        
        currentUser.username = username
        currentUser.email = email
        currentUser.firstName = firstName
        currentUser.lastName = lastName
        currentUser.bio = bio
        currentUser.link = link
        
        let currentUserRecord = currentUser.cloudKitRecord
        
        let op = CKModifyRecordsOperation(recordsToSave: [currentUserRecord], recordIDsToDelete: nil)
        
        op.modifyRecordsCompletionBlock = { ( _, _, error) in
            if let error = error { print(error.localizedDescription) }
            completion(true)
        }
        CKContainer.default().publicCloudDatabase.add(op)
    }
    
    
    func updateCurrentUserBlockedUser(completion: @escaping (_ success: Bool) -> Void ) {
        
        guard let currentUser = currentUser else { completion(false); return }
        
        let currentUserRecord = currentUser.cloudKitRecord
        
        let op = CKModifyRecordsOperation(recordsToSave: [currentUserRecord], recordIDsToDelete: nil)
        
        op.modifyRecordsCompletionBlock = { ( _, _, error) in
            if let error = error { print(error.localizedDescription) }
            completion(true)
        }
        CKContainer.default().publicCloudDatabase.add(op)
    }
    
    //    func userToBlock(blockUserRef: CKReference, completion: @escaping (_ success: Bool) -> Void) {
    //        self.currentUser?.blockedUserRefs.append(blockUserRef)
    //        guard let currentUser = self.currentUser else { return }
    //            let userRecord = currentUser.cloudKitRecord
    //
    //        cloudKitManager.modifyRecords([userRecord], perRecordCompletion: nil) { (records, error) in
    //            if let error = error {
    //                print("\(#function), \(error), \(error.localizedDescription)")
    //                completion(false); return
    //            } else {
    //                print("Blocked a user")
    //                completion(true)
    //            }
    //        }
    //    }
    
    func userToBlock(blockUserRef: CKReference, completion: @escaping (_ success: Bool) -> Void) {
        if currentUser?.cloudKitRecordID?.recordName != blockUserRef.recordID.recordName {
            self.currentUser?.blockedUserRefs.append(blockUserRef)
        } else {
            completion(false)
            return
        }
        guard let currentUser = self.currentUser else { return }
        let userRecord = currentUser.cloudKitRecord
        
        cloudKitManager.modifyRecords([userRecord], perRecordCompletion: nil) { (records, error) in
            if let error = error {
                print("\(#function), \(error), \(error.localizedDescription)")
                completion(false); return
            } else {
                print("Blocked a user")
                completion(true)
            }
        }
    }
}






























