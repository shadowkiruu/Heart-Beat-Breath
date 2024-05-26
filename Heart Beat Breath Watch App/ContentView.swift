//
//  ContentView.swift
//  Heart Beat Breath Watch App
//
//  Created by Shan Havilah on 22/05/24.
//

import SwiftUI
import UserNotifications

struct ContentView: View {
    @ObservedObject private var heartRateManager = HeartRateManager()

    var body: some View {
        NavigationStack {
            VStack {
                ZStack {
                    Image(systemName: "heart.fill")
                        .resizable()
                        .foregroundColor(.red)
                    .aspectRatio(contentMode: .fit)
                    
                    Text("\(String(format: "%.0f", heartRateManager.heartRate))")
                        .font(.system(size: 50))
                        .fontWeight(.medium)
                }
                
                Spacer().frame(height: 20)

                NavigationLink(destination: BreathTimer()
                                .navigationBarBackButtonHidden(true)) {
                    Text("Control Breath")
                        .font(.body)
                        .padding(8)
                }

            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}

