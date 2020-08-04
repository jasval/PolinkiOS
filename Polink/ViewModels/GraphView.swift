//
//  GraphView.swift
//  Polink
//
//  Created by Josh Valdivia on 19/07/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation
import UIKit
import Charts

class GraphView: UIView {
	init(userData: IdeologyMapping, interlocutorData: IdeologyMapping, userPerception: IdeologyMapping, interlocutorPerception: IdeologyMapping) {
		//
		super.init(frame: CGRect(0, 0, 100, 100))
		organiseData(x1: userData, y1: userPerception, x2: interlocutorData, y2: interlocutorPerception)
		setChart()
		setupViews()
	}
	
	init() {
		super.init(frame: CGRect(0, 0, 400, 400))
		setChart()
		setupViews()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	private var chart: RadarChartView?
	private var userRealData: RadarChartDataSet?
	private var userPerceivedData: RadarChartDataSet?
	private var interRealData: RadarChartDataSet?
	private var interPerceivedData: RadarChartDataSet?
	private var userChartData: RadarChartData?
	private var interlocutorChartData: RadarChartData?
	
	func organiseData(x1: IdeologyMapping, y1: IdeologyMapping, x2: IdeologyMapping, y2: IdeologyMapping) {
//		let x1liberty = x1.govt
//		let x1global = x1.dipl
//		let x1equality = x1.econ
//		let x1progress = x1.scty
//		let x1authority = 100 - x1.govt
//		let x1nation = 100 - x1.dipl
//		let x1markets = 100 - x1.econ
//		let x1tradition = 100 - x1.scty
		userRealData = GraphView.createRadarCharDataSet(data: x1, name: "User Recorded Ideology")
		userPerceivedData = GraphView.createRadarCharDataSet(data: y1, name: "User Perceived Ideology")
		interRealData = GraphView.createRadarCharDataSet(data: x2, name: "Interlocutor Recorded Ideology")
		interPerceivedData = GraphView.createRadarCharDataSet(data: y2, name: "Interlocutor Perceived Ideology")
		userChartData = RadarChartData(dataSets: [userRealData, userPerceivedData] as? [IChartDataSet])
		interlocutorChartData = RadarChartData(dataSets: [interRealData, interPerceivedData] as? [IChartDataSet])
	}
	
	func setChart() {
		chart = RadarChartView()
		
		chart?.translatesAutoresizingMaskIntoConstraints = false
		chart?.noDataText = "You need to provide data to draw a chart."
		chart?.data = userChartData
	}
	func setupViews() {
		guard let chart = chart else {return}
		translatesAutoresizingMaskIntoConstraints = false
		addSubview(chart)
		NSLayoutConstraint.activate([
			chart.topAnchor.constraint(equalTo: topAnchor),
			chart.bottomAnchor.constraint(equalTo: bottomAnchor),
			chart.leadingAnchor.constraint(equalTo: leadingAnchor),
			chart.trailingAnchor.constraint(equalTo: trailingAnchor)
		])
	}
	
	static func createRadarCharDataSet(data: IdeologyMapping, name: String) -> RadarChartDataSet {
		let dataSet = RadarChartDataSet(entries: [
			RadarChartDataEntry(value: data.govt),
			RadarChartDataEntry(value: data.dipl),
			RadarChartDataEntry(value: data.econ),
			RadarChartDataEntry(value: data.scty),
			RadarChartDataEntry(value: 100 - data.govt),
			RadarChartDataEntry(value: 100 - data.dipl),
			RadarChartDataEntry(value: 100 - data.econ),
			RadarChartDataEntry(value: 100 - data.scty)
		], label: name)
		return dataSet
	}
}
