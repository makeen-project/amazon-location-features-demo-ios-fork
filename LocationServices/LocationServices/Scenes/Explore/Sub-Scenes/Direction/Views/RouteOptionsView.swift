//
//  RouteOptionsView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

final class RouteToggleButton: UIView {
    
    private lazy var routeOptionToggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.accessibilityIdentifier = ViewsIdentifiers.Routing.routeOptionsVisibilityButton
        button.tintColor = .lsTetriary
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(routeOptionExpand), for: .touchUpInside)
        return button
    }()
    
    private var routeOptionContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false

        return view
    }()
    
    public var routeOptionImage: UIImageView = {
        let image = UIImage(systemName: "chevron.right")!
        let view = UIImageView(image: image)
        view.tintColor = .lsGrey
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    public var routeOptionTitle: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .amazonFont(type: .medium, size: 14)
        return label
    }()
    
    var routeOptionToggleHandler: VoidHandler?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError(.errorInitWithCoder)
    }
    
    private func setupViews() {
        self.addSubview(routeOptionToggleButton)
        routeOptionToggleButton.addSubview(routeOptionContainerView)
        routeOptionContainerView.addSubview(routeOptionTitle)
        routeOptionContainerView.addSubview(routeOptionImage)
        
        routeOptionToggleButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(32)
            $0.width.equalToSuperview()
        }
        
        routeOptionContainerView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.height.equalTo(16)
            $0.leading.trailing.equalToSuperview()
        }
        
        routeOptionTitle.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
        }
        
        routeOptionImage.snp.makeConstraints {
            $0.centerY.equalTo(routeOptionTitle.snp.centerY)
            $0.height.width.equalTo(12)
            $0.trailing.equalToSuperview().offset(-16)
        }
    }

    @objc func routeOptionExpand() {
        routeOptionToggleHandler?()
    }
}

final class RouteOptionsView: UIView {
    
    enum Constants {
        static let collapsedHeight: Int = 86
        
        static let segmentLeaveOptionHeight: Int = 76
        static let dateLeaveOptionHeight: Int = 478
        static let segmentRouteOptionHeight: Int = 172
        static let dateRouteOptionHeight: Int = 572
        
        static let expandedAvoidOptionHeight: Int = 379
    }
    
    var changeRouteOptionHeight: IntHandler?
    var avoidFerries: BoolHandler?
    var avoidTolls: BoolHandler?
    var avoidUturns: BoolHandler?
    var avoidTunnels: BoolHandler?
    var avoidDirtRoads: BoolHandler?
    var leaveOptionsHandler: Handler<LeaveOptions>?
    var viewModel: DirectionViewModel?
    
    private var avoidOptionState: Bool = false
    private var leaveOptionState: Bool = false
    
    private let avoidOptions: UIView = {
        let view = UIView()
        view.accessibilityIdentifier = ViewsIdentifiers.Routing.routeOptionsContainer
        view.backgroundColor = .white
        return view
    }()
    
    private let leaveOptions: UIView = {
        let view = UIView()
        view.accessibilityIdentifier = ViewsIdentifiers.Routing.leaveOptionsContainer
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var leaveSegmentControl: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["Leave now", "Leave at", "Arrive by"])
        segment.backgroundColor = .clear
        
        segment.tintColor = .clear
        segment.selectedSegmentTintColor = .white
        
        segment.setTitleTextAttributes(
            [
                NSAttributedString.Key.backgroundColor: UIColor.white,
                NSAttributedString.Key.foregroundColor: UIColor.lsPrimary,
                NSAttributedString.Key.font: UIFont.amazonFont(type: .regular, size: 14)
            ],
            for: .selected
        )
        segment.setTitleTextAttributes(
            [
                NSAttributedString.Key.backgroundColor: UIColor.clear,
                NSAttributedString.Key.foregroundColor: UIColor.lsTetriary,
                NSAttributedString.Key.font: UIFont.amazonFont(type: .regular, size: 14)
            ],
            for: .normal
        )

        segment.setWidth(120, forSegmentAt: 0)
        segment.setWidth(110, forSegmentAt: 1)
        segment.setWidth(110, forSegmentAt: 2)
        
