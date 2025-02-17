import SwiftUI
import Speech

struct ContentView: View {
    //let lightID = "401bddb0-5a93-4eb4-8300-a63c1037c00f" // Office light
    let lightID = "a612a8d3-5621-467a-bb11-65d9e9adbfd9" // playroom grouped light
    //let resourceID = "light" // for single light
    let resourceID = "grouped_light" // for a group
    let bridgeIP = "192.168.4.38" // Your Hue Bridge IP
    let applicationKey = "1-Rl4dWmmyFl6J35qKGgNOHR1tfbNkWrhQuk1CTW" // Replace with your actual key
    
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var isListening = false

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
            Button(isListening ? "Stop Listening" : "Start Listening") {
                toggleListening()
            }
            .padding()
            .background(isListening ? Color.red : Color.green)
            .foregroundColor(.white)
            .clipShape(Capsule())
            
            Text("Recognized: \(speechRecognizer.recognizedText) ").padding()
        }
        .onChange(of: speechRecognizer.recognizedText) { handleSpeechCommand(speechRecognizer.recognizedText)
        }
    }
    
    private func handleSpeechCommand(_ text: String) {
        print("Handling command: \(text)")
        
        print("Handling command: \(text)")

        let words = text.lowercased().split(separator: " ")
        guard let lastWord = words.last else { return }

        if lastWord == "on" {
            toggleLightState(to: true)
            //self.isLightOn = true
        } else if lastWord == "off" {
            toggleLightState(to: false)
            //self.isLightOn = false
        }

        // Keep only the last 1 or 2 words
//        DispatchQueue.main.async {
//            self.speechRecognizer.recognizedText = lastWord
//        }
        
//        if text.lowercased().contains("on") {
//            toggleLightState(to: true)
//            //self.isLightOn = true
//        } else if text.lowercased().contains("off") {
//            toggleLightState(to: false)
//            //self.isLightOn = false
//        }
//        
//        //Reset recognizedText to avoid handling old words
//        speechRecognizer.resetRecognizedText()
    }
    private func toggleListening() {
            if isListening {
                speechRecognizer.stopListening()
            } else {
                speechRecognizer.startListening()
            }
            isListening.toggle()
        }
    
    func toggleLightState(to state: Bool) {
        guard let url = URL(string: "https://\(bridgeIP)/clip/v2/resource/\(resourceID)/\(lightID)") else {
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
            
            print("Light state toggled successfully to: \(state)")
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
