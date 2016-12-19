//
//  ResultsTableController.swift
//  IqraApp
//
//  Created by Hussain Al-Homedawy on 2016-12-11.
//  Copyright © 2016 Hussain Al-Homedawy. All rights reserved.
//

import UIKit

class ResultsTableController: UITableViewController {
    
    var query = "Results"
    var results = [Ayah]()
    var actualResults: Int = 0
    var selection = [Bool]()
    var expectedCellHeight = [CGFloat]()
    
    @IBOutlet var resultsView: UITextView!
    
    let ROW_HEIGHT: CGFloat = 90
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        if (results.count != actualResults) {
            resultsView.text = "\(actualResults) results (not all shown) for \(query):"
        } else {
            resultsView.text = "\(results.count) results for \(query):"
        }
        
        resultsView.contentInset = UIEdgeInsetsMake(0, 15, 0, 15);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Toggle the selection state
        selection[indexPath.row] = !selection[indexPath.row]
        
        if (selection[indexPath.row] == true) {
            shareAyah(results[indexPath.row])
        }
        
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultsViewCell", for: indexPath) as! ResultsViewCell
        
        // Configure the cell
        let ayah = results[indexPath.row]
        
        cell.arabicSurahName.text = ayah.surahName
        cell.translatedSurahName.text = ayah.translatedSurah
        cell.verseNumber.text = "\(ayah.ayahNum):\(ayah.surahNum)"
        cell.arabicVerse.isHidden = selection[indexPath.row]
        cell.translatedVerse.isHidden = selection[indexPath.row]
        cell.arabicVerse.text = ayah.arabicAyah
        cell.translatedVerse.text = ayah.translatedAyah
        cell.arabicVerse.sizeToFit()
        cell.translatedVerse.sizeToFit()
    
        expectedCellHeight[indexPath.row] = cell.arabicVerse.frame.size.height + cell.translatedVerse.frame.size.height
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (selection[indexPath.row] == false) {
            return ROW_HEIGHT + expectedCellHeight[indexPath.row]
        }
        
        return ROW_HEIGHT
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Do nothing
    }
    
    private func shareAyah (_ ayah: Ayah) {
        // Share
        let textToShare = "\(ayah.arabicAyah) \n(\(ayah.surahName) الآيه \(ayah.ayahNum):\(ayah.surahNum))\n\n \(ayah.translatedAyah) \n(\(ayah.translatedSurah) verse \n(\(ayah.ayahNum):\(ayah.surahNum))"
        
        if let myWebsite = NSURL(string: "https://iqraapp.com/") {
            let objectsToShare = [textToShare, myWebsite] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            activityVC.popoverPresentationController?.sourceView = tableView
            self.present(activityVC, animated: true, completion: nil)
        }
        
    }
    
}
