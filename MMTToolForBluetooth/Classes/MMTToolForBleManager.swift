import CoreBluetooth
import Foundation

/// A manager class for handling Bluetooth operations in the MMTToolForBluetooth module.
/// 
/// This class provides various functionalities to manage Bluetooth connections and data transfer.
/// 
/// - Note: This class inherits from `NSObject`.
public class MMTToolForBleManager: NSObject {

    /// A singleton instance of `MMTToolForBleManager`.
    /// 
    /// This shared instance provides a global point of access to the `MMTToolForBleManager` class,
    /// ensuring that only one instance of the manager is created and used throughout the application.
    static let shared = MMTToolForBleManager()

    /// The central manager instance responsible for managing Bluetooth low energy (BLE) connections and interactions.
    /// This property is optional and may be nil if the central manager has not been initialized.
    /// - Note: Ensure that the central manager is properly initialized before attempting to use it.
    var centralManager: CBCentralManager?
    
    /// A dispatch queue used for managing Bluetooth-related tasks.
    /// This queue is optional and can be nil if not initialized.
    /// - Note: Ensure to initialize this queue before using it to avoid unexpected behavior.
    var queue: dispatch_queue_t?
    
    /// A variable to store the prefix used for scanning Bluetooth devices.
    /// This can be used to filter devices based on their name prefix during the scanning process.
    var scanPrefix: String?
    
    /// A dictionary that holds the list of scanned Bluetooth devices.
    /// The keys are the device identifiers as strings, and the values are `MMTToolForBleDevice` objects.
    var scanList: [String: MMTToolForBleDevice] = [:]
    
    /// A dictionary that maintains a list of connected Bluetooth devices.
    /// The keys are the device identifiers as `String`, and the values are instances of `MMTToolForBleDevice`.
    var connectList: [String: MMTToolForBleDevice] = [:]

    /**
     Configures the Bluetooth manager.

     This method sets up the necessary configurations for the Bluetooth manager to function properly.
     */
    public class func configManager() {
        shared.queue = DispatchQueue(label: "com.mmt.ble.queue")
        shared.centralManager = CBCentralManager(delegate: shared, queue: shared.queue)
    }
}

/// Extension for `CBManagerState` to add additional functionality or properties.
/// `CBManagerState` is an enumeration that describes the possible states of a Core Bluetooth manager.
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

/// Extension for `MMTToolForBleManager` class to add additional functionalities or to organize code better.
/// This extension might include methods, properties, or other functionalities that are related to Bluetooth management.
/// This extension is part of the MMTToolForBluetooth module.
extension MMTToolForBleManager {
    
    /**
     Starts scanning for Bluetooth devices.

     - Parameter perfix: An optional string to filter devices by prefix. If `nil`, all devices will be scanned.
     */
    class func startScan(perfix: String? = nil) {
        MMTToolForBleManager.shared.scanPrefix = nil
        MMTToolForBleManager.shared.scanList.removeAll()
        MMTToolForBleManager.shared.centralManager?.scanForPeripherals(withServices: nil)
    }
    
    /**
     Stops the ongoing Bluetooth scan.
     
     This method should be called to halt any active scanning for Bluetooth devices.
     */
    class func stopScan() {
        MMTToolForBleManager.shared.centralManager?.stopScan()
    }
    
}

/// Extension for `MMTToolForBleManager` to add additional functionalities or to organize code better.
/// This extension is part of the MMTToolForBluetooth module.
extension MMTToolForBleManager {
    
    /**
     Connects to the specified Bluetooth device.

     - Parameter device: The `MMTToolForBleDevice` instance representing the Bluetooth device to connect to.
     */
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
    
    /**
     Disconnects the specified Bluetooth device.

     - Parameter device: The `MMTToolForBleDevice` instance representing the Bluetooth device to disconnect.
     */
    class func disconnect(device: MMTToolForBleDevice) {
        let uuid = device.uuid
        device.disconnect()
        MMTToolForBleManager.shared.scanList.removeValue(forKey: uuid)
        MMTToolForBleManager.shared.connectList.removeValue(forKey: uuid)
    }
}

/**
 This extension conforms `MMTToolForBleManager` to the `CBCentralManagerDelegate` protocol.
 
 `CBCentralManagerDelegate` is a protocol that defines the methods that a delegate of a `CBCentralManager` object must adopt. 
 The methods of the protocol allow the delegate to monitor the discovery, connectivity, and retrieval of peripheral devices.
 
 By conforming to this protocol, `MMTToolForBleManager` can handle Bluetooth-related events such as discovering, connecting, and disconnecting from Bluetooth peripherals.
 */
extension MMTToolForBleManager: CBCentralManagerDelegate {
    
    /**
     Called when the central manager's state is updated.
     
     - Parameter central: The central manager whose state has been updated.
     */
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        MMTLog.debug.log("[MMTToolForBleManager] \(central.state.debugStrValue)")
    }
    
    /**
     * Called when a connection is successfully made to a peripheral.
     *
     * - Parameters:
     *   - central: The central manager providing this information.
     *   - peripheral: The peripheral that has connected.
     */
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        MMTLog.debug.log("[MMTToolForBleManager] didConnectPeripheral")
        let uuid = peripheral.identifier.uuidString
        if let device = MMTToolForBleManager.shared.connectList[uuid] {
            device.connectStatus = .connected
        }
    }
    
    /**
     Called when the central manager fails to connect to a peripheral.

     - Parameters:
       - central: The central manager providing this information.
       - peripheral: The peripheral that failed to connect.
       - error: An optional error object containing details about why the connection failed.
     */
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        MMTLog.debug.log("[MMTToolForBleManager] didFailToConnectPeripheral")
        let uuid = peripheral.identifier.uuidString
        if let device = MMTToolForBleManager.shared.connectList[uuid] {
            device.connectStatus = .disconnected
        }
    }
    
    /**
     Called when a peripheral device disconnects from the central manager.
     
     - Parameters:
       - central: The central manager providing this information.
       - peripheral: The peripheral that was disconnected.
       - error: An optional error object containing details of the disconnection, if any.
     */
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        MMTLog.debug.log("[MMTToolForBleManager] didDisconnectPeripheral")
        let uuid = peripheral.identifier.uuidString
        if let device = MMTToolForBleManager.shared.connectList[uuid] {
            device.connectStatus = .disconnected
        }
    }

    /**
     Called when a peripheral is discovered during a scan.

     - Parameters:
       - central: The central manager that discovered the peripheral.
       - peripheral: The discovered peripheral.
       - advertisementData: A dictionary containing any advertisement data.
       - RSSI: The received signal strength indicator (RSSI) of the peripheral.
     */
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
