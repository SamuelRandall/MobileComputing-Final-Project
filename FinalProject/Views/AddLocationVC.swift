//
//  AddLocationViewController.swift
//  nrk522_assignment4
//
//  Created by Noah Keller on 4/26/19.
//  Copyright © 2019 Noah Keller. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class AddLocationViewController: UIViewController {
    
    @IBOutlet weak var tableVeiw: UITableView!
    var currentLocation = CurrentLocation()
    var locations = [Location]()
    var dataSession = WeatherData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSession.delegate = self
        
        fetchCurrentLocation()
        fetchLocations()
    }
    
    func fetchLocations() {
        let fetchLocatioins: NSFetchRequest<Location> = Location.fetchRequest()
        do {
            let locs = try PersistanceService.context.fetch(fetchLocatioins)
            self.locations = locs
            self.tableVeiw.reloadData()
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
                print("ERROR no currentLocation found")
            }else {
                self.currentLocation = curr[0]
            }
        }
        catch {
            print("catch block for CurrentLocation coreData fetchRequest ViewController")
        }
    }
    
    
    @IBAction func addLocation(_ sender: UIButton) {
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
            }
            
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
}

extension AddLocationViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        if (indexPath.row == 0){
            let city = currentLocation.cityState
            cell.textLabel?.text = city
        }else{
            let city = locations[indexPath.row-1].cityState
            cell.textLabel?.text = city
            if (city! == currentLocation.cityState!){
                cell.accessoryType = .checkmark
                cell.isSelected = true
            }else {
                cell.accessoryType = .none
                cell.isSelected = false
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let city = self.locations.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            PersistanceService.context.delete(city)
            PersistanceService.saveContext()
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
            currentLocation.cityState = (indexPath.row == 0) ? currentLocation.cityState : locations[indexPath.row-1].cityState
//            currentLocation.cityState = (indexPath.row == 0) ? GPSLOCATION(zip or city,state) : locations[indexPath.row-1].cityState
            PersistanceService.saveContext()
            tableView.reloadData()
        }
        
        
    }
    

}

extension AddLocationViewController: nameWeatherDataProtocol{
    
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
                self.tableVeiw.reloadData()
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
