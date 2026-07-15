import LoopKitUI
import SwiftUI

struct ManualTempBasalView: View {
    @Environment(\.appName) private var appName
    @ObservedObject var viewModel: ManualTempBasalViewModel

    var body: some View {
        VStack {
            List {
                Section {
                    HStack {
                        Text("Rate", comment: "Label text for basal rate summary")
                        Spacer()
                        Text(String(
                            format: String(
                                localized: "%@ for %@",
                                comment: "Summary string for temporary basal rate configuration page"
                            ),
                            viewModel.rateFormatter(for: viewModel.selectedRate),
                            viewModel.durationFormatter(for: viewModel.selectedDuration)
                        ))
                    }
                    HStack {
                        Picker(selection: $viewModel.selectedRate) {
                            ForEach(viewModel.allowedRates, id: \.self) { item in
                                Text(viewModel.rateFormatter(for: item))
                            }
                        } label: { EmptyView() }
                            .pickerStyle(.wheel)
                            .disabled(viewModel.enacting)
                        Picker(selection: $viewModel.selectedDuration) {
                            ForEach(viewModel.allowedDurations, id: \.self) { item in
                                Text(viewModel.durationFormatter(for: item))
                            }
                        } label: { EmptyView() }
                            .pickerStyle(.wheel)
                            .disabled(viewModel.enacting)
                    }
                    .frame(maxHeight: 162.0)
                } footer: {
                    Text(
                        String(
                            format:
                            String(
                                localized: "%@ will not automatically adjust your insulin delivery until the temporary basal rate finishes or is canceled.",
                                comment: "Description text on manual temp basal action sheet"
                            ),
                            appName
                        )
                    )
                }
            }

            if let error = viewModel.error {
                Text(error)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.red)
            }
            Button(action: viewModel.enact) {
                HStack(alignment: .center, spacing: 10) {
                    if viewModel.enactingBolus {
                        ActivityIndicator()
                        Text("Bolus in progress...", comment: "Button text for setting manual temporary basal rate")
                    } else if viewModel.enacting {
                        ActivityIndicator()
                    } else {
                        Text("Set Manual Temp Basal", comment: "Button text for setting manual temporary basal rate")
                    }
                }
            }
            .buttonStyle(ActionButtonStyle(.primary))
            .disabled(viewModel.enacting || viewModel.enactingBolus)
            .padding()
        }
    }
}
