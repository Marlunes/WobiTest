//
//  WobiTestApp.swift
//  WobiTest
//
//  Created by Marlon Boncodin on 12/31/25.
//

import SwiftUI

@main
struct WobiTestApp: App {
    var body: some Scene {
        WindowGroup {
            OrdersView(viewModel: OrdersViewModel(repository: MockRepo(mode: .success)))
        }
    }
}
