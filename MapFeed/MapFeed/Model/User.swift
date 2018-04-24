//
//  User.swift
//  MapFeed
//
//  Created by Jade Thomason on 4/17/18.
//  Copyright © 2018 Jade Thomason. All rights reserved.
//

import Foundation
import CloudKit
import CoreData

class User {
    
    static let typeKey = "User"
    private let appleUserRefKey = "appleUserRef"
    private let usernameKey = "username"
    private let emailKey = "email"
    private let firstNameKey = "firstName"
    private let lastNameKey = "lastName"
    private let bioKey = "bio"
    private let linkKey = "link"
    
    var username: String
    var email: String
    var firstName: String?
    var lastName: String?
    var bio: String?
    var link: URL?
    var posts: [Post]
    var mapPins: [MapPin]
    let appleUserRef: CKReference
    var cloudKitRecordID: CKRecordID?
    
    init(username: String, email: String, firstName: String? = nil, lastName: String? = nil, bio: String? = nil, link: URL? = nil, posts: [Post] = [], mapPins: [MapPin] = [], appleUserRef: CKReference) {
        self.username = username
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.bio = bio
        self.link = link
        self.posts = posts
        self.mapPins = mapPins
        self.appleUserRef = appleUserRef
    }
    
    init?(cloudKitRecord: CKRecord) {
        guard let username = cloudKitRecord[usernameKey] as? String,
        let email = cloudKitRecord[emailKey] as? String,
        let appleUserRef = cloudKitRecord[appleUserRefKey] as? CKReference else { return nil }
        
        self.username = username
        self.email = email
        self.firstName = cloudKitRecord[firstNameKey] as? String
        self.lastName = cloudKitRecord[lastNameKey] as? String
        self.bio = cloudKitRecord[bioKey] as? String
        self.link = cloudKitRecord[linkKey] as? URL
        self.posts = []
        self.mapPins = []
        self.appleUserRef = appleUserRef
        self.cloudKitRecordID = cloudKitRecord.recordID
    }
    
    var cloudKitRecord: CKRecord {
        
        let recordID = cloudKitRecordID ?? CKRecordID(recordName: UUID().uuidString)
        let record = CKRecord(recordType: User.typeKey, recordID: recordID)
        
        record.setValue(username, forKey: usernameKey)
        record.setValue(email, forKey: emailKey)
        record.setValue(firstName, forKey: firstNameKey)
        record.setValue(lastName, forKey: lastNameKey)
        record.setValue(bio, forKey: bioKey)
        record.setValue(link, forKey: linkKey)
        record.setValue(appleUserRef, forKey: appleUserRefKey)
        
        return record
    }
}

















