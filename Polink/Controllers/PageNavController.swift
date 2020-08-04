//
//  PageNavController.swift
//  Polink
//
//  Created by Jose Saldana on 16/02/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import UIKit
import FirebaseAuth



class PageNavController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var viewControllerList:[UIViewController] = {
         let sb = UIStoryboard(name: "Registration", bundle: nil)
         
         let vc1 = sb.instantiateViewController(withIdentifier: "UserInfoVC")
         let vc2 = sb.instantiateViewController(withIdentifier: "GenderVC")
         let vc3 = sb.instantiateViewController(withIdentifier: "LocationVC")
         let vc4 = sb.instantiateViewController(withIdentifier: "RegistrationCheckVC")
         
         return [vc1, vc2, vc3, vc4]
     }()
    
    
    // authentication listener
    var handle: AuthStateDidChangeListenerHandle?
    
    var pageControl = UIPageControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Assigns itself as the data source
        self.dataSource = self
                
        // It only sets the view controllers if there is at least one view controller stored in the array list
        if let firstViewController = viewControllerList.first {
            self.setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
        
        //Asigns itself as the delegate
        self.delegate = self
        
        configurePageControl()
        
    }
    
    
    // Configuring the page view control (The three dots indicating the current page)
    func configurePageControl() {
        pageControl = UIPageControl(frame: CGRect(x: 0, y: UIScreen.main.bounds.maxY - 50 , width: UIScreen.main.bounds.width, height: 50))
        pageControl.numberOfPages = viewControllerList.count
        pageControl.currentPage = 0
        
        // Using an extension to customise the color of page control
        pageControl.customPageControl(dotFillColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), dotBorderColor: #colorLiteral(red: 0.3294117647, green: 0.3294117647, blue: 0.3450980392, alpha: 0.6), dotBorderWidth: 0.1)
        pageControl.currentPageIndicatorTintColor = UIColor.black
        self.view.addSubview(pageControl)
        
    }
    
    
    // Every time the current animation initiated by the user and managed by the page view controller finishes, the following function is called to update the page view control.
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        let pageContentViewController = pageViewController.viewControllers![0]
        self.pageControl.currentPage = viewControllerList.firstIndex(of: pageContentViewController)!
                
    }
    
    
    // Configures boundaries and basic navigation function moving in reverse
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let vcIndex = viewControllerList.firstIndex(of: viewController) else {return nil}
        
        let previousIndex = vcIndex - 1
        
        guard previousIndex >= 0 else {return nil}
        
        guard viewControllerList.count > previousIndex else {return nil}
        
        return viewControllerList[previousIndex]
    }
    
    
    // Configures boundaries and basic navigation function moving forward
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let vcIndex = viewControllerList.firstIndex(of: viewController) else {return nil}
        
        let nextIndex = vcIndex + 1
        
        guard viewControllerList.count != nextIndex else {return nil}
        
        guard viewControllerList.count > nextIndex else {return nil}
                        
        return viewControllerList[nextIndex]
    }
    
}

