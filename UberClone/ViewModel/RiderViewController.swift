//
//  RiderViewController.swift
//  UberClone
//
//  Created by Karol Chmiel on 19/11/2017.
//  Copyright © 2017 Karol Chmiel. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
import FirebaseAuth

class RiderViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var callUberButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    var userLocation = CLLocationCoordinate2D()
    var uberHasBeenCalled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLocationManager()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let email = Auth.auth().currentUser?.email {
            Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded, with: { (snapshot) in
                self.uberHasBeenCalled = true
                self.callUberButton.setTitle("Cancel Uber", for: .normal)
                Database.database().reference().child("RideRequests").removeAllObservers()
            })
        }
    }
    
    func configureLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordinates = manager.location?.coordinate {
            let centerMap = CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
            userLocation = centerMap
            let region = MKCoordinateRegion(center: centerMap, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            mapView.setRegion(region, animated: true)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = centerMap
            annotation.title = "Your location"
            mapView.addAnnotation(annotation)
        }
    }

    @IBAction func callUberAction(_ sender: Any) {
        
        if let email = Auth.auth().currentUser?.email {
            if uberHasBeenCalled {
                uberHasBeenCalled = false
                callUberButton.setTitle("Call an Uber", for: .normal)
                Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded, with: { (snapshot) in
                    snapshot.ref.removeValue()
                    Database.database().reference().child("RideRequests").removeAllObservers()
                })
            } else {
                let rideRequestDictionary: [String:Any] = ["email":email,
                                                           "lat":userLocation.latitude,
                                                           "long":userLocation.longitude]
                Database.database().reference().child("RideRequests").childByAutoId().setValue(rideRequestDictionary)
                uberHasBeenCalled = true
                callUberButton.setTitle("Cancel Uber", for: .normal)
            }
        }
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
}
