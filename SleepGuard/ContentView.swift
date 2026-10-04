import SwiftUI
import Charts

struct ContentView: View {
    @EnvironmentObject private var model: SleepGuardModel
    @State private var showingExportAlert = false

    var body: some View {
        NavigationSplitView {
            List {
                Section("SleepGuard") {
                    Label("Dashboard", systemImage: "moon.zzz.fill")
                    Label("Devices", systemImage: "wave.3.right")
                    Label("History", systemImage: "calendar")
                }
                Section("Session") {
                    Button(model.isDemoRunning ? "Stop demo" : "Start demo") { model.toggleDemo() }
                    Button("Clear session", role: .destructive) { model.clearSession() }
                }
            }
            .navigationSplitViewColumnWidth(min: 190, ideal: 220)
        } detail: {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    summaryCards
                    sleepChart
                    controls
                    epochTable
                }
                .padding(24)
            }
            .background(.background)
        }
        .alert("CSV exported", isPresented: $showingExportAlert) {
            Button("OK") { }
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("SleepGuard")
                    .font(.largeTitle.bold())
                Text("Sleep monitoring & smart awakening — macOS MVP")
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Circle()
                .fill(model.isDemoRunning ? .green : .gray)
                .frame(width: 12, height: 12)
            Text(model.isDemoRunning ? "Monitoring" : "Idle")
                .foregroundStyle(.secondary)
        }
    }

    private var summaryCards: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            MetricCard(title: "Sleep quality", value: "\(model.summary.quality)%", icon: "star.fill")
            MetricCard(title: "Duration", value: String(format: "%.1fh", model.summary.durationHours), icon: "clock.fill")
            MetricCard(title: "Avg HR", value: "\(Int(model.summary.averageHeartRate)) bpm", icon: "heart.fill")
            MetricCard(title: "Deep / REM", value: String(format: "%.0f%% / %.0f%%", model.summary.deepPercent, model.summary.remPercent), icon: "moon.fill")
        }
    }

    private var sleepChart: some View {
        GroupBox("Sleep stages") {
            if model.epochs.isEmpty {
                ContentUnavailableView("No sleep data", systemImage: "chart.xyaxis.line", description: Text("Start the demo stream or connect a BLE device."))
                    .frame(height: 260)
            } else {
                Chart(model.epochs) { epoch in
                    LineMark(x: .value("Time", epoch.timestamp), y: .value("Heart rate", epoch.heartRate))
                        .interpolationMethod(.catmullRom)
                }
                .chartYScale(domain: 45...95)
                .frame(height: 260)
                .padding(8)
            }
        }
    }

    private var controls: some View {
        HStack(alignment: .top, spacing: 16) {
            GroupBox("Smart Wake") {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Target")
                        Spacer()
                        DatePicker("", selection: wakeDateBinding, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                    HStack {
                        Text("Window")
                        Spacer()
                        Stepper("\(model.wakeWindowMinutes) min", value: $model.wakeWindowMinutes, in: 5...60, step: 5)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            GroupBox("Lamp") {
                VStack(alignment: .leading, spacing: 10) {
                    Toggle("Lamp enabled", isOn: $model.lampOn)
                    Text(model.lampOn ? "Wake light is simulated as ON" : "Wake light is OFF")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            GroupBox("Bluetooth") {
                VStack(alignment: .leading, spacing: 10) {
                    Text(model.bluetooth.state)
                        .foregroundStyle(.secondary)
                    Button(model.bluetooth.isScanning ? "Stop scan" : "Scan for bracelet") {
                        model.bluetooth.isScanning ? model.bluetooth.stopScan() : model.bluetooth.startScan()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var epochTable: some View {
        GroupBox("Recent 30-second epochs") {
            VStack(spacing: 0) {
                HStack {
                    Text("Time").frame(maxWidth: .infinity, alignment: .leading)
                    Text("HR").frame(width: 70, alignment: .trailing)
                    Text("RMSSD").frame(width: 80, alignment: .trailing)
                    Text("Movement").frame(width: 90, alignment: .trailing)
                    Text("Stage").frame(width: 90, alignment: .trailing)
                }
                .font(.caption.bold())
                .padding(.vertical, 8)
                Divider()
                ForEach(model.epochs.suffix(12).reversed()) { epoch in
                    HStack {
                        Text(epoch.timestamp, style: .time).frame(maxWidth: .infinity, alignment: .leading)
                        Text("\(Int(epoch.heartRate))").frame(width: 70, alignment: .trailing)
                        Text(String(format: "%.1f", epoch.rmssd)).frame(width: 80, alignment: .trailing)
                        Text(String(format: "%.2f", epoch.movement)).frame(width: 90, alignment: .trailing)
                        Text(epoch.stage.rawValue).frame(width: 90, alignment: .trailing)
                    }
                    .font(.caption)
                    .padding(.vertical, 6)
                    Divider()
                }
                HStack {
                    Spacer()
                    Button("Export CSV") {
                        _ = model.exportCSV()
                        showingExportAlert = true
                    }
                }
                .padding(.top, 10)
            }
        }
    }

    private var wakeDateBinding: Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(from: DateComponents(hour: model.wakeHour, minute: model.wakeMinute)) ?? Date()
            },
            set: { date in
                let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
                model.wakeHour = comps.hour ?? 7
                model.wakeMinute = comps.minute ?? 30
            }
        )
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        GroupBox {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                VStack(alignment: .leading) {
                    Text(title).font(.caption).foregroundStyle(.secondary)
                    Text(value).font(.title3.bold())
                }
                Spacer()
            }
        }
    }
}
