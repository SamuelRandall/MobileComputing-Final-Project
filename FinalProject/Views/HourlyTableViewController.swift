//
//  HourlyTableViewController.swift
//  FinalProject
//
//  Created by Noah Keller on 4/29/19.
//  Copyright © 2019 Mobile Computing. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class HourlyTableViewController: UIViewController {
    
    @IBOutlet weak var tableVeiw: UITableView!
    var currentLocation = CurrentLocation()
    var locations = [Location]()
    var dataSession = WeatherData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSession.delegate = self
        let fetchLocatioins: NSFetchRequest<Location> = Location.fetchRequest()
        do {
            let locs = try PersistanceService.context.fetch(fetchLocatioins)
            self.locations = locs
            self.tableVeiw.reloadData()
        }
        catch {
            print("catch block for Location coreData fetchRequest AddLocationViewController")
        }
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
            self.tableVeiw.reloadData()
        }
        catch {
            print("catch block for CurrentLocation coreData fetchRequest AddLocationViewController")
        }
    }
    
    
    @IBAction func addLocation(_ sender: UIButton) {
        print("button Pressed")
        addLocationPopUp()
    }
    
    func addLocationPopUp(){
        let alert = UIAlertController(title: "Add Location", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "City"
        }
        alert.addTextField { (textField) in
            textField.placeholder = "State"
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
    
}

extension AddLocationViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let city = locations[indexPath.row].cityState
        cell.textLabel?.text = city
        if (city! == currentLocation.cityState!){
            cell.accessoryType = .checkmark
            cell.isSelected = true
        }else {
            cell.accessoryType = .none
            cell.isSelected = false
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
            print(self.currentLocation)
            currentLocation.cityState = locations[indexPath.row].cityState
            PersistanceService.saveContext()
            tableView.reloadData()
        }
        
        
    }
    
    
}

extension AddLocationViewController: nameWeatherDataProtocol{
    
    func responseDataHandler(data: NSArray, city: String, state: String) {
        if (data.count == 0){
            responseError()
        }
        DispatchQueue.main.async() {
            let location = Location(context: PersistanceService.context)
            location.cityState = city + "," + state
            PersistanceService.saveContext()
            self.locations.append(location)
            self.tableVeiw.reloadData()
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
