//
//  Place.swift
//  FinalProject
//
//  Created by Samuel Randall on 5/5/19.
//  Copyright © 2019 Mobile Computing. All rights reserved.
//

import Foundation
import MapKit

class Place: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    let geocoder = CLGeocoder()
    
    init(title: String?) {
        self.title = title
        coordinate = CLLocationCoordinate2DMake(0, 0)
    }
    
    
    func getLocation(forPlaceCalled name: String,
                     completion: @escaping(Place) -> Void) {
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(name) { placemarks, error in
            
            guard error == nil else {
                print("*** Error in \(#function): \(error!.localizedDescription)")
                completion(self)
                return
            }
            
            guard let placemark = placemarks?[0] else {
                print("*** Error in \(#function): placemark is nil")
                completion(self)
                return
            }
            
            guard let location = placemark.location else {
                print("*** Error in \(#function): placemark is nil")
                completion(self)
                return
            }
            self.coordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
            print(self.coordinate)
            completion(self)
        }
        
    }
}
