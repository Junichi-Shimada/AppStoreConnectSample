//
//  ViewController.swift
//  AppStoreConnectSample
//
//  Created by shimada.junichi on 2021/09/14.
//

import UIKit

class ViewController: UIViewController {
    
    let api = AppStoreConnect()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //        print(api.debugDescription)
        
        api.listDevices { data in
            print(data)
        }
    }


}

