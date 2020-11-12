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

    @NSManaged public var timestamp: Date?
    @NSManaged public var images: NSOrderedSet?

}
