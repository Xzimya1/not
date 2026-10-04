import Foundation

enum SleepStage: String, CaseIterable, Codable {
    case awake = "Awake"
    case light = "Light"
    case deep = "Deep"
    case rem = "REM"

    var title: String { rawValue }
}

struct SleepEpoch: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let heartRate: Double
    let rmssd: Double
    let movement: Double
    let respiration: Double
    let stage: SleepStage

    init(id: UUID = UUID(), timestamp: Date, heartRate: Double, rmssd: Double, movement: Double, respiration: Double, stage: SleepStage) {
        self.id = id
        self.timestamp = timestamp
        self.heartRate = heartRate
        self.rmssd = rmssd
        self.movement = movement
        self.respiration = respiration
        self.stage = stage
    }
}

struct SleepSummary {
    var durationHours: Double
    var quality: Int
    var deepPercent: Double
    var remPercent: Double
    var awakeMinutes: Double
    var averageHeartRate: Double
}
