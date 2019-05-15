//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Анна on 26/04/2019.
//  Copyright © 2019 Anna. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    
    var audioRecorder: AVAudioRecorder!
    var time: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stopRecordingButton.isEnabled = false
    }
    
    
    @IBAction func recordAudio(_ sender: Any) {
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath,recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        
        let session = AVAudioSession.sharedInstance()  // to share audio hardware between APPs
        try! session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
        checkRecordingStatus(status: audioRecorder.isRecording)
    }
    
    @IBAction func stopRecording(_ sender: Any) {
        time = formatDuration(time: audioRecorder.currentTime)
        print(Float(audioRecorder.currentTime))
        audioRecorder.stop()
        checkRecordingStatus(status: audioRecorder.isRecording)
        
        let session = AVAudioSession.sharedInstance()
        try! session.setActive(false)
        
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
        } else {
            print("Recording was not successful")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording" {
            let playSoundVC = segue.destination as! PlaySoundsViewController
            let recordedAudioURL = sender as! URL
            playSoundVC.recordedAudioURL = recordedAudioURL
            playSoundVC.recordDuration = time
        }
    }
    
    func checkRecordingStatus(status: Bool) {
        if status {
            recordingLabel.text = "Recording in progress"
            recordButton.isEnabled = false
            stopRecordingButton.isEnabled = true
        } else {
            recordingLabel.text = "Tap to record"
            recordButton.isEnabled = true
            stopRecordingButton.isEnabled = false
        }
    }
    
    func formatDuration(time: Double) -> String {
        let time = NSNumber(value: time)
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        guard let formattedDuration = formatter.string(from: time) else {return "0.00"}
        return formattedDuration
    }
    
}



