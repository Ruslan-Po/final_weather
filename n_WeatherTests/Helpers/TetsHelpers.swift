import Foundation
import CoreData
import XCTest
@testable import n_Weather

extension NSError {
    static func testError(domain: String = "TestDomain", code: Int = 1, description: String = "Test error") -> NSError {
        return NSError(domain: domain, code: code, userInfo: [
            NSLocalizedDescriptionKey: description
        ])
    }
}

struct TestHelper {
    static func wait(seconds: TimeInterval = 0.1) {
        let expectation = XCTestExpectation(description: "Wait")
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            expectation.fulfill()
        }
        _ = XCTWaiter.wait(for: [expectation], timeout: seconds + 1.0)
    }
}


class CoreDataTestHelper {
    static func createInMemoryContext() -> NSManagedObjectContext {
        guard let modelURL = Bundle.main.url(forResource: "n_Weather", withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Unable to load Core Data model")
        }
        
        let container = NSPersistentContainer(name: "n_Weather", managedObjectModel: model)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load in-memory store: \(error)")
            }
        }
        
        return container.viewContext
    }
}
