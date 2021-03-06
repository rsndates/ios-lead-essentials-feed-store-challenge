//
//  CoreDataFeedStore.swift
//  FeedStoreChallenge
//
//  Created by Robert Dates on 11/11/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation
import CoreData

enum CoreDataError: Error {
    case setUpError
    case deleteError
}

public class CoreDataFeedStore: FeedStore {
    
    private let persistentContainer: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    static let managedObjectModel: NSManagedObjectModel? = NSManagedObjectModel(
        contentsOf: Bundle(for: CoreDataFeedStore.self).url(forResource: "CoreData", withExtension: "momd")!)

    public init(storeURL: URL) throws {
        guard let managedObjectModel = CoreDataFeedStore.managedObjectModel else {
            throw CoreDataError.setUpError
        }
        persistentContainer = NSPersistentContainer(
            name: "CoreData", managedObjectModel: managedObjectModel)
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        persistentContainer.persistentStoreDescriptions = [storeDescription]

        var receivedError: Error?
        persistentContainer.loadPersistentStores { (_, error) in
            receivedError = error
        }
        if let error = receivedError { throw error }

        context = persistentContainer.newBackgroundContext()
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        context.perform { [weak self] in
            guard let self = self else { return }
            do {
                try self.deleteCache(completion: completion)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        context.perform { [context, weak self] in
            guard let self = self else { return }
            do {
                try self.deleteCache(completion: completion)
                let cache = ManagedCache(context: context)
                cache.timestamp = timestamp
                let managedFeedArray = feed.map { (image) -> ManagedFeedImage in
                    let managedFeedImage = ManagedFeedImage(context: context)
                    managedFeedImage.id = image.id
                    managedFeedImage.objectDescription = image.description
                    managedFeedImage.location = image.location
                    managedFeedImage.url = image.url
                    return managedFeedImage
                }
                cache.feed = NSOrderedSet(array: managedFeedArray)
                try context.save()
                completion(nil)

            } catch {
                completion(error)
            }
         }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        context.perform { [context] in
             do {
                let fetchedCaches = try context.fetch(ManagedCache.fetchRequest() as NSFetchRequest<ManagedCache>)

                if let managedCache = fetchedCaches.first {
                     let localFeed = managedCache.feed.compactMap { (managedImage) -> LocalFeedImage? in
                         if let image = managedImage as? ManagedFeedImage {
                             return LocalFeedImage(id: image.id, description: image.objectDescription, location: image.location, url: image.url)
                         } else {
                             return nil
                         }
                     }
                     completion(.found(feed: localFeed, timestamp: managedCache.timestamp))
                 } else {
                     completion(.empty)
                 }
             } catch {
                 completion(.failure(error))
             }
         }
    }
    
    // MARK: - Helpers
    
    private func deleteCache(completion: @escaping DeletionCompletion) throws {
        let managedCaches = try context.fetch(ManagedCache.fetchRequest() as NSFetchRequest<ManagedCache>)
        try managedCaches.first.map(context.delete).map(context.save)
    }
}

