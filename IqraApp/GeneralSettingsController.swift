//
//  SettingsController.swift
//  IqraApp
//
//  Created by Hussain Al-Homedawy on 2016-12-04.
//  Copyright © 2016 Hussain Al-Homedawy. All rights reserved.
//

import UIKit

class GeneralSettingsController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet var backButton: UIBarButtonItem!
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var pickerView: UIPickerView!
    
    var translationSource = ["(EN) Sahih International", "(EN) A. J. Arberry", "(EN) Muhammad Asad",
                            "(EN) Abdul Majid Daryabadi", "(EN) Abdullah Yusuf Ali", "(EN) Sayyid Abul Ala Maududi",
                            "(EN) Mohammad Habib Shakir", "(EN) Mohammed Marmaduke William Pickthall", "(EN) Professor Shaykh Hasan Al-Fatih Qaribullah", "(EN) Muhammad Sarwar", "(EN) Dr. Muhammad Taqi-ud-Din al-Hilali and Dr. Muhammad Muhsin Khan", "(EN) Transliteration"];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.dataSource = self;
        pickerView.delegate = self;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let source = sender as! UIBarButtonItem
        
        if (source == backButton) {
            // do nothing
        } else if (source == saveButton) {
            // do nothing
        }
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return translationSource.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return translationSource[row]
    }
}
