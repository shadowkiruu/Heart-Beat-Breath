

import HealthKit
import UserNotifications

class HeartRateManager: ObservableObject {
    @Published var heartRate: Double = 0.0
    let healthStore = HKHealthStore()
    
    init() {
        requestHeartRatePermission()
    }
    
    func requestHeartRatePermission() {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let typesToRead: Set = [heartRateType]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { (success, error) in
            if success {
                self.startHeartRateDetection()
            } else {
                print("Failed to request authorization for heart rate")
            }
        }
    }
    
    func startHeartRateDetection() {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            return
        }
        
        let query = HKObserverQuery(sampleType: heartRateType, predicate: nil) { (query, completionHandler, error) in
            if let error = error {
                print("Failed to query heart rate: \(error.localizedDescription)")
                return
            }
            
            self.fetchLatestHeartRate { heartRate in
                DispatchQueue.main.async {
                    self.heartRate = heartRate
//                    if self.heartRate > 50{
//                        self.sendNotification(heartRate: heartRate)
//                    }
                }
            }
            completionHandler()
        }
        
        healthStore.execute(query)
        healthStore.enableBackgroundDelivery(for: heartRateType, frequency: .immediate) { (success, error) in
            if success {
                print("Enabled background delivery for heart rate")
            } else {
                print("Failed to enable background delivery for heart rate")
            }
        }
    }
    
    func fetchLatestHeartRate(completion: @escaping (Double) -> Void) {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            return
        }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            if let error = error {
                print("Failed to query heart rate: \(error.localizedDescription)")
                completion(0.0)
                return
            }
            
            if let heartRateSample = samples?.first as? HKQuantitySample {
                let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
                let heartRate = heartRateSample.quantity.doubleValue(for: heartRateUnit)
                DispatchQueue.main.async {
                    self.heartRate = heartRate
                    if self.heartRate > 100{
                        self.sendNotification(heartRate: heartRate)
                    }
                }
                completion(heartRate)
            } else {
                completion(0.0)
            }
        }
        
        healthStore.execute(query)
    }
    
    func sendNotification(heartRate: Double) {
        
        let content = UNMutableNotificationContent()
        content.title = "High Heart Rate Alert"
        content.body = "Your heart rate is \(heartRate) BPM, which is above the normal limit."
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

