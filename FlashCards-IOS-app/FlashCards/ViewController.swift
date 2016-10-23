//
//  ViewController.swift
//  FlashCards
//
//  Created by Shruthi Vinjamuri on 10/1/16.
//  Copyright © 2016 Shruthi Vinjamuri. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var vwMeaning: UIView!
    @IBOutlet weak var btnNo: UIButton!
    @IBOutlet weak var btnYes: UIButton!
    @IBOutlet weak var toolbarTap: UIToolbar!
    @IBOutlet weak var lblProgress: UILabel!
    fileprivate var count: Int = 1
    fileprivate let of10 = " of 10"
    @IBOutlet weak var vwDefinition: UITextView!
    @IBOutlet weak var vwWord: UITextView!
    @IBOutlet weak var progressView: UIProgressView!
    fileprivate var isFlipped: Bool = false
    fileprivate var satWords: [(word: String, definition: String)] = [
        ("Abhor", "hate"),
        ("Bigot", "narrow-minded, prejudiced person"),
        ("Counterfeit",	"fake; false"),
        ("Enfranchise",	"give voting rights"),
        ("Hamper",	"hinder; obstruct"),
        ("Kindle", "to start a fire"),
        ("Noxious",	"harmful; poisonous; lethal"),
        ("Placid",	"calm; peaceful"),
        ("Remuneration", "payment for work done"),
        ("Talisman", "lucky charm")]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vwMeaning?.layer.cornerRadius = 10
        vwMeaning?.layer.masksToBounds = true
        vwMeaning?.layer.borderWidth = 1.0
        vwMeaning?.layer.borderColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1).cgColor
        intialState()
    }

    fileprivate func intialState() {
        self.count = 1
        lblProgress.text = String(count) + of10
        btnYes.isHidden = true
        btnNo.isHidden = true
        toolbarTap.isHidden = false
        progressView.setProgress(Float(count)/10, animated: true)
        shuffle(startIdx: 0)
        self.vwDefinition.isHidden = true
        self.vwWord.text = self.satWords[self.count-1].word
    }
    
    @IBAction func btnYesClicked(_ sender: UIButton) {
        count += 1
        if count > 10 {
            UIView.transition(with: vwMeaning!, duration: 0.5, options:.transitionFlipFromRight, animations: { () -> Void in
                self.vwDefinition.isHidden = true
                self.vwWord.text = "End of Stack!"
                self.toolbarTap.isHidden = true
                self.btnYes.isHidden = true
                self.btnNo.isHidden = true
                }, completion: { (Bool) -> Void in
                     // May not be effective here, but if there are overlapping views this will
                    // bring the required view forward
                    self.vwMeaning!.bringSubview(toFront: self.vwWord!)
            })
            return
        }
        lblProgress.text = String(count) + of10
        progressView.setProgress(Float(count)/10, animated: true)
        flip()
    }
    
    @IBAction func btnNoClicked(_ sender: UIButton) {
        shuffle(startIdx: self.count-1)
        flip()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func tapToSee(_ sender: UIBarButtonItem) {
        flip()
    }
    
    fileprivate func shuffle(startIdx: Int) {
        for i in (startIdx..<10).reversed(){
            let j = Int(arc4random_uniform(UInt32(i - startIdx))) + startIdx
            let temp = self.satWords[i]
            self.satWords[i] = self.satWords[j]
            self.satWords[j] = temp
        }
    }
    
    fileprivate func flip()
    {
        if (self.isFlipped == false)
        {
            UIView.transition(with: vwMeaning!, duration: 0.5, options:.transitionFlipFromRight, animations: { () -> Void in
                self.vwDefinition.isHidden = false
                self.vwDefinition.text = self.satWords[self.count-1].definition
                self.toolbarTap.isHidden = true
                self.btnYes.isHidden = false
                self.btnNo.isHidden = false
                }, completion: { (Bool) -> Void in
                    self.isFlipped = true
                    // May not be effective here, but if there are overlaping views this will
                    // bring the required view forward
                    self.vwMeaning!.bringSubview(toFront: self.vwWord!)
            })
        }
        else
        {
            UIView.transition(with: vwMeaning!, duration: 0.5, options:.transitionFlipFromRight, animations: { () -> Void in
                self.vwDefinition.isHidden = true
                self.toolbarTap.isHidden = false
                self.btnYes.isHidden = true
                self.btnNo.isHidden = true
                self.vwWord.text = self.satWords[self.count-1].word
                }, completion: { (Bool) -> Void in
                    self.isFlipped = false
                    self.vwMeaning!.bringSubview(toFront: self.vwWord!)
            })
        }
    }

}

