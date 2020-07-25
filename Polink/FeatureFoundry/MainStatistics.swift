//
//  MainStatistics.swift
//  Polink
//
//  Created by Josh Valdivia on 23/07/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation
import UIKit
import Charts

class MainStatistics: UIView {
	
	var mainStack: UIStackView = {
		let stack = UIStackView()
		stack.translatesAutoresizingMaskIntoConstraints = false
		stack.axis = .horizontal
		stack.alignment = .fill
		return stack
	}()
	
	
	var agreeableStack: UIStackView = {
		let stack = UIStackView()
		stack.translatesAutoresizingMaskIntoConstraints = false
		stack.axis = .vertical
		stack.alignment = .center
		return stack
	}()
	
	var moralHumilityStack: UIStackView = {
		let stack = UIStackView()
		stack.translatesAutoresizingMaskIntoConstraints = false
		stack.axis = .vertical
		stack.alignment = .center
		return stack
	}()
	
	let agreeablenessLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = "Agreeableness"
		label.textAlignment = .center
		label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
		return label
	}()
	
	let moralHumilityLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = "Moral Humility"
		label.textAlignment = .center
		label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
		return label
	}()
	
	let getLatestStatsButton: UIButton = {
		let button = UIButton(type: .roundedRect)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setTitle("Get Latest Stats", for: .normal)
		button.setTitleColor(.white, for: .normal)
		button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
		button.backgroundColor = .black
		button.layer.cornerRadius = 10
		button.layer.shadowOffset = CGSize(width: 2, height: 2)
		button.layer.shadowColor = UIColor.lightGray.cgColor
		button.layer.shadowRadius = 5
		button.layer.shadowOpacity = 0.5
		button.addTarget(self, action: #selector(didPressStatsButton(_:)), for: .touchUpInside)
		return button
	}()
	
	var agreeableGraph: PieChartView = {
		let pie = PieChartView()
		pie.translatesAutoresizingMaskIntoConstraints = false
		pie.isUserInteractionEnabled = true
		pie.holeRadiusPercent = 0.5
		pie.transparentCircleRadiusPercent = 0.6
		pie.drawEntryLabelsEnabled = false
		pie.legend.enabled = false
		pie.noDataText = "Get latest data and match first to show statistics."
		pie.highlightPerTapEnabled = false
		return pie
	}()
	
	var moralHumilityGraph: PieChartView = {
		let pie = PieChartView()
		pie.translatesAutoresizingMaskIntoConstraints = false
		pie.isUserInteractionEnabled = true
		pie.noDataText = "Get latest data and match first to show statistics."
		pie.holeRadiusPercent = 0.5
		pie.transparentCircleRadiusPercent = 0.6
		pie.drawEntryLabelsEnabled = false
		pie.legend.enabled = false
		pie.highlightPerTapEnabled = false
		return pie
	}()
	
	var pFormatter: NumberFormatter = {
		let pFormatter = NumberFormatter()
		pFormatter.numberStyle = .percent
		pFormatter.maximumFractionDigits = 1
		pFormatter.multiplier = 100
		pFormatter.percentSymbol = "%"
		return pFormatter
	}()
	
	var delegate: MainStatisticsDelegate
	var data: [K.Statistics: Double]?

	init(_ delegate: MainStatisticsDelegate) {
		self.delegate = delegate
		super.init(frame: CGRect(0, 0, 100, 100))
		setupViews()
		setupConstraints()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
// MARK: Layout functions
extension MainStatistics {
	
	func setupViews() {
		self.translatesAutoresizingMaskIntoConstraints = false
		addSubview(getLatestStatsButton)
		addSubview(mainStack)
		//		mainStack.addArrangedSubview(matchStack)
		mainStack.addArrangedSubview(agreeableStack)
		mainStack.addArrangedSubview(moralHumilityStack)
		//		matchStack.addArrangedSubview(matchesLabel)
		//		matchStack.addArrangedSubview(counterLabel)
		agreeableStack.addArrangedSubview(agreeablenessLabel)
		agreeableStack.addArrangedSubview(agreeableGraph)
		moralHumilityStack.addArrangedSubview(moralHumilityLabel)
		moralHumilityStack.addArrangedSubview(moralHumilityGraph)
	}
	
	func setupConstraints() {
		NSLayoutConstraint.activate([
			getLatestStatsButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5),
			getLatestStatsButton.centerXAnchor.constraint(equalTo: centerXAnchor),
			getLatestStatsButton.topAnchor.constraint(equalTo: topAnchor),
			getLatestStatsButton.heightAnchor.constraint(equalToConstant: 30),
			
			mainStack.topAnchor.constraint(equalTo: getLatestStatsButton.bottomAnchor, constant: 10),
			mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
			mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
			mainStack.bottomAnchor.constraint(equalTo: bottomAnchor),
			
			agreeableStack.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5),
			moralHumilityStack.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5),
			
			agreeablenessLabel.widthAnchor.constraint(equalTo: mainStack.widthAnchor, multiplier: 0.5),
			moralHumilityLabel.widthAnchor.constraint(equalTo: mainStack.widthAnchor, multiplier: 0.5),
			agreeablenessLabel.heightAnchor.constraint(equalToConstant: 30),
			moralHumilityLabel.heightAnchor.constraint(equalToConstant: 30),
			
			agreeableGraph.leadingAnchor.constraint(equalTo: agreeableStack.leadingAnchor, constant: 10),
			agreeableGraph.trailingAnchor.constraint(equalTo: agreeableStack.trailingAnchor, constant: -10),
			moralHumilityGraph.leadingAnchor.constraint(equalTo: moralHumilityStack.leadingAnchor, constant: 10),
			moralHumilityGraph.trailingAnchor.constraint(equalTo: moralHumilityStack.trailingAnchor, constant: -10),
			agreeableGraph.topAnchor.constraint(equalTo: agreeablenessLabel.bottomAnchor),
			moralHumilityGraph.topAnchor.constraint(equalTo: moralHumilityLabel.bottomAnchor),
			agreeableGraph.bottomAnchor.constraint(equalTo: agreeableStack.bottomAnchor),
			moralHumilityGraph.bottomAnchor.constraint(equalTo: moralHumilityStack.bottomAnchor),
		])
	}
	
}


