import LoopKitUI
import SwiftUI

struct OnboardingWelcomeView: View {
    @Environment(\.dismissAction) private var dismiss

    let nextStep: () -> Void

    var body: some View {
        VStack {
            List {
                Section {
                    PumpImage(is300u: false)
                    Text(
                        "You will start by setting up your insulin type & basic patch settings before activating your patch.",
                        comment: "Welcome text for MedtrumKit"
                    )
                }
            }
            Spacer()

            Button(action: { nextStep() }) {
                Text("Continue", comment: "Continue")
            }
            .buttonStyle(ActionButtonStyle())
            .padding([.bottom, .horizontal])
        }
        .listStyle(InsetGroupedListStyle())
        .edgesIgnoringSafeArea(.bottom)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(String(localized: "Cancel", comment: "Cancel button title"), action: {
                    self.dismiss()
                })
            }
        }
    }
}
