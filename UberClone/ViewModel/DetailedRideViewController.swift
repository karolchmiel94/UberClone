//
//  DetailedRideViewController.swift
//  UberClone
//
//  Created by Karol Chmiel on 03/12/2017.
//  Copyright © 2017 Karol Chmiel. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

class DetailedRideViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    var requestLocation = CLLocationCoordinate2D()
    var driverLocation = CLLocationCoordinate2D()
    var requestEmail = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setMapRegion()
        self.setMapAnnotation()
        
        
    }

    func setMapRegion() {
        let region = MKCoordinateRegion(center: requestLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: false)
    }
    
    func setMapAnnotation() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = requestLocation
        annotation.title = requestEmail
        mapView.addAnnotation(annotation)
    }
    
    @IBAction func acceptRequestAction(_ sender: Any) {
        //Update the ride Request
        Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: requestEmail).observe(.childAdded) { (snapshot) in
            snapshot.ref.updateChildValues(["driverLat":self.driverLocation.latitude,
                                            "driverLon":self.driverLocation.longitude])
            Database.database().reference().child("RideRequests").removeAllObservers()
        }
        
        //Show directions
        let requestCLLocation = CLLocation(latitude: requestLocation.latitude, longitude: requestLocation.longitude)
        CLGeocoder().reverseGeocodeLocation(requestCLLocation, completionHandler: { (placemarks, error) in
            if let placemarks = placemarks {
                if placemarks.count > 0 {
                    let mkPlacemark = MKPlacemark(placemark: placemarks[0])
                    let mapItem = MKMapItem(placemark: mkPlacemark)
                    mapItem.name = self.requestEmail
                    let options = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                    mapItem.openInMaps(launchOptions: options)
                }
            }
        })
    }
    
}
