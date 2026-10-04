import Foundation
import Combine

@MainActor
final class SleepGuardModel: ObservableObject {
    @Published var epochs: [SleepEpoch] = []
    @Published var isDemoRunning = false
    @Published var lampOn = false
    @Published var wakeHour = 7
    @Published var wakeMinute = 30
    @Published var wakeWindowMinutes = 30
    @Published var bluetooth = BluetoothManager()

    private let engine = SleepEngine()
    private var timer: Timer?

    var summary: SleepSummary { engine.summary(for: epochs) }

    func toggleDemo() {
        isDemoRunning ? stopDemo() : startDemo()
    }

    func startDemo() {
        guard !isDemoRunning else { return }
        isDemoRunning = true
        if epochs.isEmpty { generateDemo(count: 240) }
        timer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in self.appendDemoEpoch() }
        }
    }

    func stopDemo() {
        isDemoRunning = false
        timer?.invalidate()
        timer = nil
    }

    func clearSession() {
        stopDemo()
        epochs.removeAll()
    }

    private func generateDemo(count: Int) {
        let start = Date().addingTimeInterval(-Double(count) * 30)
        for index in 0..<count {
            let phase = Double(index) / Double(max(count - 1, 1))
            let hr = 58 + 4 * sin(phase * .pi * 5) + Double.random(in: -2...2)
            let rmssd = 38 + 22 * (1 - phase) + Double.random(in: -7...7)
            let movement = max(0, min(1, 0.12 + 0.12 * sin(phase * .pi * 8) + Double.random(in: 0...0.15)))
            let respiration = 13.2 + 1.8 * sin(phase * .pi * 4) + Double.random(in: -0.5...0.5)
            let stage = engine.classify(heartRate: hr, rmssd: rmssd, movement: movement, respiration: respiration)
            epochs.append(SleepEpoch(timestamp: start.addingTimeInterval(Double(index) * 30), heartRate: hr, rmssd: rmssd, movement: movement, respiration: respiration, stage: stage))
        }
    }

    private func appendDemoEpoch() {
        let i = epochs.count
        let hr = 60 + 5 * sin(Double(i) / 8) + Double.random(in: -2...2)
        let rmssd = 48 + 12 * sin(Double(i) / 15) + Double.random(in: -5...5)
        let movement = max(0, min(1, Double.random(in: 0.03...0.28)))
        let respiration = 13.5 + Double.random(in: -1.2...1.2)
        let stage = engine.classify(heartRate: hr, rmssd: rmssd, movement: movement, respiration: respiration)
        epochs.append(SleepEpoch(timestamp: Date(), heartRate: hr, rmssd: rmssd, movement: movement, respiration: respiration, stage: stage))
        if epochs.count > 720 { epochs.removeFirst() }
    }

    func exportCSV() -> URL? {
        guard !epochs.isEmpty else { return nil }
        var csv = "timestamp,heart_rate,rmssd,movement,respiration,stage\n"
        let formatter = ISO8601DateFormatter()
        for e in epochs {
            csv += "\(formatter.string(from: e.timestamp)),\(String(format: "%.2f", e.heartRate)),\(String(format: "%.2f", e.rmssd)),\(String(format: "%.3f", e.movement)),\(String(format: "%.2f", e.respiration)),\(e.stage.rawValue)\n"
        }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("SleepGuard-session.csv")
        do {
            try csv.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch { return nil }
    }
}
