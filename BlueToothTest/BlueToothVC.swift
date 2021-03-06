//
//  BlueToothVC.swift
//  CoreBlueTest
//
//  Created by Jhen Mu on 2022/1/25.
//

import UIKit
import CoreBluetooth

class BlueToothVC: UIViewController,CBCentralManagerDelegate,CBPeripheralDelegate {
    
    let blueToothView = BlueToothView()
    
    let C001_CHARACTERISTIC = "C001"
    
    var centralManager:CBCentralManager!
    
    var connectPeripheral:CBPeripheral!
    
    var charDictionary = [String:CBCharacteristic]()

    //MARK:-LifeCycle
    
    override func loadView() {
        super.loadView()
        view = blueToothView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "CoreBlue"
        setTextField()
        setButton()
        let queue = DispatchQueue.global()
        var centralManager = CBCentralManager(delegate: self, queue: queue)
    }
    
    //MARK:-Methods
    enum SendDataError:Error{
        case CharacteristicNotFound
    }
    
    private func sendData(_ data:Data,uuidString:String,writeType:CBCharacteristicWriteType) throws{
        guard let characteristic = charDictionary[uuidString] else {
            throw SendDataError.CharacteristicNotFound
        }
        connectPeripheral.writeValue(data, for: characteristic, type: writeType)
    }
    
    func setSwitch(){
        blueToothView.switchButton.isOn = false
    }
    
    private func setTextField(){
        blueToothView.textField.delegate = self
        blueToothView.textField.resignFirstResponder()
        blueToothView.textView.delegate = self
    }
    
    private func setButton(){
        blueToothView.sendButton.addTarget(self, action: #selector(send), for: .touchDown)
    }
    
    @objc func send(){
        let string = blueToothView.textField.text ?? ""
        if blueToothView.textView.text.isEmpty{
            blueToothView.textView.text = string
            blueToothView.textField.text = ""
        }else{
            blueToothView.textView.text = blueToothView.textView.text + "\n" + string
            blueToothView.textField.text = ""
        }
        do {
            let data = string.data(using: .utf8)
            try sendData(data!, uuidString: C001_CHARACTERISTIC, writeType: .withResponse)
            }catch{
            print(error)
        }
    }
    
    //MARK:-1.??????????????????????????????
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard  central.state == .poweredOn else {
            return
        }
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    //MARK:-2.???????????????peripheral
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard let deviceName = peripheral.name else {
            return
        }
        print("??????????????????")
        guard deviceName.range(of:"??????ABC??????") != nil || deviceName.range(of: "MacBook") != nil else {
            return
        }
        
        central.stopScan()
        connectPeripheral = peripheral
        connectPeripheral.delegate = self
        centralManager.connect(connectPeripheral, options: nil)
    }
    //MARK:-3.??????????????????peripheral??????????????????
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        charDictionary = [:]
        peripheral.discoverServices(nil)
    }
    
    //MARK:-4.??????????????????service??????????????????
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else {
            print("Error:\(#function)")
            print(error!.localizedDescription)
            return
        }
        for service in peripheral.services!{
            connectPeripheral.discoverCharacteristics(nil, for: service)
        }
    }
    //MARK:-5.?????????characteristic?????????charDictionary???????????????
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else {
            print("Error:\(#function)")
            print(error!.localizedDescription)
            return
        }
        for characteristic in service.characteristics!{
            let uuidString = characteristic.uuid.uuidString
            charDictionary[uuidString] = characteristic
            print("?????????\(uuidString)")
        }
    }
    //MARK:-6.????????????peripheral????????????
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        if error != nil{
            print("?????????????????????\(error!)")
        }
    }
    //MARK:-7.??????peripheral??????????????????
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            print("Error:\(#function)")
            print("error!")
            return
        }
        if characteristic.uuid.uuidString == C001_CHARACTERISTIC{
            let data = characteristic.value! as NSData
            let string = "> " + String(data: data as Data, encoding: .utf8)!
            print(string)
            
            DispatchQueue.main.async {
                if self.blueToothView.textView.text.isEmpty{
                    self.blueToothView.textView.text = string
                }else{
                    self.blueToothView.textView.text = self.blueToothView.textView.text + "\n" + string
                }
            }
        }
    }
}

extension BlueToothVC:UITextFieldDelegate,UITextViewDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}

