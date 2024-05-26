//
//  BreathTimer.swift
//  Heart Beat Breath Watch App
//
//  Created by Shan Havilah on 22/05/24.
//

import SwiftUI
import UserNotifications

struct BreathTimer: View {
    
    @State var countdown:Bool = false
    @State var time = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var start = false
    @State var count = 0
    @State var minute = 0
    @State var second = 0
    @State var to : CGFloat = 0
    @State var alertPresented = false
    @State var navigateToContentView = false
    
    var body: some View {
        
        if navigateToContentView{
            ContentView()
        }
        else{
            if countdown {
                ZStack{
                    Color.white.opacity(0.06).edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                    ZStack{
                        Circle()
                            .trim(from: 0, to: 1)
                            .stroke(Color.white, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                            .frame(width: 100, height: 100)
                        
                        Circle()
                            .trim(from: 0, to: self.to)
                            .stroke(Color.red, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                            .frame(width: 100, height: 100)
                            .rotationEffect(.init(degrees: -90))
                        
                        VStack{
                            let twoDigit = String(format: "%02d", self.second)
                            Text("\(self.minute):\(twoDigit)")
                                .font(.system(size: 25))
                                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        }
                    }
                    
                }
                .onReceive(self.time) { (_) in
                    if self.start{
                        if self.count != 300{
                            self.count += 1
                            if self.second + 1 == 60{
                                self.minute += 1
                                self.second = -1
                            }
                            self.second += 1
                        
                            withAnimation(.default){
                                self.to = CGFloat(self.count) / 300
                            }
                        }
                        
                        if self.count == 300 {
                            self.start.toggle()
                            self.notify()
                            self.alertPresented.toggle()
                            WKInterfaceDevice.current().play(.success)
                        }
                    }
                    else{
                        self.to = 0
                    }
                }
                .alert(isPresented: $alertPresented) {
                    Alert(
                        title: Text("Well Done!"),
                        message: Text("Thank you for resting, now continue your activity!"),
                        dismissButton: .default(Text("Back"), action: {
                                                    navigateToContentView = true
                                                })
                        
                    )
                }
            } else {
                Countdown()
                .onAppear{
                    Task {
                        try? await Task.sleep(for: .seconds(3))
                        countdown = true
                        start = true
                    }
                }
            }
        }
    }
    
    func notify(){
        let content = UNMutableNotificationContent()
        content.title = "Rest Time is Over!"
        content.body = "Great job! Finish your set!"
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error adding notification: \(error)")
            }
        }
    }
}

#Preview {
    BreathTimer()
}
