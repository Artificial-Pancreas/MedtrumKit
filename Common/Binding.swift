import SwiftUI

extension Binding where Value == String {
    func max(_ limit: Int) -> Self {
        if wrappedValue.count > limit {
            DispatchQueue.main.async {
                self.wrappedValue = String(self.wrappedValue.prefix(limit))
            }
        }
        return self
    }
}
