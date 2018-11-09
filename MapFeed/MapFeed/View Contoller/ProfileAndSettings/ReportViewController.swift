//
//  ReportViewController.swift
//  MapFeed
//
//  Created by Jade Thomason on 5/3/18.
//  Copyright © 2018 Jade Thomason. All rights reserved.
//

import UIKit

class ReportViewController: UIViewController {
    
    var mapPin: MapPin?
    var post: Post?
    var reportedFor: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cancelButton = UIButton(frame: CGRect(x: 10.0, y: 10.0, width: 30.0, height: 30.0))
        cancelButton.setImage(#imageLiteral(resourceName: "cancel"), for: UIControl.State())
        cancelButton.addTarget(self, action: #selector(cancel), for: UIControl.Event.touchUpInside)
        view.addSubview(cancelButton)
        
    }
    
    @IBAction func meNoLikeyButtonTapped(_ sender: Any) {
        let reportedFor = "Me no likey"
        self.reportedFor = reportedFor
        reportActionSheet()
    }
    
    @IBAction func nudityButtonTapped(_ sender: Any) {
        let reportedFor = "Nudity or pornography"
        self.reportedFor = reportedFor
        reportActionSheet()
    }
    
    @IBAction func hateSpeechButtonTapped(_ sender: Any) {
        let reportedFor = "Hate speech or symbols"
        self.reportedFor = reportedFor
        reportActionSheet()
    }
    
    @IBAction func violenceButtonTapped(_ sender: Any) {
        let reportedFor = "Violence or threats"
        self.reportedFor = reportedFor
        reportActionSheet()
    }
    
    @IBAction func firearmsButtonTapped(_ sender: Any) {
        let reportedFor = "Sale of firearms"
        self.reportedFor = reportedFor
        reportActionSheet()
    }
    
    @IBAction func drugsButtonTapped(_ sender: Any) {
        let reportedFor = "Sale of drugs"
        self.reportedFor = reportedFor
        reportActionSheet()
    }
    
    @IBAction func harassmentButtonTapped(_ sender: Any) {
        let reportedFor = "Harassment or Bullying"
        self.reportedFor = reportedFor
        reportActionSheet()
    }
    
    @IBAction func intellectualButtonTapped(_ sender: Any) {
        let reportedFor = "Intellectual property"
        self.reportedFor = reportedFor
        reportActionSheet()
    }
    
    @IBAction func selfInjuryButtonTapped(_ sender: Any) {
        let reportedFor = "Self injury"
        self.reportedFor = reportedFor
        reportActionSheet()
    }
    
    @IBAction func doucheButtonTapped(_ sender: Any) {
        let reportedFor = "Douchebaggery"
        self.reportedFor = reportedFor
        reportActionSheet()
    }
    
    @objc func cancel() {
        dismiss(animated: true, completion: nil)
    }

    func reportActionSheet() {
        let actionSheetController = UIAlertController(title: "Report", message: "Report Post", preferredStyle: .actionSheet)
        let firstAction = UIAlertAction(title: "Report", style: .default) { (report) in
            
            ReportController.shared.createReportWith(post: self.post, mapPin: self.mapPin, reportedFor: self.reportedFor, completion: { (report) in
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            })
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (cancel) in
        }
        
        actionSheetController.addAction(firstAction)
        actionSheetController.addAction(cancelAction)
        
        present(actionSheetController, animated: true, completion: nil)
    }
}
