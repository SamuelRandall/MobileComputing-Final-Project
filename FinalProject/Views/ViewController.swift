//
//  ViewController.swift
//  nrk522_assignment3
//
//  Created by Noah Keller on 2/14/19.
//  Copyright © 2019 Noah Keller. All rights reserved.
//

import UIKit
import CoreData
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    // Properties:
    @IBOutlet weak var WImage: UIImageView!
    @IBOutlet weak var temp: UILabel!
    @IBOutlet weak var clouds: UILabel!
    @IBOutlet weak var humidity: UILabel!
    @IBOutlet weak var pressure: UILabel!
    @IBOutlet weak var rain: UILabel!
    @IBOutlet weak var wind: UILabel!
    @IBOutlet weak var homeMap: MKMapView!
    
    @IBOutlet weak var WeatherStackView: UIStackView!
    @IBOutlet weak var TitleBar: UINavigationItem!
    
    let locationManager = CLLocationManager()
    
    var dataSession = WeatherData()
    var currentLocation = CurrentLocation()
    var mesurementSystem = MeasurementSystem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchCurrentLocation()
        fetchMesurementSystem()

        self.dataSession.delegate = self
        let city_State = currentLocation.cityState!.split(separator: ",")
        dataSession.getData(city: String(city_State[0]), state: String(city_State[1]))
        
        let seperate = currentLocation.cityState!.split(separator: ",")
        TitleBar.title = (seperate[1].contains("USA") || seperate[1].contains("United States of America")) ? seperate[0] + ", USA" : currentLocation.cityState!
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func fetchCurrentLocation(){
        let fetchCurrentLocation: NSFetchRequest<CurrentLocation> = CurrentLocation.fetchRequest()
        do {
            let curr = try PersistanceService.context.fetch(fetchCurrentLocation)
            if (curr.count == 0){
                let current = CurrentLocation(context: PersistanceService.context)
                current.cityState = "Austin, USA"
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
    
    func fetchMesurementSystem(){
        let fetchMeasurementFeature: NSFetchRequest<MeasurementSystem> = MeasurementSystem.fetchRequest()
        do {
            let mesurementSystem = try PersistanceService.context.fetch(fetchMeasurementFeature)
            if (mesurementSystem.count == 0){
                self.mesurementSystem = MeasurementSystem(context: PersistanceService.context)
                self.mesurementSystem.system = true
            }else{
                self.mesurementSystem = mesurementSystem[0]
            }
        }
        catch {
            print("catch block for MeasurementSystem coreData fetchRequest ViewController")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        let location = locations.last! as CLLocation
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.homeMap.setRegion(region, animated: true)
    }
    
    @IBAction func SystemToggleButton(_ sender: Any) {
        self.mesurementSystem.system = !self.mesurementSystem.system
        PersistanceService.saveContext()
        
        self.viewDidLoad()
    }
    
}
extension ViewController: nameWeatherDataProtocol {
    // functions:
    func responseDataHandler(jsonResult: NSDictionary, city: String, state: String){
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
        guard let DICT = CurrentConditions[0] as? NSDictionary else{
            print("Dictionary not found")
            return
        }
        guard let Cloud = DICT["cloudcover"] as? String else{
            print("cloudcover not found")
            return
        }
        guard let TempC = DICT["temp_C"] as? String else{
            print("temp_C not found")
            return
        }
        guard let TempF = DICT["temp_F"] as? String else{
            print("temp_F not found")
            return
        }
        guard let Humidity = DICT["humidity"] as? String else{
            print("humidity not found")
            return
        }
        guard let Pressure = DICT["pressure"] as? String else{
            print("pressure not found")
            return
        }
        guard let Prec = DICT["precipMM"] as? String else{
            print("precipMM not found")
            return
        }
        guard let WindDirection = DICT["winddir16Point"] as? String else{
            print("winddir16Point not found")
            return
        }
        guard let WindSpeedK = DICT["windspeedKmph"] as? String else{
            print("windspeedKmph not found")
            return
        }
        guard let WindSpeedM = DICT["windspeedMiles"] as? String else{
            print("windspeedMiles not found")
            return
        }
        guard let ImageArray = DICT["weatherIconUrl"] as? NSArray else{
            print("weatherIconUrl not found")
            return
        }
        guard let ImageDict = ImageArray[0] as? NSDictionary else{
            print("ImageDict not found")
            return
        }
        guard let Image = ImageDict["value"] as? String else{
            print("Image not found")
            return
        }
        
        DispatchQueue.main.async() {
            self.temp.isHidden = false
            self.WeatherStackView.isHidden = false
            self.WImage.isHidden = false
            //self.twirl.isHidden = true
            
            if (self.mesurementSystem.system){
                self.temp.text = TempF + "°F"
                self.wind.text = WindDirection + " " + WindSpeedM + " mph"
                let inches = Float(Int(Float(Prec)!*(0.0393701)*100))/100
                self.rain.text = String(inches) + " in"
            }else{
                self.temp.text = TempC + "°C"
                self.wind.text = WindDirection + " " + WindSpeedK + " Kmph"
                self.rain.text = Prec + " mm"
            }
            
            self.clouds.text = Cloud + "%"
            self.humidity.text = Humidity + "%"
            self.pressure.text = Pressure + "mbar"
            
            
            if let imageData = try? Data(contentsOf: URL(string: Image)!) {
                self.WImage.image = UIImage(data: imageData)
                let number = self.getPicCode(url:Image)
                self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background_" + number)!)
                
//                self.WImage.image = UIImage(named: "icon_" + number)
            }
            
        }
        
    }
    
    func responseError(){
        DispatchQueue.main.async() {
            self.temp.isHidden = true
            self.WeatherStackView.isHidden = true
            self.WImage.isHidden = true
            
            let alert = UIAlertController(title: "Network Error", message: "Check your internet connection and try again", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func getPicCode(url: String) -> String{
        let seperateURL = url.split(separator: "/")
        let seperateLast = seperateURL[seperateURL.count - 1].split(separator: "_")
        return String(seperateLast[1])
    }
    
}

