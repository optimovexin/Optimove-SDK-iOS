//  Copyright © 2019 Optimove. All rights reserved.

import XCTest
@testable import OptimoveSDK

class PageVisitEventTests: XCTestCase {

    func test_event_name() {
        // given
        let pageTitle = "pageTitle"
        let category = "category"

        // when
        let event = PageVisitEvent(
            title: pageTitle,
            category: category
        )

        // then
        XCTAssert(event.name == PageVisitEvent.Constants.name)
    }

    func test_event_parameters() {
        // given
        let title = "title"
        let category = "category"

        // when
        let event = PageVisitEvent(
            title: title,
            category: category
        )
        // then
        XCTAssert(event.parameters[PageVisitEvent.Constants.Key.pageTitle] as? String == title)
        XCTAssert(event.parameters[PageVisitEvent.Constants.Key.category] as? String == category)
    }

}
