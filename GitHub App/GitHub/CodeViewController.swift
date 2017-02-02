//
//  CodeViewController.swift
//  GitHub
//
//  Created by Shruthi Vinjamuri on 12/17/16.
//  Copyright © 2016 UWM. All rights reserved.
//

import UIKit

class CodeViewController: UIViewController {
    @IBOutlet weak var txtCode: UITextView!
    
    var codeContent: String? {
        didSet {
            self.configureView()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
    }
    
    func configureView() {
        if let data = self.codeContent, let codeView = self.txtCode {
            codeView.text = data
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    

}
