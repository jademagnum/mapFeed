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
import MapKit

class MapPinController {
    static let shared = MapPinController()
    
    let publicDB = CKContainer.default().publicCloudDatabase
    
    var mapPins: [MapPin] = []
    var mapPin: MapPin?
    
    let cloudKitManager: CloudKitManager = {
        return CloudKitManager()
    }()
    
    
    func createMapPinWithMediaData(user: User, gpsLatitude: Double, gpsLongitude: Double, timestamp: Date = Date(), mediaData: Data, completion: @escaping ((MapPin?) -> Void)){
        guard let userID = user.cloudKitRecordID else { return }
        let userRef = CKRecord.Reference(recordID: userID, action: .deleteSelf)
        
        let mapPin = MapPin(user: user, gpsLatitude: gpsLatitude, gpsLongitude: gpsLongitude, reference: userRef, timestamp: timestamp, mediaData: mediaData)
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
    
//    func fetchAllMapPins(completion: @escaping ([MapPin]) -> Void) {
//
//        cloudKitManager.fetchRecordsOf(type: MapPin.typeKey, database: publicDB) { (records, error) in
//            guard let records = records else { return }
//
//            let mapPins = records.compactMap({ MapPin(cloudKitRecord: $0, user: nil) })
//            completion(mapPins)
//        }
//    }
    
    func fetchMapPinWithCKRecord(cKRecord: CKRecord.ID ,completion: @escaping (MapPin?) -> Void) {
        cloudKitManager.fetchRecord(withID: cKRecord) { (record, error) in
            guard let record = record else { completion(nil); return }
            let mapPin = MapPin(cloudKitRecord: record, user: nil)
            completion(mapPin)
        }
    }
    
 //   func mapView(mapView: MKMapView, regioonDidChangeAnimated animated: Bool) {
        //        var span: MKCoordinateSpan = mapView.region.span
        //        var center: CLLocationCoordinate2D = mapView.region.center
        //
        //        //This is the farthest Lat point to the left
        //        var farthestLeft = center.latitude - span.latitudeDelta * 0.5
        //        //This is the farthest Lat point to the right
        //        var farthestRight = center.latitude + span.latitudeDelta * 0.5
        //        //This is the farthest Long point to the top
        //        var farthestTop = center.longitude - span.longitudeDelta * 0.5
        //        //This is the farthest Long point to the bottom
        //        var farthestBotton = center.longitude + span.longitudeDelta * 0.5
        //        var SWCoord = MKCoordinateForMapPoint(farthestBotton, farthestLeft)
        //        var NWCoord = MKCoordinateForMapPoint(farthestTop, farthestRight)
        
   //     //Using visible mapRect
  //      var mapRect = mapView.visibleMapRect
//     //   This is the top right Coordinate
//        var NECoord = getCoordinateFromMapRectanglePoint(MKMapRectGetMaxX(mapRect), y: mapRect.origin.y)
//        var SWCoord = getCoordinateFromMapRectanglePoint(mapRect.origin.x, y: MKMapRectGetMaxY(mapRect))
        
        
 //   }
    
    func fetchAllMapPinGPSLocationWithinACertainArea(mapView: MKMapView, completion: @escaping ([MapPin]) -> Void) {
    
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
        guard let user = UserController.shared.currentUser else { return }
        let blockedUserRefs = user.blockedUserRefs
        
        let predicate5 = NSPredicate(format: "NOT(userReference IN %@)", blockedUserRefs)
        
        
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2, predicate3, predicate4, predicate5])
        
        let query = CKQuery(recordType: MapPin.typeKey, predicate: compoundPredicate)
//        let query = CKQuery(recordType: MapPin.typeKey, predicate: NSPredicate(value: true))
        let ckQueryOperation = CKQueryOperation(query: query)
        ckQueryOperation.desiredKeys = ["gpsLatitude", "gpsLongitude", "reference", "userReference", "timestamp" ]
        
        var records: [CKRecord] = []
        
        ckQueryOperation.recordFetchedBlock = { (record) in
            records.append(record)
        }
        
        ckQueryOperation.completionBlock = {
            let mapPins = records.compactMap({MapPin(cloudKitRecord: $0, user: nil)})
            completion(mapPins)
        }
        
        publicDB.add(ckQueryOperation)
    }
    
    func fetchAllMapPinGPSLocationWithinMapViewAndCertainTime(mapView: MKMapView, timestamp: Date, completion: @escaping ([MapPin]) -> Void) {
        
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
        
        let twoDaysAhead = timestamp.addingTimeInterval(172800)
        let twoDaysBehind = timestamp.addingTimeInterval(-172800)
        
        let predicate1 = NSPredicate(format: "gpsLatitude < %lf", farthestLeft)
        let predicate2 = NSPredicate(format: "gpsLatitude > %lf", farthestRight)
        let predicate3 = NSPredicate(format: "gpsLongitude < %lf", farthestTop)
        let predicate4 = NSPredicate(format: "gpsLongitude > %lf", farthestBottom)
        let predicate5 = NSPredicate(format: "timestamp < %@", twoDaysAhead as CVarArg)
        let predicate6 = NSPredicate(format: "timestamp > %@", twoDaysBehind as CVarArg)
        
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2, predicate3, predicate4, predicate5, predicate6])
        
        let query = CKQuery(recordType: MapPin.typeKey, predicate: compoundPredicate)
        
        let ckQueryOperation = CKQueryOperation(query: query)
        ckQueryOperation.desiredKeys = ["gpsLatitude", "gpsLongitude", "reference", "userReference", "timestamp" ]
        
        var records: [CKRecord] = []
        
        ckQueryOperation.recordFetchedBlock = { (record) in
            records.append(record)
        }
        
        ckQueryOperation.completionBlock = {
            let mapPins = records.compactMap({MapPin(cloudKitRecord: $0, user: nil)})
            completion(mapPins)
        }
        
        publicDB.add(ckQueryOperation)
    }
    
//    func fetchMapPins(user: User, completion: @escaping () -> Void) {
//        guard let userRecordID = user.cloudKitRecordID else { completion(); return }
//        let userReference = CKReference(recordID: userRecordID, action: .deleteSelf)
//        let predicate = NSPredicate(format: "userReference == %@", userReference)
//
//        cloudKitManager.fetchRecordsOf(type: MapPin.typeKey, predicate: predicate, database: publicDB) { (records, error) in
//            if let error = error { print(error.localizedDescription) }
//            guard let records = records else { completion(); return }
//            let mapPins = records.compactMap({ MapPin(cloudKitRecord: $0, user: user )})
//            self.mapPins = mapPins
//            for mapPin in mapPins {
//                mapPin.user?.mapPins = mapPins
//
//            }
//            completion()
//        }
//    }
}
