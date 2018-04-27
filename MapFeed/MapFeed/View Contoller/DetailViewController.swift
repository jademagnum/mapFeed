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

class DetailViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var postWebView: WKWebView!
    @IBOutlet weak var detailMapView: MKMapView!
    
    var post: Post?
    var mapPins: [MapPin] = []
    var postAnnotation: MKPointAnnotation?
    var postAnnotationIsAdded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView()
        loadMapPoints()
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.stopUpdatingLocation()
        
        detailMapView.delegate = self
        
        mapView(detailMapView, regionDidChangeAnimated: true)
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
}













