import Foundation

final class SleepEngine {
    func classify(heartRate: Double, rmssd: Double, movement: Double, respiration: Double) -> SleepStage {
        if movement > 0.72 || heartRate > 82 { return .awake }
        if rmssd > 52 && movement < 0.22 { return .deep }
        if respiration > 15.5 && movement < 0.35 { return .rem }
        return .light
    }

    func summary(for epochs: [SleepEpoch]) -> SleepSummary {
        guard !epochs.isEmpty else {
            return SleepSummary(durationHours: 0, quality: 0, deepPercent: 0, remPercent: 0, awakeMinutes: 0, averageHeartRate: 0)
        }

        let total = Double(epochs.count) * 30.0
        let deep = Double(epochs.filter { $0.stage == .deep }.count) * 30.0
        let rem = Double(epochs.filter { $0.stage == .rem }.count) * 30.0
        let awake = Double(epochs.filter { $0.stage == .awake }.count) * 30.0
        let avgHR = epochs.map(\.heartRate).reduce(0, +) / Double(epochs.count)

        let qualityRaw = 100.0
            - (awake / 60.0) * 2.0
            + min(deep / total, 0.30) * 40.0
            + min(rem / total, 0.30) * 25.0
        let quality = max(0, min(100, Int(qualityRaw.rounded())))

        return SleepSummary(
            durationHours: total / 3600.0,
            quality: quality,
            deepPercent: deep / total * 100,
            remPercent: rem / total * 100,
            awakeMinutes: awake / 60.0,
            averageHeartRate: avgHR
        )
    }
}
