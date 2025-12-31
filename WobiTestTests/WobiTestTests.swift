//
//  WobiTestTests
//
//  Created by Marlon Boncodin on 12/31/25.
//

import XCTest
@testable import WobiTest

final class WobiTestTests: XCTestCase {

    // Test loading orders successfully
    func testLoadOrdersSuccess() async throws {
        let repository = MockRepo(mode: .success)
        let viewModel = await OrdersViewModel(repository: repository)

        await viewModel.loadOrders()

        switch await viewModel.state {
        case .loaded(let orders):
            XCTAssertEqual(orders.count, 10, "Expected 10 orders")
            XCTAssertEqual(orders[0].status, .pending, "First order should be pending")
        default:
            XCTFail("Expected loaded state, got \(await viewModel.state)")
        }
    }

    // Test empty orders
    func testLoadOrdersEmpty() async throws {
        let repository = MockRepo(mode: .empty)
        let viewModel = await OrdersViewModel(repository: repository)

        await viewModel.loadOrders()

        switch await viewModel.state {
        case .empty:
            XCTAssertTrue(true) // Passed
        default:
            XCTFail("Expected empty state, got \(await viewModel.state)")
        }
    }

    // Test failure scenario
    func testLoadOrdersFailure() async throws {
        let repository = MockRepo(mode: .failure)
        let viewModel = await OrdersViewModel(repository: repository)

        await viewModel.loadOrders()

        switch await viewModel.state {
        case .failed(let message):
            XCTAssertFalse(message.isEmpty, "Failure message should not be empty")
        default:
            XCTFail("Expected failed state, got \(await viewModel.state)")
        }
    }

    // Test filtering orders
    func testFilteringOrders() async throws {
        let repository = MockRepo(mode: .success)
        let viewModel = await OrdersViewModel(repository: repository)

        await viewModel.loadOrders()

        if case let .loaded(orders) = await viewModel.state {
            Task { @MainActor in
                viewModel.filter = .pending
            }
            let filtered = await viewModel.filteredOrders(from: orders)
            XCTAssertEqual(filtered.count, 5, "There should be 5 pending order")
            XCTAssertEqual(filtered[0].status, .pending, "Filtered order status should be pending")
        } else {
            XCTFail("Expected loaded state, got \(await viewModel.state)")
        }
    }
    
    //ORDER DETAILS
    
    func testInitialStatePending() async throws {
        let order = Order(title: "Test Order", status: .pending)
        let viewModel = await OrderDetailViewModel(order: order)

        await MainActor.run {
            XCTAssertEqual(viewModel.status, .pending)
            XCTAssertEqual(viewModel.elapsedTime, 0)
        }
    }

    func testInitialStateInTransit() async throws {
        let order = Order(title: "Test Order", status: .inTransit)
        let viewModel = await OrderDetailViewModel(order: order)

        await MainActor.run {
            XCTAssertEqual(viewModel.status, .inTransit)
            XCTAssertEqual(viewModel.elapsedTime, 31)
        }
    }

    func testInitialStateDelivered() async throws {
        let order = Order(title: "Test Order", status: .delivered)
        let viewModel = await OrderDetailViewModel(order: order)

        await MainActor.run {
            XCTAssertEqual(viewModel.status, .delivered)
            XCTAssertEqual(viewModel.elapsedTime, 121)
        }
    }

    func testStatusTransitionsOverTime() async throws {
        let order = Order(title: "Test Order", status: .pending)
        let viewModel = await OrderDetailViewModel(order: order)

        // Wait ~31 seconds for transition from pending -> inTransit
        for _ in 0..<31 {
            try await Task.sleep(nanoseconds: 1_000_000_000)
        }

        await MainActor.run {
            XCTAssertEqual(viewModel.status, .inTransit)
            XCTAssertGreaterThanOrEqual(viewModel.elapsedTime, 31)
        }
            
        // Wait ~90 more seconds to reach delivered
        for _ in 0..<90 {
            try await Task.sleep(nanoseconds: 1_000_000_000)
        }

        await MainActor.run {
            XCTAssertEqual(viewModel.status, .delivered)
            XCTAssertGreaterThanOrEqual(viewModel.elapsedTime, 121)
        }
    }

    func testStopTimerStopsProgress() async throws {
        let order = Order(title: "Test Order", status: .pending)
        let viewModel = await OrderDetailViewModel(order: order)

        // Wait a few seconds
        try await Task.sleep(nanoseconds: 3_000_000_000)
        await viewModel.stopTimer()
        let currentElapsed = await viewModel.elapsedTime

        // Wait more seconds and ensure elapsedTime did not increase
        try await Task.sleep(nanoseconds: 3_000_000_000)
        await MainActor.run {
            XCTAssertEqual(viewModel.elapsedTime, currentElapsed)
        }
    }
    
}
