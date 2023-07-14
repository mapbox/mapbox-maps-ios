import os

extension Signal {
    /// Creates a signal that traces time required to handle it's update.
    ///
    /// Every invocation on every observer will result in trancing interval.
    func tracingInterval(_ name: StaticString, _ message: String? = nil, log: OSLog = .platform) -> Signal {
        Signal { handler in
            self.observe { payload in
                log.withIntervalSignpost(name, message) {
                    handler(payload)
                }
            }
        }
    }
}
