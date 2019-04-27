//
//  WeatherData.swift
//  WeatherApp
//
//  Created by Noah Keller on 4/26/19.
//  Copyright © 2019 Noah Keller. All rights reserved.
//

import Foundation
import UIKit

protocol nameWeatherDataProtocol {
    func responseDataHandler(data: NSArray, city: String, state: String)
    func responseError()
}

class WeatherData {
    var delegate:nameWeatherDataProtocol? = nil
    
    var results = String()
    
    let session = URLSession.shared
    
    private var dataTask:URLSessionDataTask? = nil
    
    func getData(city: String, state: String){
        
        let cityState = formatText(text: city) + "," + formatText(text: state)
        var dataArray: NSArray?
        let url = URL(string: "https://api.worldweatheronline.com/premium/v1/weather.ashx?key=236178e1d71f4f14a5f174145190504&format=json&q=" + cityState)!
        let task = session.dataTask(with: url) { data, response, error in
            if error != nil || data == nil {
                print("Client error!")
                self.delegate?.responseError()
                return
            }
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                print("Server error!")
                self.delegate?.responseError()
                return
            }
            guard let mime = response.mimeType, mime == "application/json" else {
                print("Wrong MIME type!")
                self.delegate?.responseError()
                return
            }
            do {
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                if jsonResult != nil {
                    guard let Data = jsonResult!["data"] as? [String: Any] else{
                        print("Data not found")
                        self.delegate?.responseError()
                        return
                    }
                    guard let CurrentConditions = Data["current_condition"] as? NSArray else{
                        print("CurrentConditions not found")
                        self.delegate?.responseError()
                        return
                    }
                    dataArray = CurrentConditions
                    self.delegate?.responseDataHandler(data: dataArray!, city: city, state: state)
                }
            }
            catch {
                print("JSON error: \(error.localizedDescription)")
                self.delegate?.responseError()
            }
            
        }
        task.resume()
    }
    
    func formatText(text: String) -> String{
        var str = ""
        for ch in text{
            if(ch == " "){
                str += "+"
            }else{
                str += String(ch)
            }
        }
        return str
    }
    
}
