//
//  RouteOptionsView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

final class RouteOptionsView: UIView {
    
    enum Constants {
        static let collapsedHeight: Int = 32
        static let expandedRouteOptionHeight: Int = 300
        static let expandedLeaveOptionHeight: Int = 500
    }
    
    var changeRouteOptionHeight: IntHandler?
    var avoidFerries: BoolHandler?
    var avoidTolls: BoolHandler?
    var avoidUturns: BoolHandler?
    var avoidTunnels: BoolHandler?
    var avoidDirtRoads: BoolHandler?
    var leaveOptionHandler: Handler<LeaveOptions>?
    var viewModel: DirectionViewModel?
    
    private var routeOptionState: Bool = false
    private var leaveOptionState: Bool = false
    
    private let avoidOptions: UIView = {
        let view = UIView()
        view.accessibilityIdentifier = ViewsIdentifiers.Routing.routeOptionsContainer
        view.backgroundColor = .white
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.layer.borderColor = UIColor.lsLight2.cgColor
        view.layer.borderWidth = 1
        return view
    }()
    
    private let leaveOptions: UIView = {
        let view = UIView()
        view.accessibilityIdentifier = ViewsIdentifiers.Routing.leaveOptionsContainer
        view.backgroundColor = .white
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.layer.borderColor = UIColor.lsLight2.cgColor
        view.layer.borderWidth = 1
        return view
    }()
    
