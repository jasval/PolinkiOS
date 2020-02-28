//
//  SpinnerViewController.swift
//  Polink
//
//  Created by Jose Saldana on 11/02/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import UIKit

class SpinnerViewController: UIViewController {

    var spinner = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()

        view = UIView()
        view.backgroundColor = UIColor(white: 80/255, alpha: 0.2)

        spinner.color = UIColor.black
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)

        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

}
