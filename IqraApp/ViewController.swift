//
//  ViewController.swift
//  IqraApp
//
//  Created by Hussain Al-Homedawy on 2016-12-04.
//  Copyright © 2016 Hussain Al-Homedawy. All rights reserved.
//

import AVFoundation
import UIKit
import Speech

class ViewController: UIViewController, SFSpeechRecognizerDelegate, AVSpeechSynthesizerDelegate {
    
    var searchQuery: String = ""
    
    let networkRequestDelegate = NetworkDelegate()
    let audioEngine = AVAudioEngine()
    
    let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "ar_AE"))
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    
    @IBOutlet var searchView: UITextField!
    @IBOutlet var speechButton: UIButton!
    @IBOutlet var micStatus: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        speechRecognizer?.delegate = self
        speechButton.isEnabled = false
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            var isButtonEnabled = false
            
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
                break
                
            case .denied:
                isButtonEnabled = false
                break
                
            case .restricted:
                isButtonEnabled = false
                break
                
            case .notDetermined:
                isButtonEnabled = false
                break
            }
            
            OperationQueue.main.addOperation() {
                self.speechButton.isEnabled = isButtonEnabled
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Do nothing
    }
    
    @IBAction func unwindToMainSegue(sender: UIStoryboardSegue) {
        // Do nothing
    }
    
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            speechButton.isEnabled = true
        } else {
            speechButton.isEnabled = false
        }
    }
    
    private func beepSound() throws {
        AudioServicesPlaySystemSound(1113);
    }
    
    private func startRecording() throws {
        
        if (recognitionTask != nil) {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        let inputNode = audioEngine.inputNode
        try audioSession.setCategory(AVAudioSessionCategoryRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest?.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest!, resultHandler: { (result, error) in
            var isFinal = false
            
            if let result = result {
                self.searchView.text = result.bestTranscription.formattedString
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode?.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                self.speechButton.isEnabled = true
                self.endRecording()
            }
        })
        
        let recordingFormat = inputNode?.outputFormat(forBus: 0)
        inputNode?.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        try audioEngine.start()
    }
    
    private func searchCallback(_ data: Data, _ response: URLResponse) {
        let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String:AnyObject]
        
        // Parse JSON data
        let result = jsonResponse!["result"] as! [String:AnyObject]
        let matches = result["matches"] as! [[String:Any]]
        
        // Create an array of Ayah's
        var results = [Ayah]()
        
        for ayah in matches {
            let arabicAyah = ayah["arabicAyah"] as! String
            let surahName = ayah["arabicSurahName"] as! String
            let ayahNum = ayah["ayahNum"] as! Int
            let surahNum = ayah["surahNum"] as! Int
            let translatedAyah = ayah["translationAyah"] as! String
            let translatedSurah = ayah["translationSurahName"] as! String
            
            let tempAyah = Ayah.init(arabicAyah, surahName, translatedAyah, translatedSurah, ayahNum, surahNum)
            
            results.append(tempAyah)
        }
        
        // Launch results segue
        DispatchQueue.main.async {
            let storyboard = self.storyboard?.instantiateViewController(withIdentifier: "ResultsTableController") as! ResultsTableController
            
            // Shorten the list if necessary
            var finalResults = [Ayah]()
            
            if (results.count > 0) {
                if (results.count > 150) {
                    for i in 0..<150 {
                        finalResults.append(results[i])
                    }
                } else {
                    finalResults = results
                }
                
                storyboard.results = finalResults
                storyboard.selection = [Bool](repeating: true, count: finalResults.count)
                storyboard.expectedCellHeight = [CGFloat](repeating: 0, count: finalResults.count)
                storyboard.query = self.searchQuery
                storyboard.actualResults = results.count
                
                self.navigationController?.pushViewController(storyboard, animated: true)
            } else {
                self.micStatus.text = "No matches were found"
            }
        }
    }
    
    @IBAction func speechRecognition(_ sender: UIButton) {
        try! beepSound()
        
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            speechButton.isEnabled = false
        } else {
            try! startRecording()
            beginRecording()
        }
    }
    
    private func beginRecording() {
        searchView.text = ""
        speechButton.setBackgroundImage(#imageLiteral(resourceName: "mic_active"), for: .normal)
        self.micStatus.text = "Please begin reciting"
        
        searchView.text = "الله"
    }
    
    private func endRecording() {
        // Search for results
        if ((searchView.text?.characters.count)! > 0) {
            let search = searchView.text!
            let target = "\u{e2}"
            let query = search.substring(from: target.endIndex)
            
            networkRequestDelegate.performSearchQuery(query, "en-hilali", searchCallback)
        }
        
        self.searchQuery = searchView.text!
        self.searchView.text = ""
        self.speechButton.setBackgroundImage(#imageLiteral(resourceName: "mic_inactive"), for: .normal)
        self.micStatus.text = "Tap on the mic and recite a full or partial verse"
    }
}

