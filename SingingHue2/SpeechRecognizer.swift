import Foundation
import Speech
import AVFoundation

class SpeechRecognizer: ObservableObject {
    @Published var recognizedText = ""

    private let speechRecognizer = SFSpeechRecognizer()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                completion(status == .authorized)
            }
        }
    }

    func startListening() {
        // Ensure audio engine is stopped before starting again
        stopListening()

        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else { return }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        recognitionRequest.shouldReportPartialResults = true

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        // Install a tap on the audio engine input node
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            self.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("Error starting audio engine: \(error.localizedDescription)")
            return
        }

        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self.recognizedText = result.bestTranscription.formattedString.lowercased()
                }
            }

            if error != nil {
                self.stopListening()
            }
        }
    }

    func stopListening() {
        // Remove any existing audio tap before stopping the engine
        let inputNode = audioEngine.inputNode
        inputNode.removeTap(onBus: 0)

        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
    }
    
    //func resetRecognizedText() {
    //    DispatchQueue.main.async {
    //        self.recognizedText = ""
    //    }
    //    print("recognizedText: \(recognizedText)")
    //}
}
