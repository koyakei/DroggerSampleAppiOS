//
//  MapView.swift
//  DroggerSampleAppiOS
//
//  Created by keisuke koyanagi on 2025/09/03.
//
import SwiftUI
import MapKit

struct MapView: View {
    @StateObject var bluetoothModel :BluetoothModel

    var body: some View {
        Map() {
            Marker("目印", coordinate: bluetoothModel.clLocatiionCoordinate2D)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

