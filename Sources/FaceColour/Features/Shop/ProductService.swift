import Foundation

/// Source of shoppable products for a given analysis result.
protocol ProductService {
    func products(season: Season?, monkTone: Int?) async throws -> [Product]
}

enum ProductServiceError: LocalizedError {
    case badResponse(Int)
    var errorDescription: String? {
        switch self {
        case .badResponse(let code): return "The shop service returned an error (\(code))."
        }
    }
}

/// JSON contract our remote/affiliate endpoint is expected to return.
struct ProductListResponse: Codable, Equatable {
    let products: [Product]
}

/// Generic remote client. Provider-agnostic: it expects an endpoint that returns
/// `ProductListResponse` and authenticates with a bearer key. A concrete affiliate
/// provider is adapted in later (Amazon PA-API / Rakuten / etc.).
struct RemoteProductService: ProductService {
    let baseURL: URL
    let apiKey: String
    var session: URLSession = .shared

    func products(season: Season?, monkTone: Int?) async throws -> [Product] {
        var components = URLComponents(
            url: baseURL.appendingPathComponent("products"),
            resolvingAgainstBaseURL: false
        )!
        var query: [URLQueryItem] = []
        if let season { query.append(URLQueryItem(name: "season", value: season.rawValue)) }
        if let monkTone { query.append(URLQueryItem(name: "monkTone", value: String(monkTone))) }
        components.queryItems = query.isEmpty ? nil : query

        var request = URLRequest(url: components.url!)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
        let code = (response as? HTTPURLResponse)?.statusCode ?? -1
        guard (200..<300).contains(code) else { throw ProductServiceError.badResponse(code) }
        return try JSONDecoder().decode(ProductListResponse.self, from: data).products
    }
}

/// Chooses the remote client when configured (Info.plist `PRODUCT_API_BASE_URL` +
/// `PRODUCT_API_KEY`), otherwise falls back to mock data so the app runs key-free.
enum ProductServiceFactory {
    static func make(bundle: Bundle = .main) -> any ProductService {
        if let urlString = bundle.object(forInfoDictionaryKey: "PRODUCT_API_BASE_URL") as? String,
           !urlString.isEmpty,
           let url = URL(string: urlString),
           let key = bundle.object(forInfoDictionaryKey: "PRODUCT_API_KEY") as? String,
           !key.isEmpty {
            return RemoteProductService(baseURL: url, apiKey: key)
        }
        return MockProductService()
    }
}
