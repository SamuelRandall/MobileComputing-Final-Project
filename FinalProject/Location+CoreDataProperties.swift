//
//  Location+CoreDataProperties.swift
//  FinalProject
//
//  Created by Noah Keller on 4/26/19.
//  Copyright © 2019 Mobile Computing. All rights reserved.
//
//

import Foundation
import CoreData


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var cityState: String?

}
