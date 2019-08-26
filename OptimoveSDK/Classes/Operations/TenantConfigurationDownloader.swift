//  Copyright © 2019 Optimove. All rights reserved.

import Foundation
import OptimoveCore

final class TenantConfigurationDownloader: AsyncOperation {

    private let networking: RemoteConfigurationNetworking
    private let repository: ConfigurationRepository

    init(networking: RemoteConfigurationNetworking,
         repository: ConfigurationRepository) {
        self.networking = networking
        self.repository = repository
    }

    override func main() {
        guard !self.isCancelled else { return }
        state = .executing
        networking.getTenantConfiguration { (result) in
            do {
                let tenant = try result.get()
                try self.repository.saveTenant(tenant)
            } catch {
                Logger.error(error.localizedDescription)
            }
            self.state = .finished
        }
    }
}