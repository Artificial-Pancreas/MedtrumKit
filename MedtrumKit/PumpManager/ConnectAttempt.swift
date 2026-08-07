import Foundation

/// One connect attempt: the caller waiting on it, and the deadline that guarantees they hear
/// back. Connect, disconnect, timeout and the auth flow all race to report a result, so the
/// attempt owns which of them wins rather than each site checking for itself.
final class ConnectAttempt {
    let completion: (MedtrumConnectError?) -> Void
    var timeout: Task<Void, Never>?
    private var reported = false

    /// When the deadline currently in flight was armed. `Task.sleep` does not advance while iOS has
    /// the app suspended, so a timeout that wakes far past its budget never actually spent it
    /// waiting - see `BluetoothManager.startTimeout`.
    var armedAt: Date = .now

    static let maxExtensions = 2

    /// How many times a deadline may still be re-armed after waking up suspended. Bounded so the
    /// attempt always terminates, even if the app keeps getting suspended.
    var remainingExtensions = ConnectAttempt.maxExtensions

    init(_ completion: @escaping (MedtrumConnectError?) -> Void) {
        self.completion = completion
    }

    /// True for the first caller only - whoever gets it owns reporting the result.
    func claim() -> Bool {
        guard !reported else {
            return false
        }

        reported = true
        timeout?.cancel()
        timeout = nil

        return true
    }
}
