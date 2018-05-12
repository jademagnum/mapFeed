//
//  DetailViewController.swift
//  MapFeed
//
//  Created by Jade Thomason on 4/19/18.
//  Copyright © 2018 Jade Thomason. All rights reserved.
//

import UIKit
import WebKit
import MapKit

class DetailViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var postWebView: WKWebView!
    @IBOutlet weak var detailMapView: MKMapView!
    
    
    var post: Post?
    var mapPins: [MapPin] = []
    var postAnnotation: MKPointAnnotation?
    var postAnnotationIsAdded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        webView()
        loadMapPoints()
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.stopUpdatingLocation()
        
        detailMapView.delegate = self
        
        mapView(detailMapView, regionDidChangeAnimated: true)
        
        setupViews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        guard let postAnnotation = self.postAnnotation else { return }
        var unseenAnnotations = detailMapView.annotations.filter({ !mapPins.compactMap({$0.coordinate}).contains($0.coordinate) })
        for _ in unseenAnnotations {
            if let postAnnotationIndex = unseenAnnotations.index(where: {$0.coordinate == postAnnotation.coordinate}) {
                unseenAnnotations.remove(at: postAnnotationIndex)
            }
        }
        detailMapView.removeAnnotations(unseenAnnotations)
        handleFetching()
    }
    
    func handleFetching() {
        
        guard let timestamp = post?.timeStamp else { return }
        
        MapPinController.shared.fetchAllMapPinGPSLocationWithinMapViewAndCertainTime(mapView: detailMapView, timestamp: timestamp) { (mapPins) in
            DispatchQueue.main.async {
                self.mapPins = mapPins
                //                self.detailMapView.reloadInputViews()
                self.detailMapView.addAnnotations(mapPins)
                
                guard let postAnnotation = self.postAnnotation, !self.postAnnotationIsAdded else { return }
                self.detailMapView.addAnnotation(postAnnotation)
                self.postAnnotationIsAdded = true
            }
        }
    }
    
    func webView() {
        guard let postURL = post?.url else { return }
        guard let url = URL(string: "\(postURL)") else { return }
        let request = URLRequest(url: url)
        postWebView.load(request)
        postWebView.goBack()
    }
    
    func loadMapPoints() {
        
        guard let gpsLatitude = post?.gpsLatitude,
            let gpsLongitude = post?.gpsLongitude else { return }
        //       let distanceSpan: CLLocationDegrees = 2000
        let postLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(gpsLatitude, gpsLongitude)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: postLocation, span: span)
        self.detailMapView.setRegion(region, animated: true)
        
        //Create Annotation
        let searchAnnotation = MKPointAnnotation()
        searchAnnotation.title = "\(post?.headline ?? "")"
        searchAnnotation.coordinate = CLLocationCoordinate2DMake(gpsLatitude, gpsLongitude)
        //        self.detailMapView.addAnnotation(searchAnnotation)
        self.postAnnotation = searchAnnotation
    }
    
    
    //MARK: - MAP, User Location
    let locationManager = CLLocationManager()
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //        let location = locations[0]
        //        let myLocation = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        //        let spanMeters:CLLocationDistance = 2000
        //        let region = MKCoordinateRegionMakeWithDistance(myLocation, spanMeters, spanMeters)
        //        detailMapView.setRegion(region, animated: true)
        self.detailMapView.showsUserLocation = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCommentVC" {
            if let commentVC = segue.destination as? CommentViewController,
                let post = post {
                commentVC.post = post
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //MARK: -MOVE DIVIDER
    
    @IBOutlet weak var dividerView: UIView!
    
    var location: CGPoint = CGPoint.zero {
        willSet {
            oldLocation = location
        }
    }
    var oldLocation: CGPoint = CGPoint.zero
    var velocity: CGPoint = CGPoint.zero
    var locationInDividerView = CGPoint.zero
    var bottomStoppingPoint: CGFloat = 580
    var topStoppingPoint: CGFloat = 50
    
    var isDragging = false
    
    var currentViewPosition: ViewPosition = .top
    
    enum ViewPosition {
        case top
        case bottom
        case other
    }
    
    func setupViews() {
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panAction))
        panGesture.minimumNumberOfTouches = 1
        
        panGesture.delegate = self
        
        self.view.addGestureRecognizer(panGesture)
        
    }
    
    @objc func panAction(sender: UIPanGestureRecognizer) {
        
        switch sender.state {
        case .began:
            break
        case .changed:
            if currentViewPosition != .other { currentViewPosition = .other }
            let location = sender.location(ofTouch: 0, in: self.view)
            self.location = CGPoint(x: location.x, y: location.y)
            
            self.locationInDividerView = sender.location(ofTouch: 0, in: self.dividerView)
            self.velocity = sender.velocity(in: self.view)
            
            if self.dividerView.frame.contains(self.location) || isDragging {
                isDragging = true
                
                print(dividerView.frame.origin.y, self.dividerView.frame.origin.y)
                dividerView.frame.origin.y = self.location.y
            }
        case .ended:
            print(self.dividerView.frame)
            if self.velocity.y > 900 && self.dividerView.frame.contains(self.location) {
                snapToBottom()
            } else if self.velocity.y < -900 && self.dividerView.frame.contains(self.location) {
                snapToTop()
            } else if self.dividerView.frame.origin.y > bottomStoppingPoint {
                snapToBottom()
            } else if self.dividerView.frame.origin.y < topStoppingPoint {
                snapToTop()
            }
            
            isDragging = false
            self.velocity = CGPoint.zero
            
        default:
            break
        }
    }
    
    func snapToBottom() {
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.dividerView.frame.origin.y = 600
        })
        currentViewPosition = .bottom
    }
    
    func snapToTop() {
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.dividerView.frame.origin.y = self.topStoppingPoint + 10
        })
        currentViewPosition = .top
    }
    
}













