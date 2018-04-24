//
//  Post.swift
//  MapFeed
//
//  Created by Jade Thomason on 4/17/18.
//  Copyright © 2018 Jade Thomason. All rights reserved.
//

import Foundation
import CloudKit
import CoreData

class Post {
    
    static let typeKey = "Post"
    private let headlineKey = "headline"
    private let userRefKey = "userRef"
    private let urlKey = "url"
    private let gpsPinKey = "gpsPin"
    private let timeStampKey = "timeStamp"
    
    weak var user: User?
    var headline: String
    var url: String
    var gpsPin: CLLocation
    var comments: [Comment]
    var likes: [Like]
    var timeStamp: Date
    var cloudKitRecordID: CKRecordID?
    var userRef: CKReference?
    
    init(user: User?, headline: String, url: String, gpsPin: CLLocation, comments: [Comment] = [], likes: [Like] = [], timeStamp: Date = Date(), userRef: CKReference?) {
        
        self.user = user
        self.headline = headline
        self.url = url
        self.gpsPin = gpsPin
        self.comments = comments
        self.likes = likes
        self.timeStamp = timeStamp
        self.userRef = userRef
    }
    
    init?(cloudKitRecord: CKRecord, user: User?) {
        guard let url = cloudKitRecord[urlKey] as? String,
            let headline = cloudKitRecord[headlineKey] as? String,
            let timeStamp = cloudKitRecord.creationDate,
            let gpsPin = cloudKitRecord[gpsPinKey] as? CLLocation,
            let userRef = cloudKitRecord[userRefKey] as? CKReference else { return nil }
            
        self.url = url
        self.headline = headline
        self.gpsPin = gpsPin
        self.comments = []
        self.likes = []
        self.timeStamp = timeStamp
        self.userRef = userRef
        self.cloudKitRecordID = cloudKitRecord.recordID
        self.user = user
    }
    
    var cloudKitRecord: CKRecord {
        let recordID = cloudKitRecordID ?? CKRecordID(recordName: UUID().uuidString)
        let record = CKRecord(recordType: Post.typeKey, recordID: recordID)
        record.setValue(url, forKey: urlKey)
        record.setValue(headline, forKey: headlineKey)
        record.setValue(gpsPin, forKey: gpsPinKey)
        record.setValue(timeStamp, forKey: timeStampKey)
        
        if let user = user,
            let userRecordID = user.cloudKitRecordID {
            let userReference = CKReference(recordID: userRecordID, action: .deleteSelf)
            record.setValue(userReference, forKey: userRefKey)
        } else {
            record.setValue(userRef, forKey: userRefKey)
        }
        return record
    }
}















