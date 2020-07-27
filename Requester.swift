import Foundation

typealias Headers = [String: String]
typealias RequestCallback = (Result<Any, Error>) -> Void

protocol EndpointProvider {
    var url: String { get }
}

enum APIError: Error {
    case invalidURL
}

protocol BackendRequester {
    associatedtype Endpoint: EndpointProvider

    /// Executa uma requisição para o backend
    /// - Parameters:
    ///   - to: endpoint a ser utilizado
    ///   - input: um model que possa ser convertido para envio no corpo da requisição
    ///   - headers: cabeçalhos para a requisição
    ///   - completion: o que fazer quando a requisição for concluída
    func request(to: Endpoint,
                 input: Encodable?,
                 headers: Headers?,
                 completion: @escaping RequestCallback)
}

extension BackendRequester {
    var baseURL: String { "https://some-api-root.com.br" }

    func request(to endpoint: Endpoint,
                 input: Encodable? = nil,
                 headers: Headers? = nil,
                 completion: @escaping RequestCallback) {

        guard let url = URL(string: "\(baseURL)/\(endpoint.url)") else {
            completion(.failure(APIError.invalidURL))
            return
        }

        var request = URLRequest(url: url)

        headers?.forEach({ key, value in
            request.addValue(value, forHTTPHeaderField: key)
        })

        URLSession.shared.dataTask(with: request) { data, response, error in
            // devem existir uns 6 mil posts explicando o que fazer aqui dentro, não se acanhe
        }
    }
}

struct UserBackendRequester: BackendRequester {
    typealias Endpoint = UserEndpoint

    enum UserEndpoint: String, EndpointProvider {
        case login
        case resetPassword
        case register

        var url: String {
            self.rawValue
        }
    }
}

struct ProductBackendRequester: BackendRequester {
    typealias Endpoint = ProductEndpoint

    enum ProductEndpoint: EndpointProvider {
        case list
        case detail(code: String)

        var url: String {
            switch self {
            case .list:
                return "list"
            case .detail(let code):
                return "detail/\(code)"
            }
        }
    }
}

let userRequester = UserBackendRequester()
userRequester.request(to: .login, completion: { _ in })

let productRequester = ProductBackendRequester()
productRequester.request(to: .detail(code: "123asdf"), completion: { _ in })
