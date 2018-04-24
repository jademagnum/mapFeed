//
//  UserController.swift
//  MapFeed
//
//  Created by Jade Thomason on 4/18/18.
//  Copyright © 2018 Jade Thomason. All rights reserved.
//

import Foundation
import CloudKit

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
            
            
            let user = User(username: username, email: email, appleUserRef: appleUserRef)
            
            let userRecord = user.cloudKitRecord
            let firstName = user.firstName
            
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
    
    func fetchAllUsers(completion: @escaping (_ success: Bool) -> Void = { _ in }) {
        CKContainer.default().fetchUserRecordID { (appleRecordID, error) in
            
            if let error = error { print(error.localizedDescription) }
            
//            guard let appleRecordID = appleRecordID else { completion(false); return }
            
            let predicate = NSPredicate(value: true)
            
            self.cloudKitManager.fetchRecordsWithType(User.typeKey, predicate: predicate, recordFetchedBlock: nil, completion: { (records, error) in
                if let error = error { print(error.localizedDescription) }
                guard let records = records else { completion(false); return}
                let users = records.compactMap{User(cloudKitRecord: $0)}
                self.users = users
                completion(true)
            })
        
            guard let user = self.currentUser else { return }
            
            self.fetchPostsFor(user: user, completion: { (success) in
                if !success {
                    print("Error fetching posts")
                }
            })
        }
    }
    
    func fetchPostsFor(user: User, completion: @escaping (_ success: Bool) -> Void) {
        guard let userRecordID = user.cloudKitRecordID else { completion(false); return }
        let userReference = CKReference(recordID: userRecordID, action: .deleteSelf)
        let predicate = NSPredicate(value: true)
        CloudKitManager.shared.fetchRecordsOf(type: Post.typeKey, predicate: predicate, database: publicDB) { (records, error) in
            if let error = error {
                print("Error fetching posts for user \(#file) \(#function) \(error.localizedDescription)")
                completion(false); return
            }
            guard let records = records else { completion(false); return }
            let posts = records.compactMap({ Post(cloudKitRecord: $0 ) })
            user.posts = posts
//            let allPosts = PostController.shared.posts
//            user.posts = allPosts
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
    
}































