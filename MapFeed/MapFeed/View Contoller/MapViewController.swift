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

class MapViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var slider: UISlider!
    
    var mapPins: [MapPin] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.stopUpdatingLocation()
        
        exploreMapView.delegate = self

    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let unseenAnnotations = exploreMapView.annotations.filter({ !mapPins.compactMap({$0.coordinate}).contains($0.coordinate) })
        exploreMapView.removeAnnotations(unseenAnnotations)
        handleFetching()
    }
    
    
        
    func handleFetching() {
//        guard let user = UserController.shared.currentUser else { return }
        
        MapPinController.shared.fetchAllMapPinGPSLocationWithinACertainArea(mapView: exploreMapView) { (mapPins) in
            
            DispatchQueue.main.async {
                self.mapPins = mapPins
                self.exploreMapView.reloadInputViews()
                
                self.exploreMapView.addAnnotations(mapPins)
            }
        }
        
//        MapPinController.shared.fetchMapPins(user: user) {
//            DispatchQueue.main.async {
//                self.exploreMapView.reloadInputViews()
//
//
//                let mapPins = MapPinController.shared.mapPins
//
//                self.exploreMapView.addAnnotations(mapPins)
//            }
//        }
        
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
        let spanMeters:CLLocationDistance = 2000
        let region = MKCoordinateRegionMakeWithDistance(myLocation, spanMeters, spanMeters)
        exploreMapView.setRegion(region, animated: true)
        self.exploreMapView.showsUserLocation = true
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
