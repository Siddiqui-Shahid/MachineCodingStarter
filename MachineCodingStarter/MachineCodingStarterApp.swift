import SwiftUI

@main
struct MachineCodingStarterApp: App {
    private let container = AppContainer()

    var body: some Scene {
        WindowGroup {
            ProductListView(vm: container.makeProductListViewModel())
        }
    }
}
