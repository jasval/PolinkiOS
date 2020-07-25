//
//  ProfileDetailViewController.swift
//  Polink
//
//  Created by Josh Valdivia on 19/07/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation
import UIKit
import Charts

class ProfileDetailViewController: UIViewController {
	
	private var quizButton: UIButton = {
		var button = UIButton(type: .roundedRect)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setTitle("Re-Do Quiz", for: .normal)
		button.setTitleColor(.white, for: .normal)
		button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
		button.backgroundColor = .black
		
		button.layer.cornerRadius = 25
		button.layer.shadowOffset = CGSize(width: 2, height: 2)
		button.layer.shadowColor = UIColor.lightGray.cgColor
		button.layer.shadowRadius = 5
		button.layer.shadowOpacity = 0.5
		button.addTarget(self, action: #selector(didPressQuizButton), for: .touchUpInside)
		return button
	}()
	
	private var profile: ProfilePublic
	private var graphView: RadarChartView?
	private var userData: RadarChartData?
	private var delegate: ProfileDetailViewControllerDelegate
	
	init(_ profile: ProfilePublic, delegate: ProfileDetailViewControllerDelegate) {
		self.profile = profile
		self.delegate = delegate
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground
		setupViews()
		setupConstraints()
		animateChart()
	}
	
	func setupViews() {
		setupGraph()
		// set background
		view.addSubview(graphView!)
		view.addSubview(quizButton)
		navigationController?.isToolbarHidden = false
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(profileDetailViewIsDone(_:)))
		
		// Next release of the feature
		quizButton.isHidden = true
	}
	
	func setupGraph() {
		graphView = RadarChartView()
		graphView?.translatesAutoresizingMaskIntoConstraints = false
		graphView?.noDataText = "Please input some data to display a graph"
		let dataSet = GraphView.createRadarCharDataSet(data: profile.ideology!, name: "User Data")
		let redColor = UIColor(red: 247/255, green: 67/255, blue: 115/255, alpha: 1)
		let redFillColor = UIColor(red: 247/255, green: 67/255, blue: 115/255, alpha: 0.6)
		dataSet.colors = [redColor]
		dataSet.fillColor = redFillColor
		dataSet.drawFilledEnabled = true
		dataSet.valueFormatter = DataSetValueFormatter()
		let data = RadarChartData(dataSet: dataSet)
		graphView?.data = data
		graphView?.webLineWidth = 0.5
		graphView?.innerWebLineWidth = 0.5
		graphView?.webColor = .lightGray
		graphView?.innerWebColor = .lightGray
		graphView?.rotationEnabled = false
		graphView?.legend.enabled = false
		graphView?.isMultipleTouchEnabled = true
		graphView?.isUserInteractionEnabled = false
		
		let xAxis = graphView?.xAxis
		xAxis?.labelFont = .systemFont(ofSize: 10, weight: .bold)
		xAxis?.labelTextColor = .black
		xAxis?.xOffset = 10
		xAxis?.yOffset = 10
		xAxis?.valueFormatter = XAxisFormatter()
		
		let yAxis = graphView?.yAxis
		yAxis?.labelFont = .systemFont(ofSize: 9, weight: .light)
		yAxis?.labelCount = 3
		yAxis?.labelXOffset = 5
		yAxis?.drawTopYLabelEntryEnabled = true
		yAxis?.axisMinimum = 0
		yAxis?.valueFormatter = YAxisFormatter()
	}
	
	func animateChart() {
		graphView?.animate(yAxisDuration: 1.4, easingOption: .linear)
	}
	
	func setupConstraints() {
		guard let g = graphView else {return}
		NSLayoutConstraint.activate([
			
			g.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
			g.heightAnchor.constraint(equalToConstant: 350),
			g.widthAnchor.constraint(equalToConstant: 350),
			g.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			
			quizButton.heightAnchor.constraint(equalToConstant: 70),
			quizButton.widthAnchor.constraint(equalToConstant: 200),
			quizButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			quizButton.topAnchor.constraint(equalToSystemSpacingBelow: g.bottomAnchor, multiplier: 4)
		])
	}
	
	@objc func didPressQuizButton() {
		quizButton.pulsate()
	}
	
	@objc func profileDetailViewIsDone(_ sender: UIBarButtonItem) {
		delegate.dismissProfileDetailViewController(self)
	}
	
}

protocol ProfileDetailViewControllerDelegate {
	func dismissProfileDetailViewController(_ controller: ProfileDetailViewController)
}

class DataSetValueFormatter: IValueFormatter {
	func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
		""
	}
}

class XAxisFormatter: IAxisValueFormatter {
	let titles = ["Libertarian", "Globalist", "Egalitarian", "Progressive", "Authoritarian", "Nationalist", "Capitalist", "Conservative"]
	
	func stringForValue(_ value: Double, axis: AxisBase?) -> String {
		titles[Int(value) % titles.count]
	}
}

class YAxisFormatter: IAxisValueFormatter {
	func stringForValue(_ value: Double, axis: AxisBase?) -> String {
		"\(Int(value))%"
	}
}
