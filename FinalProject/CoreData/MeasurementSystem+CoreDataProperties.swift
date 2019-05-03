//
//  MeasurementSystem+CoreDataProperties.swift
//  FinalProject
//
//  Created by Noah Keller on 5/3/19.
//  Copyright © 2019 Mobile Computing. All rights reserved.
//
//

import Foundation
import CoreData


extension MeasurementSystem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MeasurementSystem> {
        return NSFetchRequest<MeasurementSystem>(entityName: "MeasurementSystem")
    }

    @NSManaged public var system: Bool

}
