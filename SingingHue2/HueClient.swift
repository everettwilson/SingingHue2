//
//  HueClient.swift
//  SingingHue2
//
//  Created by Everett Wilson on 2/17/25.
//

import Foundation

enum HueError: Error {
    case invalidURL
    case invalidPayload
}

class HueClient {
    static let shared = HueClient()  // Singleton instance for easy access
    
    // MARK: - Configuration
    // You can later load these values from a secure source or configuration file.
    private let bridgeIP = "192.168.4.38"         // Replace with your actual Hue Bridge IP
    private let applicationKey = "1-Rl4dWmmyFl6J35qKGgNOHR1tfbNkWrhQuk1CTW"     // Replace with your actual Hue application key
    
    private init() {} // Private initializer to enforce singleton usage
    
    // MARK: - Update a Single Light
    /// Updates the on/off state of a single Philips Hue light.
    /// - Parameters:
    ///   - lightID: The unique identifier for the light.
    ///   - isOn: A Boolean indicating whether the light should be on (true) or off (false).
    ///   - completion: Completion handler returning a Result.
    func updateLightState(lightID: String, isOn: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        // Construct the URL for a specific light (v2 API endpoint).
        guard let url = URL(string: "https://\(bridgeIP)/clip/v2/resource/light/\(lightID)") else {
            completion(.failure(HueError.invalidURL))
            return
        }
        
        // Create the payload to update the light's state.
        let payload: [String: Any] = [
            "on": ["on": isOn]
        ]
        
        // Convert payload to JSON data.
        guard let body = try? JSONSerialization.data(withJSONObject: payload, options: []) else {
            completion(.failure(HueError.invalidPayload))
            return
        }
        
        // Set up the required headers.
        let headers = [
            "Content-Type": "application/json",
            "hue-application-key": applicationKey
        ]
        
        // Use the generic APIClient to send the PUT request.
        APIClient.shared.request(url: url, httpMethod: "PUT", headers: headers, body: body) { (result: Result<Data, Error>) in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Update a Group of Lights
    /// Updates the on/off state of all lights in a group.
    /// - Parameters:
    ///   - groupID: The unique identifier for the group (could be a room or custom group).
    ///   - isOn: A Boolean indicating whether the lights should be on (true) or off (false).
    ///   - completion: Completion handler returning a Result.
    func updateGroupState(groupID: String, isOn: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        // Construct the URL for the group action endpoint.
        guard let url = URL(string: "https://\(bridgeIP)/clip/v2/resource/grouped_light/\(groupID)") else {
            completion(.failure(HueError.invalidURL))
            return
        }
        
        // Create the payload for the group update.
        let payload: [String: Any] = [
            "on": ["on": isOn]
        ]
        
        // Convert the payload to JSON data.
        guard let body = try? JSONSerialization.data(withJSONObject: payload, options: []) else {
            completion(.failure(HueError.invalidPayload))
            return
        }
        
        // Set up headers similar to the single light call.
        let headers = [
            "Content-Type": "application/json",
            "hue-application-key": applicationKey
        ]
        
        // Use APIClient to send the request.
        APIClient.shared.request(url: url, httpMethod: "PUT", headers: headers, body: body) { (result: Result<Data, Error>) in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
