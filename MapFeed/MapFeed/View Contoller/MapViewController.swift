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
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var begDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    
    var mapPins: [MapPin] = []
    var filteredMapPins: [MapPin] = []
    var filteredPosts: [Post] = []
    var posts: [Post] = []
    var post: Post?
    
    var allAnnotations: [MKAnnotation] {
        var annotations: [MKAnnotation] = filteredMapPins
        annotations.append(contentsOf: filteredPosts)
        
        return annotations
    }
    
    var postAnnotations: [MKPointAnnotation]? = []
    var currentDate: Date = Date()
    
    var begDateValue: Date = Date().addingTimeInterval(-86400)
    var endDateValue: Date = Date()
    
    @IBAction func sliderValueChanged(_ sender: Any) {
        
        let value = Double(slider.value)
        
        var rangeOffset = 5400.0
        
        switch segmentControl.selectedSegmentIndex {
            
        case 0:
            // All Time
            rangeOffset = 129600.0
        case 1:
            // Year
            rangeOffset = 1296000.0
        case 2:
            // Month
            rangeOffset = 129600.0
        case 3:
            // Day
            rangeOffset = 86400.0
        case 4:
            // Day
            rangeOffset = 7200.0
        default:
            break
        }
        
        let beginningFilterDate = Date(timeIntervalSince1970: value - rangeOffset)
        let endFilterDate = Date(timeIntervalSince1970: value + rangeOffset)
        
        self.begDateValue = beginningFilterDate
        self.endDateValue = endFilterDate
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        begDateLabel.text = dateFormatter.string(from: beginningFilterDate)
        endDateLabel.text = dateFormatter.string(from: endFilterDate)
        
        dateFilter(begDate: beginningFilterDate, endDate: endFilterDate)
        
    }
    
    @IBAction func segmentControlValueChanged(_ sender: Any) {
        // Run the filter here too
        switch segmentControl.selectedSegmentIndex {
            
        case 0:
            // All Time
            var c = DateComponents()
            c.year = 2018
            c.month = 4
            c.day = 20
            
            let date = Calendar.current
            let begDate = date.date(from: c)
            
            let endDate = currentDate
            
            guard let begDateFloat = begDate?.timeIntervalSince1970 else { return }
            let endDateFloat = endDate.timeIntervalSince1970
            
            slider.minimumValue = Float(begDateFloat)
            slider.maximumValue = Float(endDateFloat)
            
            let value = Double(slider.value)
            
            let beginningFilterDate = Date(timeIntervalSince1970: value - 7776000.0)
            let endFilterDate = Date(timeIntervalSince1970: value + 7776000.0)
            
            slider.isHidden = false
            
            
        case 1:
            // Year
            let begDate = currentDate.addingTimeInterval(-31536000)
            let endDate = currentDate
            
            let begDateFloat = begDate.timeIntervalSince1970
            let endDateFloat = endDate.timeIntervalSince1970
            
            slider.minimumValue = Float(begDateFloat)
            slider.maximumValue = Float(endDateFloat)
            
            let value = Double(slider.value)
            
            let beginningFilterDate = Date(timeIntervalSince1970: value - 1296000.0)
            let endFilterDate = Date(timeIntervalSince1970: value + 1296000.0)
            
            
            slider.isHidden = false
            
        case 2:
            // Month
            let begDate = currentDate.addingTimeInterval(-2592000)
            let endDate = currentDate
            
            let begDateFloat = begDate.timeIntervalSince1970
            let endDateFloat = endDate.timeIntervalSince1970
            
            slider.minimumValue = Float(begDateFloat)
            slider.maximumValue = Float(endDateFloat)
            
            let value = Double(slider.value)
            
            let beginningFilterDate = Date(timeIntervalSince1970: value - 86400.0)
            let endFilterDate = Date(timeIntervalSince1970: value + 86400.0)
            
            slider.isHidden = false
            
        case 3:
            // Week
            let begDate = currentDate.addingTimeInterval(-604800)
            let endDate = currentDate
            
            let begDateFloat = begDate.timeIntervalSince1970
            let endDateFloat = endDate.timeIntervalSince1970
            
            slider.minimumValue = Float(begDateFloat)
            slider.maximumValue = Float(endDateFloat)
            
            let value = Double(slider.value)
            
            let beginningFilterDate = Date(timeIntervalSince1970: value - 5400.0)
            let endFilterDate = Date(timeIntervalSince1970: value + 5400.0)
            
            slider.isHidden = false
            
        case 4:
            // Day
            let begDate = currentDate.addingTimeInterval(-86400)
            let endDate = currentDate
            
            let begDateFloat = begDate.timeIntervalSince1970
            let endDateFloat = endDate.timeIntervalSince1970
            
            slider.minimumValue = Float(begDateFloat)
            slider.maximumValue = Float(endDateFloat)
            
            let value = Double(slider.value)
            
            let beginningFilterDate = Date(timeIntervalSince1970: value - 5400.0)
            let endFilterDate = Date(timeIntervalSince1970: value + 5400.0)
            
            slider.isHidden = false
            
        default:
            break
        }
    }
    
    func dateFilter(begDate: Date, endDate: Date) {
        let filteredPins = self.mapPins.filter({$0.timestamp > begDate && $0.timestamp < endDate})
        let filteredPosts = self.posts.filter({$0.timeStamp > begDate && $0.timeStamp < endDate})
        
        print(filteredPins.count)
        
        for annotation in exploreMapView.annotations {
            
            if annotation is MapPin {
                
                if !filteredPins.contains(where: {$0.coordinate == annotation.coordinate}) {
                    exploreMapView.removeAnnotation(annotation)
                }
                
            } else if annotation is Post {
                if !filteredPosts.contains(where: {$0.coordinate == annotation.coordinate}) {
                    exploreMapView.removeAnnotation(annotation)
                }
            }
        }
        
        for filteredPin in filteredPins {
            if !exploreMapView.annotations.contains(where: {$0.coordinate == filteredPin.coordinate}) {
                exploreMapView.addAnnotation(filteredPin)
            }
        }
        
        for filteredPost in filteredPosts {
            if !exploreMapView.annotations.contains(where: {$0.coordinate == filteredPost.coordinate}) {
                exploreMapView.addAnnotation(filteredPost)
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.stopUpdatingLocation()
        
        exploreMapView.delegate = self
        
        segmentControl.selectedSegmentIndex = 4
        segmentControlValueChanged(self)
        slider.value = slider.maximumValue
        sliderValueChanged(self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(recenterMapOnUser), name: mediaUploadNotification, object: nil)
        
    }
    
    @objc func recenterMapOnUser() {
        guard let location = locationManager.location else { return }
        DispatchQueue.main.async {
            
            let myLocation = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
            let spanMeters:CLLocationDistance = 50
            let region = MKCoordinateRegion.init(center: myLocation, latitudinalMeters: spanMeters, longitudinalMeters: spanMeters)
            self.exploreMapView.setRegion(region, animated: true)
            self.exploreMapView.showsUserLocation = true
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        var unseenAnnotations = exploreMapView.annotations
        for _ in unseenAnnotations {
            for post in posts {
                if let postAnnotationIndex = unseenAnnotations.index(where: {$0.coordinate == post.coordinate}) {
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
//        guard let postAnnotations = self.postAnnotations else { return }
//        var unseenAnnotations = exploreMapView.annotations
//        for _ in unseenAnnotations {
//            for postAnnotation in postAnnotations {
//                if let postAnnotationIndex = unseenAnnotations.index(where: {$0.coordinate == postAnnotation.coordinate}) {
//                    unseenAnnotations.remove(at: postAnnotationIndex)
//                }
//            }
//
//            for mapPin in mapPins {
//                if let mapPinAnnotationIndex = unseenAnnotations.index(where: {$0.coordinate == mapPin.coordinate}) {
//                    unseenAnnotations.remove(at: mapPinAnnotationIndex)
//                }
//            }
//        }
//        exploreMapView.removeAnnotations(unseenAnnotations)
//        handleFetching()
//    }
    
        func handleFetching() {
            MapPinController.shared.fetchAllMapPinGPSLocationWithinACertainArea(mapView: exploreMapView) { (mapPins) in
                PostController.shared.fetchAllMapPinGPSLocationWithinACertainArea(mapView: self.exploreMapView, completion: { (posts) in
                    DispatchQueue.main.async {
                        self.mapPins = mapPins
                        self.posts = posts
    
                        var mapPinsToAdd: [MapPin] = []
                        for mapPin in mapPins {
                            if !self.exploreMapView.annotations.contains(where: {$0.coordinate == mapPin.coordinate}) {
                                mapPinsToAdd.append(mapPin)
                            }
                        }
    
                        var postsPinsToAdd: [Post] = []
                        for post in posts {
                            if !self.exploreMapView.annotations.contains(where: {$0.coordinate == post.coordinate}) {
                                postsPinsToAdd.append(post)
                            }
                        }
    
                        self.exploreMapView.addAnnotations(mapPinsToAdd)
                        self.exploreMapView.addAnnotations(postsPinsToAdd)
    
                        self.dateFilter(begDate: self.begDateValue, endDate: self.endDateValue)
                    }
                })
            }
        }
    

    
    
//    func handleFetching() {
//
//        PostController.shared.fetchAllMapPinGPSLocationWithinACertainArea(mapView: self.exploreMapView) { (posts) in
//            DispatchQueue.main.async {
//                self.posts = posts
//                var postsPinsToAdd: [Post] = []
//                for post in posts {
//                    if !self.exploreMapView.annotations.contains(where: {$0.coordinate == post.coordinate}) {
//                        postsPinsToAdd.append(post)
//                    }
//                }
//                self.exploreMapView.addAnnotations(postsPinsToAdd)
//                self.dateFilter(begDate: self.begDateValue, endDate: self.endDateValue)
//            }
//        }
//
//        MapPinController.shared.fetchAllMapPinGPSLocationWithinACertainArea(mapView: exploreMapView) { (mapPins) in
//            DispatchQueue.main.async {
//                self.mapPins = mapPins
//                var mapPinsToAdd: [MapPin] = []
//                for mapPin in mapPins {
//                    if !self.exploreMapView.annotations.contains(where: {$0.coordinate == mapPin.coordinate}) {
//                        mapPinsToAdd.append(mapPin)
//                    }
//                }
//                self.exploreMapView.addAnnotations(mapPinsToAdd)
//                self.dateFilter(begDate: self.begDateValue, endDate: self.endDateValue)
//            }
//        }
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
                mkMarkerAnnotationView.frame.width
                
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
        activityIndicator.style = UIActivityIndicatorView.Style.gray
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
        
        //Hide SearchBar
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        //Create the search request
        let searchRequest = MKLocalSearch.Request()
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
        let region = MKCoordinateRegion.init(center: myLocation, latitudinalMeters: spanMeters, longitudinalMeters: spanMeters)
        exploreMapView.setRegion(region, animated: true)
        self.exploreMapView.showsUserLocation = true
    }
    
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
