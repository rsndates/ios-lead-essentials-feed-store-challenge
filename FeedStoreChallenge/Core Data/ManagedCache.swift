//
//  ManagedCache.swift
//  FeedStoreChallenge
//
//  Created by Robert Dates on 11/12/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation
import CoreData

@objc(ManagedCache)
public class ManagedCache: NSManagedObject, Identifiable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedCache> {
        return NSFetchRequest<ManagedCache>(entityName: "Cache")
    }
    @NSManaged public var timestamp: Date?
    @NSManaged public var feed: NSOrderedSet?

}
