import WebKit

// Mock class for WKScriptMessage
class MockWKScriptMessage: WKScriptMessage {
    var mockBody: Any
    var mockName: String
    var mockFrameInfo: WKFrameInfo

    override var body: Any {
        return mockBody
    }

    override var name: String {
        return mockName
    }

    override var frameInfo: WKFrameInfo {
        return mockFrameInfo
    }

    init(body: Any, name: String, frameInfo: WKFrameInfo) {
        self.mockBody = body
        self.mockName = name
        self.mockFrameInfo = frameInfo
    }
}
