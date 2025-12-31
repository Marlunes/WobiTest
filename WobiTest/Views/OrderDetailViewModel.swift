//
//  OrderDetailViewModel.swift
//  WobiTest
//
//  Created by Marlon Boncodin on 12/31/25.
//

import Foundation

@MainActor
final class OrderDetailViewModel: ObservableObject {

    @Published private(set) var order: Order
    @Published private(set) var status: OrderStatus
    @Published var elapsedTime: Int = 0
    private var isRunning = false

    init(order: Order) {
        self.order = order
        self.status = order.status
        
        switch status {
        case .pending:
            elapsedTime = 0
        case .inTransit:
            elapsedTime = 31
        case .delivered:
            elapsedTime = 121
        }
        
        if status != .delivered {
            simulateProgress()
        }
    }


    func simulateProgress() {
        guard !isRunning else { return }
        isRunning = true

        Task {
            while isRunning && elapsedTime <= 121 { // stop at 2 min 1 sec
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                elapsedTime += 1
                updateStatus()
                if elapsedTime >= 121 {
                    stopTimer()
                }
            }
            isRunning = false
        }
    }

    func stopTimer() {
        isRunning = false
    }

    private func updateStatus() {
        switch elapsedTime {
        case 0...30:
            status = .pending
        case 31...120:
            status = .inTransit
        default:
            status = .delivered
        }
    }
}
