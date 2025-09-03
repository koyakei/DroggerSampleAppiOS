//
//  MapView.swift
//  DroggerSampleAppiOS
//
//  Created by keisuke koyanagi on 2025/09/03.
//
import SwiftUI
import MapKit

struct MapView: View {
    var bluetoothModel :BluetoothModel
    
    @State private var position = MapCameraPosition.region(
            MKCoordinateRegion(
                center: .init(),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        )

    var body: some View {
        Map() {
            Marker("目印", coordinate: bluetoothModel.clLocatiionCoordinate2D)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

