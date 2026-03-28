import Foundation
import LoopKit

class MedtrumDoseProgressReporter: DoseProgressTimerEstimator {
    override var progress: DoseProgress {
        let elapsed = -dose.startDate.timeIntervalSinceNow
        let duration = dose.estimatedEndDate.timeIntervalSince(dose.startDate)
        let percentComplete = min(elapsed / duration, 1)
        let delivered = pumpManager.roundToSupportedBolusVolume(units: percentComplete * dose.value)
        return DoseProgress(deliveredUnits: delivered, percentComplete: percentComplete)
    }

    private let dose: UnfinalizedDose
    private let pumpManager: MedtrumPumpManager

    public init(pumpManager: MedtrumPumpManager, dose: UnfinalizedDose, reportingQueue: DispatchQueue) {
        self.pumpManager = pumpManager
        self.dose = dose

        super.init(reportingQueue: reportingQueue)
    }

    override func timerParameters() -> (delay: TimeInterval, repeating: TimeInterval) {
        let timeSinceStart = dose.startDate.timeIntervalSinceNow
        let timeBetweenPulses = TimeInterval.seconds(2)
        let delayUntilNextPulse = timeBetweenPulses - timeSinceStart.remainder(dividingBy: timeBetweenPulses)

        return (delay: delayUntilNextPulse, repeating: timeBetweenPulses)
    }
}
