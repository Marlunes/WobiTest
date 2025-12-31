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

        case let .loaded(orders):
            VStack {
                HStack {
                    Button("Pending") {
                        if viewModel.filter == .pending {
                            viewModel.filter = nil
                        } else {
                            viewModel.filter = .pending
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.all, 12)
                    .background {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(viewModel.filter == .pending ? Color.red : Color.gray)
                    }
                    
                    Button("In transit") {
                        if viewModel.filter == .inTransit {
                            viewModel.filter = nil
                        } else {
                            viewModel.filter = .inTransit
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.all, 12)
                    .background {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(viewModel.filter == .inTransit ? Color.blue : Color.gray)
                    }
                    
                    Button("Delivered") {
                        if viewModel.filter == .delivered {
                            viewModel.filter = nil
                        } else {
                            viewModel.filter = .delivered
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.all, 12)
                    .background {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(viewModel.filter == .delivered ? Color.green : Color.gray)
                    }
                }
                
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
}
