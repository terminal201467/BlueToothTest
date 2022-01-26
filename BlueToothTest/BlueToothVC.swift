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
    
    //MARK:-1.判斷藍芽電池是否開啟
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard  central.state == .poweredOn else {
            return
        }
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    //MARK:-2.取得連線的peripheral
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard let deviceName = peripheral.name else {
            return
        }
        print("找到藍芽裝置")
        guard deviceName.range(of:"我的ABC裝置") != nil || deviceName.range(of: "MacBook") != nil else {
            return
        }
        
        central.stopScan()
        connectPeripheral = peripheral
        connectPeripheral.delegate = self
        centralManager.connect(connectPeripheral, options: nil)
    }
    //MARK:-3.找到要連線的peripheral，掃描該設備
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        charDictionary = [:]
        peripheral.discoverServices(nil)
    }
    
    //MARK:-4.根據掃描到的service，進一步掃描
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
    //MARK:-5.找到的characteristic儲存到charDictionary字典物件中
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else {
            print("Error:\(#function)")
            print(error!.localizedDescription)
            return
        }
        for characteristic in service.characteristics!{
            let uuidString = characteristic.uuid.uuidString
            charDictionary[uuidString] = characteristic
            print("找到：\(uuidString)")
        }
    }
    //MARK:-6.資料傳到peripheral時會呼叫
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        if error != nil{
            print("寫入資料錯誤：\(error!)")
        }
    }
    //MARK:-7.取得peripheral送過來的資料
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

