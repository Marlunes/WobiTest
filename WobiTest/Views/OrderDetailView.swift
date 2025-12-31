//
//  OrderDetailView.swift
//  WobiTest
//
//  Created by Marlon Boncodin on 12/31/25.
//

import SwiftUI

struct OrderDetailView: View {

    @StateObject private var viewModel: OrderDetailViewModel

    init(order: Order) {
        _viewModel = StateObject(wrappedValue: OrderDetailViewModel(order: order))
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Order Status")
                .font(.headline)
                        
            Text(viewModel.status.getName())
                .font(.title)
                .foregroundColor(viewModel.status.getColor())
            
            ProgressView(value: Double(viewModel.elapsedTime),
                         total: 121)
               .progressViewStyle(LinearProgressViewStyle())
               .tint(viewModel.status.getColor())
               .padding(.horizontal, 24)
        }
        .padding()
    }
}
