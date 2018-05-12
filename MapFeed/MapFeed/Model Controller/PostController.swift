//
//  PostController.swift
//  MapFeed
//
//  Created by Jade Thomason on 4/18/18.
//  Copyright © 2018 Jade Thomason. All rights reserved.
//

import Foundation
import CloudKit
import MapKit

class PostController {
    static let shared = PostController()
    
    let publicDB = CKContainer.default().publicCloudDatabase
    
    var posts: [Post] = []
    
    let cloudKitManager: CloudKitManager = {
        return CloudKitManager()
    }()
    
    
    func createPostWith(user: User, headline: String, url: String, gpsLatitude: Double, gpsLongitude: Double, timestamp: Date = Date(), completion: @escaping ((Post?) -> Void)){
        guard let userID = user.cloudKitRecordID else { return }
        
        let userRef = CKReference(recordID: userID, action: .deleteSelf)
    
        let post = Post(user: user, headline: headline, url: url, gpsLatitude: gpsLatitude, gpsLongitude: gpsLongitude, userRef: userRef)
        
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
        
        guard let postID = post.cloudKitRecordID else { return }
        let postRef = CKReference(recordID: postID, action: .deleteSelf)
        
        let captionComment = addComment(toPost: post, user: user, commentText: headline, userRef: userRef, postRef: postRef)
        
        cloudKitManager.modifyRecords([captionComment.cloudKitRecord], perRecordCompletion: nil) { (records, error) in
            guard let records = records else { return }
            if let error = error {
                print("\(#function), \(error), \(error.localizedDescription)")
                return
            }
        }
    }
    
    @discardableResult func addComment(toPost post: Post, user: User, commentText: String, userRef: CKReference, postRef: CKReference, completion: @escaping ((Comment) -> Void) = { _ in }) -> Comment {
        let comment = Comment(post: post, user: user, text: commentText, userRef: userRef, postRef: postRef)
        post.comments.append(comment)
        
//        cloudKitManager.modifyRecords([comment.cloudKitRecord], perRecordCompletion: nil) { (records, error) in
//            guard let records = records else { return }
//            if let error = error {
//                print("\(#function), \(error), \(error.localizedDescription)")
//            }
//        }
        return comment
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
    
    
    func fetchAllMapPinGPSLocationWithinACertainArea(mapView: MKMapView, completion: @escaping ([Post]) -> Void) {
        
        let span: MKCoordinateSpan = mapView.region.span
        let center: CLLocationCoordinate2D = mapView.region.center
        //This is the farthest Lat point to the left
        let farthestLeft = center.latitude + span.latitudeDelta * 1.0
        //This is the farthest Lat point to the right
        let farthestRight = center.latitude - span.latitudeDelta * 1.0
        //This is the farthest Long point to the top
        let farthestTop = center.longitude + span.longitudeDelta * 1.0
        //This is the farthest Long point to the bottom
        let farthestBottom = center.longitude - span.longitudeDelta * 1.0
        
        let predicate1 = NSPredicate(format: "gpsLatitude < %lf", farthestLeft)
        let predicate2 = NSPredicate(format: "gpsLatitude > %lf", farthestRight)
        let predicate3 = NSPredicate(format: "gpsLongitude < %lf", farthestTop)
        let predicate4 = NSPredicate(format: "gpsLongitude > %lf", farthestBottom)
        
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2, predicate3, predicate4])
        
        let query = CKQuery(recordType: Post.typeKey, predicate: compoundPredicate)
        //This gets everything
        //        let query = CKQuery(recordType: MapPin.typeKey, predicate: NSPredicate(value: true))
        let ckQueryOperation = CKQueryOperation(query: query)
        ckQueryOperation.desiredKeys = ["gpsLatitude", "gpsLongitude", "url", "headline", "userRef", "timestamp" ]
        
        var records: [CKRecord] = []
        
        ckQueryOperation.recordFetchedBlock = { (record) in
            records.append(record)
        }
        
        ckQueryOperation.completionBlock = {
            let posts = records.compactMap({Post(cloudKitRecord: $0, user: nil)})
            completion(posts)
        }
        
        publicDB.add(ckQueryOperation)
    }
}


/// fetch the users and the pins together
// fetch the post seperate

























