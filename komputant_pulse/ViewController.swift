//
//  ViewController.swift
//  komputant_pulse
//
//  Created by Abdullah Merei on 2020-04-01.
//  Copyright © 2020 Komputant Inc. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {

    @IBOutlet weak var statusLbl: UILabel!
    
    @IBOutlet weak var confLbl: UILabel!
    
    @IBOutlet weak var pulseLbl: UILabel!
    
    @IBOutlet weak var oxygenLbl: UILabel!
    
    var centralManager: CBCentralManager!
    
    var heartRatePeripheral: CBPeripheral!
    
    let heartRateMeasurementCharacteristicCBUUID = CBUUID(string: "18B10001-E8F2-537E-4F6C-D104768A1216")
    let statCharacteristicCBUUID = CBUUID(string: "18B10001-E8F2-537E-4F6C-D104768A1214")
    let confCharacteristicCBUUID = CBUUID(string: "18B10001-E8F2-537E-4F6C-D104768A1215")
    let oxygenCharacteristicCBUUID = CBUUID(string: "18B10001-E8F2-537E-4F6C-D104768A1217")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        
        
    }


}

extension ViewController: CBCentralManagerDelegate{
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {

        case .unknown:
          print("central.state is .unknown")
        case .resetting:
          print("central.state is .resetting")
        case .unsupported:
          print("central.state is .unsupported")
        case .unauthorized:
          print("central.state is .unauthorized")
        case .poweredOff:
          print("central.state is .poweredOff")
        case .poweredOn:
          print("central.state is .poweredOn")
          let heartRateServiceCBUUID = CBUUID(string: "18B10000-E8F2-537E-4F6C-D104768A1214")
          centralManager.scanForPeripherals(withServices: [heartRateServiceCBUUID])
        @unknown default:
            print("unknown")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if(peripheral.name == "Arduino")
        {
            print(peripheral)
            heartRatePeripheral = peripheral
            heartRatePeripheral.delegate = self
            centralManager.stopScan()
            centralManager.connect(heartRatePeripheral)
        }
    }
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected!")
        heartRatePeripheral.discoverServices(nil)
    }
    
    
}

extension ViewController: CBPeripheralDelegate
{
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }

        for service in services {
          print(service)
            peripheral.discoverCharacteristics(nil, for: service)
            
         
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }

        for characteristic in characteristics {
          print(characteristic)
            
            if characteristic.properties.contains(.read) {
              print("\(characteristic.uuid): properties contains .read")
                peripheral.readValue(for: characteristic)
            }
            if characteristic.properties.contains(.notify) {
              print("\(characteristic.uuid): properties contains .notify")
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        switch characteristic.uuid {
          case heartRateMeasurementCharacteristicCBUUID:
           guard let characteristicData = characteristic.value,
            let byte = characteristicData.first
            else{
                print("failed")
                return
           }
            pulseLbl.text = String(byte) + " bpm"
            
            print(String(byte))
            
            case statCharacteristicCBUUID:
                
            
            
             statusLbl.text = status(from: characteristic)
             
             //print(String(byte))
             
            case confCharacteristicCBUUID:
            guard let characteristicData = characteristic.value,
             let byte = characteristicData.first
             else{
                 print("failed")
                 return
            }
             confLbl.text = String(byte) + " %"
             
             print(String(byte))
             
            
            case oxygenCharacteristicCBUUID:
            guard let characteristicData = characteristic.value,
             let byte = characteristicData.first
             else{
                 print("failed")
                 return
            }
             oxygenLbl.text = String(byte) + " %"
             
             print(String(byte))
             
            
          
          default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
    }
    
    private func status(from characteristic: CBCharacteristic) -> String {
      guard let characteristicData = characteristic.value,
        let byte = characteristicData.first else { return "Error" }

      switch byte {
        case 0: return "Success"
        case 7: return "Not Ready"
        case 1: return "Object Detected"
        case 2: return "Excessive Sensor Device Motion"
        case 3: return "No object detected"
        case 4: return "Pressing too hard"
        case 5: return "Object other than finger detected"
      case 6: return "Excessive finger motion"
        default:
          return "Reserved for future use"
      }
    }
    
    
}
