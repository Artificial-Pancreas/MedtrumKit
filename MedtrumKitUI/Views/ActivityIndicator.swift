import SwiftUI

struct ActivityIndicator: View {
    var body: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
    }
}