// MARK: Actions
extension MainStatistics {
	
	@objc func didPressStatsButton(_ sender: UIButton) {
		sender.pulsate()
		do {
			try delegate.getHistoryData(calculateStatistics(_:rooms:))
		} catch {
			fatalError("Couldn't process the request")
		}
	}
	
	func calculateStatistics(_ userId: String, rooms:[Room]) {
		data = [:]
		var tempEngagementCoeff: Double = 0
		var tempInformationCoeff: Double = 0
		var tempConversationCoeff: Double = 0
		let totalCount: Double = Double(rooms.count)
		var disagreedCount: Double = 0
		for room in rooms {
			guard let feedback = room.participantFeedbacks.first(where: { participant -> Bool in
				participant.uid == userId
			}) else {
				fatalError("There is no match between user and participants in this room")
			}
			if !feedback.agreement {
				tempEngagementCoeff += Double(feedback.engagementRating) / 5
				tempInformationCoeff += Double(feedback.informativeRating) / 5
				tempConversationCoeff += Double(feedback.conversationRating) / 5
				disagreedCount += 1
			}
		}
		let hCf = ((tempEngagementCoeff / disagreedCount) * 0.2) + ((tempInformationCoeff / disagreedCount) * 0.4) + ((tempConversationCoeff / disagreedCount) * 0.4)
		data?[.humilityCoeff] = hCf
		data?[.disagreements] = disagreedCount
		data?[.conversations] = totalCount
		data?[.moralHumilityPerCent] = (hCf * disagreedCount) / disagreedCount
		
		updateGraph()
	}
	
	func updateGraph() {
		guard let disagreements = data?[.disagreements], let total = data?[.conversations], let moralHumility = data?[.moralHumilityPerCent] else {return}
		
		let shadow = NSShadow()
		shadow.shadowColor = UIColor.lightGray
		shadow.shadowBlurRadius = 10
		
		let attributes: [NSAttributedString.Key: Any] = [
			.font: UIFont.systemFont(ofSize: 15, weight: .semibold),
			.foregroundColor : UIColor.black,
			.shadow: shadow
		]

		let disagreementEntry = PieChartDataEntry(value: disagreements)
		let agreementEntry = PieChartDataEntry(value: (total - disagreements))
		let agreeableDataset = PieChartDataSet(entries: [agreementEntry, disagreementEntry])
		
		agreeableDataset.drawIconsEnabled = false
		agreeableDataset.sliceSpace = 2
		agreeableDataset.colors = [UIColor.black, UIColor.lightGray]
		agreeableDataset.drawValuesEnabled = false
		agreeableGraph.data = PieChartData(dataSet: agreeableDataset)
		agreeableGraph.highlightValue(Highlight(x: 0, dataSetIndex: 0, stackIndex: 0))
		agreeableGraph.centerAttributedText = NSAttributedString(string: "\(Int(agreementEntry.value * 100))%", attributes: attributes)

		
		if moralHumility > 0 {
			let moralHumilityEntry = PieChartDataEntry(value: moralHumility)
			let totalHumilityEntry = PieChartDataEntry(value: (1 - moralHumility))
			let moralDataset = PieChartDataSet(entries: [moralHumilityEntry, totalHumilityEntry])
			
			moralDataset.drawIconsEnabled = false
			moralDataset.sliceSpace = 2
			moralDataset.colors = [UIColor.black, UIColor.lightGray]
			moralDataset.drawValuesEnabled = false
			moralHumilityGraph.data = PieChartData(dataSets: [moralDataset])
			moralHumilityGraph.highlightValue(Highlight(x: 0, dataSetIndex: 0, stackIndex: 0))
			moralHumilityGraph.centerAttributedText = NSAttributedString(string: "\(Int(moralHumilityEntry.value * 100))%", attributes: attributes)
		}
		
		agreeableGraph.notifyDataSetChanged()
		moralHumilityGraph.notifyDataSetChanged()
		
		moralHumilityGraph.animate(yAxisDuration: 1.4, easingOption: .easeInOutSine)
		agreeableGraph.animate(yAxisDuration: 1.4, easingOption: .easeInOutSine)
	}
}

protocol MainStatisticsDelegate {
	func getHistoryData(_ completion: @escaping (String, [Room]) -> ()) throws
	func getCurrentUserID() -> String
	
	
}