    private lazy var leaveSegmentControl: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["Leave now", "Leave at", "Arrive by"])
        segment.setDividerImage(nil, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        segment.selectedSegmentTintColor = .white
        segment.addTarget(self, action: #selector(leaveSegmentChanged), for: .valueChanged)
        segment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.lsPrimary, NSAttributedString.Key.font: UIFont.amazonFont(type: .regular, size: 14)], for: .selected)
        segment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.lsTetriary, NSAttributedString.Key.font: UIFont.amazonFont(type: .regular, size: 14)], for: .normal)
        return segment
    }()
    
    private lazy var leaveDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.tintColor = .lsPrimary
        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .inline
        picker.minimumDate = Date()
        picker.addTarget(self, action: #selector(leaveValueChanged(_:)), for: .valueChanged)
        return picker
    }()
    
    private lazy var leaveOptionToggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.accessibilityIdentifier = ViewsIdentifiers.Routing.routeOptionsVisibilityButton
        button.tintColor = .black
        button.backgroundColor = .mapElementDiverColor
        button.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(leaveOptionExpand), for: .touchUpInside)
        return button
    }()
    
    private var leaveOptionImage: UIImageView = {
        let image = UIImage(systemName: "chevron.down")!
        let view = UIImageView(image: image)
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private var leaveOptionTitle: UILabel = {
        let label = UILabel()
        label.text = "Leave Now"
        label.font = .amazonFont(type: .bold, size: 12)
        return label
    }()
    
    private var leaveOptionContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false

        return view
    }()
    
    private lazy var routeOptionToggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.accessibilityIdentifier = ViewsIdentifiers.Routing.routeOptionsVisibilityButton
        button.tintColor = .black
        button.backgroundColor = .mapElementDiverColor
        button.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(routeOptionExpand), for: .touchUpInside)
        return button
    }()
    
    private var routeOptionImage: UIImageView = {
        let image = UIImage(systemName: "chevron.down")!
        let view = UIImageView(image: image)
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private var routeOptionTitle: UILabel = {
        let label = UILabel()
        label.text = "Route Options"
        label.font = .amazonFont(type: .bold, size: 12)
        return label
    }()
    
    private var routeOptionContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false

        return view
    }()
    
    private let tollOption: RouteOptionView = {
        let view = RouteOptionView(title: StringConstant.avoidTolls)
        view.accessibilityIdentifier = ViewsIdentifiers.Routing.avoidTollsOptionContainer
        return view
    }()
    
    private let ferriesOption: RouteOptionView = {
        let view = RouteOptionView(title: StringConstant.avoidFerries)
        view.accessibilityIdentifier = ViewsIdentifiers.Routing.avoidFerriesOptionContainer
        return view
    }()
    
    private let uturnsOption: RouteOptionView = {
        let view = RouteOptionView(title: StringConstant.avoidUturns)
        view.accessibilityIdentifier = ViewsIdentifiers.Routing.avoidUturnsOptionContainer
        return view
    }()
    
    private let tunnelsOption: RouteOptionView = {
        let view = RouteOptionView(title: StringConstant.avoidTunnels)
        view.accessibilityIdentifier = ViewsIdentifiers.Routing.avoidTunnelsOptionContainer
        return view
    }()
    
    private let dirtRoadsOption: RouteOptionView = {
        let view = RouteOptionView(title: StringConstant.avoidDirtRoads)
        view.accessibilityIdentifier = ViewsIdentifiers.Routing.avoidDirtRoadsOptionContainer
        return view
    }()
    
    private var firstSeperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .searchBarBackgroundColor
        return view
    }()
    
    private var secondSeperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .searchBarBackgroundColor
        return view
    }()
    
    private var thirdSeperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .searchBarBackgroundColor
        return view
    }()
    
    private var fourthSeperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .searchBarBackgroundColor
        return view
    }()
    
    private let routeOptionsStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .equalSpacing
        sv.spacing = 5
        return sv
    }()
    
    private let avoidOptionStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .equalSpacing
        sv.spacing = 0
        return sv
    }()
    
    private let leaveOptionStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .equalSpacing
        sv.spacing = 0
        return sv
    }()
    
    @objc func routeOptionExpand() {
        // Collapse Leave Option if expanded
        if leaveOptionState {
            leaveOptionState = false
            toggleOption(state: &leaveOptionState, toggleButton: leaveOptionToggleButton, optionsView: leaveOptions, optionImage: leaveOptionImage, expandedHeight: Constants.expandedLeaveOptionHeight)
        }
        
        // Toggle Route Option
        routeOptionState.toggle()
        toggleOption(state: &routeOptionState, toggleButton: routeOptionToggleButton, optionsView: avoidOptions, optionImage: routeOptionImage, expandedHeight: Constants.expandedRouteOptionHeight)
    }

    @objc func leaveOptionExpand() {
        // Collapse Route Option if expanded
        if routeOptionState {
            routeOptionState = false
            toggleOption(state: &routeOptionState, toggleButton: routeOptionToggleButton, optionsView: avoidOptions, optionImage: routeOptionImage, expandedHeight: Constants.expandedRouteOptionHeight)
        }
        
        // Toggle Leave Option
        leaveOptionState.toggle()
        toggleOption(state: &leaveOptionState, toggleButton: leaveOptionToggleButton, optionsView: leaveOptions, optionImage: leaveOptionImage, expandedHeight: Constants.expandedLeaveOptionHeight)
    }
    
    private func toggleOption(state: inout Bool, toggleButton: UIButton, optionsView: UIView, optionImage: UIImageView, expandedHeight: Int) {
        toggleButton.backgroundColor = state ? .white : .mapElementDiverColor
        optionsView.isHidden = !state
        optionImage.image = UIImage(systemName: state ? "chevron.up" : "chevron.down")
        changeRouteOptionHeight?(state ? expandedHeight : Constants.collapsedHeight)
    }
    
    @objc private func leaveSegmentChanged() {
        if leaveSegmentControl.selectedSegmentIndex == 0 {
            leaveDatePicker.isHidden = true
            leaveOptionHandler?(LeaveOptions(leaveNow: true, leaveTime: nil, arrivalTime: nil))
        }
        else if leaveSegmentControl.selectedSegmentIndex == 1 {
            leaveDatePicker.isHidden = false
            leaveOptionHandler?(LeaveOptions(leaveNow: false, leaveTime: leaveDatePicker.date, arrivalTime: nil))
        }
        else if leaveSegmentControl.selectedSegmentIndex == 2 {
            leaveDatePicker.isHidden = false
            leaveOptionHandler?(LeaveOptions(leaveNow: false, leaveTime: nil, arrivalTime: leaveDatePicker.date))
        }
        leaveValueChanged(leaveDatePicker)
    }
    
    @objc private func leaveValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd HH:mm"
        if leaveSegmentControl.selectedSegmentIndex == 0 {
            leaveOptionTitle.textColor = .lsTetriary
            leaveOptionTitle.text = "Leave now"
        }
        else if leaveSegmentControl.selectedSegmentIndex == 1 {
            leaveOptionTitle.textColor = .lsPrimary
            leaveOptionTitle.text = "Leave \(dateFormatter.string(from: selectedDate))"
        }
        else if leaveSegmentControl.selectedSegmentIndex == 2 {
            leaveOptionTitle.textColor = .lsPrimary
            leaveOptionTitle.text = "Arrive \(dateFormatter.string(from: selectedDate))"
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHandlers()
        setupViews()
    }
    
    private func setupHandlers() {
        ferriesOption.boolHandler = { [weak self] state in
            self?.avoidFerries?(state)
            self?.setRouteTitle()
        }
        
        tollOption.boolHandler = { [weak self] state in
            self?.avoidTolls?(state)
            self?.setRouteTitle()
        }
        
        uturnsOption.boolHandler = { [weak self] state in
            self?.avoidUturns?(state)
            self?.setRouteTitle()
        }
        
        tunnelsOption.boolHandler = { [weak self] state in
            self?.avoidTunnels?(state)
            self?.setRouteTitle()
        }
        
        dirtRoadsOption.boolHandler = { [weak self] state in
            self?.avoidDirtRoads?(state)
            self?.setRouteTitle()
        }
        leaveSegmentControl.selectedSegmentIndex = 0
    }
    
    func setLocalValues(toll: Bool, ferries: Bool, uturns: Bool, tunnels: Bool, dirtRoads: Bool) {
        tollOption.setDefaultState(state: toll)
        ferriesOption.setDefaultState(state: ferries)
        uturnsOption.setDefaultState(state: ferries)
        tunnelsOption.setDefaultState(state: ferries)
        dirtRoadsOption.setDefaultState(state: ferries)

        setRouteTitle()
        leaveSegmentChanged()
    }
    
    func setRouteTitle() {
        let avoidCount = [tollOption.getState(), ferriesOption.getState(), uturnsOption.getState(), tunnelsOption.getState(), dirtRoadsOption.getState()].filter{$0}.count
        if avoidCount == 0 {
            routeOptionTitle.text = "Route Options"
            routeOptionTitle.textColor = .lsTetriary
        }
        else {
            routeOptionTitle.text = "Avoid \(avoidCount)"
            routeOptionTitle.textColor = .lsPrimary
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError(.errorInitWithCoder)
    }
    
    private func setupViews() {
        avoidOptionStackView.removeArrangedSubViews()
        avoidOptionStackView.addArrangedSubview(tollOption)
        avoidOptionStackView.addArrangedSubview(firstSeperatorView)
        avoidOptionStackView.addArrangedSubview(ferriesOption)
        avoidOptionStackView.addArrangedSubview(secondSeperatorView)
        avoidOptionStackView.addArrangedSubview(uturnsOption)
        avoidOptionStackView.addArrangedSubview(thirdSeperatorView)
        avoidOptionStackView.addArrangedSubview(tunnelsOption)
        avoidOptionStackView.addArrangedSubview(fourthSeperatorView)
        avoidOptionStackView.addArrangedSubview(dirtRoadsOption)
        avoidOptions.addSubview(avoidOptionStackView)
        
        leaveOptionStackView.removeArrangedSubViews()
        leaveOptionStackView.addArrangedSubview(leaveSegmentControl)
        leaveOptionStackView.addArrangedSubview(leaveDatePicker)
        leaveOptions.addSubview(leaveOptionStackView)
        
        
        routeOptionContainerView.addSubview(routeOptionTitle)
        routeOptionContainerView.addSubview(routeOptionImage)
        routeOptionToggleButton.addSubview(routeOptionContainerView)
        
        leaveOptionContainerView.addSubview(leaveOptionTitle)
        leaveOptionContainerView.addSubview(leaveOptionImage)
        leaveOptionToggleButton.addSubview(leaveOptionContainerView)
        
        routeOptionsStackView.addArrangedSubview(leaveOptionToggleButton)
        routeOptionsStackView.addArrangedSubview(routeOptionToggleButton)

        self.addSubview(routeOptionsStackView)
        self.addSubview(leaveOptions)
        self.addSubview(avoidOptions)
        
        leaveSegmentControl.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(40)
        }
        
        leaveDatePicker.snp.makeConstraints {
            $0.top.equalTo(leaveSegmentControl.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        routeOptionsStackView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }
        
        leaveOptionToggleButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.height.equalTo(40)
            $0.width.equalTo(152)
        }
        
        leaveOptionContainerView.snp.makeConstraints {
            $0.width.equalTo(118)
            $0.height.equalTo(16)
            $0.centerX.centerY.equalToSuperview()
        }
        
        leaveOptionTitle.snp.makeConstraints {
            $0.top.bottom.leading.equalToSuperview()
        }
        
        leaveOptionImage.snp.makeConstraints {
            $0.centerY.equalTo(routeOptionTitle.snp.centerY)
            $0.height.equalTo(4)
            $0.width.equalTo(6)
            $0.trailing.equalToSuperview()
        }

        routeOptionToggleButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(32)
            $0.width.equalTo(152)
        }
        
        routeOptionContainerView.snp.makeConstraints {
            $0.width.equalTo(118)
            $0.height.equalTo(16)
            $0.centerX.centerY.equalToSuperview()
        }
        
        routeOptionTitle.snp.makeConstraints {
            $0.top.bottom.leading.equalToSuperview()
        }
        
        routeOptionImage.snp.makeConstraints {
            $0.centerY.equalTo(routeOptionTitle.snp.centerY)
            $0.height.equalTo(4)
            $0.width.equalTo(6)
            $0.trailing.equalToSuperview()
        }
        
        leaveOptions.snp.makeConstraints {
            $0.top.equalTo(routeOptionsStackView.snp.bottom).offset(16)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
        
        avoidOptions.snp.makeConstraints {
            $0.top.equalTo(routeOptionsStackView.snp.bottom).offset(16)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
        
        tollOption.snp.makeConstraints {
            $0.height.equalTo(56)
        }
        
        firstSeperatorView.snp.makeConstraints {
            $0.height.equalTo(1)
        }
        
        ferriesOption.snp.makeConstraints {
            $0.height.equalTo(56)
        }
        
        avoidOptionStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.trailing.leading.bottom.equalToSuperview()
        }
        
        leaveOptionStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.trailing.leading.bottom.equalToSuperview()
        }
        
        avoidOptions.isHidden = true
        leaveOptions.isHidden = true
    }
}
