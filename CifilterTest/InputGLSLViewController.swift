//
//  InputGLSLViewController.swift
//  CifilterTest
//
//  Created by jeongkyu kim on 11/12/2018.
//  Copyright © 2018 jeongkyu kim. All rights reserved.
//

import UIKit

class InputGLSLViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.textView.text = CIKernelFilter.instance.gslsText
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func applay(_ sender: Any) {
        
        CIKernelFilter.instance.gslsText = self.textView.text
    }
}
