import CoreBluetooth
import Foundation

class MMTToolForBleManager: NSObject {

    static let shared = MMTToolForBleManager()
    var centralManager: CBCentralManager?
    var queue: dispatch_queue_t?
    var scanPrefix: String?
    var scanList: [MMTToolForBleDevice] = []
    var connectList: [MMTToolForBleDevice] = []

    class func configManager() {
        shared.queue = dispatch_queue_create("com.mmt.ble.queue", DISPATCH_QUEUE_SERIAL)
        shared.centralManager = CBCentralManager(delegate: shared, queue: shared.queue)
    }
    
    class func startScan(perfix: String? = nil) {
        self.scanPrefix = nil
        scanList.removeAll()
        shared.centralManager?.scanForPeripheralsWithServices(nil, options: nil)
    }
}

extension MMTToolForBleManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch central.state {
        case .PoweredOn:
            print("蓝牙已打开")
        case .PoweredOff:
            print("蓝牙已关闭")
        case .Resetting:
            print("蓝牙重置中")
        case .Unauthorized:
            print("蓝牙未授权")
        case .Unknown:
            print("蓝牙未知状态")
        case .Unsupported:
            print("蓝牙不支持")
        }
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("连接成功")
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("连接失败")
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("断开连接")
    }

    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        print("发现外设")
    }

    
}