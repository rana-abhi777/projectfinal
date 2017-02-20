//
//  ViewController.swift
//  taskAttempt01
//
//  Created by Sierra 4 on 13/02/17.
//  Copyright © 2017 code-brew. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var btnStop: UIButton!
    @IBOutlet weak var btnStart: UIButton!
    let locationManager = CLLocationManager()
    var didFindMyLocation = false
    
    var MyLocations = [CLLocationCoordinate2D]()
    
    let path = GMSMutablePath()
    let pathDone = GMSMutablePath()
    let markerStart = GMSMarker()
    let markerStop = GMSMarker()
    let markerCurrent = GMSMarker()
    
    var journeyTotal = [[CLLocationCoordinate2D]]()
    
    // generalised button designer function
    func buttonDesigning(btnName: UIButton) {
        btnName.layer.cornerRadius = 17.5
        //btnName.layer.borderWidth = 2
        //btnName.layer.borderColor = UIColor.white.cgColor
    }
    
    
    @IBOutlet weak var MapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        // Do any additional setup after loading the view, typically from a nib.
        MapView.delegate = self
        locationManager.delegate = self
        
        // buttton layout designing
        buttonDesigning(btnName: btnStart)
        buttonDesigning(btnName: btnStop)
        buttonDesigning(btnName: btnDone)
        
        
        let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: 37.331650830000001, longitude: -122.03029752, zoom: 17)
        MapView.camera = camera
        MapView.isMyLocationEnabled = true
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        //current location button in the map
        MapView.settings.myLocationButton = true
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(30.741482, 76.768066)
        marker.map = MapView
        
    }
    // create a start button
    @IBAction func btnStartClick(_ sender: Any) {
        locationManager.startUpdatingLocation()
    }
    // create a stop button
    @IBAction func btnStopClick(_ sender: Any) {
        locationManager.stopUpdatingLocation()
        markerStart.position = MyLocations[0]
        markerStop.position = MyLocations.last!
        markerStart.title = "Start"
        markerStart.icon = GMSMarker.markerImage(with: UIColor.green)
        markerStop.icon = GMSMarker.markerImage(with: UIColor.green)
        
        markerStop.title = "Stop"
        
        let indexLast = MyLocations.count - 1
        var indexBefore = Int()
        if indexLast == 0{
            indexBefore = indexLast
        }
        else {
            indexBefore = indexLast - 1
        }
        //indexBefore = (indexLast - 1)
        let heading = GMSGeometryHeading(MyLocations[indexBefore], MyLocations[indexLast])
        
        markerStop.rotation = heading;
        markerStart.map = MapView
        markerStop.map = MapView
        
        journeyTotal.append(MyLocations)
        MyLocations = []
        
        
    }
    func calculateDistanceTotal(journeyTotal: [[CLLocationCoordinate2D]]) -> Double {
        var distance = Double()
        var tempLatFirst = CLLocationDegrees()
        var tempLongFirst = CLLocationDegrees()
        var tempLatLast = CLLocationDegrees()
        var tempLongLast = CLLocationDegrees()
        for journey in journeyTotal {
            for index in 0...(journey.count - 2) {
                tempLatFirst = journey[index].latitude
                tempLongFirst = journey[index].longitude
                tempLatLast = journey[index + 1].latitude
                tempLongLast = journey[index + 1].longitude
                let locationFirst = CLLocation(latitude: tempLatLast, longitude: tempLongLast)
                let locationLast = CLLocation(latitude: tempLatFirst, longitude: tempLongFirst)
                distance += locationLast.distance(from: locationFirst)
            }
        }
        return distance
    }
    @IBAction func btnDoneClick(_ sender: Any) {
        var distance = Double()
        for journey in journeyTotal {
            for location in journey {
                //let path = GMSMutablePath()
                pathDone.add(location)
                let rectangle = GMSPolyline.init(path: pathDone)
                rectangle.strokeColor = UIColor.red
                rectangle.strokeWidth = 3.0
                rectangle.map = MapView
            }
        }
        distance = calculateDistanceTotal(journeyTotal: journeyTotal)
        print("the distance travelled is : \(Int(distance))metres")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue = manager.location?.coordinate
        
        print("the location is : \(locValue?.latitude) \(locValue?.longitude).")
        //path making in the updatefunctions
        path.add(locValue!)
        markerCurrent.position = locValue!
        //heading orinetation of the icon to user direction
        ///*
        let headingCurrent = GMSGeometryHeading(MyLocations.last ?? locValue!, locValue!)
        markerCurrent.rotation = headingCurrent
        markerCurrent.map = MapView
        markerCurrent.map = MapView
        markerCurrent.icon = UIImage(named: "navigationMaps_black")
        //*/
        let rectangle = GMSPolyline.init(path: path)
        rectangle.strokeColor = UIColor.orange
        rectangle.strokeWidth = 3.0
        rectangle.map = MapView
        MyLocations.append(locValue!)
        /*
        let headingCurrent = GMSGeometryHeading(MyLocations.last!, locValue!)
        markerCurrent.rotation = headingCurrent
        markerCurrent.map = MapView
        markerCurrent.map = MapView
        markerCurrent.icon = UIImage(named: "airplane_black")
        */

    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showJourney" {
            if let destination = segue.destination as? DisplayTheHistoryViewController {
                destination.journeyTotal = journeyTotal
            }
        }
    }
    
}
