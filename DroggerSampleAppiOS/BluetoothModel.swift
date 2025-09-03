//
//  BluetoothModel.swift
//  DroggerSampleAppiOS
//
//  Copyright 2024 BizStation Corp.
//

import Foundation
import CoreBluetooth
import SwiftUI
import CoreLocation

enum ConnectionStatus: String {
    case connected = "Connected"
    case disconncected = "Disconnected"
    case scanning = "Scanning..."
    case connecting = "Connecting..."
    case error = "Error"
}

struct Drogger{
    let droggerService = CBUUID(string: "0baba001-0000-1000-8000-00805f9b34fb")
    let droggerSerialDataCharactaristic = CBUUID(string: "0baba002-0000-1000-8000-00805f9b34fb")
    let droggerSerialWriteCharactaristic = CBUUID(string: "0baba003-0000-1000-8000-00805f9b34fb")
}

class BluetoothModel: NSObject, ObservableObject {
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral?
    private var outputs: [String] = []
    var enableToUpdateOutputText = true
    @Published var peripheralStatus: ConnectionStatus = .disconncected
    @Published var deviceDetail: String = ""
    @Published var output: String = ""
    @Published var clLocatiionCoordinate2D : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func scanForPeripherals() {
        peripheralStatus = .scanning
        centralManager.scanForPeripherals(withServices: nil)
    }
    
    func addOutput(string: String) {
        outputs.append(string)
        if (outputs.count > 40) {
            outputs.remove(at: 0)
        }
        if !enableToUpdateOutputText {
            return
        }
        self.output = self.outputs.joined(separator: "")
    }
}

extension BluetoothModel: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("Bluetooth powered on")
            scanForPeripherals()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover p: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        peripheralStatus = .connecting
        let name = p.name ?? "no name"
        print("Discovered \(name)")
        if !(name.starts(with: "RZS") || name.starts(with: "RWS") || name.starts(with: "DG-PRO1RWS")) {
            return
        }
        peripheral = p
        centralManager.connect(p)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect p: CBPeripheral) {
        print("Connected")
        peripheralStatus = .connected
        p.delegate = self
        p.discoverServices([Drogger().droggerService])
        centralManager.stopScan()
        self.deviceDetail = String(format: "\(p.name!): \(p.identifier)")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?) {
        peripheralStatus = .disconncected
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: (any Error)?) {
        peripheralStatus = .error
        print(error?.localizedDescription ?? "no error details")
    }
}

extension BluetoothModel: CBPeripheralDelegate {
    func peripheral(_ p: CBPeripheral, didDiscoverServices error: (any Error)?) {
        for service in p.services ?? [] {
            if service.uuid == Drogger().droggerService {
                p.discoverCharacteristics([Drogger().droggerSerialDataCharactaristic, Drogger().droggerSerialWriteCharactaristic], for: service)
            }
        }
    }
    
    func peripheral(_ p: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        for characteristic in service.characteristics ?? [] {
            p.setNotifyValue(true, for: characteristic)
            print("Found the charactaristic \(characteristic.uuid). Waiting for values")
        }
    }
    
    
    private func parseNMEALatLng(nmeaSentence: String) -> CLLocationCoordinate2D? {
        let parts = nmeaSentence.components(separatedBy: ",")
        guard parts.count > 6, parts[0].hasSuffix("GGA") else {
            return nil
        }
        let latRaw = parts[2]
        let latDirection = parts[3]
        let lonRaw = parts[4]
        let lonDirection = parts[5]
        
        // 緯度 (DDMM.MMMM) -> (度 + 分/60)
        if let latDegrees = Double(latRaw.prefix(2)), let latMinutes = Double(latRaw.suffix(latRaw.count - 2)),
           let lonDegrees = Double(lonRaw.prefix(3)), let lonMinutes = Double(lonRaw.suffix(lonRaw.count - 3)) {
            var latitude = latDegrees + latMinutes / 60.0
            var longitude = lonDegrees + lonMinutes / 60.0
            
            if latDirection == "S" {
                latitude = -latitude
            }
            if lonDirection == "W" {
                longitude = -longitude
            }
            
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        return nil
    }
    
    func peripheral(_ p: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        if characteristic.uuid == Drogger().droggerSerialDataCharactaristic {
            guard let data = characteristic.value else {
                print("No data received for SerialData");
                return
            }
            let str = String(decoding: data, as: UTF8.self)
            
            if let lanLat = parseNMEALatLng(nmeaSentence: str) {
                clLocatiionCoordinate2D = lanLat
            }
            addOutput(string: str)
            return
        }
        
        if characteristic.uuid == Drogger().droggerSerialWriteCharactaristic {
            print("Write characteristic");
            return
        }
        
        print("charactaristic \(characteristic.uuid) did not match.")
    }
}

