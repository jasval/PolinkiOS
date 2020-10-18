//
//  TitleLabel.swift
//  Polink
//
//  Created by Jasper Valdivia on 17/10/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import UIKit

class TitleLabel: UILabel {
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        contentMode = .center
        textAlignment = .center
        text = K.appName
        font = Appearance.Font.title
        textColor = Appearance.ColorPalette.primaryColor
        shadowColor = Appearance.ColorPalette.primaryShadowColor
        shadowOffset = CGSize(1,1)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
