//
//  MockRepo.swift
//  WobiTest
//
//  Created by Marlon Boncodin on 12/31/25.
//

import Foundation


protocol OrderRepository {
    func fetchOrders() async throws -> [Order]
}

final class MockRepo: OrderRepository {

    enum Mode {
        case success
        case empty
        case failure
        case delayed
    }

    private let mode: Mode

    init(mode: Mode) {
        self.mode = mode
    }

    func fetchOrders() async throws -> [Order] {
        if mode == .delayed {
            try await Task.sleep(nanoseconds: 1_000_000_000)
        }

        switch mode {
        case .success, .delayed:
            return [
                Order(title: "Order #1", status: .pending),
                Order(title: "Order #2", status: .inTransit),
                Order(title: "Order #3", status: .delivered),
                Order(title: "Order #4", status: .delivered),
                Order(title: "Order #5", status: .inTransit),
                Order(title: "Order #6", status: .pending),
                Order(title: "Order #7", status: .pending),
                Order(title: "Order #8", status: .pending),
                Order(title: "Order #9", status: .inTransit),
                Order(title: "Order #10", status: .pending)
            ]
        case .empty:
            return []
        case .failure:
            throw NSError(domain: "MockError", code: 1)
        }
    }
}
