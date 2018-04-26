//
//  AddAnnotationViewController.swift
//  MapFeed
//
//  Created by Jade Thomason on 4/20/18.
//  Copyright © 2018 Jade Thomason. All rights reserved.
//

import UIKit
import MapKit
import Contacts

class AddAnnotationViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate, MKMapViewDelegate {
    
    var gps = CLLocation()
    var newGPS = CLLocation()
    
    @IBOutlet weak var addAnnotationMap: MKMapView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.stopUpdatingLocation()
        
    }
    
    @IBAction func addAnnotationGesture(_ sender: UILongPressGestureRecognizer) {
        let location = sender.location(in: self.addAnnotationMap)
        let locationCoordinate = self.addAnnotationMap.convert(location, toCoordinateFrom: self.addAnnotationMap)
        let userAnnotation = MKPointAnnotation()
        
//        let annotationView = MKAnnotationView(annotation: userAnnotation, reuseIdentifier: String(userAnnotation.hash))
//        let rightButton = UIButton(type: .contactAdd)
//        rightButton.tag = annotationView.hash
//        annotationView.canShowCallout = true
//        annotationView.rightCalloutAccessoryView = rightButton
        
        userAnnotation.coordinate = locationCoordinate
        userAnnotation.title = ""
        userAnnotation.subtitle = ""
        
        self.addAnnotationMap.removeAnnotations(addAnnotationMap.annotations)
        self.addAnnotationMap.addAnnotation(userAnnotation)
        
        let clLocation2 = CLLocation(latitude: userAnnotation.coordinate.latitude, longitude: userAnnotation.coordinate.longitude)
        self.gps = clLocation2
        
    }
    
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
    }
    


    let locationManager = CLLocationManager()
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        let myLocation = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let spanMeters:CLLocationDistance = 20000
        let region = MKCoordinateRegionMakeWithDistance(myLocation, spanMeters, spanMeters)
        addAnnotationMap.setRegion(region, animated: true)
        self.addAnnotationMap.showsUserLocation = true
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
            self.addAnnotationMap.removeAnnotations(self.addAnnotationMap.annotations)
            
            if let error = error { print(error.localizedDescription) }
            guard let response = response else { return }
            let latitude = response.boundingRegion.center.latitude
            let longitude = response.boundingRegion.center.longitude
            
            //Create Annotation
            let searchAnnotation = MKPointAnnotation()
            searchAnnotation.title = searchBar.text
            searchAnnotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
            self.addAnnotationMap.addAnnotation(searchAnnotation)
            
            let clLocation = CLLocation(latitude: searchAnnotation.coordinate.latitude, longitude: searchAnnotation.coordinate.longitude)
            self.gps = clLocation
            
            //Zooming in on an annotation
            let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            let region = MKCoordinateRegion(center: coordinate, span: span)
            self.addAnnotationMap.setRegion(region, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        newGPS = gps
    }
}





















