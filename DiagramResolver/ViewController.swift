//
//  ViewController.swift
//  DiagramResolver
//
//  Created by Lukasz Szyszkowski on 09.01.2017.
//  Copyright © 2017 Lukasz Szyszkowski. All rights reserved.
//

import UIKit
import SwiftSpinner

class ViewController: UIViewController {
    
    fileprivate let userFlow = UserInfoFlow()

    @IBOutlet weak var label: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SwiftSpinner.show("Updating user info")
        userFlow.start { viewType in
            SwiftSpinner.hide()
            switch viewType {
            case .regular:
                self.label.text = "Regular user :|"
            case .premium:
                self.label.text = "Premium user :D"
            case .premiumRenew:
                self.label.text = "Premium renew :/"
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

