//
//  ViewController.swift
//  nrk522_assignment3
//
//  Created by Noah Keller on 2/14/19.
//  Copyright © 2019 Noah Keller. All rights reserved.
//

import UIKit
import CoreData
class ViewController: UIViewController, UITextFieldDelegate, nameWeatherDataProtocol {
    
    // Properties:
    @IBOutlet weak var WImage: UIImageView!
    @IBOutlet weak var temp: UILabel!
    @IBOutlet weak var clouds: UILabel!
    @IBOutlet weak var humidity: UILabel!
    @IBOutlet weak var pressure: UILabel!
    @IBOutlet weak var rain: UILabel!
    @IBOutlet weak var wind: UILabel!
    
    var dataSession = WeatherData()
    var currentLocation = CurrentLocation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //        nameTextField.delegate = self
        //        cityTextField.delegate = self
        let fetchCurrentLocation: NSFetchRequest<CurrentLocation> = CurrentLocation.fetchRequest()
        do {
            let curr = try PersistanceService.context.fetch(fetchCurrentLocation)
            print(curr)
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
            print("catch block for CurrentLocation coreData fetchRequest AddLocationViewController")
        }
        
        self.dataSession.delegate = self
        dataSession.getData(city: "austin", state: "tx")
    }
    
    
    // functions:
    func responseDataHandler(data: NSArray, city: String, state: String){
        guard let DICT = data[0] as? NSDictionary else{
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
        guard let WindDegree = DICT["winddirDegree"] as? String else{
            print("winddirDegree not found")
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
        let Wind = WindSpeedK + "kmph/" + WindSpeedM + "mph " + WindDirection + "(" + WindDegree + "°)"
        
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
            self.clouds.isHidden = false
            self.humidity.isHidden = false
            self.pressure.isHidden = false
            self.rain.isHidden = false
            self.wind.isHidden = false
            
            self.WImage.isHidden = false
            
            self.temp.text = TempC + "°C/" + TempF + "°F"
            self.clouds.text = self.replaceData(original: self.clouds.text!, data: Cloud + "%")
            self.humidity.text = self.replaceData(original: self.humidity.text!, data: Humidity + "%")
            self.pressure.text = self.replaceData(original: self.pressure.text!, data: Pressure + "mbar")
            self.rain.text = self.replaceData(original: self.rain.text!, data: Prec + "mm")
            self.wind.text = self.replaceData(original: self.wind.text!, data: Wind)
            if let imageData = try? Data(contentsOf: URL(string: Image)!) {
                self.WImage.image = UIImage(data: imageData)
            }
            
        }
        
    }
    
    func responseError(){
        DispatchQueue.main.async() {
            self.temp.isHidden = true
            self.clouds.isHidden = true
            self.humidity.isHidden = true
            self.pressure.isHidden = true
            self.rain.isHidden = true
            self.wind.isHidden = true
            self.WImage.isHidden = true
        }
    }
    
    func replaceData(original: String, data: String) -> String{
        var str = ""
        var flag = true
        for ch in original{
            if(flag){
                str += String(ch)
            }else{
                break
            }
            if (ch == ":"){
                flag = false
            }
        }
        return str + data
        
    }
    
}