        segment.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        segment.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .compact)
        segment.addTarget(self, action: #selector(leaveSegmentChanged), for: .valueChanged)

        return segment
    }()
    
    private lazy var leaveDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.backgroundColor = .white
        picker.tintColor = .lsPrimary
        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .inline
        picker.minimumDate = Date()
        picker.addTarget(self, action: #selector(leaveValueChanged(_:)), for: .valueChanged)
        
        for subview in picker.subviews {
                for view in subview.subviews {
                    if let label = view as? UILabel {
                        label.font = UIFont.amazonFont(type: .regular, size: 17)
                        label.textAlignment = .justified
                    }
                }
            }
        
        return picker
    }()
    
    private lazy var leaveOptionToggleButton = RouteToggleButton()
    
    private lazy var avoidOptionToggleButton = RouteToggleButton()
    
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
    
    private var seperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lsLight2
        return view
    }()
    
    private var firstSeperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lsLight2
        return view
    }()
    
    private var secondSeperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lsLight2
        return view
    }()
    
    private var thirdSeperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lsLight2
        return view
    }()
    
    private var fourthSeperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lsLight2
        return view
    }()
    
    private let routeOptionsStackView: UIStackView = {
        let sv = UIStackView()
        sv.backgroundColor = .white
        sv.axis = .vertical
        sv.distribution = .equalSpacing
        sv.spacing = 5
        sv.layer.cornerRadius = 8
        sv.layer.borderColor = UIColor.lsLight2.cgColor
        sv.layer.borderWidth = 1
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
    
    @objc func avoidOptionExpand() {
        // Collapse Leave Option if expanded
        if leaveOptionState {
            leaveOptionState = false
            toggleOption(state: &leaveOptionState, optionsView: leaveOptions, toggleButton: leaveOptionToggleButton, expandedHeight: leaveSegmentControl.selectedSegmentIndex == 0 ? Constants.segmentRouteOptionHeight : Constants.dateRouteOptionHeight)
        }
        
        // Toggle Route Option
        avoidOptionState.toggle()
        toggleOption(state: &avoidOptionState, optionsView: avoidOptions, toggleButton: avoidOptionToggleButton, expandedHeight: Constants.expandedAvoidOptionHeight)
    }

    @objc func leaveOptionExpand() {
        // Collapse Route Option if expanded
        if avoidOptionState {
            avoidOptionState = false
            toggleOption(state: &avoidOptionState, optionsView: avoidOptions, toggleButton: avoidOptionToggleButton, expandedHeight: Constants.expandedAvoidOptionHeight)
        }
        
        // Toggle Leave Option
        leaveOptionState.toggle()
        toggleOption(state: &leaveOptionState, optionsView: leaveOptions, toggleButton: leaveOptionToggleButton, expandedHeight: leaveSegmentControl.selectedSegmentIndex == 0 ? Constants.segmentRouteOptionHeight : Constants.dateRouteOptionHeight)
        
        if leaveOptionState {
            leaveOptions.snp.updateConstraints {
                $0.height.equalTo(leaveSegmentControl.selectedSegmentIndex == 0 ? Constants.segmentLeaveOptionHeight : Constants.dateLeaveOptionHeight)
            }
        }
    }
    
    private func toggleOption(state: inout Bool, optionsView: UIView, toggleButton: RouteToggleButton, expandedHeight: Int) {
        optionsView.isHidden = !state
        toggleButton.routeOptionImage.image = UIImage(systemName: state ? "chevron.down" : "chevron.right")
        changeRouteOptionHeight?(state ? expandedHeight : Constants.collapsedHeight)
    }
    
    @objc private func leaveSegmentChanged() {
        if leaveSegmentControl.selectedSegmentIndex == 0 {
            leaveDatePicker.isHidden = true
            leaveOptionsHandler?(LeaveOptions(leaveNow: true, leaveTime: nil, arrivalTime: nil))
            changeRouteOptionHeight?(Constants.segmentRouteOptionHeight)
        }
        else if leaveSegmentControl.selectedSegmentIndex == 1 {
            leaveDatePicker.isHidden = false
            leaveOptionsHandler?(LeaveOptions(leaveNow: nil, leaveTime: getLeaveDate(), arrivalTime: nil))
            changeRouteOptionHeight?(Constants.dateRouteOptionHeight)
        }
        else if leaveSegmentControl.selectedSegmentIndex == 2 {
            leaveDatePicker.isHidden = false
            leaveOptionsHandler?(LeaveOptions(leaveNow: nil, leaveTime: nil, arrivalTime: getLeaveDate()))
            changeRouteOptionHeight?(Constants.dateRouteOptionHeight)
        }
        if leaveOptionState {
            leaveOptions.snp.updateConstraints {
                $0.height.equalTo(leaveSegmentControl.selectedSegmentIndex == 0 ? Constants.segmentLeaveOptionHeight : Constants.dateLeaveOptionHeight)
            }
        }
        setLeaveOptionTitle()
    }
    
    @objc private func leaveValueChanged(_ sender: UIDatePicker) {
        setLeaveOptionTitle()
        leaveOptionsHandler?(LeaveOptions(leaveNow: leaveSegmentControl.selectedSegmentIndex == 0,
                                          leaveTime: leaveSegmentControl.selectedSegmentIndex == 1 ? getLeaveDate(): nil,
                                          arrivalTime: leaveSegmentControl.selectedSegmentIndex == 2 ? getLeaveDate(): nil))
    }
    
    private func getLeaveDate() -> Date? {
        return leaveDatePicker.date
    }
    
    private func setLeaveOptionTitle() {
        let selectedDate = leaveDatePicker.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd HH:mm"
        if leaveSegmentControl.selectedSegmentIndex == 0 {
            leaveOptionToggleButton.routeOptionTitle.textColor = .lsTetriary
            leaveOptionToggleButton.routeOptionTitle.text = "Leave now"
        }
        else if leaveSegmentControl.selectedSegmentIndex == 1 {
            leaveOptionToggleButton.routeOptionTitle.textColor = .lsPrimary
            leaveOptionToggleButton.routeOptionTitle.text = "Leave at \(dateFormatter.string(from: selectedDate))"
        }
        else if leaveSegmentControl.selectedSegmentIndex == 2 {
            leaveOptionToggleButton.routeOptionTitle.textColor = .lsPrimary
            leaveOptionToggleButton.routeOptionTitle.text = "Arrive by \(dateFormatter.string(from: selectedDate))"
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHandlers()
        setupViews()
    }
    
    private func setupHandlers() {
        leaveOptionToggleButton.routeOptionToggleHandler = leaveOptionExpand
        avoidOptionToggleButton.routeOptionToggleHandler = avoidOptionExpand
        
        ferriesOption.boolHandler = { [weak self] state in
            self?.avoidFerries?(state)
            self?.setAvoidTitle()
        }
        
        tollOption.boolHandler = { [weak self] state in
            self?.avoidTolls?(state)
            self?.setAvoidTitle()
        }
        
        uturnsOption.boolHandler = { [weak self] state in
            self?.avoidUturns?(state)
            self?.setAvoidTitle()
        }
        
        tunnelsOption.boolHandler = { [weak self] state in
            self?.avoidTunnels?(state)
            self?.setAvoidTitle()
        }
        
        dirtRoadsOption.boolHandler = { [weak self] state in
            self?.avoidDirtRoads?(state)
            self?.setAvoidTitle()
        }
        leaveSegmentControl.selectedSegmentIndex = 0
    }
    
    func setLocalValues(toll: Bool, ferries: Bool, uturns: Bool, tunnels: Bool, dirtRoads: Bool) {
        tollOption.setDefaultState(state: toll)
        ferriesOption.setDefaultState(state: ferries)
        uturnsOption.setDefaultState(state: ferries)
        tunnelsOption.setDefaultState(state: ferries)
        dirtRoadsOption.setDefaultState(state: ferries)

        setAvoidTitle()
        leaveSegmentChanged()
        changeRouteOptionHeight?(Constants.collapsedHeight)
    }
    
    func setAvoidTitle() {
        let avoidCount = [tollOption.getState(), ferriesOption.getState(), uturnsOption.getState(), tunnelsOption.getState(), dirtRoadsOption.getState()].filter{$0}.count
        if avoidCount == 0 {
            avoidOptionToggleButton.routeOptionTitle.text = "Route Options"
            avoidOptionToggleButton.routeOptionTitle.textColor = .lsTetriary
        }
        else {
            avoidOptionToggleButton.routeOptionTitle.text = "\(avoidCount) Options"
            avoidOptionToggleButton.routeOptionTitle.textColor = .lsPrimary
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError(.errorInitWithCoder)
    }
    
    private func setupViews() {
        self.addSubview(routeOptionsStackView)
        
        routeOptionsStackView.removeArrangedSubViews()
        routeOptionsStackView.addArrangedSubview(leaveOptionToggleButton)
        routeOptionsStackView.addArrangedSubview(leaveOptions)
        routeOptionsStackView.addArrangedSubview(seperatorView)
        routeOptionsStackView.addArrangedSubview(avoidOptionToggleButton)
        routeOptionsStackView.addArrangedSubview(avoidOptions)
        
        leaveOptions.addSubview(leaveOptionStackView)
        leaveOptionStackView.removeArrangedSubViews()
        leaveOptionStackView.addArrangedSubview(leaveSegmentControl)
        leaveOptionStackView.addArrangedSubview(leaveDatePicker)
        
        avoidOptions.addSubview(avoidOptionStackView)
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
        
        leaveOptionToggleButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(11)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(32)
            $0.width.equalToSuperview()
        }
        
        leaveOptions.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(0)
        }
        
        leaveOptionStackView.snp.makeConstraints {
            $0.trailing.leading.equalToSuperview()
        }
        
        leaveSegmentControl.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.centerX.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(40)
        }
        
        leaveDatePicker.snp.makeConstraints {
            $0.top.equalTo(leaveSegmentControl.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        avoidOptionToggleButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(36)
            $0.width.equalToSuperview()
        }
        
        routeOptionsStackView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }
        
        seperatorView.snp.makeConstraints {
            $0.height.equalTo(1)
        }
        
        avoidOptions.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
        
        avoidOptionStackView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.leading.bottom.equalToSuperview()
        }
        
        tollOption.snp.makeConstraints {
            $0.height.equalTo(56)
        }
        
        firstSeperatorView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        ferriesOption.snp.makeConstraints {
            $0.height.equalTo(56)
        }
        
        secondSeperatorView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        uturnsOption.snp.makeConstraints {
            $0.height.equalTo(56)
        }
        
        thirdSeperatorView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        tunnelsOption.snp.makeConstraints {
            $0.height.equalTo(56)
        }
        
        fourthSeperatorView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        dirtRoadsOption.snp.makeConstraints {
            $0.height.equalTo(56)
        }
        
        avoidOptions.isHidden = true
        leaveOptions.isHidden = true
    }
}
