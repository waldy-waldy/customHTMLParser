//
//  ViewController.swift
//  customHTMLParser
//
//  Created by neoviso on 9/29/21.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var enterTextView: UITextView!
    @IBOutlet weak var resultLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func convertButtonDidTap(_ sender: Any) {
        let str = enterTextView.text
        if (str != "") {
            let tmp = HTMLParser().htmlToString(str!)
            resultLabel.attributedText = NSAttributedString(string: "Hi")
            resultLabel.attributedText = tmp
        }
        else {
            resultLabel.text = "empty string"
        }
        
    }
}

