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
    private let blockedUserRefsKey = "blockedUserRefs"
    
    var username: String
    var email: String
    var firstName: String?
    var lastName: String?
    var bio: String?
    var link: URL?
    var posts: [Post]
    var mapPins: [MapPin]
    var blockedUserRefs: [CKRecord.Reference] = []
    
    let appleUserRef: CKRecord.Reference
    var cloudKitRecordID: CKRecord.ID?
    
    init(username: String, email: String, firstName: String? = nil, lastName: String? = nil, bio: String? = nil, link: URL? = nil, posts: [Post] = [], mapPins: [MapPin] = [], appleUserRef: CKRecord.Reference, blockedUserRefs: [CKRecord.Reference] = []) {
        self.username = username
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.bio = bio
        self.link = link
        self.posts = posts
        self.mapPins = mapPins
        self.appleUserRef = appleUserRef
        self.blockedUserRefs = blockedUserRefs
    }
    
    init?(cloudKitRecord: CKRecord) {
        guard let username = cloudKitRecord[usernameKey] as? String,
        let email = cloudKitRecord[emailKey] as? String,
        let appleUserRef = cloudKitRecord[appleUserRefKey] as? CKRecord.Reference else { return nil }
        
        self.blockedUserRefs = cloudKitRecord[blockedUserRefsKey] as? [CKRecord.Reference] ?? []
        
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
        
        let recordID = cloudKitRecordID ?? CKRecord.ID(recordName: UUID().uuidString)
        let record = CKRecord(recordType: User.typeKey, recordID: recordID)
        
        record.setValue(username, forKey: usernameKey)
        record.setValue(email, forKey: emailKey)
        record.setValue(firstName, forKey: firstNameKey)
        record.setValue(lastName, forKey: lastNameKey)
        record.setValue(bio, forKey: bioKey)
        record.setValue(link, forKey: linkKey)
        record.setValue(appleUserRef, forKey: appleUserRefKey)
        record.setValue(blockedUserRefs, forKey: blockedUserRefsKey)
        
        return record
    }
}

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        if lhs.username != rhs.username { return false}
        if lhs.email != rhs.email { return false}
        if lhs.firstName != rhs.firstName { return false}
        if lhs.lastName != rhs.lastName { return false}
        if lhs.bio != rhs.bio { return false}
        if lhs.link != rhs.link { return false}
        if lhs.posts != rhs.posts { return false}
        if lhs.mapPins != rhs.mapPins { return false}
        if lhs.blockedUserRefs != rhs.blockedUserRefs { return false}
        if lhs.appleUserRef != rhs.appleUserRef { return false}
        if lhs.cloudKitRecordID != rhs.cloudKitRecordID { return false}
        return true
    }
}













