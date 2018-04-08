//
//  DriverTableViewController.swift
//  UberClone
//
//  Created by Karol Chmiel on 03/12/2017.
//  Copyright © 2017 Karol Chmiel. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import MapKit

class DriverTableViewController: UITableViewController, CLLocationManagerDelegate {

    @IBOutlet var ridesTableView: UITableView!
    var rideRequest : [DataSnapshot] = []
    var locationManager = CLLocationManager()
    var driverLocation = CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    Database.database().reference().child("RideRequests").observe(.childAdded){ (snapshot) in
        if let rideDictionary = snapshot.value as? [String:AnyObject] {
                    if let lat = rideDictionary["driverLat"] as? Double {
                        if let long = rideDictionary["driverLon"] as? Double {
                        
                        }
                }
        }
            self.rideRequest.append(snapshot)
            self.ridesTableView.reloadData()
        }
        self.configureLocationManager()
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true, block: { (timer) in
            self.ridesTableView.reloadData()
        })
    }

    func configureLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coord = manager.location?.coordinate {
            driverLocation = coord
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rideCell", for: indexPath)

        let snapshot = rideRequest[indexPath.row]
        if let rideDictionary = snapshot.value as? [String:AnyObject] {
            if let email = rideDictionary["email"] as? String {
                if let lat = rideDictionary["lat"] as? Double {
                    if let long = rideDictionary["long"] as? Double {
                        
                        let riderCLLocation = CLLocation(latitude: lat, longitude: long)
                        let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
                        let distance = driverCLLocation.distance(from: riderCLLocation) / 1000
                        let roundedDistance = round(distance  * 100) / 100
                        
                        cell.textLabel?.text = "\(email) - \(roundedDistance)km away"
                    }
                }
            }
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rideRequest.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let snapshot = rideRequest[indexPath.row]
        performSegue(withIdentifier: "detailedRide", sender: snapshot)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailedRideVC = segue.destination as? DetailedRideViewController {
            if let snapshot = sender as? DataSnapshot {
                if let rideDictionary = snapshot.value as? [String:AnyObject] {
                    if let email = rideDictionary["email"] as? String {
                        if let lat = rideDictionary["lat"] as? Double {
                            if let long = rideDictionary["long"] as? Double {
                                detailedRideVC.requestEmail = email
                                let location = CLLocationCoordinate2D(latitude: lat, longitude: long)
                                detailedRideVC.requestLocation = location
                                detailedRideVC.driverLocation = self.driverLocation
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
}
