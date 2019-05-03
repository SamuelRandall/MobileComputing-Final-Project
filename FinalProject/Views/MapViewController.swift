//
//  MapViewController.swift
//  FinalProject
//
//  Created by Samuel Randall on 4/26/19.
//  Copyright © 2019 Mobile Computing. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var Map: MKMapView!
    
    var currentLocation = CurrentLocation()
    var locations = [Location]()
    
    var dataSession = WeatherData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSession.delegate = self
        
        addMapPins()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func addLocationButton(_ sender: Any) {
        let alert = UIAlertController(title: "Add Location", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "City"
            textField.autocorrectionType = .yes
        }
        alert.addTextField { (textField) in
            textField.placeholder = "State"
            textField.autocorrectionType = .yes
        }
        
        let action = UIAlertAction(title: "Submit", style: .default){ (_) in
            let city = alert.textFields!.first!.text!
            let state = alert.textFields!.last!.text!
            
            // call to the API to see if the location exists, if not return error
            if(city == "" || state == ""){
                self.responseError()
                return
            }else{
                self.dataSession.getData(city: city, state: state)
            }
            
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func fetchLocations() {
        let fetchLocations: NSFetchRequest<Location> = Location.fetchRequest()
        do {
            let locs = try PersistanceService.context.fetch(fetchLocations)
            self.locations = locs
        }
        catch {
            print("catch block for Location coreData fetchRequest AddLocationViewController")
        }
    }
    
    func fetchCurrentLocation(){
        let fetchCurrentLocation: NSFetchRequest<CurrentLocation> = CurrentLocation.fetchRequest()
        do {
            let curr = try PersistanceService.context.fetch(fetchCurrentLocation)
            if (curr.count == 0){
                let current = CurrentLocation(context: PersistanceService.context)
                current.cityState = "Austin,Tx"
                PersistanceService.saveContext()
                self.currentLocation = current
            }else {
                self.currentLocation = curr[0]
            }
        }
        catch {
            print("catch block for CurrentLocation coreData fetchRequest ViewController")
        }
    }
    
    func addMapPins() {
        // loop through list of locations, add pin for each location
    }
}
extension MapViewController: nameWeatherDataProtocol{
    func responseDataHandler(jsonResult: NSDictionary, city: String, state: String) {
        
        guard let DATA = jsonResult["data"] as? [String: Any] else{
            print("Data not found")
            responseError()
            return
        }
        guard let CurrentConditions = DATA["current_condition"] as? NSArray else{
            print("CurrentConditions not found")
            responseError()
            return
        }
        
        if (CurrentConditions.count == 0){
            responseError()
        }
        DispatchQueue.main.async() {
            let location = Location(context: PersistanceService.context)
            location.cityState = city + "," + state
            PersistanceService.saveContext()
            self.locations.append(location)
//            self.viewDidLoad()
        }
    }
    
    
    func responseError(){
        DispatchQueue.main.async() {
            let alert = UIAlertController(title: "Location Error", message: "Not a valid location", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
}
