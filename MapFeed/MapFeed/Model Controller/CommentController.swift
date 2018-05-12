//
//  CommentController.swift
//  MapFeed
//
//  Created by Jade Thomason on 5/11/18.
//  Copyright © 2018 Jade Thomason. All rights reserved.
//

import Foundation
import CloudKit

class CommmentController {
    
    static let shared = CommmentController()
    
    let publicDB = CKContainer.default().publicCloudDatabase
    
    var comments: [Comment] = []
    
    let cloudKitManager: CloudKitManager = {
        return CloudKitManager()
    }()
    
    func fetchComments(post: Post, completion: @escaping (_ success: Bool) -> Void) {
        guard let postRecordID = post.cloudKitRecordID else { completion(false); return }
        let postReference = CKReference(recordID: postRecordID, action: .deleteSelf)
        let predicate = NSPredicate(format: "postRef == %@", postReference)
        
        cloudKitManager.fetchRecordsOf(type: Comment.typeKey, predicate: predicate, database: publicDB) { (records, error) in
            if let error = error { print(error.localizedDescription) }
            guard let records = records else { completion(false); return }
            let comments = records.compactMap({ Comment(cloudKitRecord: $0, post: post)})
            let dispatchGroup = DispatchGroup()
            for comment in comments {
                dispatchGroup.enter()
                self.fetchUserFor(comment: comment, completion: { (success) in
                    if !success {
                        print("error fetching user")
                    }
                    dispatchGroup.leave()
                })
            }
            dispatchGroup.notify(queue: .main, execute: {
                post.comments = comments
                completion(true)
            })
        }
    }
    
    func fetchUserFor(comment: Comment, completion: @escaping (_ success: Bool) -> Void) {
        
       guard let userRecordID = comment.userRef?.recordID else { return }
        let userReference = CKReference(recordID: userRecordID, action: .deleteSelf)
        
             let predicate = NSPredicate(format: "recordID = %@", userReference)
  //      let predicate = NSPredicate(value: true)
        
        self.cloudKitManager.fetchRecordsWithType(User.typeKey, predicate: predicate, recordFetchedBlock: nil, completion: { (records, error) in
            if let error = error { print(error.localizedDescription) }
            guard let userRecord = records?.first else { completion(false); return}
            let user = User(cloudKitRecord: userRecord)
            comment.user = user
            completion(true)
        })
    }
}






//        let query = CKQuery(recordType: User.typeKey, predicate: predicate)
//        let ckQueryOperation = CKQueryOperation(query: query)
//        ckQueryOperation.desiredKeys = ["username"]
//
//        var records: [CKRecord] = []
//        ckQueryOperation.recordFetchedBlock = { (record) in
//            records.append(record)
//        }
//        ckQueryOperation.completionBlock = {
//            let users = records.compactMap({User(cloudKitRecord: $0)})
//            let user = users.first
//            comment.user = user
//            completion(users)








