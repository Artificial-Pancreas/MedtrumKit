import LoopKit
import LoopKitUI
import SwiftUI

struct InsulinTypeSelector: View {
    @Environment(\.dismissAction) private var dismiss

    @State private var insulinType: InsulinType?
    private var supportedInsulinTypes: [InsulinType]
    private var didConfirm: (InsulinType) -> Void
    private let showSave: Bool

    init(
        initialValue: InsulinType,
        supportedInsulinTypes: [InsulinType],
        showSave: Bool,
        didConfirm: @escaping (InsulinType) -> Void
    ) {
        _insulinType = State(initialValue: initialValue)
        self.supportedInsulinTypes = supportedInsulinTypes
        self.didConfirm = didConfirm
        self.showSave = showSave
    }

    func continueWithType(_ insulinType: InsulinType?) {
        guard let insulinType = insulinType else {
            return
        }

        didConfirm(insulinType)
    }

    var body: some View {
        VStack(alignment: .leading) {
            List {
                Section {
                    Text(
                        "Select the type of insulin that you will be using",
                        comment: "Title text for insulin type confirmation page"
                    )

                    ScrollView {
                        InsulinTypeChooser(insulinType: $insulinType, supportedInsulinTypes: supportedInsulinTypes)
                            .padding(.horizontal)
                    }
                }
            }

            Spacer()

            Button(action: { self.continueWithType(insulinType) }) {
                if showSave {
                    Text("Save", comment: "save")
                } else {
                    Text("Continue", comment: "Continue")
                }
            }
            .buttonStyle(ActionButtonStyle())
            .padding([.bottom, .horizontal])
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarHidden(false)
        .navigationTitle(String(localized: "Select insulin type", comment: "Title for insulin type"))
    }
}
