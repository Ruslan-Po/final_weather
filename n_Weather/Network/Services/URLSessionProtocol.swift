import Foundation

protocol URLSessionProtocol: AnyObject {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}
