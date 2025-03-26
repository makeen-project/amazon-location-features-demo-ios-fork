//
//  TrackingSimulationController.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit
import CoreLocation

struct RouteStatus {
    var id: String
    var isActive: Bool = false
    var simulateIndex: Int = 0
    var busAnnotation: ImageAnnotation?
    var routeCoordinates: [RouteCoordinate] = []
}

struct RouteCoordinate {
    var time: Date
    var coordinate: CLLocationCoordinate2D
}

final class TrackingSimulationController: UIViewController, UIScrollViewDelegate {
    enum Constants {
        static let titleOffsetiPhone: CGFloat = 16
        static let titleOffsetiPad: CGFloat = 0
        static let collapsedRouteHeight: Int = 64
        static let expandedRouteHeight: Int = 400
        static let collapsedTrackingHeight: Int = 64
        static let expandedTrackingHeight: Int = 400
        static let trackingRowHeight: CGFloat = 64
    }
    var trackingVC: TrackingVC?
    
    private var isiPad = UIDevice.current.userInterfaceIdiom == .pad
    private(set) lazy var headerView: TrackingRouteHeaderView = {
        let titleTopOffset: CGFloat = isiPad ? Constants.titleOffsetiPad : Constants.titleOffsetiPhone
        return TrackingRouteHeaderView(titleTopOffset: titleTopOffset)
    }()
    private let noInternetConnectionView = NoInternetConnectionView()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.accessibilityIdentifier = ViewsIdentifiers.Tracking.trackingHistoryScrollView
        scrollView.backgroundColor = .clear
        scrollView.alwaysBounceVertical = true
        scrollView.isDirectionalLockEnabled = true
        return scrollView
    }()
    
    private let scrollViewContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let mainContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    var routeContainerView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 1
        stackView.backgroundColor = .white
        stackView.layer.cornerRadius = 8
        stackView.clipsToBounds = true
        return stackView
    }()
    
    var routeTogglesContainerView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 1
        stackView.backgroundColor = .clear
        stackView.isHidden = true
        return stackView
    }()
    
    private lazy var routeHeaderView: UIButton = {
        let button = UIButton(type: .system)
        button.accessibilityIdentifier = ViewsIdentifiers.Routing.routeOptionsVisibilityButton
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(routeOptionExpand), for: .touchUpInside)
        return button
    }()
    
    private let routeIcon: UIImageView = {
        let iv = UIImageView(image: .routeIcon?.withTintColor(.black))
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private let routesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.amazonFont(type: .regular, size: 13)
        label.textColor = .black
        label.textAlignment = .left
        label.numberOfLines = 0
        label.text = StringConstant.routesNotifications
        return label
    }()
    
    private let routesDetailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.amazonFont(type: .regular, size: 13)
        label.textColor = .lsGrey
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    public var routeExpandImage: UIImageView = {
        let image = UIImage(systemName: "chevron.down")!
        let view = UIImageView(image: image)
        view.tintColor = .lsGrey
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private var routeSeperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lsLight2
        return view
    }()
    
    var trackingContainerView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = 1
        stackView.backgroundColor = .white
        stackView.layer.cornerRadius = 8
        stackView.clipsToBounds = true
        
        return stackView
    }()
    
    private lazy var trackingHeaderView: UIButton = {
        let button = UIButton(type: .system)
        button.accessibilityIdentifier = ViewsIdentifiers.Routing.routeOptionsVisibilityButton
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(trackingOptionExpand), for: .touchUpInside)
        return button
    }()
    
    private let trackingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.amazonFont(type: .regular, size: 13)
        label.textColor = .black
        label.textAlignment = .left
        label.numberOfLines = 0
        label.text = StringConstant.routesNotifications
        return label
    }()
    
    private let trackingDetailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.amazonFont(type: .regular, size: 13)
        label.textColor = .lsGrey
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var changeRouteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(StringConstant.change, for: .normal)
        button.titleLabel?.font = UIFont.amazonFont(type: .regular, size: 13)
        button.tintColor = .lsPrimary
        button.backgroundColor = .white
        button.showsMenuAsPrimaryAction = true
        return button
    }()
    
    private var trackingExpandImage: UIImageView = {
        let image = UIImage(systemName: "chevron.down")!
        let view = UIImageView(image: image)
        view.tintColor = .lsGrey
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private var trackingSeperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lsLight2
        view.isHidden = true
        return view
    }()
    
    var tableView: UITableView = {
        let tableView = UITableView()
        tableView.accessibilityIdentifier = ViewsIdentifiers.Tracking.trackingHistoryTableView
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 10
        tableView.isHidden = false
        return tableView
    }()

    var viewModel: TrackingViewModelProtocol!
    
    private var routeToggles: [RouteToggleView] = []
    var isTrackingActive: Bool = false
    var routeGeofences: [String: [GeofenceDataModel]] = [:]
    var routesStatus: [String: RouteStatus] = [:]
    
    var routeToggleState: Bool = false
    var trackingToggleState: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.post(name: Notification.updateMapLayerItems, object: nil, userInfo: nil)
        trackingAppearanceChanged(isVisible: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: Notification.resetMapLayerItems, object: nil, userInfo: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        trackingAppearanceChanged(isVisible: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = .lsTetriary
        
        scrollView.delegate = self
        tableView.delegate = self
        
        setupHandlers()
        setupViews()
        setupTableView()
        
        scrollView.isHidden = !Reachability.shared.isInternetReachable
        noInternetConnectionView.isHidden = Reachability.shared.isInternetReachable
        
        centerMap()
        NotificationCenter.default.post(name: Notification.updateTrackingHeader, object: nil, userInfo:  ["state": true])
        
        Task {
            try await Task.sleep(for: .seconds(2))
            //await startTracking()
        }
    }
    
    func centerMap() {
        trackingVC?.trackingMapView.mapView.mapView.setCenter(CLLocationCoordinate2D(latitude: 49.27046144661014, longitude: -123.13319444634126), zoomLevel: 12, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {

    }
    
    @objc private func updateButtonStyle(_ notification: Notification) {
        let state = (notification.userInfo?["state"] as? Bool) ?? false
        updateButtonStyle(state: state)
    }
    
    @objc func routeOptionExpand() {
        toggleRouteOption(state: &routeToggleState)
    }
    
    @objc func trackingOptionExpand() {
        toggleTrackingOption(state: &trackingToggleState)
    }
    
    func updateButtonStyle(state: Bool) {
        self.headerView.updateButtonStyle(isTrackingStarted: state)
        self.view.setNeedsLayout()
    }
    
    private func setupHandlers() {
        headerView.trackingButtonHandler = { state in
            Task {
                await self.startTracking()
            }
        }
        
        headerView.showAlertCallback = showAlert(_:)
        headerView.showAlertControllerCallback = { [weak self] alertController in
            self?.present(alertController, animated: true)
        }
        scrollView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(dismissTrackingSimulation), name: Notification.dismissTrackingSimulation, object: nil)
    }
    
    @objc func dismissTrackingSimulation() {
        self.dismissBottomSheet()
    }
    var eView : UIView = {
        let view = UIView()
        view.backgroundColor = .lsLight2
        return view
    }()
    
    private func setupViews() {
        view.backgroundColor = .searchBarBackgroundColor
        
        view.addSubview(headerView)
        view.addSubview(scrollView)
        
        scrollView.addSubview(scrollViewContentView)
        
        scrollViewContentView.addSubview(eView)
        eView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        scrollViewContentView.addSubview(routeContainerView)
        scrollViewContentView.addSubview(trackingContainerView)

        trackingContainerView.addArrangedSubview(trackingHeaderView)
        trackingContainerView.addArrangedSubview(tableView)
        
        trackingHeaderView.addSubview(trackingLabel)
        trackingHeaderView.addSubview(trackingDetailLabel)
        trackingHeaderView.addSubview(changeRouteButton)
        trackingHeaderView.addSubview(trackingExpandImage)
        trackingHeaderView.addSubview(trackingSeperatorView)

        headerView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.equalTo(60)
        }
        
        scrollView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(headerView.snp.bottom).offset(16)
        }
        
        scrollViewContentView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
            $0.width.equalTo(scrollView.frameLayoutGuide)
            $0.height.equalTo(500)
        }
        
        trackingContainerView.snp.makeConstraints {
            $0.top.equalTo(routeContainerView.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(Constants.collapsedTrackingHeight)
        }
        
        trackingHeaderView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(Constants.collapsedTrackingHeight)
        }
        
        tableView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        trackingLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.leading.equalToSuperview().offset(16)
        }
        
        trackingDetailLabel.snp.makeConstraints {
            $0.top.equalTo(trackingLabel.snp.bottom)
            $0.leading.equalToSuperview().offset(16)
        }
        
        changeRouteButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.trailing.equalTo(trackingExpandImage.snp.leading).offset(-16)
            $0.width.equalTo(60)
            $0.height.equalTo(18)
        }
        
        trackingExpandImage.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.trailing.equalTo(-16)
            $0.width.height.equalTo(24)
        }
        
        trackingSeperatorView.snp.makeConstraints {
            $0.top.equalTo(trackingDetailLabel.snp.bottom).offset(10)
            $0.height.equalTo(1)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
        
        generateRouteToggles()

        setChangeMenu()
        if let route = viewModel.busRoutes.first {
            setTrackingHeaders(route: route)
        }
    }
    
    var tableContentHeight = 0
    var trackingContainerHeight = 0
    
    func adjustTableViewHeight() {
        tableContentHeight = trackingToggleState ?  (getActiveRouteCoordinates().count * Int(Constants.trackingRowHeight) + 20): 0
        trackingContainerHeight = trackingToggleState ?  (tableContentHeight + 20 + Constants.collapsedTrackingHeight): Constants.collapsedTrackingHeight
        print("tableView height: \(tableContentHeight)")
        tableView.snp.updateConstraints {
            $0.height.equalTo(tableContentHeight)
        }
        trackingContainerView.snp.updateConstraints {
            $0.height.equalTo(trackingContainerHeight)
        }
        tableView.layoutIfNeeded()
        tableView.layoutSubviews()
        updateScrollViewContentSize()
    }
    
    func updateScrollViewContentSize() {
        let scrollHeight: CGFloat = CGFloat(trackingContainerHeight + (routeToggleState ? Constants.expandedRouteHeight : Constants.collapsedRouteHeight))
        let totalContentHeight = scrollHeight+100
        print("totalContentHeight: \(totalContentHeight)")
        scrollViewContentView.snp.updateConstraints {
            $0.height.equalTo(totalContentHeight)
        }
    }
    
    func generateRouteToggles() {
        routeContainerView.addArrangedSubview(routeHeaderView)
        routeHeaderView.addSubview(routeIcon)
        routeHeaderView.addSubview(routesLabel)
        routeHeaderView.addSubview(routesDetailLabel)
        routeHeaderView.addSubview(routeExpandImage)
        routeContainerView.addArrangedSubview(routeSeperatorView)
        routeContainerView.addArrangedSubview(routeTogglesContainerView)
        
        routeContainerView.snp.makeConstraints {
            $0.top.equalTo(eView.snp.bottom).offset(5)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(Constants.collapsedRouteHeight)
        }
        
        routeHeaderView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(Constants.collapsedRouteHeight)
        }
        
        routeIcon.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(16)
            $0.width.height.equalTo(20)
        }
        
        routesLabel.snp.makeConstraints {
            $0.top.equalTo(routeIcon.snp.top)
            $0.leading.equalTo(routeIcon.snp.trailing).offset(16)
        }
        
        routesDetailLabel.snp.makeConstraints {
            $0.top.equalTo(routesLabel.snp.bottom)
            $0.leading.equalTo(routeIcon.snp.trailing).offset(16)
        }
        
        routeExpandImage.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(-16)
            $0.width.height.equalTo(24)
        }
        
        routeSeperatorView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
        
        routeTogglesContainerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
        }
        
        for route in viewModel.busRoutes {
                routesStatus[route.id] = RouteStatus(id: route.id, isActive: false, simulateIndex: 0)
                let routeToggle = RouteToggleView()
                routeToggle.id = route.id
                routeToggle.optionTitle.text = route.name
                let seperatorView: UIView = {
                    let view = UIView()
                    view.backgroundColor = .lsLight2
                    return view
                }()
                routeTogglesContainerView.addArrangedSubview(routeToggle)
                routeTogglesContainerView.addArrangedSubview(seperatorView)
                
                routeToggle.snp.makeConstraints {
                    $0.leading.equalToSuperview().offset(16)
                    $0.trailing.equalToSuperview()
                }
                
                seperatorView.snp.makeConstraints {
                    $0.height.equalTo(1)
                    $0.leading.equalToSuperview().offset(16)
                    $0.trailing.equalToSuperview()
                }
                
                routeToggle.boolHandler = { [weak self] isOn in
                    self?.evaluateSelectedRoutes()
                    self?.clearGeofences()
                    self?.drawGeofences()
                    self?.drawTrackingRoutes()
                    if isOn {
                        self?.simulateTrackingRoute(routeToggle: routeToggle)
                    } else {
                        if let routeId = routeToggle.id {
                            self?.trackingVC?.trackingMapView.deleteTrackingRoute(routeId: routeId)
                            self?.routesStatus[routeId]?.isActive = false
                            self?.routesStatus[routeId]?.simulateIndex = 0
                        }
                    }
                }
                
                routeToggles.append(routeToggle)

            routeToggles[0].setState(isOn: true)
        }
    }
    
    var activeRouteId: String?
    func setChangeMenu() {
        let menuItems = viewModel.busRoutes.map { route in
            UIAction(title: route.name) { _ in
                print("Selected route: \(route.name)")
                self.setTrackingHeaders(route: route)
            }
        }

        let menu = UIMenu(children: menuItems)
        changeRouteButton.menu = menu
    }
    
    
    func setTrackingHeaders(route: BusRoute) {
        activeRouteId = route.id
        let words = route.name.split(separator: " ")
        if let lastWord = words.last {
            let firstPart = words.dropLast().joined(separator: " ")
            let lastPart = String(lastWord)

            trackingLabel.text = firstPart
            trackingDetailLabel.text = lastPart
        }
    }
    
    
    func evaluateSelectedRoutes() {
        let count = routeToggles.count(where: { $0.getState()})
        routesDetailLabel.text = "\(count) routes active"
    }
    
    func getActiveRouteCoordinates() -> [RouteCoordinate] {
        routesStatus.first(where: { $0.key == activeRouteId })?.value.routeCoordinates ?? []
    }
    
    private func toggleRouteOption(state: inout Bool) {
        state.toggle()
        routeExpandImage.image = UIImage(systemName: state ? "chevron.down" : "chevron.up")
        routeTogglesContainerView.isHidden = !state
        let height = state ? Constants.expandedRouteHeight: Constants.collapsedRouteHeight
        
        routeContainerView.snp.updateConstraints {
            $0.height.equalTo(height)
        }

        //updateScrollViewContentSize()
    }
    
    private func toggleTrackingOption(state: inout Bool) {
        state.toggle()
        trackingSeperatorView.isHidden = !state
        trackingExpandImage.image = UIImage(systemName: state ? "chevron.down" : "chevron.up")
        let height = state ? Constants.expandedTrackingHeight: Constants.collapsedTrackingHeight
        trackingContainerView.snp.updateConstraints {
            $0.height.equalTo(height)
        }
        //updateScrollViewContentSize()
    }
    
    func startTracking() async {
        isTrackingActive.toggle()
        centerMap()
        
        updateButtonStyle(state: isTrackingActive)
        if !isTrackingActive {
            trackingVC?.viewModel.stopIoTSubscription()
            return
        }
        
        trackingVC?.viewModel.startIoTSubscription()
        let count = routeToggles.count(where: { $0.getState()})
        if count == 0 {
            routeToggles.first?.changeState()
        }
        clearGeofences()

        await fetchGeoFences()
        drawGeofences()
        drawTrackingRoutes()
        //Start tracking
        simulateTrackingRoutes()
    }
    
    func convertToCoordinates(from array: [[Double]]) -> [CLLocationCoordinate2D] {
        return array.compactMap { pair in
            guard pair.count == 2 else { return nil }
            return CLLocationCoordinate2D(latitude: pair[1], longitude: pair[0])
        }
    }
    
    func simulateTrackingRoutes() {
        for routeToggle in routeToggles {
            simulateTrackingRoute(routeToggle: routeToggle)
        }
    }
    
    func simulateTrackingRoute(routeToggle: RouteToggleView) {
        if let id = routeToggle.id, routeToggle.getState() == true,
           let routesData = viewModel.busRoutes.first(where: { $0.id == id }) {
            let coordinates = convertToCoordinates(from: routesData.coordinates)
            self.routesStatus[id]!.busAnnotation = trackingVC!.trackingMapView.addRouteBusAnnotation(id: id, coordinate: coordinates[self.routesStatus[id]!.simulateIndex])
            
            // Move the annotation along the route every second
            Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { timer in
                if !self.isTrackingActive {
                    timer.invalidate()
                    return
                }
                if self.routesStatus[id]!.simulateIndex >= coordinates.count {
                    for jIndex in 0..<coordinates.count {
                        self.trackingVC?.trackingMapView.updateFeatureColor(at: jIndex, sourceId: id, isCovered: false)
                    }
                    self.routesStatus[id]!.simulateIndex = 0
                    self.routesStatus[id]?.routeCoordinates = []
                    self.reloadTableView()
                }
                
                // Move annotation forward
                UIView.animate(withDuration: 0.5) {
                    self.routesStatus[id]!.busAnnotation!.coordinate = coordinates[self.routesStatus[id]!.simulateIndex]
                    
                    self.trackingVC?.trackingMapView.updateDashLayer(routeId: id, coordinates: [coordinates[self.routesStatus[id]!.simulateIndex]])
                    self.trackingVC?.trackingMapView.updateFeatureColor(at: self.routesStatus[id]!.simulateIndex, sourceId: id, isCovered: true)
                    
                }
                self.routesStatus[id]!.simulateIndex += 1
                if let routeStatus = self.routesStatus[id], routeStatus.simulateIndex < coordinates.count {
                    self.routesStatus[id]!.routeCoordinates.append(RouteCoordinate(time: Date(), coordinate: coordinates[routeStatus.simulateIndex] ))
                    self.reloadTableView()
                    Task {
                        await self.batchEvaluateGeofence(coordinate: coordinates[self.routesStatus[id]!.simulateIndex], collectionName: routesData.geofenceCollection)
                    }
                }

            }
        }
    }
    
    func fetchGeoFences() async {
        if routeGeofences.count > 0 { return }
        for route in viewModel.busRoutes {
                let geofences = await trackingVC?.viewModel.fetchListOfGeofences(collectionName: route.geofenceCollection)
                routeGeofences[route.geofenceCollection] = geofences
        }
    }

    func batchEvaluateGeofence(coordinate: CLLocationCoordinate2D, collectionName: String) async {
        await trackingVC?.viewModel.evaluateGeofence(coordinate: coordinate, collectionName: collectionName)
    }
    
    func drawGeofences() {
        for routeToggle in routeToggles {
            if let id = routeToggle.id, routeToggle.getState() == true {
                if let geofenceCollection = viewModel.busRoutes.first(where: { $0.id == id })?.geofenceCollection, let geofences = routeGeofences[geofenceCollection] {
                    trackingVC?.viewModel.showGeofences(routeId: id, geofences: geofences)
                }
            }
        }
    }
    
    func clearGeofences() {
        trackingVC?.removeGeofencesFromMap()
    }
    
    func drawTrackingRoutes() {
        for routeToggle in routeToggles {
            if let id = routeToggle.id, routeToggle.getState() == true, !routesStatus[id]!.isActive {
                if let routesData = viewModel.busRoutes.first(where: { $0.id == id }) {
                    let coordinates = convertToCoordinates(from: routesData.coordinates)
                    trackingVC?.viewModel.drawTrackingRoute(routeId: id, coordinates: coordinates)
                    routesStatus[id]?.isActive = true
                }
            }
        }
    }
    
    private func trackingAppearanceChanged(isVisible: Bool) {
        let userInfo = ["isVisible" : isVisible]
        NotificationCenter.default.post(name: Notification.trackingAppearanceChanged, object: nil, userInfo: userInfo)
    }
    
    func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.adjustTableViewHeight()
        }
    }
}

