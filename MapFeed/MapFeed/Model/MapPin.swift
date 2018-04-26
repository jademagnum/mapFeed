//
//  MapPin.swift
//  MapFeed
//
//  Created by Jade Thomason on 4/17/18.
//  Copyright © 2018 Jade Thomason. All rights reserved.
//

import Foundation
import UIKit
import CloudKit
import UIKit

class MapPin {
    
    static let typeKey = "MapPin"
    private let gpsCoordinatesKey = "gpsCoordinates"
    private let referenceKey = "reference"
    private let timestampKey = "timestamp"
    private let mediaDataKey = "mediaData"
    private let userRefKey = "userReference"
    
    weak var user: User?
    let gpsCoordinates: CLLocation
    let reference: CKReference
    let timestamp: Date
    let mediaData: Data?
    var cloudKitRecordID: CKRecordID?
    var photo: UIImage? {
        guard let mediaData = mediaData else { return nil }
        return UIImage(data: mediaData)
    }
    
    init(user: User?, gpsCoordinates: CLLocation, reference: CKReference, timestamp: Date = Date(), mediaData: Data = Data(), photo: UIImage = UIImage()) {
        self.user = user
        self.gpsCoordinates = gpsCoordinates
        self.reference = reference
        self.timestamp = timestamp
        self.mediaData = mediaData
    }

    init?(cloudKitRecord: CKRecord) {
        
        guard let gpsCoordinates = cloudKitRecord[gpsCoordinatesKey] as? CLLocation,
            let reference = cloudKitRecord[referenceKey] as? CKReference,
            let timestamp = cloudKitRecord[timestampKey] as? Date
  //          let mediaData = cloudKitRecord[mediaDataKey] as? CKAsset
            else { return nil }
        self.gpsCoordinates = gpsCoordinates
        self.reference = reference
        self.timestamp = timestamp
 //       self.mediaData = mediaData
        self.cloudKitRecordID = cloudKitRecord.recordID
        
        guard let photoAsset = cloudKitRecord[mediaDataKey] as? CKAsset else { return nil }
        let mediaData = try? Data(contentsOf: photoAsset.fileURL)
        self.mediaData = mediaData
    }
    
    var temporaryPhotoURL: URL {
        let temporaryDirectory = NSTemporaryDirectory()
        let temporaryDirectoryURL = URL(fileURLWithPath: temporaryDirectory)
        let fileURL = temporaryDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
        try? mediaData?.write(to: fileURL, options: [.atomic])
        return fileURL
    }
    
    
    var cloudKitRecord: CKRecord {
        let recordID = cloudKitRecordID ?? CKRecordID(recordName: UUID().uuidString)
        let record = CKRecord(recordType: MapPin.typeKey, recordID: recordID)
        
        record.setValue(gpsCoordinates, forKey: gpsCoordinatesKey)
        record.setValue(reference, forKey: referenceKey)
        record.setValue(timestamp, forKey: timestampKey)
//      record.setValue(mediaData, forKey: mediaDataKey)
        record.setValue(CKAsset(fileURL: temporaryPhotoURL), forKey: mediaDataKey)
        
        if let user = user,
            let userRecordID = user.cloudKitRecordID {
            let userReference = CKReference(recordID: userRecordID, action: .deleteSelf)
            record.setValue(userReference, forKey: userRefKey)
        }
        return record
    }
}

















