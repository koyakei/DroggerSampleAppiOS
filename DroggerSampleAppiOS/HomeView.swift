//
//  HomeVIew.swift
//  DroggerSampleAppiOS
//
//  Created by keisuke koyanagi on 2025/09/03.
//
import SwiftUI

struct HomeView: View {
    @StateObject var bluetoothModel :BluetoothModel
    @State private var enableToUpdateOutputText = true
    var body: some View {
        VStack(alignment: .leading) {
            Text("RWS iOS Sample App")
                .font(.largeTitle)
                .padding(.bottom, 12)
            HStack () {
                Label("Device", systemImage: "info.circle")
                    .labelStyle(.automatic)
                    .padding(.bottom, 12)
                Spacer()
                Text(bluetoothModel.peripheralStatus.rawValue)
            }
            Text(bluetoothModel.deviceDetail)
                .font(.system(size: 10, design: .monospaced))
                .textSelection(.enabled)
            Divider()
                .padding(.top, 12)
                .padding(.bottom, 12)
            HStack () {
                Label("Output", systemImage: "scroll")
                    .labelStyle(.automatic)
                    .padding(.bottom, 12)
                Spacer()
                Toggle("Update", isOn: $enableToUpdateOutputText)
                    .frame(width: 120)
                    .onChange(of: enableToUpdateOutputText) {
                        bluetoothModel.enableToUpdateOutputText = enableToUpdateOutputText
                    }
            }
            Text(bluetoothModel.output)
                .font(.system(size: 10, design: .monospaced))
                .textSelection(.enabled)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(12)
        .tabItem {
            Label("ホーム", systemImage: "house")
        }
    }
}
