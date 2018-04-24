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

class DetailViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var postWebView: WKWebView!
    @IBOutlet weak var detailMapView: MKMapView!
    
    var post: Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView()
        loadMapPoints()
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.stopUpdatingLocation()
    }

    func webView() {
        guard let postURL = post?.url else { return }
        guard let url = URL(string: "\(postURL)") else { return }
        let request = URLRequest(url: url)
        postWebView.load(request)
    }
    
    func loadMapPoints() {
        
        guard let clLocation = post?.gpsPin else { return }
 //       let distanceSpan: CLLocationDegrees = 2000
        let postLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(clLocation.coordinate.latitude, clLocation.coordinate.longitude)

        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: postLocation, span: span)
        self.detailMapView.setRegion(region, animated: true)
        
        //Create Annotation
        let searchAnnotation = MKPointAnnotation()
        searchAnnotation.title = "\(post?.headline ?? "")"
        searchAnnotation.coordinate = CLLocationCoordinate2DMake(clLocation.coordinate.latitude, clLocation.coordinate.longitude)
        self.detailMapView.addAnnotation(searchAnnotation)
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
}













