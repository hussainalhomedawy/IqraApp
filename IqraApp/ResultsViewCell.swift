//
//  ResultsViewCell.swift
//  IqraApp
//
//  Created by Hussain Al-Homedawy on 2016-12-11.
//  Copyright © 2016 Hussain Al-Homedawy. All rights reserved.
//

import UIKit

class ResultsViewCell: UITableViewCell {
    
    @IBOutlet var translatedSurahName: UILabel!
    @IBOutlet var arabicSurahName: UILabel!
    @IBOutlet var verseNumber: UILabel!
    
    @IBOutlet var arabicVerse: UITextView!
    @IBOutlet var translatedVerse: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        arabicSurahName.textAlignment = .right
        translatedVerse.textAlignment = .left
        verseNumber.textAlignment = .right
        
        arabicVerse.textAlignment = .right
        translatedVerse.textAlignment = .left
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
