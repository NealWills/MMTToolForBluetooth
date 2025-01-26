import Foundation 
import CoreBluetooth

/// A class that provides tools for interacting with Bluetooth devices.
/// 
/// This class is part of the MMTToolForBluetooth module and is designed to facilitate
/// communication and operations with Bluetooth devices.
/// 
/// - Note: This class inherits from `NSObject`.
public class MMTToolForBleDevice: NSObject {
    
    enum ConnectStatus {
        case disconnected
        case connecting
        case connected
    }

    /// The connection status of the Bluetooth device.
    /// 
    /// This property holds the current connection status of the Bluetooth device.
    /// It is of type `ConnectStatus` and is initialized to `.disConnect`.
    ///
    /// - Note: The `ConnectStatus` enum should define the possible states of the connection.
    var connectStatus: ConnectStatus = .disconnected
    
    /// The `CBPeripheral` instance representing the Bluetooth peripheral device.
    var peripheral: CBPeripheral
    
    /// A string representing the universally unique identifier (UUID) of the Bluetooth device.
    var uuid: String
    
    /// The name of the Bluetooth device.
    /// This property is optional and can be nil if the device name is not available.
    var deviceName: String?
    
    /// The received signal strength indicator (RSSI) value for the Bluetooth device.
    /// This value represents the signal strength in decibels (dBm).
    /// It is an optional integer, which means it can be `nil` if the RSSI value is not available.
    var rssi: Int?
    
    /// The MAC address of the Bluetooth device.
    /// This property is optional and may be `nil` if the MAC address is not available.
    var mac: String?
    
    /// A variable to store additional information related to the MAC address of the Bluetooth device.
    var macExtra: String?
    
    /// A dictionary containing the advertisement data of the Bluetooth device.
    /// The keys are `String` representing the type of advertisement data, and the values are `AnyObject` representing the data itself.
    /// This property is optional and may be `nil` if no advertisement data is available.
    var advertisementData: [String: AnyObject]?
    
    /// A variable to store the timestamp.
    /// 
    /// This variable holds a `TimeInterval` value representing the timestamp.
    /// The default value is set to 0.
    var timestamp: TimeInterval = 0
    /// A weak reference to the `CBCentralManager` instance.
    /// This property is used to manage Bluetooth-related tasks.
    /// The weak reference helps to avoid retain cycles and memory leaks.
    /// 
    weak var manager: CBCentralManager?
    
    /// Initializes a new instance of `MMTToolForBleDevice` with the specified peripheral and manager.
    ///
    /// - Parameters:
    ///   - peripheral: The `CBPeripheral` instance representing the Bluetooth peripheral device.
    ///   - manager: An optional `CBCentralManager` instance managing the Bluetooth connection.
    init(peripheral: CBPeripheral, manager: CBCentralManager?) {
        self.peripheral = peripheral
        self.uuid = peripheral.identifier.uuidString.lowercased()
        super.init()
        peripheral.delegate = self
    }

    /**
     Updates the Bluetooth device with the provided advertisement data.
     
     - Parameter advertisementData: A dictionary containing the advertisement data. The keys are `String` and the values are `AnyObject`.
     */
    func update(advertisementData: [String: AnyObject]?) {
        self.advertisementData = advertisementData
        // self.deviceName = peripheral.name
        // self.mac = peripheral.identifier.UUIDString
        // self.macExtra = peripheral.identifier.UUIDString
    }

    /// Updates the RSSI (Received Signal Strength Indicator) value for the Bluetooth device.
    ///
    /// - Parameter rssi: An optional integer representing the RSSI value. If `nil`, the RSSI value is not updated.
    func update(rssi: Int?) {
        self.rssi = rssi
    }

}


/// Extension for the `MMTToolForBleDevice` class.
/// This extension provides additional functionality specific to Bluetooth device operations.
extension MMTToolForBleDevice {
    
    /// Establishes a connection to the Bluetooth device.
    /// 
    /// This method initiates the process of connecting to a Bluetooth device.
    /// It handles the necessary steps to establish a connection and ensures
    /// that the device is ready for communication.
    func connect() {
        self.connectStatus = .connecting
        self.manager?.connect(self.peripheral)
    }
    
