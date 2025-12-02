import LoopKit
import LoopKitUI
import SwiftUI

struct MedtrumKitSettings: View {
    @State private var showingTimeSyncConfirmation: Bool = false
    @State private var isSharePresented: Bool = false
    @ObservedObject var viewModel: MedtrumKitSettingsViewModel

    @Environment(\.dismissAction) private var dismiss
    @Environment(\.insulinTintColor) var insulinTintColor
    @Environment(\.guidanceColors) private var guidanceColors
    @Environment(\.appName) private var appName

    var supportedInsulinTypes: [InsulinType]

    var syncPumpTime: ActionSheet {
        ActionSheet(
            title: Text(LocalizedString("Time Change Detected", comment: "Title for pod sync time action sheet.")),
            message: Text(LocalizedString(
                "The time on your pump is different from the current time. Do you want to update the time on your pump to the current time?",
                comment: "Message for pod sync time action sheet"
            )),
            buttons: [
                .default(Text(LocalizedString("Yes, Sync to Current Time", comment: "Button text to confirm pump time sync"))) {
                    self.viewModel.syncPumpTime()
                },
                .cancel(Text(LocalizedString("No, Keep Pump As Is", comment: "Button text to cancel pump time sync")))
            ]
        )
    }

    var body: some View {
        List {
            Section {
                VStack {
                    PumpImage(is300u: viewModel.is300u)
                    patchLifecycle
                }

                HStack(alignment: .top) {
                    deliveryStatus
                    Spacer()
                    reservoirStatus
                }
                .padding(.bottom, 5)

                if viewModel.showPumpTimeSyncWarning {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(LocalizedString("Time Change Detected", comment: "title for time change detected notice"))
                            .font(Font.subheadline.weight(.bold))
                        Text(LocalizedString(
                            "The time on your pump is different from the current time. Your pump’s time controls your scheduled therapy settings. Scroll down to Pump Time row to review the time difference and configure your pump.",
                            comment: "description for time change detected notice"
                        ))
                            .font(Font.footnote.weight(.semibold))
                    }.padding(.vertical, 8)
                }
            }

            Section {
                Button(action: {
                    viewModel.suspendResumeButtonPressed()
                }) {
                    HStack {
                        if viewModel.basalType == .suspended {
                            Text(LocalizedString("Resume delivery", comment: "Resume patch"))
                        } else {
                            Text(LocalizedString("Suspend delivery", comment: "Suspend patch"))
                        }
                        Spacer()
                        if viewModel.isUpdatingSuspend {
                            ActivityIndicator(isAnimating: .constant(true), style: .medium)
                        }
                    }
                }
                .disabled(viewModel.isUpdatingPumpState || viewModel.isUpdatingTempBasal || viewModel.isUpdatingSuspend)

                if viewModel.basalType == .tempBasal {
                    Button(action: {
                        viewModel.stopTempBasal()
                    }) {
                        HStack {
                            Text(LocalizedString("Stop temp basal", comment: "Stop temp basal"))
                            Spacer()
                            if viewModel.isUpdatingTempBasal {
                                ActivityIndicator(isAnimating: .constant(true), style: .medium)
                            }
                        }
                    }
                    .disabled(viewModel.isUpdatingPumpState || viewModel.isUpdatingTempBasal || viewModel.isUpdatingSuspend)
                }

                Button(action: { viewModel.syncData() }) {
                    HStack {
                        Text(LocalizedString("Sync patch data", comment: "sync pump"))
                        Spacer()
                        if viewModel.isUpdatingPumpState {
                            ActivityIndicator(isAnimating: .constant(true), style: .medium)
                        }
                    }
                }
                .disabled(viewModel.isUpdatingPumpState || viewModel.isUpdatingTempBasal || viewModel.isUpdatingSuspend)

                if viewModel.patchState.rawValue < PatchState.active.rawValue && viewModel.patchState != .none {
                    Button(action: { viewModel.toPumpActivation() }) {
                        HStack {
                            Text(LocalizedString("Activate patch", comment: "label for activate patch"))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: UIFont.systemFontSize, weight: .bold))
                                .opacity(0.35)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Button(action: { viewModel.checkConnection() }) {
                    HStack {
                        if viewModel.isConnected {
                            Text(LocalizedString("Disconnect", comment: "disconnect from patch"))
                        } else {
                            Text(LocalizedString("Reconnect", comment: "reconnect to patch"))
                        }
                        Spacer()
                        if viewModel.isReconnecting {
                            ActivityIndicator(isAnimating: .constant(true), style: .medium)
                        }
                    }
                }

                Button(action: { viewModel.deactivatePatchAction() }) {
                    HStack {
                        Text(LocalizedString("Deactivate Patch", comment: "deactivate patch"))
                            .foregroundStyle(.red)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: UIFont.systemFontSize, weight: .bold))
                            .opacity(0.5)
                            .foregroundColor(.red)
                    }
                }

                HStack {
                    Text(LocalizedString("Patch state", comment: "Text for patch state"))
                        .foregroundColor(Color.primary)
                    Spacer()
                    Text(viewModel.patchStateString)
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text(LocalizedString("Last sync", comment: "Text for last sync"))
                        .foregroundColor(Color.primary)
                    Spacer()
                    if viewModel.patchLifecycleState != .noPatch {
                        Text(viewModel.dateFormatter.string(from: viewModel.lastSync))
                            .foregroundColor(.secondary)
                    } else {
                        Text("-")
                            .foregroundColor(.secondary)
                    }
                }

                HStack {
                    Text(LocalizedString("Status", comment: "Text for status")).foregroundColor(Color.primary)
                    Spacer()
                    HStack(spacing: 10) {
                        connectionStatusText
                        connectionStatusIcon
                    }
                }
            }

