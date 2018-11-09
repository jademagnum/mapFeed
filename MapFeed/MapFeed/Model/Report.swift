//
//  Report.swift
//  MapFeed
//
//  Created by Jade Thomason on 5/3/18.
//  Copyright © 2018 Jade Thomason. All rights reserved.
//

import Foundation
import CloudKit

class Report {
    
    static let typeKey = "Report"
    private let reportedForKey = "reportedFor"
    private let mediaRefKey = "mediaRef"
    
    weak var post: Post?
    weak var mapPin: MapPin?
    var reportedFor: String
    var cloudKitRecordID: CKRecord.ID?
    var mediaRef: CKRecord.Reference?
    
    init(post: Post?, mapPin: MapPin?, reportedFor: String, mediaRef: CKRecord.Reference?) {
        self.post = post
        self.mapPin = mapPin
        self.reportedFor = reportedFor
        self.mediaRef = mediaRef
    }
    
    init?(cloudKitRecord: CKRecord, post: Post?, mapPin: MapPin?) {
        guard let reportedFor = cloudKitRecord[reportedForKey] as? String,
        let mediaRef = cloudKitRecord[mediaRefKey] as? CKRecord.Reference else { return nil }
        
        self.post = post
        self.mapPin = mapPin
        self.reportedFor = reportedFor
        self.mediaRef = mediaRef
    }
    
    var cloudKitRecord: CKRecord {
        
        let recordID = cloudKitRecordID ?? CKRecord.ID(recordName: UUID().uuidString)
        let record = CKRecord(recordType: Report.typeKey, recordID: recordID)
        
        record.setValue(reportedFor, forKey: reportedForKey)
        
        if let post = post,
            let postRecordID = post.cloudKitRecordID {
            let postReference = CKRecord.Reference(recordID: postRecordID, action: .deleteSelf)
            record.setValue(postReference, forKey: mediaRefKey)
        } else {
            record.setValue(mediaRef, forKey: mediaRefKey)
        }
        
        if let mapPin = mapPin,
            let mapPinRecordID = mapPin.cloudKitRecordID {
            let mapPinReference = CKRecord.Reference(recordID: mapPinRecordID, action: .deleteSelf)
            record.setValue(mapPinReference, forKey: mediaRefKey)
        } else {
            record.setValue(mediaRef, forKey: mediaRefKey)
        }
        
        return record
    }   
}

























