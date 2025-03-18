//
//  TrackingSimulationController.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit
import CoreLocation

final class TrackingSimulationController: UIViewController, UIScrollViewDelegate {
    enum Constants {
        static let titleOffsetiPhone: CGFloat = 27
        static let titleOffsetiPad: CGFloat = 0
        static let collapsedRouteHeight: Int = 56
        static let expandedRouteHeight: Int = 400
        static let collapsedTrackingHeight: Int = 56
        static let expandedTrackingHeight: Int = 400
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
        stackView.distribution = .equalSpacing
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
        return view
    }()
    
    var tableView: UITableView = {
        let tableView = UITableView()
        tableView.accessibilityIdentifier = ViewsIdentifiers.Tracking.trackingHistoryTableView
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 10
        tableView.isHidden = true
        return tableView
    }()
    
    var viewModel: TrackingHistoryViewModelProtocol! {
        didSet {
            viewModel.delegate = self
        }
    }
    
    private var busRoutes: [BusRoute] = []
    private var routeToggles: [RouteToggleView] = []
    var isTrackingActive: Bool = false
    var routeGeofences: [String: [GeofenceDataModel]] = [:]
    var routesStatus: [String: RouteStatus] = [:]
    
    struct RouteStatus {
        var id: String
        var isActive: Bool = false
        var simulateIndex: Int = 0
        var busAnnotation: ImageAnnotation?
    }
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(updateButtonStyle(_:)), name: Notification.updateStartTrackingButton, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTrackingHistory(_:)), name: Notification.updateTrackingHistory, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(trackingEventReceived(_:)), name: Notification.trackingEvent, object: nil)
        navigationController?.navigationBar.tintColor = .lsTetriary
        
        scrollView.delegate = self
        tableView.delegate = self
        
        setupHandlers()
        setupViews()
        setupTableView()
        
        scrollView.isHidden = !Reachability.shared.isInternetReachable
        noInternetConnectionView.isHidden = Reachability.shared.isInternetReachable
        
        startTracking()
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
        guard viewModel !== nil else {
            return
        }
        viewModel.changeTrackingStatus(state)
        self.headerView.updateButtonStyle(isTrackingStarted: state)
        self.view.setNeedsLayout()
    }
    
    
    @objc private func updateTrackingHistory(_ notification: Notification) {
        guard (notification.object as? TrackingHistoryViewModelProtocol) !== viewModel else { return }
        guard let history = notification.userInfo?["history"] as? [TrackingHistoryPresentation] else { return }
        viewModel.setHistory(history)
        reloadTableView()
    }
    
    @objc private func trackingEventReceived(_ notification: Notification) {
        guard let model = notification.userInfo?["trackingEvent"] as? TrackingEventModel else { return }
        
        let eventText: String
        switch model.trackerEventType {
        case .enter:
            eventText = StringConstant.entered
        case .exit:
            eventText = StringConstant.exited
        }
        
        let alertModel = AlertModel(title: model.geofenceId, message: "\(StringConstant.tracker) \(eventText) \(model.geofenceId)", cancelButton: nil)
        showAlert(alertModel)
    }
    
    private func setupHandlers() {
        headerView.trackingButtonHandler = { state in
             self.startTracking()
        }
        
        headerView.showAlertCallback = showAlert(_:)
        headerView.showAlertControllerCallback = { [weak self] alertController in
            self?.present(alertController, animated: true)
        }
        scrollView.delegate = self
    }
    
    private func setupViews() {
        scrollView.isScrollEnabled = true
        view.backgroundColor = .searchBarBackgroundColor
        view.addSubview(headerView)
        view.addSubview(scrollView)
        scrollView.addSubview(scrollViewContentView)
        scrollViewContentView.addSubview(routeContainerView)
        scrollViewContentView.addSubview(trackingContainerView)

        trackingContainerView.addArrangedSubview(trackingHeaderView)
        trackingContainerView.addArrangedSubview(tableView)
        
        trackingHeaderView.addSubview(trackingLabel)
        trackingHeaderView.addSubview(trackingDetailLabel)
        trackingHeaderView.addSubview(changeRouteButton)
        trackingHeaderView.addSubview(trackingExpandImage)
        trackingHeaderView.addSubview(trackingSeperatorView)
        
        view.addSubview(noInternetConnectionView)
        
        headerView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
        }
        
        scrollView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(headerView.snp.bottom).offset(16)
        }
        
        scrollViewContentView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
            $0.width.equalTo(scrollView.frameLayoutGuide)
            $0.height.equalTo(1000)
        }
        
        trackingContainerView.snp.makeConstraints {
            $0.top.equalTo(routeContainerView.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(Constants.collapsedTrackingHeight)
        }
        
        tableView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
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
            $0.centerY.equalTo(trackingExpandImage.snp.centerY)
            $0.trailing.equalTo(trackingExpandImage.snp.leading).offset(-16)
            $0.width.equalTo(60)
            $0.height.equalTo(18)
        }
        
        trackingExpandImage.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(-16)
            $0.width.height.equalTo(24)
        }
        
        trackingSeperatorView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
        
        noInternetConnectionView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview()
        }
        
        generateRouteToggles()

        setChangeMenu()
        if let route = busRoutes.first {
            setTrackingHeaders(route: route)
        }
    }
    
    func setChangeMenu() {
        let menuItems = busRoutes.map { route in
            UIAction(title: route.name) { _ in
                print("Selected route: \(route.name)")
                self.setTrackingHeaders(route: route)
            }
        }

        let menu = UIMenu(children: menuItems)
        changeRouteButton.menu = menu
    }
    
    func getBusRoutesData() -> BusRoutesData? {
        do {
            if let jsonData = JsonHelper.loadJSONFile(fileName: "RoutesData") {
                let decoder = JSONDecoder()
                let busRoutesData = try decoder.decode(BusRoutesData.self, from: jsonData)
                return busRoutesData
            }
            return nil
        }
        catch {
            print("Error decoding BusRoutesData: \(error)")
            return nil
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
            $0.top.equalTo(headerView.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(Constants.collapsedRouteHeight)
        }
        
        routeHeaderView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(56)
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
        
        let busRoutesData = getBusRoutesData()
        busRoutes = busRoutesData?.busRoutesData ?? []
            for route in busRoutes {
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
    
    func setTrackingHeaders(route: BusRoute) {
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
    
    private func toggleRouteOption(state: inout Bool) {
        state.toggle()
        routeExpandImage.image = UIImage(systemName: state ? "chevron.down" : "chevron.up")
        routeTogglesContainerView.isHidden = !state
        let height = state ? Constants.expandedRouteHeight: Constants.collapsedRouteHeight
        
        routeContainerView.snp.updateConstraints {
            $0.height.equalTo(height)
        }

        updateScrollViewContentSize()
    }
    
    private func toggleTrackingOption(state: inout Bool) {
        state.toggle()
        trackingExpandImage.image = UIImage(systemName: state ? "chevron.down" : "chevron.up")
        tableView.isHidden = !state
        let height = state ? Constants.expandedTrackingHeight: Constants.collapsedTrackingHeight
        trackingContainerView.snp.updateConstraints {
            $0.height.equalTo(height)
        }
        updateScrollViewContentSize()
    }
    
    func adjustTableViewHeight() {
        tableView.snp.remakeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            if(isiPad){
                $0.height.equalTo(self.view.snp.height).offset(-350)
            }
            else {
                let contentHeight = min(tableView.contentSize.height+100, UIScreen.main.bounds.height - 400)
                $0.height.equalTo(contentHeight)
            }
        }
    }
    
    func updateScrollViewContentSize() {
        let scrollHeight: CGFloat = 1200
        let totalContentHeight = scrollHeight
        scrollViewContentView.snp.updateConstraints {
            $0.height.equalTo(totalContentHeight)
        }
    }
    
    func startTracking() {
        isTrackingActive.toggle()

        updateButtonStyle(state: isTrackingActive)
        if !isTrackingActive {
            return
        }
        trackingVC?.trackingMapView.mapView.mapView.setCenter(CLLocationCoordinate2D(latitude: 49.27046144661014, longitude: -123.13319444634126), zoomLevel: 12, animated: false)
        let count = routeToggles.count(where: { $0.getState()})
        if count == 0 {
            routeToggles.first?.changeState()
        }
        clearGeofences()
        Task {
            await fetchGeoFences()
            drawGeofences()
        }
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
        if let id = routeToggle.id, routeToggle.getState() == true {
            if let routesData = busRoutes.first(where: { $0.id == id }) {
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
                   }

                   // Move annotation forward
                   UIView.animate(withDuration: 0.5) {
                       self.routesStatus[id]!.busAnnotation!.coordinate = coordinates[self.routesStatus[id]!.simulateIndex]
                       self.trackingVC?.trackingMapView.updateDashLayer(routeId: id, coordinates: [coordinates[self.routesStatus[id]!.simulateIndex]])
                       self.trackingVC?.trackingMapView.updateFeatureColor(at: self.routesStatus[id]!.simulateIndex, sourceId: id, isCovered: true)
                       self.routesStatus[id]!.simulateIndex += 1
                   }
               }
            }
        }
    }
    
    func fetchGeoFences() async {
        if routeGeofences.count > 0 { return }
        for route in busRoutes {
                let geofences = await trackingVC?.viewModel.fetchListOfGeofences(collectionName: route.geofenceCollection)
                routeGeofences[route.geofenceCollection] = geofences
        }
    }
    
    func drawGeofences() {
        for routeToggle in routeToggles {
            if let id = routeToggle.id, routeToggle.getState() == true {
                if let geofenceCollection = busRoutes.first(where: { $0.id == id })?.geofenceCollection, let geofences = routeGeofences[geofenceCollection] {
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
                if let routesData = busRoutes.first(where: { $0.id == id }) {
                    let coordinates = convertToCoordinates(from: routesData.coordinates)
                    trackingVC?.viewModel.drawTrackingRoute(routeId: id, coordinates: coordinates)
                    routesStatus[id]?.isActive = true
                }
            }
        }
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if scrollView == self.tableView {
//            let isReachedBottom = scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.size.height
//            self.tableView.isScrollEnabled = !isReachedBottom
//            self.scrollView.isScrollEnabled = isReachedBottom
//        } else if scrollView == self.scrollView {
//            let isReachedTop = scrollView.contentOffset.y <= 0
//            self.tableView.isScrollEnabled = isReachedTop
//            self.scrollView.isScrollEnabled = !isReachedTop
//        }
//        self.scrollView.isScrollEnabled = false
//    }
    
    private func trackingAppearanceChanged(isVisible: Bool) {
        let userInfo = ["isVisible" : isVisible]
        NotificationCenter.default.post(name: Notification.trackingAppearanceChanged, object: nil, userInfo: userInfo)
    }
}

extension TrackingSimulationController: TrackingHistoryViewModelOutputDelegate {
    func stopTracking() {
        
    }
    
    func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.adjustTableViewHeight()
        }
    }
}

extension TrackingSimulationController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none // Ensures popover on all devices
    }
}

class MenuViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false

        let option1 = UIButton(type: .system)
        option1.setTitle("Option 1", for: .normal)
        option1.addTarget(self, action: #selector(option1Tapped), for: .touchUpInside)

        let option2 = UIButton(type: .system)
        option2.setTitle("Option 2", for: .normal)
        option2.addTarget(self, action: #selector(option2Tapped), for: .touchUpInside)

        stackView.addArrangedSubview(option1)
        stackView.addArrangedSubview(option2)

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc func option1Tapped() {
        print("Option 1 Selected")
        dismiss(animated: true)
    }

    @objc func option2Tapped() {
        print("Option 2 Selected")
        dismiss(animated: true)
    }
}