    /// Disconnects the Bluetooth device.
    ///
    /// This method terminates the connection with the currently connected Bluetooth device.
    /// It ensures that any ongoing communication is properly closed and resources are released.
    ///
    /// - Note: Make sure to handle any necessary cleanup or state updates after calling this method.
    func disconnect() {
        self.manager?.cancelPeripheralConnection(self.peripheral)
        self.connectStatus = .disconnected
    }
}


extension MMTToolForBleDevice: CBPeripheralDelegate {
    
    
    /**
     *  @method peripheralDidUpdateName:
     *
     *  @param peripheral    The peripheral providing this update.
     *
     *  @discussion            This method is invoked when the @link name @/link of <i>peripheral</i> changes.
     */
    func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        MMTLog.debug.log("[MMTToolForBleDevice \(self.mac)] peripheralDidUpdateName \(peripheral.name)")
    }

    /**
     *  @method peripheral:didModifyServices:
     *
     *  @param peripheral            The peripheral providing this update.
     *  @param invalidatedServices    The services that have been invalidated
     *
     *  @discussion            This method is invoked when the @link services @/link of <i>peripheral</i> have been changed.
     *                        At this point, the designated <code>CBService</code> objects have been invalidated.
     *                        Services can be re-discovered via @link discoverServices: @/link.
     */
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        MMTLog.debug.log("[MMTToolForBleDevice \(self.mac)] didModifyServices")
    }

    /**
     *  @method peripheralDidUpdateRSSI:error:
     *
     *  @param peripheral    The peripheral providing this update.
     *    @param error        If an error occurred, the cause of the failure.
     *
     *  @discussion            This method returns the result of a @link readRSSI: @/link call.
     *
     *  @deprecated            Use {@link peripheral:didReadRSSI:error:} instead.
     */
    func peripheralDidUpdateRSSI(_ peripheral: CBPeripheral, error: (any Error)?) {
        MMTLog.debug.log("[MMTToolForBleDevice \(self.mac)] peripheralDidUpdateRSSI")
        peripheral.readRSSI()
    }

    /**
     *  @method peripheral:didReadRSSI:error:
     *
     *  @param peripheral    The peripheral providing this update.
     *  @param RSSI            The current RSSI of the link.
     *  @param error        If an error occurred, the cause of the failure.
     *
     *  @discussion            This method returns the result of a @link readRSSI: @/link call.
     */
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: (any Error)?) {
        MMTLog.debug.log("[MMTToolForBleDevice \(self.mac)] didReadRSSI")
        self.update(rssi: RSSI.intValue)
    }

    /**
     *  @method peripheral:didDiscoverServices:
     *
     *  @param peripheral    The peripheral providing this information.
     *    @param error        If an error occurred, the cause of the failure.
     *
     *  @discussion            This method returns the result of a @link discoverServices: @/link call. If the service(s) were read successfully, they can be retrieved via
     *                        <i>peripheral</i>'s @link services @/link property.
     *
     */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        MMTLog.debug.log("[MMTToolForBleDevice \(self.mac)] didDiscoverServices")
    }

    /**
     *  @method peripheral:didDiscoverIncludedServicesForService:error:
     *
     *  @param peripheral    The peripheral providing this information.
     *  @param service        The <code>CBService</code> object containing the included services.
     *    @param error        If an error occurred, the cause of the failure.
     *
     *  @discussion            This method returns the result of a @link discoverIncludedServices:forService: @/link call. If the included service(s) were read successfully,
     *                        they can be retrieved via <i>service</i>'s <code>includedServices</code> property.
     */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: (any Error)?) {
        MMTLog.debug.log("[MMTToolForBleDevice \(self.mac)] didDiscoverIncludedServicesFor \(service)")
    }

    /**
     *  @method peripheral:didDiscoverCharacteristicsForService:error:
     *
     *  @param peripheral    The peripheral providing this information.
     *  @param service        The <code>CBService</code> object containing the characteristic(s).
     *    @param error        If an error occurred, the cause of the failure.
     *
     *  @discussion            This method returns the result of a @link discoverCharacteristics:forService: @/link call. If the characteristic(s) were read successfully,
     *                        they can be retrieved via <i>service</i>'s <code>characteristics</code> property.
     */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        MMTLog.debug.log("[MMTToolForBleDevice \(self.mac)] didDiscoverCharacteristicsFor \(service)")
    }

    /**
     *  @method peripheral:didUpdateValueForCharacteristic:error:
     *
     *  @param peripheral        The peripheral providing this information.
     *  @param characteristic    A <code>CBCharacteristic</code> object.
     *    @param error            If an error occurred, the cause of the failure.
     *
     *  @discussion                This method is invoked after a @link readValueForCharacteristic: @/link call, or upon receipt of a notification/indication.
     */
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        MMTLog.debug.log("[MMTToolForBleDevice \(self.mac)] didUpdateValueFor \(characteristic)")
    }

    /**
     *  @method peripheral:didWriteValueForCharacteristic:error:
     *
     *  @param peripheral        The peripheral providing this information.
     *  @param characteristic    A <code>CBCharacteristic</code> object.
     *    @param error            If an error occurred, the cause of the failure.
     *
     *  @discussion                This method returns the result of a {@link writeValue:forCharacteristic:type:} call, when the <code>CBCharacteristicWriteWithResponse</code> type is used.
     */
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        MMTLog.debug.log("[MMTToolForBleDevice \(self.mac)] didWriteValueFor \(characteristic)")
    }

    /**
     *  @method peripheral:didUpdateNotificationStateForCharacteristic:error:
     *
     *  @param peripheral        The peripheral providing this information.
     *  @param characteristic    A <code>CBCharacteristic</code> object.
     *    @param error            If an error occurred, the cause of the failure.
     *
     *  @discussion                This method returns the result of a @link setNotifyValue:forCharacteristic: @/link call.
     */
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: (any Error)?) {
        MMTLog.debug.log("[MMTToolForBleDevice \(self.mac)] didUpdateNotificationStateFor \(characteristic)")
    }

    /**
     *  @method peripheral:didDiscoverDescriptorsForCharacteristic:error:
     *
     *  @param peripheral        The peripheral providing this information.
     *  @param characteristic    A <code>CBCharacteristic</code> object.
     *    @param error            If an error occurred, the cause of the failure.
     *
     *  @discussion                This method returns the result of a @link discoverDescriptorsForCharacteristic: @/link call. If the descriptors were read successfully,
     *                            they can be retrieved via <i>characteristic</i>'s <code>descriptors</code> property.
     */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: (any Error)?) {
        MMTLog.debug.log("[MMTToolForBleDevice \(self.mac)] didDiscoverDescriptorsFor \(characteristic)")
    }

    /**
     *  @method peripheral:didUpdateValueForDescriptor:error:
     *
     *  @param peripheral        The peripheral providing this information.
     *  @param descriptor        A <code>CBDescriptor</code> object.
     *    @param error            If an error occurred, the cause of the failure.
     *
     *  @discussion                This method returns the result of a @link readValueForDescriptor: @/link call.
     */
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: (any Error)?) {
        MMTLog.debug.log("[MMTToolForBleDevice \(self.mac)] didUpdateValueFor \(descriptor)")
    }

    /**
     *  @method peripheral:didWriteValueForDescriptor:error:
     *
     *  @param peripheral        The peripheral providing this information.
     *  @param descriptor        A <code>CBDescriptor</code> object.
     *    @param error            If an error occurred, the cause of the failure.
     *
     *  @discussion                This method returns the result of a @link writeValue:forDescriptor: @/link call.
     */
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: (any Error)?) {
        MMTLog.debug.log("[MMTToolForBleDevice \(self.mac)] didWriteValueFor \(descriptor)")
    }

    /**
     *  @method peripheralIsReadyToSendWriteWithoutResponse:
     *
     *  @param peripheral   The peripheral providing this update.
     *
     *  @discussion         This method is invoked after a failed call to @link writeValue:forCharacteristic:type: @/link, when <i>peripheral</i> is again
     *                      ready to send characteristic value updates.
     *
     */
    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
        MMTLog.debug.log("[MMTToolForBleDevice \(self.mac)] peripheralIsReady")
    }

    /**
     *  @method peripheral:didOpenL2CAPChannel:error:
     *
     *  @param peripheral        The peripheral providing this information.
     *  @param channel            A <code>CBL2CAPChannel</code> object.
     *    @param error            If an error occurred, the cause of the failure.
     *
     *  @discussion                This method returns the result of a @link openL2CAPChannel: @link call.
     */
    func peripheral(_ peripheral: CBPeripheral, didOpen channel: CBL2CAPChannel?, error: (any Error)?) {
        MMTLog.debug.log("[MMTToolForBleDevice \(self.mac)] didOpen channel \(channel)")
    }
    
}
