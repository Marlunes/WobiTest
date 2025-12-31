//
//  Order.swift
//  WobiTest
//
//  Created by Marlon Boncodin on 12/31/25.
//

import Foundation
import SwiftUICore

enum OrderStatus: String, CaseIterable {
    case pending = "PENDING"
    case inTransit = "IN_TRANSIT"
    case delivered = "DELIVERED"
    
    func getName() -> String {
        switch self {
            case .pending:
                return "Pending"
            case .inTransit:
                return "In Transit"
            case .delivered:
                return "Delivered"
        }
    }
    
    func getColor() -> Color {
        switch self {
            case .pending:
                return .red
            case .inTransit:
                return .blue
            case .delivered:
                return .green
        }
    }
}

struct Order: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let status: OrderStatus
}


