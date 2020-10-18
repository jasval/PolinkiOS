//
//  UIPageVC+Ext.swift
//  Polink
//
//  Created by Jose Saldana on 29/05/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation
import UIKit

extension UIPageViewController {
    
    func goToNextPage(){
        
        guard let currentViewController = self.viewControllers?.first else {return}
        
        guard let nextViewController = dataSource?.pageViewController(self, viewControllerAfter: currentViewController) else {return}
        
        setViewControllers([nextViewController], direction: .forward, animated: true, completion: nil)
    }
    
    func goToPreviousPage(){

        guard let currentViewController = self.viewControllers?.first else { return }

        guard let previousViewController = dataSource?.pageViewController( self, viewControllerBefore: currentViewController ) else { return }

        setViewControllers([previousViewController], direction: .reverse, animated: false, completion: nil)

    }

}
