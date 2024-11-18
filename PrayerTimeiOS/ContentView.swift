//
//  ContentView.swift
//  PrayerTimeiOS
//
//  Created by Md. Abu Sufian Sufi on 11/17/24.
//

import SwiftUI
import SwiftData
import Adhan
import CoreLocation

struct ContentView: View {
   
    @StateObject private var locationManager = LocationManager()
    @AppStorage("calculationMethod") private var calculationMethod = "Karachi"
    @AppStorage("madhab") private var madhab = "Hanafi"
    @AppStorage("highLatitudeRule") private var highLatitudeRule = "Middle of the Night"
    
    let calculationMethods = ["Karachi", "Muslim World League", "Egyptian", "North America", "Kuwait", "Qatar", "Singapore"]
    let madhabs = ["Hanafi", "Shafi"]
    let highLatitudeRules = ["Middle of the Night", "Seventh of the Night", "Twilight Angle"]
    
    var body: some View {
        NavigationStack {
            List {
                Section("Location") {
                    LocationView(locationManager: locationManager)
                }
                
                Section("Calculation Settings") {
                    Picker("Calculation Method", selection: $calculationMethod) {
                        ForEach(calculationMethods, id: \.self) { method in
                            Text(method).tag(method)
                        }
                    }
                    
                    Picker("Madhab", selection: $madhab) {
                        ForEach(madhabs, id: \.self) { madhab in
                            Text(madhab).tag(madhab)
                        }
                    }
                    
                    Picker("High Latitude Rule", selection: $highLatitudeRule) {
                        ForEach(highLatitudeRules, id: \.self) { rule in
                            Text(rule).tag(rule)
                        }
                    }
                }
                
                Section("Prayer Time Adjustments") {
                    AdjustmentRow(prayerName: "Fajr", adjustment: 0)
                    AdjustmentRow(prayerName: "Sunrise", adjustment: 0)
                    AdjustmentRow(prayerName: "Dhuhr", adjustment: 0)
                    AdjustmentRow(prayerName: "Asr", adjustment: 0)
                    AdjustmentRow(prayerName: "Maghrib", adjustment: 0)
                    AdjustmentRow(prayerName: "Isha", adjustment: 0)
                }
            }
            .navigationTitle("Prayer Settings")
        }
    }
}

struct AdjustmentRow: View {
    let prayerName: String
    @AppStorage private var adjustment: Int
    
    init(prayerName: String, adjustment: Int) {
        self.prayerName = prayerName
        self._adjustment = AppStorage(wrappedValue: adjustment, "\(prayerName.lowercased())Adjustment")
    }
    
    var body: some View {
        HStack {
            Text(prayerName)
            Spacer()
            Stepper("\(adjustment) min", value: $adjustment, in: -30...30)
        }
    }
}

struct LocationView: View {
    @ObservedObject var locationManager: LocationManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if locationManager.authorizationStatus == .denied {
                Text("Location access denied. Please enable in Settings.")
                    .foregroundColor(.red)
                Link("Open Settings", destination: URL(string: UIApplication.openSettingsURLString)!)
            } else {
                if let location = locationManager.location {
                    Text("Latitude: \(location.coordinate.latitude, specifier: "%.4f")")
                    Text("Longitude: \(location.coordinate.longitude, specifier: "%.4f")")
                } else {
                    Text("Location not available")
                        .foregroundColor(.gray)
                }
                
                Button(action: {
                    locationManager.requestLocation()
                }) {
                    Text("Update Location")
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
