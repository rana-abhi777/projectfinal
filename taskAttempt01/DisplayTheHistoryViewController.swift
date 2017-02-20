//
//  DisplayTheHistoryViewController.swift
//  taskAttempt01
//
//  Created by Sierra 4 on 16/02/17.
//  Copyright © 2017 code-brew. All rights reserved.
//

import UIKit
import GoogleMaps
import CSPieChart
import CoreData

class DisplayTheHistoryViewController: UIViewController, CSPieChartDataSource, CSPieChartDelegate {
    
    
    
    @IBOutlet weak var lblDistanceTotal: UILabel!           // distance total display label
    @IBOutlet weak var btnGoBack: UIButton!                 // back navigation button
    @IBOutlet weak var pieChart: CSPieChart!                // piechart in the view
    
    var journeyTotal = [[CLLocationCoordinate2D]]()         // array of array for journey wise points traversed by user
    var distanceJouney = [Double]()                         // array for different journeys
    var distanceTotal = Double()                            // contains total distance travelled
    
    var journeyTotalFetched = [[CLLocationCoordinate2D]]()  //
    var distanceJouneyFetched = [Double]()                  //
    
    var journeyFetched = [CLLocationCoordinate2D]()                // location for single journey
    var countJourney = Int()
    
    var dataListJourney = [CSPieChartData]()                // contains the key value pair for the pie chart representation
    
    var indexJourneyTrack = 1                               // index for core data tracks journey number
    
    //function to calculate the total journey: journey wise division
    func calculateDistanceTotal(journey: [CLLocationCoordinate2D]) -> Double {
        var distance = Double()
        var tempLatFirst = CLLocationDegrees()
        var tempLongFirst = CLLocationDegrees()
        var tempLatLast = CLLocationDegrees()
        var tempLongLast = CLLocationDegrees()
        var upperLimit = Int()
        if journey.count < 1 {
            upperLimit = 0
        }
        else {
            upperLimit = journey.count - 2
        }
        //let upperLimit: Int = journey.count - 2
        
        for index in 0...upperLimit {
            tempLatFirst = journey[index].latitude
            tempLongFirst = journey[index].longitude
            tempLatLast = journey[index + 1].latitude
            tempLongLast = journey[index + 1].longitude
            let locationFirst = CLLocation(latitude: tempLatLast, longitude: tempLongLast)
            let locationLast = CLLocation(latitude: tempLatFirst, longitude: tempLongFirst)
            distance += locationLast.distance(from: locationFirst)
        }
    return distance
    }
    // function to divide the distance as per the journey
    func journeyDistanceDivision() {
        for journey in journeyTotal {
            distanceJouney.append(calculateDistanceTotal(journey: journey))
        }
    }
    // function to set the data values for the pie chart
    // which has key and value as pair in the CSPieChart
    func pieChartValues() {
        var index = 1
        for distance in distanceJouney {
            dataListJourney.append(CSPieChartData(key: "journey \(index)", value: distance))
            index += 1
            distanceTotal += distance
        }
    }
    var colorList: [UIColor] = [                            // color for the pie chart
        .red,
        .orange,
        .yellow,
        .green,
        .blue,
        .magenta
    ]
    var subViewList: [UIView] = []                         // subview list!!!!!
    func addLabel(viewText: String) {                      //genreic function to add labels to the pie chart slices
        let view = UILabel()
        view.text = "\(viewText)"
        view.textAlignment = .left
        view.font = UIFont.systemFont(ofSize: 12)
        view.sizeToFit()
        subViewList.append(view)
    }
    // core data add------------------------------------------------------------------------
    func addToCoreData() {
        let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let journey = JourneyData(context: context)
        
        var indexJourneyTrack = 1
        for journeyNumber in journeyTotal {
            for location in journeyNumber {
                journey.setValue(location.latitude, forKey: "latitude")
                journey.setValue(location.longitude, forKey: "longitude")
                journey.setValue(indexJourneyTrack, forKey: "journeyNumber")
                /*
                print(journey.value(forKey: "journeyNumber")!)
                print(journey.value(forKey: "longitude")!)
                print(journey.value(forKey: "latitude")!)
                */
                
                do {
                    try context.save()
                    print("Content saved")
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
                
                
            }
            indexJourneyTrack += 1
        }
        
        

    }
    //------------------------------------------------------------------------------------------
    // core data fetch--------------------------------------------------------------------------
    func fetchFromCoreData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "JourneyData")
        let context = appDelegate.persistentContainer.viewContext
        var locationArrayFetched = CLLocationCoordinate2D()
        do {
            let journeyTotalFetchedCoreData = try context.fetch(fetchRequest)
            for location in journeyTotalFetchedCoreData{
                for index in 0...countJourney {
                    let journeyNumber:Int = location.value(forKey: "journeyNumber") as! Int? ?? 0
                    if journeyNumber == index {
                        locationArrayFetched = CLLocationCoordinate2D(latitude: location.value(forKey: "latitude") as! CLLocationDegrees, longitude: location.value(forKey: "longitude") as! CLLocationDegrees)
                        /*
                        print("\n\n\n\n\n\n\n\n")
                        print(locationArrayFetched)
                        */
                        journeyFetched.append(locationArrayFetched)
 
                    }
                    journeyTotalFetched.append(journeyFetched)
                    //print(journeyTotalFetched)
                }
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
          }

    }
    //------------------------------------------------------------------------------------------
    var index = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        btnGoBack.layer.cornerRadius = 20
        //count the number of journeys taken
        countJourney = journeyTotal.count
        /*core data functionality
        addToCoreData()
        //fetchFromCoreData()
        */
        //call to the functions for accessing the ditance per journey
        journeyDistanceDivision()
        pieChartValues()
        
        
        lblDistanceTotal.text = "\(Int(distanceTotal)) metres"
        

        pieChart?.dataSource = self
        pieChart?.delegate = self
        
        pieChart?.pieChartRadiusRate = 0.6
        pieChart?.pieChartLineLength = 10
        pieChart?.seletingAnimationType = .touch
        
        for _ in journeyTotal {
            addLabel(viewText: "Journey\(index)")
            index += 1
        }
    }
    
    func numberOfComponentData() -> Int {
        return dataListJourney.count
    }
    
    func pieChartComponentData(at index: Int) -> CSPieChartData {
        return dataListJourney[index]
    }
    
    func numberOfComponentColors() -> Int {
        return colorList.count
    }
    
    func pieChartComponentColor(at index: Int) -> UIColor {
        return colorList[index]
    }
    
    func numberOfLineColors() -> Int {
        return colorList.count
    }
    
    func pieChartLineColor(at index: Int) -> UIColor {
        return colorList[index]
    }
    
    func numberOfComponentSubViews() -> Int {
        return subViewList.count
    }
    
    func pieChartComponentSubView(at index: Int) -> UIView {
        return subViewList[index]
    }
    
    func didSelectedPieChartComponent(at index: Int) {
        let data = dataListJourney[index]
        print("For \(data.key) distance travelled is \(Int(data.value))metres")
    }
    @IBAction func btnGoBackClick(_ sender: Any) {
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
    
}
