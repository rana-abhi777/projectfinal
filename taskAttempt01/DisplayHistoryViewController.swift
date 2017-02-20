//
//  DisplayHistoryViewController.swift
//  taskAttempt01
//
//  Created by Sierra 4 on 14/02/17.
//  Copyright © 2017 code-brew. All rights reserved.
//

import UIKit
import GoogleMaps

class DisplayHistoryViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var MapView: GMSMapView!
    
    var MyLocations = [CLLocationCoordinate2D]()
    
    var locationsObject = [LocationHistory]()
    var indexOutside = 0
    
    func addLocationToPath(location: CLLocationCoordinate2D) {
        let path = GMSMutablePath()
        path.add(location)
        
        let rectangle = GMSPolyline.init(path: path)
        rectangle.strokeColor = UIColor.purple
        rectangle.strokeWidth = 3.0
        rectangle.map = MapView
        
    }
    // generalised function to add marker
    // could be defined in another class ex. Model class and inherit it in both the view controllers
    func addMarker(marker: GMSMarker, title: String, index: Int) {
        let marker = GMSMarker()
        marker.position = MyLocations[index]
        //marker.position = locationsObject[indexOutside].locationValues[index]
        //marker.position = loca[index]
        marker.title = title
        marker.map = MapView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        MapView.delegate = self
        let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: 37.33162154, longitude: -122.03033696999999, zoom: 15)
        MapView.camera = camera
        let markerStart = GMSMarker()
        let markerStop = GMSMarker()
        addMarker(marker: markerStart, title: "Start", index: 0)
        addMarker(marker: markerStop, title: "Stop", index: (MyLocations.count - 1))
        //addMarker(marker: markerStop, title: "Stop", index: (locationsObject[indexOutside].locationValues.count - 1))
        
        let path = GMSMutablePath()
        for MyLocation in MyLocations{
        //for MyLocation in locationsObject[indexOutside].locationValues {
            path.add(MyLocation)
        }
        // to make a path for the locations travelled
        let rectangle = GMSPolyline.init(path: path)
        rectangle.strokeColor = UIColor.orange
        rectangle.strokeWidth = 3.0
        rectangle.map = MapView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
