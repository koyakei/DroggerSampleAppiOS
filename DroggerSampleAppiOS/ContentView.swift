//
//  ContentView.swift
//  DroggerSampleAppiOS
//
//  Copyright 2024 BizStation Corp.
//

import SwiftUI

struct ContentView: View {
    @StateObject var bluetoothModel = BluetoothModel()
    var body: some View {
        TabView {
            HomeView(bluetoothModel: bluetoothModel)
            SettingsView(bluetoothModel: bluetoothModel)
            MapView(bluetoothModel: bluetoothModel)
        }
    }
}

#Preview {
    ContentView()
}

