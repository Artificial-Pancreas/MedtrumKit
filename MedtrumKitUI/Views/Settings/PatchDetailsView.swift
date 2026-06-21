import SwiftUI

struct PatchDetailsView: View {
    @ObservedObject var viewModel: PatchDetailsViewModel

    var body: some View {
        List {
            Section {
                sectionItem(
                    title: Text("Patch State", comment: "Text for patch state"),
                    value: viewModel.patchStateString
                )
                sectionItem(
                    title: Text("Pump base SN", comment: "Text for pumpSN"),
                    value: viewModel.pumpBaseSN
                )
                sectionItem(
                    title: Text("Pump base Firmware", comment: "Text for firmware version"),
                    value: viewModel.swVersion
                )
                sectionItem(
                    title: Text("Pump base model", comment: "Text for model"),
                    value: viewModel.model
                )
                sectionItem(
                    title: Text("Patch ID", comment: "Text for pumpSN"),
                    value: viewModel.patchId
                )
                sectionItem(
                    title: Text("Battery", comment: "Text for battery voltageB"),
                    value: viewModel.batteryText(for: viewModel.battery)
                )
                sectionItem(
                    title: Text("Activation", comment: "Text for activatedAt"),
                    value: viewModel.activatedAt
                )
                sectionItem(
                    title: Text("Cannula Age", comment: "Text for cannula age (CAGE)"),
                    value: viewModel.patchLifetime
                )

                if let initialReservoirLevel = viewModel.initialReservoirLevel {
                    sectionItem(
                        title: Text("Insulin Used", comment: "Text for Insulin used"),
                        value: viewModel.reservoirText(for: initialReservoirLevel - viewModel.reservoirLevel)
                    )
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }

    @ViewBuilder func sectionItem(title: Text, value: String) -> some View {
        HStack {
            title
                .foregroundColor(Color.primary)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.trailing)
        }
    }
}
