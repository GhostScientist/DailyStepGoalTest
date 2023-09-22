//
//  ContentView.swift
//  DailyStepGoalTest Watch App
//
//  Created by Dakota Kim on 9/21/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var healthManager = HealthManager()

        var body: some View {
            VStack {
                Text("Steps Today")
                    .font(.headline)
                Text("\(healthManager.steps)")
                    .font(.largeTitle)
                Button("Update Steps") {
                    healthManager.fetchTodaySteps()
                }
            }
            .onAppear(perform: {
                healthManager.requestAuthorization()
            })
        }
}

#Preview {
    ContentView()
}