            Section(header: SectionHeader(label: LocalizedString("Configuration", comment: "Configuration section"))) {
                HStack {
                    Text(LocalizedString("Insulin Type", comment: "Text for selecting insulin type"))
                        .foregroundColor(Color.primary)
                    Spacer()
                    Text(viewModel.insulinType.brandName)
                        .foregroundColor(.secondary)
                        .padding(.trailing, 3)
                    Image(systemName: "chevron.right")
                        .font(.system(size: UIFont.systemFontSize, weight: .medium))
                        .opacity(0.3)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.toInsulinType()
                }

                HStack {
                    Text(LocalizedString("Patch settings", comment: "Text for patch settings view"))
                        .foregroundColor(Color.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: UIFont.systemFontSize, weight: .medium))
                        .opacity(0.3)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.toSettings()
                }
            }

            Section(header: SectionHeader(label: LocalizedString(
                "Information",
                comment: "The title for patch/pump information"
            ))) {
                HStack {
                    Text(LocalizedString("Pump base SN", comment: "Text for pumpSN"))
                        .foregroundColor(Color.primary)
                    Spacer()
                    Text(viewModel.pumpBaseSN)
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text(LocalizedString("Pump base model", comment: "Text for model"))
                        .foregroundColor(Color.primary)
                    Spacer()
                    Text(viewModel.model)
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text(LocalizedString("Pump base firmware", comment: "Text for firmware"))
                        .foregroundColor(Color.primary)
                    Spacer()
                    Text(viewModel.swVersion)
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text(LocalizedString("Patch ID", comment: "Text for activatedAt"))
                        .foregroundColor(Color.primary)
                    Spacer()
                    Text("\(viewModel.patchId)")
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text(LocalizedString("Patch activated at", comment: "Text for activatedAt"))
                        .foregroundColor(Color.primary)
                    Spacer()
                    if viewModel.patchLifecycleState != .noPatch {
                        Text(viewModel.dateTimeFormatter.string(from: viewModel.patchActivatedAt))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.trailing)
                    } else {
                        Text("-")
                            .foregroundColor(.secondary)
                    }
                }
                HStack {
                    Text(LocalizedString("Patch expires at", comment: "Text for expiresAt"))
                        .foregroundColor(Color.primary)
                    Spacer()
                    if viewModel.patchLifecycleState != .noPatch {
                        Text(viewModel.dateTimeFormatter.string(from: viewModel.patchExpiresAt))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.trailing)
                    } else {
                        Text("-")
                            .foregroundColor(.secondary)
                    }
                }
                HStack {
                    Text(LocalizedString("Battery", comment: "Text for battery voltageB"))
                        .foregroundColor(Color.primary)
                    Spacer()
                    Text(viewModel.batteryText(for: viewModel.battery))
                        .foregroundColor(.secondary)
                }
                if let initialReservoirLevel = viewModel.initialReservoirLevel {
                    HStack {
                        Text(LocalizedString("Insulin used", comment: "Text for Insulin used"))
                            .foregroundColor(Color.primary)
                        Spacer()
                        Text(viewModel.reservoirText(for: initialReservoirLevel - viewModel.reservoirLevel))
                            .foregroundColor(.secondary)
                    }
                }
            }

            Section(header: SectionHeader(label: LocalizedString(
                "Patch time",
                comment: "The title for patch time"
            ))) {
                HStack {
                    Text(LocalizedString("Patch time", comment: "Text for pump time"))
                        .foregroundColor(Color.primary)
                    Spacer()
                    if viewModel.showPumpTimeSyncWarning {
                        Image(systemName: "clock.fill")
                            .foregroundColor(guidanceColors.warning)
                    }
                    Text(String(viewModel.dateFormatter.string(from: viewModel.pumpTime)))
                        .foregroundColor(viewModel.showPumpTimeSyncWarning ? guidanceColors.warning : .secondary)
                }
                HStack {
                    Text(LocalizedString("Checked at", comment: "Text for pump time synced at"))
                        .foregroundColor(Color.primary)
                    Spacer()
                    Text(String(viewModel.dateFormatter.string(from: viewModel.pumpTimeSyncedAt)))
                        .foregroundColor(.secondary)
                }

                Button(action: {
                    showingTimeSyncConfirmation = true
                }) {
                    HStack {
                        Text(LocalizedString("Manually sync Pump time", comment: "Label for syncing the time on the pump"))
                            .foregroundColor(.accentColor)

                        Spacer()

                        if viewModel.isUpdatingPumpState {
                            ActivityIndicator(isAnimating: .constant(true), style: .medium)
                        }
                    }
                }
                .disabled(viewModel.isUpdatingPumpState)
                .actionSheet(isPresented: $showingTimeSyncConfirmation) {
                    syncPumpTime
                }
            }

            if let previousPatch = viewModel.previousPatch {
                Section(header: SectionHeader(label: LocalizedString(
                    "Previous Patch Details",
                    comment: "label for previous patch details"
                ))) {
                    HStack {
                        Text(LocalizedString("Patch ID", comment: "Text for patchId"))
                            .foregroundColor(Color.primary)
                        Spacer()
                        Text("\(previousPatch.patchId.toUInt64())")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text(LocalizedString("Patch state", comment: "Text for state"))
                            .foregroundColor(Color.primary)
                        Spacer()
                        Text((PatchState(rawValue: previousPatch.lastStateRaw) ?? .none).description)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text(LocalizedString("Activated at", comment: "Text for activatedAt"))
                            .foregroundColor(Color.primary)
                        Spacer()
                        Text(viewModel.dateTimeFormatter.string(from: previousPatch.activatedAt))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text(LocalizedString("Deactivated at", comment: "Text for deactivatedAt"))
                            .foregroundColor(Color.primary)
                        Spacer()
                        Text(viewModel.dateTimeFormatter.string(from: previousPatch.deactivatedAt))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text(LocalizedString("Battery", comment: "Text for battery voltageB"))
                            .foregroundColor(Color.primary)
                        Spacer()
                        Text(viewModel.batteryText(for: previousPatch.battery))
                            .foregroundColor(.secondary)
                    }
                    if let reservoirLevel = previousPatch.reservoirLevel,
                       let initialReservoirLevel = previousPatch.initialReservoirLevel
                    {
                        HStack {
                            Text(LocalizedString("Insulin used", comment: "Text for Insulin used"))
                                .foregroundColor(Color.primary)
                            Spacer()
                            Text(viewModel.reservoirText(for: initialReservoirLevel - reservoirLevel))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }

            Section {
                Button(LocalizedString("Share Medtrum patch logs", comment: "Share logs")) {
                    self.isSharePresented = true
                }
                .sheet(isPresented: $isSharePresented, onDismiss: {}, content: {
                    ActivityViewController(activityItems: viewModel.getLogs())
                })

                Button(action: {
                    viewModel.showingDeleteConfirmation = true
                }) {
                    Text(LocalizedString("Delete Pump", comment: "Label for PumpManager deletion button"))
                        .foregroundColor(guidanceColors.critical)
                }
                .actionSheet(isPresented: $viewModel.showingDeleteConfirmation) {
                    removePumpManagerActionSheet(deleteAction: viewModel.pumpRemovalAction)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarItems(trailing: doneButton)
        .navigationBarTitle(viewModel.pumpName)
    }

    var reservoirStatus: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(LocalizedString("Insulin Remaining", comment: "Header for insulin remaining on pod settings screen"))
                .foregroundColor(Color(UIColor.secondaryLabel))
            HStack {
                ReservoirView(
                    reservoirLevel: viewModel.reservoirLevel,
                    fillColor: reservoirColor,
                    maxReservoirLevel: viewModel.maxReservoirLevel
                )
                .frame(width: 23, height: 32)
                Text(viewModel.reservoirText(for: viewModel.reservoirLevel))
                    .font(.system(size: 28))
                    .fontWeight(.heavy)
                    .fixedSize()
            }
        }
    }

    var deliveryStatus: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(deliverySectionTitle)
                .foregroundColor(Color(UIColor.secondaryLabel))

            switch viewModel.basalType {
            case .active,
                 .tempBasal:
                HStack(alignment: .center) {
                    HStack(alignment: .lastTextBaseline, spacing: 3) {
                        Text(viewModel.basalRateFormatter.string(from: viewModel.basalRate as NSNumber) ?? "")
                            .font(.system(size: 28))
                            .fontWeight(.heavy)
                            .fixedSize()
                        Text(LocalizedString("U/hr", comment: "Units for showing temp basal rate"))
                            .foregroundColor(.secondary)
                    }
                }
            case .suspended:
                HStack(alignment: .center) {
                    Image(systemName: "pause.circle.fill")
                        .font(.system(size: 34))
                        .fixedSize()
                        .foregroundColor(guidanceColors.warning)
                    Text(LocalizedString(
                        "Insulin\nSuspended",
                        comment: "Text shown in insulin delivery space when insulin suspended"
                    ))
                        .fontWeight(.bold)
                        .fixedSize()
                }
            }
        }
    }

    var patchLifecycle: some View {
        VStack {
            switch viewModel.patchLifecycleState {
            case .noPatch:
                HStack {
                    Text(LocalizedString("No active patch", comment: "Text shown when no patch active"))
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            case .active:
                HStack {
                    if viewModel.patchLifecycleExpiration {
                        Text(LocalizedString("Expires in:", comment: "Text shown while patch is active"))
                            .foregroundStyle(.secondary)
                    } else {
                        Text(LocalizedString("Age:", comment: "Text shown while patch is active"))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    viewModel.patchLifecycleDays.map { days in
                        timeComponent(
                            value: days,
                            units: days == 1 ?
                                LocalizedString("day", comment: "Unit for singular day") :
                                LocalizedString("days", comment: "Unit for plural days")
                        )
                    }
                    viewModel.patchLifecycleHours.map { hours in
                        timeComponent(
                            value: hours,
                            units: hours == 1 ?
                                LocalizedString("hour", comment: "Unit for singular hour") :
                                LocalizedString("hours", comment: "Unit for plural hours")
                        )
                    }
                    viewModel.patchLifecycleMinutes.map { minutes in
                        timeComponent(
                            value: minutes,
                            units: minutes == 1 ?
                                LocalizedString("minute", comment: "Unit for singular minute") :
                                LocalizedString("minutes", comment: "Unit for plural minutes")
                        )
                    }
                }
            case .expired:
                HStack {
                    Text(LocalizedString("Patch expired", comment: "Text shown when patch expired"))
                        .foregroundStyle(.red)
                    Spacer()
                }
            }

            if viewModel.patchLifecycleExpiration {
                ProgressView(progress: viewModel.patchLifecycleProgress)
                    .padding(.top, -5)
            }
        }
    }

    func timeComponent(value: Int, units: String) -> some View {
        Group {
            Text(String(value))
                .font(.system(size: 24))
                .fontWeight(.heavy)
                .foregroundColor(.primary)
            Text(units)
                .foregroundColor(.secondary)
        }
    }

    private var doneButton: some View {
        Button(LocalizedString("Done", comment: "Button for closing settings"), action: {
            dismiss()
        })
    }

    public var reservoirColor: Color {
        // TODO: Configurable??
        if viewModel.reservoirLevel > (viewModel.maxReservoirLevel * 0.1) {
            return insulinTintColor
        }

        if viewModel.reservoirLevel > 0 {
            return guidanceColors.warning
        }

        return guidanceColors.critical
    }

    var connectionStatusText: some View {
        if viewModel.isConnected {
            return Text(LocalizedString("Connected", comment: "label for connected"))
        }

        if viewModel.isReconnecting {
            return Text(LocalizedString("Reconnecting...", comment: "label for reconnecting"))
        }

        return Text(LocalizedString("Disconnected", comment: "label for disconnected"))
    }

    var connectionStatusIcon: some View {
        let color = viewModel.isReconnecting ? Color.orange : viewModel.isConnected ? Color.green : Color.red

        return Circle()
            .fill(color)
            .frame(width: 10, height: 10)
    }

    var deliverySectionTitle: String {
        switch viewModel.basalType {
        case .active:
            return LocalizedString("Scheduled Basal", comment: "Title of insulin delivery section")
        case .tempBasal:
            return LocalizedString("Temp Basal", comment: "Pump Event title for UnfinalizedDose with doseType of .tempBasal")
        case .suspended:
            return LocalizedString("Insulin Delivery", comment: "Title of insulin delivery section")
        }
    }
}
