//
//  ManagedFeedImage.swift
//  FeedStoreChallenge
//
//  Created by Robert Dates on 11/12/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation
import CoreData

@objc(ManagedFeedImage)
public class ManagedFeedImage: NSManagedObject, Identifiable {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedFeedImage> {
        return NSFetchRequest<ManagedFeedImage>(entityName: "FeedImage")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var objectDescription: String?
    @NSManaged public var location: String?
    @NSManaged public var url: URL
    @NSManaged public var cache: ManagedCache?
}
