import CoreBluetooth
import Foundation

public class MMTToolForBleManager: NSObject {

    static let shared = MMTToolForBleManager()
    var centralManager: CBCentralManager?
    var queue: dispatch_queue_t?
    var scanPrefix: String?
    var scanList: [String: MMTToolForBleDevice] = [:]
    var connectList: [String: MMTToolForBleDevice] = [:]

    public class func configManager() {
        shared.queue = DispatchQueue(label: "com.mmt.ble.queue")
        shared.centralManager = CBCentralManager(delegate: shared, queue: shared.queue)
    }
}

extension CBManagerState {
    var debugStrValue: String {
        switch self {
        case .unknown:
            return "unknown"
        case .resetting:
            return "resetting"
        case .unsupported:
            return "unsupported"
        case .unauthorized:
            return "unauthorized"
        case .poweredOff:
            return "poweredOff"
        case .poweredOn:
            return "poweredOn"
        }
    }
}

extension MMTToolForBleManager {
    
    class func startScan(perfix: String? = nil) {
        MMTToolForBleManager.shared.scanPrefix = nil
        MMTToolForBleManager.shared.scanList.removeAll()
        MMTToolForBleManager.shared.centralManager?.scanForPeripherals(withServices: nil)
    }
    
    class func stopScan() {
        MMTToolForBleManager.shared.centralManager?.stopScan()
    }
    
}

extension MMTToolForBleManager {
    
    class func connect(device: MMTToolForBleDevice) {
        let uuid = device.uuid
        
        if let device = MMTToolForBleManager.shared.connectList[uuid] {
            if device.connectStatus != .disconnected { return }
        }
        if let device = MMTToolForBleManager.shared.scanList[uuid] {
            MMTToolForBleManager.shared.scanList.removeValue(forKey: uuid)
            MMTToolForBleManager.shared.connectList[uuid] = device
            device.connect()
        }
    }
    
    class func disconnect(device: MMTToolForBleDevice) {
        let uuid = device.uuid
        device.disconnect()
        MMTToolForBleManager.shared.scanList.removeValue(forKey: uuid)
        MMTToolForBleManager.shared.connectList.removeValue(forKey: uuid)
    }
}

extension MMTToolForBleManager: CBCentralManagerDelegate {
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        MMTLog.debug.log("[MMTToolForBleManager] \(central.state.debugStrValue)")
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        MMTLog.debug.log("[MMTToolForBleManager] didConnectPeripheral")
        let uuid = peripheral.identifier.uuidString
        if let device = MMTToolForBleManager.shared.connectList[uuid] {
            device.connectStatus = .connected
        }
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        MMTLog.debug.log("[MMTToolForBleManager] didFailToConnectPeripheral")
        let uuid = peripheral.identifier.uuidString
        if let device = MMTToolForBleManager.shared.connectList[uuid] {
            device.connectStatus = .disconnected
        }
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        MMTLog.debug.log("[MMTToolForBleManager] didDisconnectPeripheral")
        let uuid = peripheral.identifier.uuidString
        if let device = MMTToolForBleManager.shared.connectList[uuid] {
            device.connectStatus = .disconnected
        }
    }

    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        MMTLog.debug.log("[MMTToolForBleManager] didDiscoverPeripheral")
        let device = MMTToolForBleDevice(peripheral: peripheral, manager: central)
        if let perfix = MMTToolForBleManager.shared.scanPrefix, perfix.count > 0 {
            let mac = device.mac ?? ""
            let deviceName = device.deviceName ?? ""
            let uuid = device.uuid ?? ""
            if !mac.hasPrefix(perfix) && !deviceName.hasPrefix(perfix) && !uuid.hasPrefix(perfix) {
                return 
            }
        }
        if let oldDevice = MMTToolForBleManager.shared.scanList[device.uuid] {
            oldDevice.update(rssi: RSSI.intValue)
            oldDevice.update(advertisementData: advertisementData)
            oldDevice.timestamp = Date().timeIntervalSince1970
        } else {
            device.update(rssi: RSSI.intValue)
            device.update(advertisementData: advertisementData)
            device.timestamp = Date().timeIntervalSince1970
            MMTToolForBleManager.shared.connectList[device.uuid] = device
        }
    }

    
}
