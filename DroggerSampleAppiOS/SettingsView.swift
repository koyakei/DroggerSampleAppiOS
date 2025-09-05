//
//  SettingView.swift
//  DroggerSampleAppiOS
//
//  Created by keisuke koyanagi on 2025/09/03.
//
import SwiftUI

struct SettingsView: View {
    @StateObject var bluetoothModel :BluetoothModel
    @State var ssid: String = ""
    @State var password: String = ""
    
    var body: some View {
        VStack{
            Text("wifi setting 接続先")
            TextField("SSID", text: $ssid)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button("接続"){
                bluetoothModel.setWifiSetting(ssid: ssid, password: password)
            }
            Text("接続遅延秒数 \(String(describing: bluetoothModel.age))")
        }.tabItem {
            Label("setting", systemImage: "gear")
        }
    }
}
