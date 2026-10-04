import Foundation
import CoreBluetooth

final class BluetoothManager: NSObject, ObservableObject {
    @Published private(set) var state: String = "Not connected"
    @Published private(set) var isScanning = false
    @Published private(set) var discoveredNames: [String] = []

    private var central: CBCentralManager!
    private var peripherals: [UUID: CBPeripheral] = [:]

    override init() {
        super.init()
        central = CBCentralManager(delegate: self, queue: .main)
    }

    func startScan() {
        guard central.state == .poweredOn else {
            state = "Bluetooth unavailable"
            return
        }
        discoveredNames.removeAll()
        isScanning = true
        state = "Scanning..."
        central.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
    }

    func stopScan() {
        central.stopScan()
        isScanning = false
        if state == "Scanning..." { state = "Scan stopped" }
    }
}

extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn: state = "Bluetooth ready"
        case .poweredOff: state = "Bluetooth is off"
        case .unauthorized: state = "Bluetooth permission denied"
        case .unsupported: state = "Bluetooth unsupported"
        case .resetting: state = "Bluetooth resetting"
        default: state = "Bluetooth unavailable"
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        peripherals[peripheral.identifier] = peripheral
        let name = peripheral.name ?? "Unnamed device"
        if !discoveredNames.contains(name) {
            discoveredNames.append(name)
        }
    }
}
