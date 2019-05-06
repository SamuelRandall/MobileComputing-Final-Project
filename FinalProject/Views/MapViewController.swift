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

class MapViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var Map: MKMapView!
    
    var currentLocation = MKPointAnnotation()
    let locationManager = CLLocationManager()
    var locations = [Location]()
    
    var dataSession = WeatherData()
    
    var places = [Place]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSession.delegate = self
        fetchLocations()
        addMapPins()
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func addLocationButton(_ sender: Any) {
        let alert = UIAlertController(title: "Add Location", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "City or Postal Code"
            textField.autocorrectionType = .yes
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Country (Optional)"
            textField.autocorrectionType = .yes
        }
        
        let action = UIAlertAction(title: "Submit", style: .default){ (_) in
            let city = alert.textFields!.first!.text!
            let state = alert.textFields!.last!.text!
            
            // call to the API to see if the location exists, if not return error
            if(city == ""){
                self.responseError()
                return
            }else{
                self.dataSession.getData(city: city, state: state)
                self.viewDidLoad()
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        let location = locations.last! as CLLocation
//        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        currentLocation.title = "Current"
        currentLocation.coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        self.Map.addAnnotation(currentLocation)
//        self.Map.setRegion(region, animated: true)
    }
    //MARK: - Annotations
    
    func addMapPins() {
        // loop through list of locations, add pin for each location
        var name:String? = ""
        for loc in locations {
            name = loc.cityState
            places.append(Place(title:name))
        }
        for place in places {
            place.getLocation(forPlaceCalled: place.title!, completion: { (placeWithDetails) in
                self.Map.addAnnotation(placeWithDetails)
            })
        }
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
        guard let request = DATA["request"] as? NSArray else{
            print("request not found")
            responseError()
            return
        }
        guard let requestDict = request[0] as? NSDictionary else{
            print("requestDict not found")
            responseError()
            return
        }
        guard let city = requestDict["query"] as? String else{
            print("city not found")
            responseError()
            return
        }
        if (CurrentConditions.count == 0){
            responseError()
        }
        var flag = true
        for loc in locations{
            if (loc.cityState == city) {
                flag = false
            }
        }
        if (flag){
            DispatchQueue.main.async() {
                let location = Location(context: PersistanceService.context)
                location.cityState = city
                PersistanceService.saveContext()
                self.locations.append(location)
            }
        }else{
            DispatchQueue.main.async() {
                let alert = UIAlertController(title: "Location Error", message: "Location is already in the list", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
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

