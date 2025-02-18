//
//  APIClient.swift
//  SingingHue2
//
//  Created by Everett Wilson on 2/17/25.
//

import Foundation

class APIClient {
    static let shared = APIClient() // Singleton instance for easy access
    private let session: URLSession

    // Private initializer to enforce singleton usage
    private init() {
        //self.session = URLSession(configuration: .default) //this will not work for SSLBypass
        let configuration = URLSessionConfiguration.default
            self.session = URLSession(configuration: configuration, delegate: SSLBypass(), delegateQueue: nil)
    }
    
    // MARK: - Generic Request with Decodable Response
    /// Makes an API call and decodes the response to the expected type.
    /// - Parameters:
    ///   - url: The endpoint URL.
    ///   - httpMethod: The HTTP method, e.g., "GET", "POST", "PUT".
    ///   - headers: Optional headers dictionary.
    ///   - body: Optional HTTP body data.
    ///   - completion: Completion handler with a Result containing the decoded response or an Error.
    func request<T: Decodable>(
        url: URL,
        httpMethod: String = "GET",
        headers: [String: String]? = nil,
        body: Data? = nil,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        
        // Set request headers if provided.
        headers?.forEach { field, value in
            request.setValue(value, forHTTPHeaderField: field)
        }
        request.httpBody = body
        
        let task = session.dataTask(with: request) { data, response, error in
            // Handle network error.
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            // Ensure data is available.
            guard let data = data else {
                DispatchQueue.main.async {
                    let err = NSError(
                        domain: "APIClient",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "No data returned"]
                    )
                    completion(.failure(err))
                }
                return
            }
            
            // Decode the response data.
            do {
                let decoder = JSONDecoder()
                let decodedResponse = try decoder.decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(decodedResponse))
                }
            } catch let decodeError {
                DispatchQueue.main.async {
                    completion(.failure(decodeError))
                }
            }
        }
        task.resume()
    }
    
    // MARK: - Generic Request Returning Raw Data
    /// Makes an API call and returns the raw data.
    func request(
        url: URL,
        httpMethod: String = "GET",
        headers: [String: String]? = nil,
        body: Data? = nil,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        
        headers?.forEach { field, value in
            request.setValue(value, forHTTPHeaderField: field)
        }
        request.httpBody = body
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    let err = NSError(
                        domain: "APIClient",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "No data returned"]
                    )
                    completion(.failure(err))
                }
                return
            }
            DispatchQueue.main.async {
                completion(.success(data))
            }
        }
        task.resume()
    }
}
