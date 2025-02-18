import SwiftUI
import Speech

struct ContentView: View {
    
    let playroomLight = Light(lightID: "a612a8d3-5621-467a-bb11-65d9e9adbfd9", type: .group)
    let officeLight = Light(lightID: "401bddb0-5a93-4eb4-8300-a63c1037c00f", type: .single)
    
    @State private var currentLight: Light

    // Use an initializer to set the initial value of currentLight.
    init() {
        _currentLight = State(initialValue: playroomLight)
    }

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
        } else if HueColors.mapping[String(lastWord)] != nil {
            updateLightColorCommand(to: String(lastWord))
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
      
        HueClient.shared.updateLightState(light: currentLight , isOn: state) { result in
                switch result {
                case .success:
                    print("Light state toggled successfully to: \(state)")
                case .failure(let error):
                    print("Error toggling light state: \(error.localizedDescription)")
                }
            }
    }
    
    func updateLightColorCommand(to color: String) {
        HueClient.shared.updateLightColor(light: currentLight, color: color) { result in
            switch result {
            case .success:
                print("\(color.capitalized) color applied successfully")
            case .failure(let error):
                print("Error updating light color: \(error.localizedDescription)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
