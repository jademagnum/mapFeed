//
//  MapViewController.swift
//  MapFeed
//
//  Created by Jade Thomason on 4/19/18.
//  Copyright © 2018 Jade Thomason. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

let mediaUploadNotification = Notification.Name("mediaUploadNotification")

class MapViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate, MKMapViewDelegate {
    
    
    @IBOutlet weak var slider: UISlider!
    
    var mapPins: [MapPin] = []
    var posts: [Post] = []
    var post: Post?
    var postAnnotations: [MKPointAnnotation]? = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.stopUpdatingLocation()
        
        exploreMapView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(recenterMapOnUser), name: mediaUploadNotification, object: nil)
        
    }
    
    @objc func recenterMapOnUser() {
        guard let location = locationManager.location else { return }
        DispatchQueue.main.async {
            
            let myLocation = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
            let spanMeters:CLLocationDistance = 50
            let region = MKCoordinateRegionMakeWithDistance(myLocation, spanMeters, spanMeters)
            self.exploreMapView.setRegion(region, animated: true)
            self.exploreMapView.showsUserLocation = true
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        guard let postAnnotations = self.postAnnotations else { return }
        var unseenAnnotations = exploreMapView.annotations.filter({ mapPins.compactMap({$0.coordinate}).contains($0.coordinate) })
        for _ in unseenAnnotations {
            for postAnnotation in postAnnotations {
                if let postAnnotationIndex = unseenAnnotations.index(where: {$0.coordinate == postAnnotation.coordinate}) {
                    unseenAnnotations.remove(at: postAnnotationIndex)
                }
            }
            
            for mapPin in mapPins {
                if let mapPinAnnotationIndex = unseenAnnotations.index(where: {$0.coordinate == mapPin.coordinate}) {
                    unseenAnnotations.remove(at: mapPinAnnotationIndex)
                }
            }
        }
        exploreMapView.removeAnnotations(unseenAnnotations)
        handleFetching()
    }
    
    //    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    //
    //        var posts: [Post] = []
    //
    //        guard let postAnnotation = self.postAnnotation else { return }
    //        var unseenAnnotations = detailMapView.annotations.filter({ !mapPins.compactMap({$0.coordinate}).contains($0.coordinate) })
    //        for _ in unseenAnnotations {
    //
    //            for post in posts {
    //
    //                if let postAnnotationIndex = unseenAnnotations.index(where: {$0.coordinate == postAnnotation.coordinate}) {
    //                    unseenAnnotations.remove(at: postAnnotationIndex)
    //                }
    //
    //            }
    //        }
    //        detailMapView.removeAnnotations(unseenAnnotations)
    //        handleFetching()
    //    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotation = annotation
        let identifier = "mapPin"
        var mkMarkerAnnotationView: MKMarkerAnnotationView
        
        if annotation.coordinate == mapView.userLocation.coordinate {
            return nil
            // This is the user
        } else if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            if annotation is MapPin {
                dequeuedView.markerTintColor = UIColor.red
                dequeuedView.glyphText = "📷"
//                dequeuedView.detailCalloutAccessoryView = nil
                
                dequeuedView.titleVisibility = .hidden
                
                dequeuedView.canShowCallout = true
                dequeuedView.calloutOffset = CGPoint(x: -5, y: 5)
                dequeuedView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                
            } else {
                dequeuedView.markerTintColor = UIColor.black
                dequeuedView.glyphText = "🦐"
                dequeuedView.canShowCallout = true
                dequeuedView.calloutOffset = CGPoint(x: -5, y: 5)
                dequeuedView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                
            }
            dequeuedView.annotation = annotation
            mkMarkerAnnotationView = dequeuedView
        } else {
            mkMarkerAnnotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            if annotation is MapPin {
                mkMarkerAnnotationView.markerTintColor = UIColor.red
                mkMarkerAnnotationView.glyphText = "📷"
//                mkMarkerAnnotationView.detailCalloutAccessoryView = nil
                mkMarkerAnnotationView.titleVisibility = .hidden
                
                mkMarkerAnnotationView.canShowCallout = true
                mkMarkerAnnotationView.calloutOffset = CGPoint(x: -5, y: 5)
                mkMarkerAnnotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                
            } else {
                mkMarkerAnnotationView.markerTintColor = UIColor.black
                mkMarkerAnnotationView.glyphText = "🦐"
                mkMarkerAnnotationView.canShowCallout = true
                mkMarkerAnnotationView.calloutOffset = CGPoint(x: -5, y: 5)
                mkMarkerAnnotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            }
        }
        return mkMarkerAnnotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if view.annotation is MapPin {
            performSegue(withIdentifier: "toMediaPlayerVC", sender: view)
        } else {
            performSegue(withIdentifier: "toDetailVC", sender: view)
        }
    }
    
    func handleFetching() {
        //        guard let user = UserController.shared.currentUser else { return }
        
        MapPinController.shared.fetchAllMapPinGPSLocationWithinACertainArea(mapView: exploreMapView) { (mapPins) in
            PostController.shared.fetchAllMapPinGPSLocationWithinACertainArea(mapView: self.exploreMapView, completion: { (posts) in
                DispatchQueue.main.async {
                    self.mapPins = mapPins
                    self.posts = posts
                    self.exploreMapView.addAnnotations(mapPins)
                    self.exploreMapView.addAnnotations(posts)
                }
            })
        }
    }
    
    @IBOutlet weak var exploreMapView: MKMapView!
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        
        
        //MARK: - MAP SEARCH AND SEARCHBAR
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //Ignore User
        UIApplication.shared.beginIgnoringInteractionEvents()
        //Activity Indicator
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
        
        //Hide SearchBar
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        //Create the search request
        let searchRequest = MKLocalSearchRequest()
        searchRequest.naturalLanguageQuery = searchBar.text
        
        let activeSearch = MKLocalSearch(request: searchRequest)
        activeSearch.start { (response, error) in
            
            activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            if let error = error { print(error.localizedDescription) }
            guard let response = response else { return }
            let latitude = response.boundingRegion.center.latitude
            let longitude = response.boundingRegion.center.longitude
            
            //Create Annotation
            let searchAnnotation = MKPointAnnotation()
            searchAnnotation.title = searchBar.text
            searchAnnotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
            self.exploreMapView.addAnnotation(searchAnnotation)
            
            //Zooming in on an annotation
            let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            let region = MKCoordinateRegion(center: coordinate, span: span)
            self.exploreMapView.setRegion(region, animated: true)
            
        }
    }
    
    
    //MARK: - MAP, User Location
    let locationManager = CLLocationManager()
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        let myLocation = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let spanMeters:CLLocationDistance = 20000
        let region = MKCoordinateRegionMakeWithDistance(myLocation, spanMeters, spanMeters)
        exploreMapView.setRegion(region, animated: true)
        self.exploreMapView.showsUserLocation = true
    }
    
    
    
    // MARK: - Navigation
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //        if segue.identifier == "toDetailVC" {
    //            if let detailVC = segue.destination as? DetailViewController {
    //                let post = self.post
    //                detailVC.post = post
    //            }
    //        }
    //    }    toMediaPlayerVC
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailVC" {
            guard let sender = sender as? MKAnnotationView,
                let detailVC = segue.destination as? DetailViewController else { return }
            let post = sender.annotation as? Post
            detailVC.post = post
        } else if segue.identifier == "toMediaPlayerVC" {
            guard let sender = sender as? MKAnnotationView,
                let detailVC = segue.destination as? MediaViewerViewController else { return }
            let mapPin = sender.annotation as? MapPin
            detailVC.mapPin = mapPin
        }
    }
}
