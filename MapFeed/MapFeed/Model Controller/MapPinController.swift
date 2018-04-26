//
//  MapPinController.swift
//  MapFeed
//
//  Created by Jade Thomason on 4/25/18.
//  Copyright © 2018 Jade Thomason. All rights reserved.
//

import Foundation
import CloudKit
import UIKit

class MapPinController {
    static let shared = MapPinController()
    
    let publicDB = CKContainer.default().publicCloudDatabase
    
    var mapPins: [MapPin] = []
    
    let cloudKitManager: CloudKitManager = {
        return CloudKitManager()
    }()
    
    
    func createMapPinWithPhoto(user: User, gps: CLLocation, timestamp: Date = Date(), photo: UIImage?, completion: @escaping ((MapPin?) -> Void)){
        guard let userID = user.cloudKitRecordID,
            let photo = photo,
            let photoData = UIImageJPEGRepresentation(photo, 0.8) else { return }
        let userRef = CKReference(recordID: userID, action: .deleteSelf)
        
        let mapPin = MapPin(user: user, gpsCoordinates: gps, reference: userRef, timestamp: timestamp, mediaData: photoData)
        mapPins.append(mapPin)
        
        // CloudKit manager asks to save a ckRecord
        let mapPinRecord = mapPin.cloudKitRecord
        
        // pass in that record
        cloudKitManager.saveRecord(mapPinRecord) { (record, error) in
            if let error = error { print(error.localizedDescription) }
            guard let record = record else { return }
            
            // match the record that you get back from cloudKit manager to you object
            let mapPinID = record.recordID
            mapPin.cloudKitRecordID = mapPinID
            // this populates the local array and matches the new post
            self.mapPins = [mapPin]
            completion(mapPin)
        }
    }
    
    
    func fetchMapPins(user: User, completion: @escaping () -> Void) {
        guard let userRecordID = user.cloudKitRecordID else { completion(); return }
        let userReference = CKReference(recordID: userRecordID, action: .deleteSelf)
        let predicate = NSPredicate(format: "userRef == %@", userReference)
        
        cloudKitManager.fetchRecordsOf(type: MapPin.typeKey, predicate: predicate, database: publicDB) { (records, error) in
            if let error = error { print(error.localizedDescription) }
            guard let records = records else { completion(); return }
            let mapPins = records.compactMap({ MapPin(cloudKitRecord: $0)})
            self.mapPins = mapPins
            for mapPin in mapPins {
                mapPin.user?.mapPins = mapPins
            }
            completion()
        }
    }
}
