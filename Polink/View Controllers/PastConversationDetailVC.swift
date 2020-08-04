//
//  PastConversationDetailVC.swift
//  Polink
//
//  Created by Josh Valdivia on 01/08/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//
import Foundation
import UIKit
import Charts

class PastConversationDetailVC: UIViewController {
	
	private var room: Room
	private var feedback: ParticipantFeedback?
	private var profile: ProfilePublic
	private var graphView: RadarChartView?
	private var userData: RadarChartData?
	private var delegate: PastConversationDetailDelegate
	
	init(_ room: Room, profile: ProfilePublic, delegate: PastConversationDetailDelegate) {
		self.room = room
		self.profile = profile
		self.delegate = delegate
		super.init(nibName: nil, bundle: nil)
		guard let feedbackFromInterlocutor = (room.participantFeedbacks.first { (participant) -> Bool in
			participant.uid != profile.uid
		}) else {
			self.feedback = nil
			dismiss(animated: true, completion: nil)
			return
		}
		self.feedback = feedbackFromInterlocutor
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
		navigationController?.title = feedback?.randomUsername
		navigationController?.isToolbarHidden = false
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(profileDetailViewIsDone(_:)))
		
	}
	
	func setupGraph() {
		graphView = RadarChartView()
		graphView?.translatesAutoresizingMaskIntoConstraints = false
		graphView?.noDataText = "Please input some data to display a graph"
		let personalData = GraphView.createRadarCharDataSet(data: profile.ideology!, name: "User Ideology")
		let feedbackData = GraphView.createRadarCharDataSet(data: feedback!.perceivedIdeology, name: "Perceived Ideology")
		let blueColor = UIColor(red: 80/255, green: 130/255, blue: 206/255, alpha: 1)
		let blueFillColor = UIColor(red: 80/255, green: 130/255, blue: 206/255, alpha: 0.6)
		let redColor = UIColor(red: 247/255, green: 67/255, blue: 115/255, alpha: 1)
		let redFillColor = UIColor(red: 247/255, green: 67/255, blue: 115/255, alpha: 0.6)
		personalData.colors = [redColor]
		personalData.fillColor = redFillColor
		personalData.drawFilledEnabled = true
		personalData.valueFormatter = DataSetValueFormatter()
		feedbackData.colors = [blueColor]
		feedbackData.fillColor = blueFillColor
		feedbackData.drawFilledEnabled = true
		feedbackData.valueFormatter = DataSetValueFormatter()
		let data = RadarChartData(dataSets: [personalData, feedbackData])
		graphView?.data = data
		graphView?.webLineWidth = 0.5
		graphView?.innerWebLineWidth = 0.5
		graphView?.webColor = .lightGray
		graphView?.innerWebColor = .lightGray
		graphView?.rotationEnabled = false
		graphView?.legend.enabled = true
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
			
		])
	}
	
	@objc func profileDetailViewIsDone(_ sender: UIBarButtonItem) {
		delegate.dismissDetailViewController(self)
	}
	
}

protocol PastConversationDetailDelegate {
	func dismissDetailViewController(_ controller: PastConversationDetailVC)
}

