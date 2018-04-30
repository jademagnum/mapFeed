//
//  PhotoViewController.swift
//  MapFeed
//
//  Created by Jade Thomason on 4/25/18.
//  Copyright © 2018 Jade Thomason. All rights reserved.
//

import UIKit
import MapKit

class PhotoViewController: UIViewController, CLLocationManagerDelegate {
    
    var mapPin: MapPin?
    let locationManager = CLLocationManager()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private var backgroundImage: UIImage
    
    init(image: UIImage) {
        self.backgroundImage = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.gray
        let backgroundImageView = UIImageView(frame: view.frame)
        backgroundImageView.contentMode = UIViewContentMode.scaleAspectFit
        backgroundImageView.image = backgroundImage
        view.addSubview(backgroundImageView)
        
        let cancelButton = UIButton(frame: CGRect(x: 20.0, y: 20.0, width: 30.0, height: 30.0))
        cancelButton.setImage(#imageLiteral(resourceName: "cancel"), for: UIControlState())
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        view.addSubview(cancelButton)
        
        let viewSize = self.view.frame.size
        let addMapPostButton = UIButton(frame: CGRect(x: ((viewSize.width)-50), y: 20, width: 30, height: 30))
        addMapPostButton.setImage(#imageLiteral(resourceName: "focus"), for: UIControlState())
        addMapPostButton.addTarget(self, action: #selector(addMapPost), for: .touchUpInside)
        view.addSubview(addMapPostButton)
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.stopUpdatingLocation()
        
    }
    
    
    
    @objc func addMapPost() {
        guard let currentUser = UserController.shared.currentUser,
        let gpsLatitude =  locationManager.location?.coordinate.latitude,
        let gpsLongitude = locationManager.location?.coordinate.longitude,
        let photoData = UIImageJPEGRepresentation(backgroundImage, 0.8) else { return }
        
        
        MapPinController.shared.createMapPinWithMediaData(user: currentUser, gpsLatitude: gpsLatitude, gpsLongitude: gpsLongitude, mediaData: photoData) { (mapPin) in
            NotificationCenter.default.post(name: mediaUploadNotification, object: nil)
            if let tabBarController = self.presentingViewController as? UITabBarController {
                self.dismiss(animated: true) {
                    tabBarController.selectedIndex = 1
                }
            }
        }
    }
    
    @objc func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    

}
