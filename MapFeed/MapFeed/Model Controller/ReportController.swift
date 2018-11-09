//
//  ReportController.swift
//  MapFeed
//
//  Created by Jade Thomason on 5/3/18.
//  Copyright © 2018 Jade Thomason. All rights reserved.
//

import Foundation
import CloudKit

class ReportController {
    static let shared = ReportController()
    
    let publicDB = CKContainer.default().publicCloudDatabase
    
    var reports: [Report] = []
    
    let cloudKitManager: CloudKitManager = {
        return CloudKitManager()
    }()
    
    func createReportWith(post: Post?, mapPin: MapPin?, reportedFor: String, completion: @escaping ((Report?) -> Void)) {
        
        var mediaIDToReport: CKRecord.ID!
        
        if post != nil {
            guard let mediaID = post?.cloudKitRecordID else { completion(nil); return }
            mediaIDToReport = mediaID
        } else {
            guard let mediaID = mapPin?.cloudKitRecordID else { completion(nil); return }
            mediaIDToReport = mediaID
        }
        
        guard let mediaID = mediaIDToReport else { completion(nil); return }
        
        let mediaRef = CKRecord.Reference(recordID: mediaID, action: .deleteSelf)
        
        let report = Report(post: post, mapPin: mapPin, reportedFor: reportedFor, mediaRef: mediaRef)
        reports.append(report)
        
        let reportRecord = report.cloudKitRecord
        
        cloudKitManager.saveRecord(reportRecord) { (record, error) in
            if let error = error  {
                print("Error saving report: \(#function) \(error.localizedDescription)")
            }
            guard let record = record else { return }
            
            let reportID = record.recordID
            report.cloudKitRecordID = reportID
            
            self.reports = [report]
            completion(report)
            return
        }
    }
}





















