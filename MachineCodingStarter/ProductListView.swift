import SwiftUI

struct ProductListView: View {
    @StateObject var vm: ProductListViewModel

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading && vm.products.isEmpty {
                    ProgressView()
                } else if let error = vm.errorMessage, vm.products.isEmpty {
                    ContentUnavailableView {
                        Label("Error", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(error)
                    } actions: {
                        Button("Retry") { Task { await vm.load(reset: true) } }
                    }
                } else if vm.products.isEmpty {
                    ContentUnavailableView("No products", systemImage: "bag")
                } else {
                    List(vm.products) { product in
                        NavigationLink {
                            ProductDetailView(product: product, vm: vm)
                        } label: {
                            HStack {
                                AsyncImage(url: product.thumbnail.flatMap(URL.init)) { image in
                                    image.resizable()
                                } placeholder: {
                                    Color.secondary.opacity(0.15)
                                }
                                .frame(width: 56, height: 56)
                                .clipShape(.rect(cornerRadius: 8))
                                VStack(alignment: .leading) {
                                    Text(product.title).font(.headline).lineLimit(1)
                                    Text(product.price, format: .currency(code: "USD"))
                                }
                                Spacer()
                                Button { vm.toggleFav(product) } label: {
                                    Image(systemName: vm.isFav(product) ? "heart.fill" : "heart")
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .task {
                            if product.id == vm.products.last?.id { await vm.loadMore() }
                        }
                    }
                }
            }
            .navigationTitle("Products")
            .searchable(text: $vm.searchText)
            .onChange(of: vm.searchText) { _, _ in vm.searchChanged() }
            .refreshable { await vm.load(reset: true) }
            .task { await vm.load(reset: true) }
        }
    }
}

struct ProductDetailView: View {
    let product: Product
    @ObservedObject var vm: ProductListViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                AsyncImage(url: product.thumbnail.flatMap(URL.init)) { image in
                    image.resizable()
                } placeholder: {
                    Color.secondary.opacity(0.15)
                }
                .frame(height: 200)
                Text(product.title).font(.title2.bold())
                Text(product.description)
                Button(vm.isFav(product) ? "Unfavorite" : "Favorite") {
                    vm.toggleFav(product)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .navigationTitle("Details")
    }
}
