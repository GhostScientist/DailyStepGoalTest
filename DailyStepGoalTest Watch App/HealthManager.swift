//
//  HealthManager.swift
//  DailyStepGoalTest Watch App
//
//  Created by Dakota Kim on 9/21/23.
//

import HealthKit

class HealthManager: ObservableObject {
    private var healthStore: HKHealthStore?

    @Published var steps: Int = 0

    init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
        }
    }

    func requestAuthorization() {
        // Ensure the health store is available.
        guard let healthStore = healthStore else { return }

        // The type of data we're requesting.
        let stepsQuantityType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        
        healthStore.requestAuthorization(toShare: [], read: [stepsQuantityType]) { success, error in
            if success {
                self.fetchTodaySteps()
            } else if let error = error {
                print("Error requesting HealthKit authorization: \(error)")
            }
        }
    }

    func fetchTodaySteps() {
        guard let healthStore = healthStore,
              let stepsQuantityType = HKObjectType.quantityType(forIdentifier: .stepCount) else { return }
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepsQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            
            guard let result = result, let sum = result.sumQuantity() else {
                print("Failed to fetch steps: \(error?.localizedDescription ?? "No error provided")")
                return
            }
            
            DispatchQueue.main.async {
                self.steps = Int(sum.doubleValue(for: HKUnit.count()))
            }
        }
        
        healthStore.execute(query)
    }
}
