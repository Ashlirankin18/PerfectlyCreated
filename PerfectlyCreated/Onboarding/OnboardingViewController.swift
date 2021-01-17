//
//  OnboardingViewController.swift
//  PerfectlyCreated
//
//  Created by Ashli Rankin on 1/16/21.
//  Copyright © 2020 Ashli Rankin. All rights reserved.
//

import UIKit
import Combine

final class OnboardingViewController: UIViewController {

    @IBAction private func createButtonTapped(_ sender: UIButton) {
        NotificationCenter.default.post(name: .signupSuccessfullyCompleted, object: nil)
    }
}
