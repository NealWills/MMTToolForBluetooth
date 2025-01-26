import Foundation 
import CoreBluetooth

class MMTToolForBleDevice: NSObject {
    
    var peripheral: CBPeripheral
    var characteristic: CBCharacteristic?
    var deviceName: String?
    var rssi: Int?
    var mac: String?
    var macExtra: String?
    var advertisementData: [String: AnyObject]?
    
    init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
    }

    func update(advertisementData: [String: AnyObject]?) {
        self.advertisementData = advertisementData
        // self.deviceName = peripheral.name
        // self.mac = peripheral.identifier.UUIDString
        // self.macExtra = peripheral.identifier.UUIDString
    }

    func update(rssi: Int?) {
        self.rssi = rssi
    }


}