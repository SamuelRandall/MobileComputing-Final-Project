//
//  Hour.swift
//  FinalProject
//
//  Created by Noah Keller on 4/29/19.
//  Copyright © 2019 Mobile Computing. All rights reserved.
//

import Foundation

class Hour {
    var tempC: String
    var tempF: String
    var windspeedKmph:String
    var windspeedMiles: String
    var chanceofrain: String
    var humidity: String
    var time: String
    var Image: String
    var winddir16Point: String
    var cloudCover: String
    var feelsLikeF: String
    var feelsLikeC: String
    
    init(tempC: String, tempF: String, windspeedKmph:String, windspeedMiles: String, chanceofrain: String, humidity: String, time: String, Image: String, winddir16Point: String, cloudCover: String, feelsLikeF: String, feelsLikeC: String) {
        self.tempC = tempC
        self.tempF = tempF
        self.windspeedKmph = windspeedKmph
        self.windspeedMiles = windspeedMiles
        self.chanceofrain = chanceofrain
        self.humidity = humidity
        self.time = time
        self.Image = Image
        self.winddir16Point = winddir16Point
        self.cloudCover = cloudCover
        self.feelsLikeF = feelsLikeF
        self.feelsLikeC = feelsLikeC
    }
}
