//
//  PostController.swift
//  MapFeed
//
//  Created by Jade Thomason on 4/18/18.
//  Copyright © 2018 Jade Thomason. All rights reserved.
//

import Foundation
import CloudKit

class PostController {
    static let shared = PostController()
    
    let publicDB = CKContainer.default().publicCloudDatabase
    
    var posts: [Post] = []
    
    let cloudKitManager: CloudKitManager = {
        return CloudKitManager()
    }()
    
    
    func createPostWith(user: User, headline: String, url: String, gps: CLLocation, timestamp: Date = Date(), completion: @escaping ((Post?) -> Void)){
        guard let userID = user.cloudKitRecordID else { return }
        
        let userRef = CKReference(recordID: userID, action: .deleteSelf)
    
        let post = Post(user: user, headline: headline, url: url, gpsPin: gps, userRef: userRef)
        posts.append(post)
        
        // CloudKit manager asks to save a ckRecord
        let postRecord = post.cloudKitRecord
        
        // pass in that record
        cloudKitManager.saveRecord(postRecord) { (record, error) in
            if let error = error { print(error.localizedDescription) }
            guard let record = record else { return }
            
            // match the record that you get back from cloudKit manager to you object
            let postID = record.recordID
            post.cloudKitRecordID = postID
            // this populates the local array and matches the new post 
            self.posts = [post]
            completion(post)
            return
        }
    }
    
    func fetchPosts(user: User, completion: @escaping () -> Void) {
        guard let userRecordID = user.cloudKitRecordID else { completion(); return }
        let userReference = CKReference(recordID: userRecordID, action: .deleteSelf)
        let predicate = NSPredicate(format: "userRef == %@", userReference)
        
        cloudKitManager.fetchRecordsOf(type: Post.typeKey, predicate: predicate, database: publicDB) { (records, error) in
            if let error = error { print(error.localizedDescription) }
            guard let records = records else { completion(); return }
            let posts = records.compactMap({ Post(cloudKitRecord: $0, user: user )})
            self.posts = posts
            for post in posts {
                post.user?.posts = posts
            }
            
            completion()
        }
    }

    // This shouldn't be used anymore
    
    func fetchAllPosts(post: Post, completion: @escaping () -> Void) {
        
        let predicate = NSPredicate(value: true)
        
        cloudKitManager.fetchRecordsWithType(Post.typeKey, predicate: predicate, recordFetchedBlock: nil) { (records, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(); return
            }
            guard let records = records else { completion(); return }
            let posts = records.compactMap {Post(cloudKitRecord: $0, user: nil)}
            self.posts = posts
            
        }
    }
    
   
}


/// fetch the users and the pins together
// fetch the post seperate

























