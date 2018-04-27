//
//  AddPostViewController.swift
//  MapFeed
//
//  Created by Jade Thomason on 4/19/18.
//  Copyright © 2018 Jade Thomason. All rights reserved.
//

import UIKit
import MapKit

class AddPostViewController: ShiftableViewController {
    
    @IBOutlet weak var headlineTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var gpsLocationLabel: UILabel!
    
    var post: Post?
    var gps = CLLocation()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headlineTextField.delegate = self
        urlTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateViews()
    }
    
    @IBAction func addPostButtonTapped(_ sender: UIButton) {
    
        guard let headline = headlineTextField.text,
            let url = urlTextField.text,
            let user = UserController.shared.currentUser else { return }
            let gpsLatitude = gps.coordinate.latitude
            let gpsLongitude = gps.coordinate.longitude
        
        PostController.shared.createPostWith(user: user, headline: headline, url: url, gpsLatitude: gpsLatitude, gpsLongitude: gpsLongitude) { (post) in
            DispatchQueue.main.async {
                self.post = post
                
                self.performSegue(withIdentifier: "toDetailVC", sender: nil)
            }
        }
    }
    
    @IBAction func unwindFromAddAnnotationVC(_ sender: UIStoryboardSegue) {
        if sender.source is AddAnnotationViewController {
            if let senderVC = sender.source as? AddAnnotationViewController {
                gps = senderVC.gps
            }
        }
    }
    
    func updateViews() {
        let geoCoder = CLGeocoder()
        let location = gps
        geoCoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print("Error updateing clocation to clplacemark \(error) \(error.localizedDescription)")
            }
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            let name = placemark?.name ?? ""
            let city = placemark?.locality ?? ""
            let state = placemark?.administrativeArea ?? ""
            let postalCode = placemark?.postalCode ?? ""
            let country = placemark?.country ?? ""
            DispatchQueue.main.async {
                self.gpsLocationLabel.text = """
                \(name)
                \(city), \(state) \(postalCode)
                \(country)
                """
            }
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailVC" {
            if let detailVC = segue.destination as? DetailViewController {
                let post = self.post
                detailVC.post = post
            }
        }
    }
}


















