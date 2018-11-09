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
    
//    init() {
//        self.comments = fetchComments()
//    }
 
    
    func fetchComments(post: Post, completion: @escaping (_ success: Bool) -> Void)  {
        guard let postRecordID = post.cloudKitRecordID else { completion(false); return }
        let postReference = CKRecord.Reference(recordID: postRecordID, action: .deleteSelf)
        let predicate = NSPredicate(format: "postRef == %@", postReference)
        
        cloudKitManager.fetchRecordsOf(type: Comment.typeKey, predicate: predicate, database: publicDB) { (records, error) in
            if let error = error { print(error.localizedDescription) }
            guard let records = records else { completion(false); return }
            var comments = records.compactMap({ Comment(cloudKitRecord: $0, post: post)})
            comments.sort(by: { $0.timestamp.compare($1.timestamp) == .orderedAscending })
            self.comments = comments
//            for comment in comments {
//                post.comments = comments
//            }
//            completion(true)
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
        let userReference = CKRecord.Reference(recordID: userRecordID, action: .deleteSelf)
        
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
    
    func addComment(toPost post: Post, user: User, commentText: String, userRef: CKRecord.Reference, postRef: CKRecord.Reference, completion: @escaping ((Comment) -> Void) = { _ in }) -> Comment {
        let comment = Comment(post: post, user: user, text: commentText, userRef: userRef, postRef: postRef)
        post.comments.append(comment)
        
                cloudKitManager.modifyRecords([comment.cloudKitRecord], perRecordCompletion: nil) { (records, error) in
                    guard let records = records else { return }
                    if let error = error {
                        print("\(#function), \(error), \(error.localizedDescription)")
                    }
                }
        return comment
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








