//
//  Comment.swift
//  MapFeed
//
//  Created by Jade Thomason on 4/17/18.
//  Copyright © 2018 Jade Thomason. All rights reserved.
//

import Foundation
import CloudKit

class Comment {
    
    static let typeKey = "Comment"
    private let textKey = "text"
    private let postKey = "post"
    private let userKey = "user"
    private let timestampKey = "timestamp"
    private let userRefKey = "userRef"
    private let postRefKey = "postRef"
    
    let timestamp: Date
    let text: String
    var post: Post?
    var userRef: CKRecord.Reference?
    var cloudKitRecordID: CKRecord.ID?
    var postRef: CKRecord.Reference?
    var user: User?
    
    init(post: Post?, user: User? = nil, text: String, timestamp: Date = Date(), userRef: CKRecord.Reference?, postRef: CKRecord.Reference?) {
        self.post = post
        self.user = user
        self.text = text
        self.timestamp = timestamp
        self.userRef = userRef
        self.postRef = postRef
    }
    
    init?(cloudKitRecord: CKRecord, post: Post?) {
        guard let timestamp = cloudKitRecord.creationDate,
        let text = cloudKitRecord[textKey] as? String,
            let postRef = cloudKitRecord[postRefKey] as? CKRecord.Reference,
            let userRef = cloudKitRecord[userRefKey] as? CKRecord.Reference else { return nil }
        
        self.timestamp = timestamp
        self.text = text
        self.userRef = userRef
        self.cloudKitRecordID = cloudKitRecord.recordID
        self.post = post
        self.postRef = postRef
    }
    
    var cloudKitRecord: CKRecord {
        let recordID = cloudKitRecordID ?? CKRecord.ID(recordName: UUID().uuidString)
        let record = CKRecord(recordType: Comment.typeKey, recordID: recordID)
        record.setValue(timestamp, forKey: timestampKey)
        record.setValue(text, forKey: textKey)
        record.setValue(userRef, forKey: userRefKey)
        
        if let post = post,
            let postRecordID = post.cloudKitRecordID {
            let postReference = CKRecord.Reference(recordID: postRecordID, action: .deleteSelf)
            record.setValue(postReference, forKey: postRefKey)
        } else {
            record.setValue(postRef, forKey: postRefKey)
        }
        
        if let user = user,
            let userRecordID = user.cloudKitRecordID {
            let userReference = CKRecord.Reference(recordID: userRecordID, action: .deleteSelf)
            record.setValue(userReference, forKey: userRefKey)
        } else {
            record.setValue(userRef, forKey: userRefKey)
        }
        return record
    }
}
