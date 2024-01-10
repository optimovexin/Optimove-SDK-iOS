import CoreData
@testable import OptimoveSDK
import OptimoveCore
import OptimoveTest
import XCTest


let path = "/dev/null"

class MockPersistentContainer: NSPersistentContainer {
    static func mockContainer(tenant: Int) -> NSPersistentContainer {
        let container = PersistentContainer(storeType: PersistentContainer.PersistentStoreType.inMemory)
        do {
            try container.loadPersistentStores(
                storeName: "\(OptistreamQueueImpl.Constants.Store.name)-\(tenant)"
            )
        }catch {
            Logger.error(error.localizedDescription)
        }
        return container
    }
}

class MockInAppMessageEntity {
    public var id: Int64
    public var updatedAt: NSDate
    public var content: NSDictionary
    public var data: NSDictionary?
    public var badgeConfig: NSDictionary?
    public var inboxConfig: NSDictionary?
    public var dismissedAt: NSDate?
    public var readAt: NSDate?
    public var sentAt: NSDate?
    
    init(id: Int64, updatedAt: NSDate, content: NSDictionary, data: NSDictionary? = nil, badgeConfig: NSDictionary? = nil, inboxConfig: NSDictionary? = nil, dismissedAt: NSDate? = nil, readAt: NSDate? = nil, sentAt: NSDate? = nil) {
        self.id = id
        self.updatedAt = updatedAt
        self.content = content
        self.data = data
        self.badgeConfig = badgeConfig
        self.inboxConfig = inboxConfig
        self.dismissedAt = dismissedAt
        self.readAt = readAt
        self.sentAt = sentAt
    }
}

class MockInAppMessage:  NSObject , InAppMessageProtocol {
    typealias T = MockInAppMessageEntity
    public var id: Int64
    public var updatedAt: NSDate
    public var content: NSDictionary
    public var data: NSDictionary?
    public var badgeConfig: NSDictionary?
    public var inboxConfig: NSDictionary?
    public var dismissedAt: NSDate?
    public var readAt: NSDate?
    public var sentAt: NSDate?
    
    required init(entity: MockInAppMessageEntity) {
        self.id = entity.id
        self.updatedAt = entity.updatedAt
        self.content = entity.content
        self.data = entity.data
        self.badgeConfig = entity.badgeConfig
        self.inboxConfig = entity.inboxConfig
        self.dismissedAt = entity.dismissedAt
        self.readAt = entity.readAt
        self.sentAt = entity.sentAt
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let other = object as? InAppMessage {
            return id == other.id
        }
        
        return super.isEqual(object)
    }
    
    override var hash: Int {
        id.hashValue
    }
}


class MockOptimobile : IOptimobile {
  
    var handled = false
    var notificationCenter: Any?
    var pushNotificationDeviceType: Int = 1
    var pushNotificationProductionTokenType: Int = 1
    var inAppConsentStrategy: InAppConsentStrategy
    var inAppManager: InAppManager
    var config: OptimobileConfig
    var analyticsHelper: AnalyticsHelper
    var deepLinkHelper: DeepLinkHelper?
    static var handleActionExpectation: XCTestExpectation! = XCTestExpectation.init()
    
    fileprivate static var instance: IOptimobile?
    
    static var properties: [String: Any]?

    init(handleActionExpectation: XCTestExpectation!, handled: Bool = false, notificationCenter: Any? = nil, pushNotificationDeviceType: Int, pushNotificationProductionTokenType: Int, inAppConsentStrategy: InAppConsentStrategy, inAppManager: InAppManager, config: OptimobileConfig, analyticsHelper: AnalyticsHelper, deepLinkHelper: DeepLinkHelper? = nil) {
        self.handled = handled
        self.notificationCenter = notificationCenter
        self.pushNotificationDeviceType = pushNotificationDeviceType
        self.pushNotificationProductionTokenType = pushNotificationProductionTokenType
        self.inAppConsentStrategy = inAppConsentStrategy
        self.inAppManager = inAppManager
        self.config = config
        self.analyticsHelper = analyticsHelper
        self.deepLinkHelper = deepLinkHelper
    }
    
    func updateNotificationCenter(with notificationCenter: Any?) {
        self.notificationCenter = notificationCenter
    }

    static var sharedInstance: IOptimobile  {
        return instance!
    }
    
    static func getInstance() -> IOptimobile {
        return instance!
    }
    
    static func trackEventImmediately(eventType: String, properties: [String: Any]?)
    {
        MockOptimobile.properties = properties
        MockOptimobile.handleActionExpectation.fulfill()
    }
    static func pushRequestDeviceToken()
    {
        return
    }
    func pushHandleDismissed(withUserInfo: [AnyHashable: Any]?, response: UNNotificationResponse?) -> Bool
    {
        return true
    }
    @available(iOS 10.0, *)
    func pushHandleOpen(withUserInfo: [AnyHashable: Any]?, response: UNNotificationResponse?) -> Bool
    {
        return true
    }
}
