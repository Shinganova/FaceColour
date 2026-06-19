import SwiftUI

/// "Shop your colors" — products matching the analysis, deep-linking out to retailers.
struct ShopView: View {
    let season: Season?
    let monkTone: Int?
    var service: any ProductService = ProductServiceFactory.make()

    @Environment(\.dismiss) private var dismiss
    @State private var phase: Phase = .loading

    enum Phase: Equatable {
        case loading
        case loaded([Product])
        case empty
        case failed(String)
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Shop your colors")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") { dismiss() }
                    }
                }
                .task { await load() }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch phase {
        case .loading:
            ProgressView("Finding your colors…")
        case .empty:
            ContentUnavailableView("No matches yet",
                                   systemImage: "bag",
                                   description: Text("We couldn't find products for this result."))
        case .failed(let message):
            ContentUnavailableView("Couldn't load shop",
                                   systemImage: "wifi.exclamationmark",
                                   description: Text(message))
        case .loaded(let products):
            List(products) { product in
                Link(destination: product.productURL) {
                    ProductRow(product: product)
                }
            }
        }
    }

    private func load() async {
        phase = .loading
        do {
            let products = try await service.products(season: season, monkTone: monkTone)
            phase = products.isEmpty ? .empty : .loaded(products)
        } catch {
            phase = .failed(error.localizedDescription)
        }
    }
}

private struct ProductRow: View {
    let product: Product

    var body: some View {
        HStack(spacing: 12) {
            thumbnail
                .frame(width: 52, height: 52)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(product.title).font(.headline)
                if let brand = product.brand {
                    Text(brand).font(.subheadline).foregroundStyle(.secondary)
                }
            }
            Spacer()
            if let price = product.price {
                Text(price).font(.subheadline.weight(.medium))
            }
            Image(systemName: "arrow.up.right.square")
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var thumbnail: some View {
        if let url = product.imageURL {
            AsyncImage(url: url) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                swatch
            }
        } else {
            swatch
        }
    }

    private var swatch: some View {
        (product.colorHex.flatMap { Color(hex: $0) } ?? Color.gray)
    }
}

#Preview {
    ShopView(season: .autumn, monkTone: 6)
}
