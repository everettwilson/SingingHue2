import SwiftUI
import Speech

struct ContentView: View {
    // Use the grouped light for a room (or group) update.
    let lightID = "a612a8d3-5621-467a-bb11-65d9e9adbfd9" // Playroom grouped light ID
    //let resourceID = "light" // for a single light
    let resourceID = "grouped_light" // for a group

    // These properties are now used only for reference; HueClient handles API details.
    let bridgeIP = "192.168.4.38"
    let applicationKey = "1-Rl4dWmmyFl6J35qKGgNOHR1tfbNkWrhQuk1CTW"
    
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
            
            Text("Recognized: \(speechRecognizer.recognizedText)")
                .padding()
        }
        .onChange(of: speechRecognizer.recognizedText) { handleSpeechCommand(speechRecognizer.recognizedText)
        }
    }
    
    private func handleSpeechCommand(_ text: String) {
        print("Handling command: \(text)")
        
        let words = text.lowercased().split(separator: " ")
        guard let lastWord = words.last else { return }

        if lastWord == "on" {
            toggleLightState(to: true)
        } else if lastWord == "off" {
            toggleLightState(to: false)
        }
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
        // If resourceID is for a group, use updateGroupState. Otherwise, update a single light.
        if resourceID == "grouped_light" {
            HueClient.shared.updateGroupState(groupID: lightID, isOn: state) { result in
                switch result {
                case .success:
                    print("Group state toggled successfully to: \(state)")
                case .failure(let error):
                    print("Error toggling group state: \(error.localizedDescription)")
                }
            }
        } else {
            HueClient.shared.updateLightState(lightID: lightID, isOn: state) { result in
                switch result {
                case .success:
                    print("Light state toggled successfully to: \(state)")
                case .failure(let error):
                    print("Error toggling light state: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
