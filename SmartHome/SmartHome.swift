//
//  SmartHome.swift
//  SmartHome
//
//  Created by Bhumika Patel on 11/01/25.
//

import SwiftUI

struct SmartHomeView: View {
    @State private var isLightOn: Bool = true
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("Smart Home")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
                Button(action: {
                    // Action for settings
                }) {
                    Image(systemName: "gearshape")
                        .font(.title)
                        .foregroundColor(.primary)
                }
            }
            .padding()

            // Main Device Control
            VStack(spacing: 20) {
                Text(isLightOn ? "Light On" : "Light Off")
                    .font(.title)
                    .fontWeight(.semibold)
                
                ZStack {
                    Circle()
                        .fill(isLightOn ? Color.yellow.opacity(0.5) : Color.gray.opacity(0.2))
                        .frame(width: 200, height: 200)
                    
                    Button(action: {
                        withAnimation {
                            isLightOn.toggle()
                        }
                    }) {
                        Image(systemName: isLightOn ? "lightbulb.fill" : "lightbulb")
                            .font(.system(size: 80))
                            .foregroundColor(isLightOn ? .yellow : .gray)
                    }
                }
            }

            Spacer()

            // Other Controls
            HStack(spacing: 20) {
                DeviceControl(icon: "thermometer", label: "Temperature")
                DeviceControl(icon: "fanblades", label: "Fan")
                DeviceControl(icon: "tv", label: "TV")
            }
            .padding()

            Spacer()
        }
        .padding()
    }
}

struct DeviceControl: View {
    let icon: String
    let label: String

    var body: some View {
        VStack {
            Button(action: {
                // Action for device control
            }) {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: icon)
                            .font(.title)
                            .foregroundColor(.blue)
                    )
            }
            Text(label)
                .font(.caption)
                .foregroundColor(.primary)
        }
    }
}

struct SmartHomeView_Previews: PreviewProvider {
    static var previews: some View {
        SmartHomeView()
    }
}
