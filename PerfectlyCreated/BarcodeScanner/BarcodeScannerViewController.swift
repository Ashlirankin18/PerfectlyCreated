//
//  BarcodeScannerViewController.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 10/31/20.
//  Copyright © 2020 Ashli Rankin. All rights reserved.
//

import UIKit

class BarcodeScannerViewController: UIViewController {
    
    private lazy var videoSession = VideoSessionController(backgroundView: view)
   
    override func viewDidLoad() {
        super.viewDidLoad()
        videoSession.configureCaptureDevice()
    }
}
