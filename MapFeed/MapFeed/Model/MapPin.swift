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
import MapKit

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude &&
            lhs.longitude == rhs.longitude
    }
}

class MapPin: NSObject, MKAnnotation {
    
    static let typeKey = "MapPin"
    private let gpsLongitudeKey = "gpsLongitude"
    private let gpsLatitudeKey = "gpsLatitude"
    private let referenceKey = "reference"
    private let timestampKey = "timestamp"
    private let mediaDataKey = "mediaData"
    private let userRefKey = "userReference"
    
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: gpsLatitude, longitude: gpsLongitude)
    }
    
    var title: String? {
        return "Media"
    }
    
    weak var user: User?
    let gpsLongitude: Double
    let gpsLatitude: Double
    let reference: CKReference
    let timestamp: Date
    var mediaData: Data?
    var cloudKitRecordID: CKRecordID?
    var photo: UIImage? {
        guard let mediaData = mediaData else { return nil }
        return UIImage(data: mediaData)
    }
    
    init(user: User?, gpsLatitude: Double, gpsLongitude: Double, reference: CKReference, timestamp: Date = Date(), mediaData: Data = Data(), photo: UIImage = UIImage()) {
        self.user = user
        self.gpsLatitude = gpsLatitude
        self.gpsLongitude = gpsLongitude
        self.reference = reference
        self.timestamp = timestamp
        self.mediaData = mediaData
    }

    init?(cloudKitRecord: CKRecord, user: User?) {
        
        guard let gpsLatitude = cloudKitRecord[gpsLatitudeKey] as? Double,
            let gpsLongitude = cloudKitRecord[gpsLongitudeKey] as? Double,
            let reference = cloudKitRecord[referenceKey] as? CKReference,
            let timestamp = cloudKitRecord[timestampKey] as? Date else { return nil }
        self.gpsLatitude = gpsLatitude
        self.gpsLongitude = gpsLongitude
        self.reference = reference
        self.timestamp = timestamp
        self.cloudKitRecordID = cloudKitRecord.recordID
        
        guard let photoAsset = cloudKitRecord[mediaDataKey] as? CKAsset else { return }
        let mediaData = try? Data(contentsOf: photoAsset.fileURL)
        self.mediaData = mediaData
        self.user = user
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
        
        record.setValue(gpsLatitude, forKey: gpsLatitudeKey)
        record.setValue(gpsLongitude, forKey: gpsLongitudeKey)
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

















