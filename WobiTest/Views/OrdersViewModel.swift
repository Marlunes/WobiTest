//
//  OrdersViewModel.swift
//  WobiTest
//
//  Created by Marlon Boncodin on 12/31/25.
//

import Foundation

enum ViewStatusLoadable<T: Equatable>: Equatable {
    case idle
    case loading
    case loaded(T)
    case empty
    case failed(String)
}

@MainActor
final class OrdersViewModel: ObservableObject {

    @Published private(set) var state: ViewStatusLoadable<[Order]> = .idle
    @Published var filter: OrderStatus?

    private let repository: OrderRepository

    init(repository: OrderRepository) {
        self.repository = repository
    }

    func loadOrders() async {
        state = .loading
        do {
            let orders = try await repository.fetchOrders()
            state = orders.isEmpty ? .empty : .loaded(orders)
        } catch {
            state = .failed("Failed to load orders")
        }
    }

    func filteredOrders(from orders: [Order]) -> [Order] {
        guard let filter else { return orders }
        return orders.filter { $0.status == filter }
    }
}
