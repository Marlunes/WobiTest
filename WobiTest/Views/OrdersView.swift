//
//  OrdersView.swift
//  WobiTest
//
//  Created by Marlon Boncodin on 12/31/25.
//

import SwiftUI

struct OrdersView: View {

    @StateObject var viewModel: OrdersViewModel

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Orders")
                .onAppear {
                    Task {
                        await viewModel.loadOrders()
                    }
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading, .idle:
            ProgressView()

        case .empty:
            Text("No orders available")

        case .failed(let message):
            VStack {
                Text(message)
                Button("Retry") {
                    Task { await viewModel.loadOrders() }
                }
            }

        case .loaded(let orders):
            List(viewModel.filteredOrders(from: orders)) { order in
                NavigationLink(destination: OrderDetailView(order: order)) {
                    HStack {
                        Text(order.title)
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Text(order.status.getName())
                            .font(.subheadline)
                            .foregroundColor(order.status.getColor())
                    }
                }
            }
        }
    }
}
