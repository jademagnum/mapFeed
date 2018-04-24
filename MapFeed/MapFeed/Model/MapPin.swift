//
//  MapPin.swift
//  MapFeed
//
//  Created by Jade Thomason on 4/17/18.
//  Copyright © 2018 Jade Thomason. All rights reserved.
//

import Foundation
import CloudKit

class MapPin {
    
    static let typeKey = "MapPin"
    private let gpsCoordinatesKey = "gpsCoordinates"
    private let referenceKey = "reference"
    private let timestampKey = "timestamp"
    private let videoKey = "video"
    private let userRefKey = "userReference"
    
    weak var user: User?
    let gpsCoordinates: Double
    let reference: CKReference
    let timestamp: Date
    let video: Data
    var cloudKitRecordID: CKRecordID?
    
    init(user: User?, gpsCoordinates: Double, reference: CKReference, timestamp: Date = Date(), video: Data = Data()) {
        self.user = user
        self.gpsCoordinates = gpsCoordinates
        self.reference = reference
        self.timestamp = timestamp
        self.video = video
    }
    
    init?(cloudKitRecord: CKRecord) {
        guard let gpsCoordinates = cloudKitRecord[gpsCoordinatesKey] as? Double,
            let reference = cloudKitRecord[referenceKey] as? CKReference,
            let timestamp = cloudKitRecord[timestampKey] as? Date,
            let video = cloudKitRecord[videoKey] as? Data else { return nil }
        self.gpsCoordinates = gpsCoordinates
        self.reference = reference
        self.timestamp = timestamp
        self.video = video
        self.cloudKitRecordID = cloudKitRecord.recordID
    }
    
    var cloudKitRecord: CKRecord {
        let recordID = cloudKitRecordID ?? CKRecordID(recordName: UUID().uuidString)
        let record = CKRecord(recordType: MapPin.typeKey, recordID: recordID)
        record.setValue(gpsCoordinates, forKey: gpsCoordinatesKey)
        record.setValue(reference, forKey: referenceKey)
        record.setValue(timestamp, forKey: timestampKey)
        record.setValue(video, forKey: videoKey)
        
        if let user = user,
            let userRecordID = user.cloudKitRecordID {
            let userReference = CKReference(recordID: userRecordID, action: .deleteSelf)
            record.setValue(userReference, forKey: userRefKey)
        }
        return record
    }
}

















