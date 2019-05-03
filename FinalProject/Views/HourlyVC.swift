//
//  HourlyVC.swift
//  FinalProject
//
//  Created by Noah Keller on 4/29/19.
//  Copyright © 2019 Mobile Computing. All rights reserved.
//

import Foundation

import Foundation
import UIKit
import CoreData


class HourlyViewController: UIViewController {
    
    
    @IBOutlet weak var tableVeiw: UITableView!
    
    var currentLocation = CurrentLocation()
    var dataSession = WeatherData()
    var hourlyList = [Hour]()
    
    var expanded:Bool = false
    var mesurementSystem = MeasurementSystem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load core data
        fetchCurrentLocation()
        fetchMesurementSystem()
        
        // get data from rest service
        self.dataSession.delegate = self
        let city_State = currentLocation.cityState!.split(separator: ",")
        dataSession.getData(city: String(city_State[0]), state: String(city_State[1]))
        
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
            self.tableVeiw.reloadData()
        }
        catch {
            print("catch block for CurrentLocation coreData fetchRequest AddLocationViewController")
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
    
    @IBAction func measurementToggle(_ sender: UIBarButtonItem) {
        self.mesurementSystem.system = !self.mesurementSystem.system
        PersistanceService.saveContext()
        self.tableVeiw.reloadData()
    }
    
}

extension HourlyViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hourlyList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HourlyCell", for: indexPath) as! HourlyCell
        let hour = hourlyList[indexPath.row]
        
        if (mesurementSystem.system){
            cell.tempLabel.text = hour.tempF + "°F"
            cell.feelsLikeLabel.text = hour.feelsLikeF + "°F"
            cell.windDirLabel.text = hour.winddir16Point + " " + hour.windspeedMiles + " mph"
        }else{
            cell.tempLabel.text = hour.tempC + "°C"
            cell.feelsLikeLabel.text = hour.feelsLikeC + "°C"
            cell.windDirLabel.text = hour.winddir16Point + " " + hour.windspeedKmph + " Kmph"
        }
    
        if let imageData = try? Data(contentsOf: URL(string: hour.Image)!) {
            cell.img.image = UIImage(data: imageData)!
        }
        cell.cloudCoverLabel.text = hour.cloudCover + "%"
        cell.humidityLabel.text = hour.humidity + "%"
        cell.rainChanceLabel.text = hour.chanceofrain + "%"

        cell.time.text = getTime(add: Int(hour.time)!/100)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.expanded {
            return 150
        }else {
            return 75
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.expanded = !self.expanded
        self.tableVeiw.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.expanded = !self.expanded
        self.tableVeiw.reloadData()
    }
    
    func getTime(add: Int)->String {
        // get current hour
        
        let calendar = NSCalendar.current
        let currentHour = calendar.component(.hour,from: NSDate() as Date)
        let HOUR = (currentHour + add + 3) % 24
        if (HOUR < 12){
            return HOUR == 0 ? "12 AM" : String(HOUR) + " AM"
        }else{
            return HOUR == 12 ? "12 PM" : String((HOUR)-12) + " PM"
        }
    }
    
    
}

extension HourlyViewController: nameWeatherDataProtocol{
    
    func responseDataHandler(jsonResult: NSDictionary, city: String, state: String) {
        guard let DATA = jsonResult["data"] as? [String: Any] else{
            print("Data not found")
            responseError()
            return
        }
        guard let weather = DATA["weather"] as? NSArray else{
            print("Weather not found")
            responseError()
            return
        }
        guard let weather_first = weather[0] as? NSDictionary else{
            print("weather_first not found")
            responseError()
            return
        }
        guard let List = weather_first["hourly"] as? NSArray else{
            print("hourlyList not found")
            responseError()
            return
        }
        for index in 0..<List.count{
            extractData(list: List, idx: index)
        }
        DispatchQueue.main.async(){
            self.tableVeiw.reloadData()
        }
    }
    
    
    func responseError(){
        DispatchQueue.main.async() {
            let alert = UIAlertController(title: "Network Error", message: "Check your internet connection and try again", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func extractData(list: NSArray, idx: Int) {
        guard let element = list[idx] as? NSDictionary else{
            print("element not found")
            responseError()
            return
        }
        guard let TC = element["tempC"] as? String else{
            print("tempC not found")
            responseError()
            return
        }
        guard let TF = element["tempF"] as? String else{
            print("tempF not found")
            responseError()
            return
        }
        guard let WSK = element["windspeedKmph"] as? String else{
            print("windspeedKmph not found")
            responseError()
            return
        }
        guard let WSM = element["windspeedMiles"] as? String else{
            print("windspeedMiles not found")
            responseError()
            return
        }
        guard let RP = element["chanceofrain"] as? String else{
            print("chanceofrain not found")
            responseError()
            return
        }
        guard let H = element["humidity"] as? String else{
            print("humidity not found")
            responseError()
            return
        }
        guard let T = element["time"] as? String else{
            print("time not found")
            responseError()
            return
        }
        guard let WD = element["winddir16Point"] as? String else{
            print("winddir16Point not found")
            responseError()
            return
        }
        guard let CC = element["cloudcover"] as? String else{
            print("cloudcover not found")
            responseError()
            return
        }
        guard let FLF = element["FeelsLikeF"] as? String else{
            print("FeelsLikeF not found")
            responseError()
            return
        }
        guard let FLC = element["FeelsLikeC"] as? String else{
            print("FeelsLikeC not found")
            responseError()
            return
        }
        guard let ImageArray = element["weatherIconUrl"] as? NSArray else{
            print("weatherIconUrl not found")
            return
        }
        guard let ImageDict = ImageArray[0] as? NSDictionary else{
            print("ImageDict not found")
            return
        }
        guard let I = ImageDict["value"] as? String else{
            print("Image not found")
            return
        }
        
        let hour = Hour(tempC: TC, tempF: TF, windspeedKmph: WSK, windspeedMiles: WSM, chanceofrain: RP, humidity: H, time: T, Image: I, winddir16Point: WD, cloudCover: CC, feelsLikeF: FLF ,feelsLikeC: FLC)
        hourlyList.append(hour)
    }
}
