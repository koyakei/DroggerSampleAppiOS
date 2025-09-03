//
//  SettingView.swift
//  DroggerSampleAppiOS
//
//  Created by keisuke koyanagi on 2025/09/03.
//
import SwiftUI

struct SettingsView: View {
    @StateObject var bluetoothModel :BluetoothModel
    
    var body: some View {
        VStack{
            Text("SettingView")
        }.tabItem {
            Label("setting", systemImage: "house")
        }
    }
}
