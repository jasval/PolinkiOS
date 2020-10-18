//
//  AnimatedLogo.swift
//  Polink
//
//  Created by Jasper Valdivia on 17/10/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation
import UIKit
import Lottie

class AnimatedLogo: UIView {
    
    private let animationView: AnimationView
    private let titleLabel: TitleLabel
    
    init() {
        self.animationView = AnimationView(name: K.lightAnimationName)
        animationView.loopMode = .repeat(2)
        animationView.animationSpeed = 0.4
        self.titleLabel = TitleLabel()
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentMode = .scaleAspectFit
        translatesAutoresizingMaskIntoConstraints = false
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.contentMode = .scaleAspectFit
        
        addSubview(animationView)
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: topAnchor),
            animationView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
            animationView.leftAnchor.constraint(lessThanOrEqualToSystemSpacingAfter: leftAnchor, multiplier: 1),
            animationView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.3),
            titleLabel.leftAnchor.constraint(equalTo: animationView.rightAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: animationView.centerYAnchor),
            titleLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.6),
        ])
        
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewWasTapped(_:))))
    }
    
    func playAnimation() {
        if !animationView.isAnimationPlaying {
            self.animationView.play()
        } else {
            animationView.stop()
            animationView.play()
        }
    }
    
    @objc private func viewWasTapped(_ sender: AnimatedLogo) {
        playAnimation()
    }

}
