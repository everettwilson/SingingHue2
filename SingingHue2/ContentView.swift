import SwiftUI

struct ContentView: View {
    let lightID = "401bddb0-5a93-4eb4-8300-a63c1037c00f" // Your specific light ID
    let bridgeIP = "192.168.4.38" // Your Hue Bridge IP
    let applicationKey = "1-Rl4dWmmyFl6J35qKGgNOHR1tfbNkWrhQuk1CTW" // Replace with your actual key

    @State private var isLightOn: Bool = false

    var body: some View {
        VStack {
            Text("Philips Hue Light")
                .font(.largeTitle)
            
            Toggle("Light State", isOn: $isLightOn)
                .onChange(of: isLightOn) {
                    toggleLightState(to: isLightOn)
                }
                .padding()
        }
    }
    
    func toggleLightState(to state: Bool) {
        guard let url = URL(string: "https://\(bridgeIP)/clip/v2/resource/light/\(lightID)") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(applicationKey, forHTTPHeaderField: "hue-application-key") // Correct header

        let body: [String: Any] = [
            "on": [
                "on": state
            ]
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let session = URLSession(configuration: .default, delegate: SSLBypass(), delegateQueue: nil) // Custom delegate

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error toggling light: \(error.localizedDescription)")
                return
            }
            
            if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode) {
                print("HTTP error: \(response.statusCode)")
                return
            }
            
            print("Light state toggled successfully")
        }.resume()
    }
}

// MARK: - Ignore SSL Errors (ONLY for Testing)
class SSLBypass: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
        completionHandler(.useCredential, credential)
    }
}
