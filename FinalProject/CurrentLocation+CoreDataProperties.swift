//
//  CurrentLocation+CoreDataProperties.swift
//  FinalProject
//
//  Created by Noah Keller on 4/26/19.
//  Copyright © 2019 Mobile Computing. All rights reserved.
//
//

import Foundation
import CoreData


extension CurrentLocation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CurrentLocation> {
        return NSFetchRequest<CurrentLocation>(entityName: "CurrentLocation")
    }

    @NSManaged public var cityState: String?

}
