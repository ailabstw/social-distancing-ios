//
//  UINavigationControllerExtensions.swift
//  ExposureNotification
//
//  Created by Chuck on 2022/5/13.
//  Copyright © 2022 AI Labs. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController {
    func popToViewController(_ viewController: UIViewController, animated: Bool, completion: @escaping () -> Void) {
        popToViewController(viewController, animated: animated)
        
        if animated, let coordinator = transitionCoordinator {
            coordinator.animate(alongsideTransition: nil) { _ in
                completion()
            }
        } else {
            completion()
        }
    }
}
