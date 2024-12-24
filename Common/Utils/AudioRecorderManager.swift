import AVFAudio
import Foundation

class AudioRecorderManager {
    
    private var audioRecorder: AVAudioRecorder?
    private var audioFileURL: URL?
    
    var isRecording: Bool {
        return audioRecorder?.isRecording ?? false
    }
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            completion(granted)
        }
    }
    
    private func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .default, options: [.defaultToSpeaker])
            try audioSession.setActive(true)
        } catch {
            print("configureAudioSession : \(error.localizedDescription)")
        }
    }
    
    // MARK: - 녹음 시작
    func startRecording() {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Failed to find document directory.")
            return
        }
        
        let fileName = "\(UUID().uuidString).m4a"
        audioFileURL = documentDirectory.appendingPathComponent(fileName)
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            configureAudioSession()
            audioRecorder = try AVAudioRecorder(url: audioFileURL!, settings: settings)
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()
            print("🎙️ Recording started: \(audioFileURL?.absoluteString ?? "")")
        } catch {
            print("❌ Failed to start recording: \(error.localizedDescription)")
        }
    }
    
    func stopRecording() -> URL? {
        audioRecorder?.stop()
        print("🛑 Recording stopped: \(audioFileURL?.absoluteString ?? "")")
        return audioFileURL
    }
    
    func getCurrentRecordingTime() -> TimeInterval {
        return audioRecorder?.currentTime ?? 0
    }
}
