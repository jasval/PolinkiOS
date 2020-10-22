//
//  Appearance.swift
//  Polink
//
//  Created by Jasper Valdivia on 17/10/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation
import UIKit

struct Appearance {
    
    static let cornerRadius: CGFloat = 8.0
    static let cornerRadiusBig: CGFloat = 25.0
    static let padding: CGFloat = 16.0
    static let cellVerticalPadding: CGFloat = 10.0
    static let separatorThickHeight: CGFloat = 8.0
    static let preferredCompactWidth: CGFloat = 295.0
    static let preferredRegularWidth: CGFloat = 560.0

    // TO-DO: Add Appearance Values
    
    struct Font {
        static let logo = UIFont.boldSystemFont(ofSize: 50)
        
    }
    
    struct ColorPalette {
        static let primaryColor = UIColor(hue: 170/360, saturation: 0.73, brightness: 0.34, alpha: 1)
        static let secondaryColor = UIColor(hue: 170/360, saturation: 0.73, brightness: 0.64, alpha: 1)
        static let tertiaryColor = UIColor(hue: 170/360, saturation: 0.43, brightness: 0.84, alpha: 1)
        static let primaryTextColor = UIColor.darkGray
        static let secondaryTextColor = UIColor.lightGray
        static let primaryShadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
    }
    
    static func preferredWidth(for traitCollection: UITraitCollection) -> CGFloat {
        switch traitCollection.horizontalSizeClass {
        case .regular:
            return preferredRegularWidth
        default:
            return preferredCompactWidth
        }
    }
    
    static func setupUiAppearance(in window: UIWindow) {
        window.overrideUserInterfaceStyle = .dark
        window.tintColor = .gray
        
        UINavigationBar.appearance().barStyle = UIBarStyle.black
        UINavigationBar.appearance().titleTextAttributes = [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20),
                                                             NSAttributedString.Key.kern: NSNumber(0.3)]
        UINavigationBar.appearance().largeTitleTextAttributes = [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 32),
                                                                  NSAttributedString.Key.kern: NSNumber(0.3)]
        UIBarButtonItem.appearance().setTitleTextAttributes([ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)],
                                                            for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)],
                                                            for: .highlighted)
        UIBarButtonItem.appearance().setTitleTextAttributes([ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)],
                                                            for: .disabled)
        
        UITabBar.appearance().barStyle = .black

    }
    
}
