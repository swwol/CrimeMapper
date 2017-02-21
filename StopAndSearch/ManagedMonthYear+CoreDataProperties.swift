//
//  ManagedMonthYear+CoreDataProperties.swift
//  StopAndSearch
//
//  Created by edit on 21/02/2017.
//  Copyright © 2017 edit. All rights reserved.
//

import Foundation
import CoreData


extension ManagedMonthYear {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedMonthYear> {
        return NSFetchRequest<ManagedMonthYear>(entityName: "ManagedMonthYear");
    }

    @NSManaged public var month: Int16
    @NSManaged public var year: Int16

}
