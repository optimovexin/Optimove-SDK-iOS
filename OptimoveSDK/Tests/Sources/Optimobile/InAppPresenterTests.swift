//  Copyright © 2023 Optimove. All rights reserved.

import WebKit
import CoreData
@testable import OptimoveSDK
import OptimoveTest
import XCTest


class InAppPresenterTests : XCTestCase {
    
    var appPresenter: InAppPresenter!
    
    var wkScriptMessage : MockWKScriptMessage!
    
    var wKUserContentController: WKUserContentController!
    
    var jsonNSDictionary: NSDictionary!
    
    let jsonString : String  = "{\"type\": \"EXECUTE_ACTIONS\", \"data\": {\"callToActionId\": \"MNiIG_\",\"actions\": [{\"type\": \"EXECUTE_ACTIONS\"}]}}"

    var pendingTickleIds = NSMutableOrderedSet(capacity: 1)
    
    var messages : [any InAppMessageProtocol] = []

    var mockPersistentContainer: NSPersistentContainer!

    var mockManagedObjectContext: NSManagedObjectContext!

    var migrator: CoreDataMigrator!

    override func setUpWithError() throws {
        
        super.setUp()

        FileManager.clearTempDirectoryContents()
        
        migrator = CoreDataMigrator()
        
        appPresenter = InAppPresenter(displayMode: InAppDisplayMode.automatic, urlBuilder: UrlBuilder(storage: KeyValPersistenceHelper.self))
    
        wKUserContentController = WKUserContentController()
    }


    private func MockContainer() throws  {
        
        let sourceURL = FileManager.moveFileFromBundleToTempDirectory(filename: "Events-2590.sqlite")
        let toVersion = CoreDataMigrationVersion.version2

        try migrator.migrateStore(at: sourceURL, toVersion: toVersion)

        XCTAssertTrue(FileManager.default.fileExists(atPath: sourceURL.path))

        let model = CoreDataModelDescription.makeOptistreamEventModel(version: toVersion)
        mockManagedObjectContext = NSManagedObjectContext(model: model, storeURL: sourceURL)
        
        
        let migratedPosts = try EventCDv2.fetch(in: mockManagedObjectContext) { request in
            request.predicate = EventCDv2.queueTypePredicate(queueType: .track)
            request.sortDescriptors = EventCDv2.defaultSortDescriptors
            request.fetchLimit = 50
            request.returnsObjectsAsFaults = false
        }

        XCTAssertEqual(migratedPosts.count, 10)

        let migratedPost = migratedPosts[0]
        XCTAssertNoThrow(try JSONDecoder().decode(OptistreamEvent.self, from: migratedPost.data))
        mockManagedObjectContext.destroyStore()
    }
        
    private func MockMessage() {
        let content = NSDictionary(dictionary: [
            "title": "Example Title",
            "message": "This is an example message."
        ])
        
        let updateAt =  NSDate.init()
        let data = NSDictionary(dictionary: [
            "optimoveMetricsContext":
                NSDictionary(dictionary: ["optimoveMetricsContext":
                                            NSDictionary(dictionary: ["send_id": "12345",
                                                                      "execution_date": "2023-11-21",
                                                                      "execution_datetime": "2023-11-21T16:37:08+00:00",
                                                                      "insertion_time": "2020-06-09T05:32:21+00:00",
                                                                      "execution_gateway": "optimobile-in-app",
                                                                    ])
                                                                ])
            ])
        
        messages.append(MockInAppMessage(entity: MockInAppMessageEntity(id: 1, updatedAt: updateAt , content: content , data: data)))
    }

    override func tearDown() {
        appPresenter = nil
        wkScriptMessage = nil
        wKUserContentController = nil
        super.tearDown()
    }
    
    func test_userContentController() throws {
        
        appPresenter.setOptimobile(MockOptimobile.self)
        
        try MockContainer()
        
        MockMessage()
    
        appPresenter.queueMessagesForPresentation(messages: messages, tickleIds: pendingTickleIds)
        
        appPresenter.presentFromQueue()

        do {
            let data = Data(jsonString.utf8)
            var dictonary:NSDictionary?
            dictonary =  try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
            wkScriptMessage = MockWKScriptMessage(body: dictonary as Any, name: "inAppHost", frameInfo: WKFrameInfo())
           }
        catch let error as NSError {
            print(error)
        }
        
        appPresenter.userContentController(wKUserContentController, didReceive: wkScriptMessage)
        
        XCTAssertEqual(MockOptimobile.handleActionExpectation.expectedFulfillmentCount, 1)
        
        XCTAssertEqual(MockOptimobile.properties?.count, 2)

        XCTAssertEqual(MockOptimobile.properties?["callToActionId"] as? String, "MNiIG_")
        
        XCTAssertEqual((MockOptimobile.properties?["optimoveMetricsContext"] as? NSDictionary)?.count, 5)
    }
}
