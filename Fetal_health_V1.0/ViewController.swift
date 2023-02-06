import UIKit
import AVFoundation
import MobileCoreServices

  
class ViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var pandr: UIButton!
    var audioRecorder: AVAudioRecorder!
    var musicPlaying = false
  
    // change for total time at two places one here and other in reset timer. Addiitonally update the UI
     var totalTime: Int = 5
    
    // count down timer
    var countdownTimer: Timer!
 
    @IBOutlet weak var timerLabel: UILabel!
    
    var playerLooper: AVPlayerLooper! // should be defined in class
    var player: AVQueuePlayer!
    var audioPlayer: AVAudioPlayer?

    //@IBOutlet weak var StopUSPulse: UIButton!
    
    @IBOutlet weak var PatientIDLbl: UILabel!
    // displaying patient ID
    var patientID = ""
    
    // Global variables to store feedback data
    var additionalComments: String?
    var isSatisfactory: Bool?
    
    @IBOutlet weak var pandr_Pulse: UIButton!
    
    @IBOutlet weak var StopUS: UIButton!
    
   // @IBOutlet weak var pandr_Pulse: UIButton!
    
    var togglebuttonchecked = false

    @IBOutlet weak var StopUSPulse: UIButton!
    
    //var audioPlayer: AVAudioPlayer?
    //var audioPlayer_sweep: AVAudioPlayer?
    var audioPlay:AVPlayer!

    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        PatientIDLbl.text = "Patient ID: "+patientID
    }
    
    
    // Everything happening from here
    //Sin20000Hz@-14.08dB16bit48000HzS
    private func setUpAudioCapture(pulse:Bool) {
            
        let recordingSession = AVAudioSession.sharedInstance()
            
        do {
            try recordingSession.setCategory(.playAndRecord)
            try recordingSession.setActive(true)
                
            recordingSession.requestRecordPermission({ result in
                    guard result else { return }
            })
            if (pulse == false){
                // Calling function Play audio -- continous wave
                PlayAudio(audiofile:"Sin20000Hz@-14.08dB16bit48000HzS")
                // Caling dunction Record and Write  -- continous wave
                RecordAndWriteAudio(type: "continous")
            }else{
                // Calling function Play audio -- not needed
                PlayAudio(audiofile:"Sin20000Hz@-14.08dB16bit48000HzS")
                // Caling dunction Record and Write  -- not needed
                RecordAndWriteAudio(type:"pulse")
            }
        } catch {
            print("ERROR: Failed to set up recording session.")
        }
    }

    
    
    
    func startTimer() {
        // Start the timer only if it's not already running
        if countdownTimer == nil {
            countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        }
    }

    @objc func updateTime() {
        timerLabel.text = "\(timeFormatted(totalTime))"

        if totalTime != 0 {
            totalTime -= 1
        } else {
            endTimer()
            resetTimer()
        }
    }

    func endTimer() {
        // Invalidate the timer when the total time reaches 0
        countdownTimer?.invalidate()
        countdownTimer = nil // Set it to nil to indicate that the timer is not running
    }

    func resetTimer() {
        // Reset the total time to the initial value (5 seconds)
        totalTime = 5
        // Update the timer label to the initial value without restarting the timer
        timerLabel.text = "\(timeFormatted(totalTime))"
    }

    // Function to format time in MM:SS format
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    

    // Beep sound for feedback
    func loadBeepSound() {
        guard let path = Bundle.main.path(forResource: "beep", ofType: "mp3") else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            audioPlayer?.prepareToPlay()
        } catch {
            print("Error loading beep sound: \(error.localizedDescription)")
        }
    }
    
    
    
    
    
    
    
    
    
    
    

     // Function to show the recording saved alert
     func showRecordingSavedAlert() {
         let alertController = UIAlertController(title: "Recording Saved!", message: "Was the recording satisfactory?", preferredStyle: .alert)

         // Add a text input field for additional comments
         alertController.addTextField { textField in
             textField.placeholder = "Additional comments"
         }

         // Action for the "Satisfactory" button
         let satisfactoryAction = UIAlertAction(title: "Satisfactory", style: .default) { [weak self] _ in
             // Handle satisfactory action
             self?.additionalComments = alertController.textFields?.first?.text
             self?.isSatisfactory = true
             print(self?.additionalComments, self?.isSatisfactory)
             // Pop back to the root view controller in the navigation stack
            self?.navigationController?.popToRootViewController(animated: true)

                   // Reset the state of the initial screen
            if let PatientIDViewController = self?.navigationController?.viewControllers.first as? PatientIDViewController {
                PatientIDViewController.resetInitialState()
                   }
         }

         // Action for the "Re-record" button
         let reRecordAction = UIAlertAction(title: "Re-record", style: .default) { [weak self] _ in
             
             self?.additionalComments = alertController.textFields?.first?.text
             self?.isSatisfactory = false
             print(self?.additionalComments, self?.isSatisfactory)
            
         }
         reRecordAction.setValue(UIColor.red, forKey: "titleTextColor")
         
         // Add actions to the alert controller
      
         alertController.addAction(satisfactoryAction)
         alertController.addAction(reRecordAction)
         // Present the alert controller
         present(alertController, animated: true, completion: nil)
     }
  
 
    
    // on clicking Record button
    @IBAction func pandr(_ sender: Any) {
        DispatchQueue.global().async {
                // Call the first function   NOT playing the first time the app is built???????
            self.loadBeepSound()
            self.audioPlayer?.play()

                // Introduce a time delay (e.g., 0.5 seconds for 0.1 second beep)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    // Call the second function after the delay
                    self.startTimer()
                self.setUpAudioCapture(pulse:false)
                self.showToast(message: "Playing and Recording Ultrasound!", font: .systemFont(ofSize: 11.0))

                }
            }
   // calling setting up function to start
            
        
            
            
            
    }
  
 
    
    // Function to play ultrasound audio through speaker
    func PlayAudio(audiofile:String) {
        guard let pathToSound = Bundle.main.path(forResource: audiofile, ofType: "wav") else
        { return }
         let url = URL(fileURLWithPath: pathToSound )
        
        do{
            try AVAudioSession.sharedInstance().setMode(.default)
            try AVAudioSession.sharedInstance().setActive(true,options: .notifyOthersOnDeactivation)
            let asset = AVAsset(url: url)
            let item = AVPlayerItem(asset: asset)
             player = AVQueuePlayer(playerItem: item)
            
            // playing audio in continous loop
            playerLooper = AVPlayerLooper(player: player, templateItem: item)

            player.play()

        }catch{
            //error handling
        }
}
    
    
    // on press stop button
    @IBAction func StopUS(_ sender: Any) {


        if let recorder = audioRecorder {
            if recorder.isRecording {
                audioRecorder?.stop()
                let audioSession = AVAudioSession.sharedInstance()
                do {
                    self.showToast(message: "Saved the Continous file!", font: .systemFont(ofSize: 11.0))

                    try audioSession.setActive(false)
                } catch _ {
                }
            }}
    
        if let player = audioPlay {
                // if player.playing {
                     player.pause()
                // }
             }
//        if((audioRecorder.isRecording) != false){
//            audioRecorder.stop()
//            audioRecorder = nil
//        }
        

    }
    
  


    
    func RecordAndWriteAudio(type:String) {
        var fileName=""
        let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMddyyyy_HHmmss" // Specify the desired date and time format
        
        let currentDateAndTime = dateFormatter.string(from: Date())
      
            
            if (type=="continous"){
                
//                fileName = "Patient ID*\(patientID)_Timestamp*\(currentDateAndTime)__RecSatisfactory*\(isSatisfactoryString)__Feedback*\(commentsString).wav"
                fileName = "Patient ID*\(patientID)_Timestamp*\(currentDateAndTime).wav"
            }else{
                // not needed
                fileName = "Pulse_AudioFile_\(UUID().uuidString).wav"
                
            
        }
       // var fileName = "AudioFile_\(UUID().uuidString).wav"
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
     
        let audioFilename = documentPath.appendingPathComponent(fileName)
        let settings = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 48000,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
            do {
                 audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
                // Total recording timer set for X sec
                    audioRecorder.delegate = self

                    audioRecorder.record(forDuration: 5.0)
                    audioRecorder.isMeteringEnabled = true
                
                    Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                        self.audioRecorder.updateMeters()
                        let db = self.audioRecorder.averagePower(forChannel: 0)
                        print(db)
                    }

            } catch {
                print("ERROR: Failed to start recording process.")
            }
     
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            // Recording finished successfully
            loadBeepSound()
            audioPlayer?.play()
            showRecordingSavedAlert()
        } else {
            print("ppp")
            // Recording finished with an error
        }
    }
    
//    @IBAction func ImportAudio(_ sender: Any) {
//        
//        let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypePlainText as String], in: .import)
//        documentPicker.delegate = self
//        documentPicker.allowsMultipleSelection = false
//        present(documentPicker,animated: true, completion: nil)
//    }
//}

//extension ViewController: UIDocumentPickerDelegate {
//    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
//        
//       guard let selctedAudioFileURL = urls.first else {
//            return
//        }
//    }
//    
    func showToast(message : String, font: UIFont) {

        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2-95, y: self.view.frame.size.height-100, width: 200, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}
