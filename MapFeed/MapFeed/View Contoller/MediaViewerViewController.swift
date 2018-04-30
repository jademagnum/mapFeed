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

class MediaViewerViewController: UIViewController, CLLocationManagerDelegate {
    
    var mapPin: MapPin?
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
//    private var videoURL: URL?
//    var player: AVPlayer?
//    var playerController : AVPlayerViewController?
//
//    init(videoURL: URL?) {
//        self.videoURL = videoURL
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MapPinController.shared.fetchMapPinWithCKRecord(cKRecord: (mapPin?.cloudKitRecordID)!) { (mapPin) in
            self.mapPin = mapPin
            
            
        }
        
//        self.view.backgroundColor = UIColor.gray
//        player = AVPlayer(url: videoURL!)
//        playerController = AVPlayerViewController()
//
//        guard player != nil && playerController != nil else {
//            return
//        }
//        playerController?.showsPlaybackControls = false
//
//        playerController?.player = player!
//        self.addChildViewController(playerController!)
//        self.view.addSubview(playerController!.view)
//        playerController?.view.frame = view.frame
//        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player!.currentItem)
        
//        let cancelButton = UIButton(frame: CGRect(x: 10.0, y: 10.0, width: 30.0, height: 30.0))
//        cancelButton.setImage(#imageLiteral(resourceName: "cancel"), for: UIControlState())
//        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
//        view.addSubview(cancelButton)
        

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
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        player?.play()
//    }
//
//    @objc func cancel() {
//        dismiss(animated: true, completion: nil)
//    }
//
//    @objc fileprivate func playerItemDidReachEnd(_ notification: Notification) {
//        if self.player != nil {
//            self.player?.seek(to: kCMTimeZero)
//            self.player?.play()
//        }
//    }
}

