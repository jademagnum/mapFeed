//
//  MediaViewerViewController.swift
//  MapFeed
//
//  Created by Jade Thomason on 4/30/18.
//  Copyright © 2018 Jade Thomason. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import MapKit
import CloudKit

class MediaViewerViewController: UIViewController, CLLocationManagerDelegate {
    
    var mapPin: MapPin?
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private var videoURL: URL?
    var image: UIImage?
    var player: AVPlayer?
    var playerController : AVPlayerViewController?
    
    init(videoURL: URL?, image: UIImage?) {
        self.videoURL = videoURL
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MapPinController.shared.fetchMapPinWithCKRecord(cKRecord: (mapPin?.cloudKitRecordID)!) { (mapPin) in
            self.mapPin = mapPin
            
            guard let data = mapPin?.mediaData else { return }
            
            if let image = UIImage(data: data) {
                
                DispatchQueue.main.async {
                    self.view.backgroundColor = UIColor.gray
                    let backgroundImageView = UIImageView(frame: self.view.frame)
                    backgroundImageView.contentMode = UIViewContentMode.scaleAspectFit
                    backgroundImageView.image = image
                    self.view.addSubview(backgroundImageView)
                    
                    let cancelButton = UIButton(frame: CGRect(x: 10.0, y: 10.0, width: 30.0, height: 30.0))
                    cancelButton.setImage(#imageLiteral(resourceName: "cancel"), for: UIControlState())
                    cancelButton.addTarget(self, action: #selector(self.cancel), for: .touchUpInside)
                    self.view.addSubview(cancelButton)
                    
                    let viewSize = self.view.frame.size
                    let addMapPostButton = UIButton(frame: CGRect(x: ((viewSize.width)-50), y: 20, width: 30, height: 30))
                    addMapPostButton.setImage(#imageLiteral(resourceName: "focus"), for: UIControlState())
                    addMapPostButton.addTarget(self, action: #selector(self.report), for: .touchUpInside)
                    self.view.addSubview(addMapPostButton)
                }
            } else {
                
                let temporaryDirectory = NSTemporaryDirectory()
                let temporaryDirectoryURL = URL(fileURLWithPath: temporaryDirectory)
                let mediaData = mapPin?.mediaData
                let videoURL = temporaryDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("mov")
                try? mediaData?.write(to: videoURL, options: [.atomic])
                self.videoURL = videoURL
                
                //            guard let videoURL = self.videoURL else { return }
                
                self.player = AVPlayer(url: videoURL)
                
                DispatchQueue.main.async {
                    self.player?.play()
                    
                    self.view.backgroundColor = UIColor.gray
                    self.playerController = AVPlayerViewController()
                    
                    guard self.player != nil && self.playerController != nil else {
                        return
                    }
                    self.playerController?.showsPlaybackControls = false
                    
                    self.playerController?.player = self.player
                    self.addChildViewController(self.playerController!)
                    self.view.addSubview(self.playerController!.view)
                    self.playerController?.view.frame = self.view.frame
                    let cancelButton = UIButton(frame: CGRect(x: 10.0, y: 10.0, width: 30.0, height: 30.0))
                    cancelButton.setImage(#imageLiteral(resourceName: "cancel"), for: UIControlState())
                    cancelButton.addTarget(self, action: #selector(self.cancel), for: .touchUpInside)
                    self.view.addSubview(cancelButton)
                    
                    let viewSize = self.view.frame.size
                    let addMapPostButton = UIButton(frame: CGRect(x: ((viewSize.width)-50), y: 20, width: 30, height: 30))
                    addMapPostButton.setImage(#imageLiteral(resourceName: "focus"), for: UIControlState())
                    addMapPostButton.addTarget(self, action: #selector(self.report), for: .touchUpInside)
                    self.view.addSubview(addMapPostButton)
                    
                    // Allow background audio to continue to play
                    do {
                        try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
                    } catch let error as NSError {
                        print(error)
                    }
                    
                    do {
                        try AVAudioSession.sharedInstance().setActive(true)
                    } catch let error as NSError {
                        print(error)
                    }
                    
                    NotificationCenter.default.addObserver(self, selector: #selector(self.playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player!.currentItem)
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        player?.play()
    }
    
    @objc func report() {
        let actionSheetController = UIAlertController(title: "Report", message: "Report Post", preferredStyle: .actionSheet)
        let firstAction = UIAlertAction(title: "Report", style: .default) { (report) in
            
            self.performSegue(withIdentifier: "toReportVC", sender: self)
            
        }
        let secondAction = UIAlertAction(title: "Block", style: .default) { (report) in
            
            guard let mapPin = self.mapPin else { return }
            
            let userToBlockRef = CKReference(recordID: mapPin.reference.recordID, action: .none)
            
            UserController.shared.userToBlock(blockUserRef: userToBlockRef, completion: { (success) in
                
                if !success {
                    let currentUserRef = UserController.shared.currentUser?.cloudKitRecordID
                    if mapPin.reference.recordID == currentUserRef {
                    self.showAlertMessage(titleStr: "You cannot block yourself silly", messageStr: "Block users that you don't want to see again... Like your Mother-in-Law")
                    } else {
                        self.showAlertMessage(titleStr: "Cannot Block User", messageStr: "Please try again")
                    }
                }
            })
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (cancel) in
        }
        
        actionSheetController.addAction(firstAction)
        actionSheetController.addAction(secondAction)
        actionSheetController.addAction(cancelAction)
        
        present(actionSheetController, animated: true, completion: nil)
        
    }
    
    @objc func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func playerItemDidReachEnd(_ notification: Notification) {
        if self.player != nil {
            self.player?.seek(to: kCMTimeZero)
            self.player?.play()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toReportVC" {
            guard let sender = sender as? MediaViewerViewController,
                let reportVC = segue.destination as? ReportViewController else { return }
            var mapPin = sender.mapPin
            reportVC.mapPin = mapPin
        }
    }
}























