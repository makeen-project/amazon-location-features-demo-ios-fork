//
//  POICardView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

final class POICardView: UIView {
    weak var delegate: POICardViewModelOutputDelegate?
    var dataModel: MapModel! {
        didSet {
            self.poiTitle.text = dataModel.placeName
            if let address = dataModel.placeAddress, address != "" {
                self.poiAddress.text = address
            } else if let lat = dataModel.placeLat, let long = dataModel.placeLong {
                self.poiTitle.text = "\(long), \(lat)"
            }
           
            if let duration = dataModel.duration {
                self.durationLabel.isHidden = false
                self.durationIconView.isHidden = false
                self.durationLabel.text = duration
            } else {
                self.durationIconView.isHidden = true
                self.durationLabel.isHidden = true
            }
          
            if let distance = dataModel.distance, distance != 0 {
                self.distanceLabel.isHidden = false
                self.dotView.isHidden = false
                self.distanceLabel.text = distance.formatToKmString()
            } else {
                self.dotView.isHidden = true
                self.distanceLabel.isHidden = true
            }

            var height: CGFloat = 200

            if let place = dataModel.place {
                if let schedule = place.openingHours {
                    scheduleDetail.text = schedule.map { $0.display!.joined(separator: "\n") }.joined(separator: "\n")
                    height += 40 // Additional padding
                }

                if let websites = place.contacts?.websites {
                    webLabel.text = websites.map { $0.value! }.joined(separator: "\n")
                    height += 40 // Additional padding
                }

                if let phones = place.contacts?.phones {
                    phoneLabel.text = phones.map { $0.value! }.joined(separator: "\n")
                    height += 40 // Additional padding
                }
                
                // Assuming label widths are the same; adjust as needed
                let labelWidth: CGFloat = scheduleDetail.frame.width // Use appropriate frame width
                let font = scheduleDetail.font ?? .amazonFont(type: .regular, size: 13)

                // Calculate precise heights for each label
                height += calculateHeight(for: scheduleDetail.text, font: font, width: labelWidth)
                height += calculateHeight(for: webLabel.text, font: font, width: labelWidth)
                height += calculateHeight(for: phoneLabel.text, font: font, width: labelWidth)
            }
            
            scheduleTitleContainer.isHidden = !(scheduleDetail.text != nil && !scheduleDetail.text!.isEmpty)
            scheduleValuesContainer.isHidden = !(scheduleDetail.text != nil && !scheduleDetail.text!.isEmpty)
            webValuesContainer.isHidden = !(webLabel.text != nil && !webLabel.text!.isEmpty)
            phoneValuesContainer.isHidden = !(phoneLabel.text != nil && !phoneLabel.text!.isEmpty)
            
            errorLabel.text = errorMessage
            errorLabel.isHidden = errorMessage == nil
            infoButton.isHidden = errorInfoMessage == nil
            
            let hasDistanceValues = dataModel.duration != nil || (dataModel.distance ?? 0) != 0
            let hideDistanceValuesContainer = !hasDistanceValues && !isLoadingData
            distanceValuesContainer.isHidden = hideDistanceValuesContainer
            
            delegate?.setPOIHeight(height)
        }
    }
    
    // Helper function to calculate height for each label
    func calculateHeight(for text: String?, font: UIFont, width: CGFloat) -> CGFloat {
        guard let text = text, !text.isEmpty else { return 0 }
        let textAttributes: [NSAttributedString.Key: Any] = [.font: font]
        let boundingRect = (text as NSString).boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: textAttributes,
            context: nil
        )
        return ceil(boundingRect.height) // Round up to the nearest whole number
    }
    
    var isLoadingData: Bool = false {
        didSet {
            placeholderAnimator.setupAnimationStatus(isActive: isLoadingData)
        }
    }
    
    var errorMessage: String?
    var errorInfoMessage: String?
    
    private var titleTopOffset: CGFloat = 20
    
    private let containerView: UIView =  {
       let view = UIView()
        view.backgroundColor = .searchBarBackgroundColor
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.cornerRadius = 20
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private let topStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        return stackView
    }()
    
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private let poiTitle: LargeTitleLabel = {
        let label = LargeTitleLabel()
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let poiAddress: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .amazonFont(type: .regular, size: 13)
        label.textColor = .searchBarTintColor
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private lazy var copyIconButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .lsGrey
        button.setImage(.copyIcon, for: .normal)
        button.addTarget(self, action: #selector(copyButtonAction), for: .touchUpInside)
        button.isUserInteractionEnabled = true
        return button
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .equalSpacing
        stackView.alignment = .leading
        stackView.isUserInteractionEnabled = true
        return stackView
    }()
    
    private let distanceValuesContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let distanceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .amazonFont(type: .bold, size: 13)
        label.textColor = .black
        label.numberOfLines = 2
        return label
    }()
    
    private let durationIconView: UIImageView = {
        let iv = UIImageView(image: .carIcon)
        iv.tintColor = .black
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.accessibilityIdentifier = ViewsIdentifiers.PoiCard.travelTimeLabel
        label.textAlignment = .left
        label.font = .amazonFont(type: .bold, size: 13)
        label.textColor = .black
        label.numberOfLines = 2
        return label
    }()
    
    private let detailsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .equalSpacing
        stackView.alignment = .leading
        return stackView
    }()
    
    private var detailsSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lsLight3
        return view
    }()
    
    private let scheduleValuesContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let scheduleTitleContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let scheduleIconView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "clock"))
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .systemGray
        return iv
    }()
    
    private let scheduleTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .amazonFont(type: .regular, size: 13)
        label.textColor = .black
        label.text = "Schedule"
        return label
    }()
    
    private lazy var expandIconView: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .lsGrey
        button.setImage(.expandDownIcon, for: .normal)
        button.addTarget(self, action: #selector(chevronButtonAction), for: .touchUpInside)
        return button
    }()
    
    private let scheduleDetail: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .amazonFont(type: .regular, size: 13)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    private let webValuesContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let webIconView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "globe"))
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .systemGray
        return iv
    }()
    
    private let webLabel: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.dataDetectorTypes = [.link]
        textView.backgroundColor = .searchBarBackgroundColor
        textView.linkTextAttributes = [.foregroundColor: UIColor.lsPrimary]
        textView.font = .amazonFont(type: .regular, size: 13)
        textView.textAlignment = .left
        return textView
    }()
    
    private let phoneValuesContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let phoneIconView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "phone"))
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .systemGray
        return iv
    }()
    
    private let phoneLabel: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.dataDetectorTypes = [.phoneNumber]
        textView.backgroundColor = .searchBarBackgroundColor
        textView.linkTextAttributes = [.foregroundColor: UIColor.lsPrimary]
        textView.font = .amazonFont(type: .regular, size: 13)
        textView.textAlignment = .left
        return textView
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .amazonFont(type: .regular, size: 13)
        label.textColor = .lsInfo
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var infoButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .lsGrey
        button.setImage(.infoIcon, for: .normal)
        button.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(infoButtonAction), for: .touchUpInside)
        return button
    }()
        
    private lazy var directionButton: UIButton = {
        let button = UIButton(type: .system)
        button.accessibilityIdentifier = ViewsIdentifiers.PoiCard.directionButton
        button.backgroundColor = .lsPrimary
        button.contentMode = .scaleAspectFit
        button.layer.cornerRadius = 10
        button.isUserInteractionEnabled = true
        button.addTarget(self, action: #selector(directionButtonAction), for: .touchUpInside)
        return button
    }()
    
    private let dotView: UIView = {
        let view = UIView()
        view.backgroundColor = .searchBarTintColor
        view.layer.cornerRadius = 3
        return view
    }()
    
    private let directionIcon: UIImageView = {
        let iv = UIImageView(image: .directionMapIcon.withRenderingMode(.alwaysTemplate))
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
        return iv
    }()
    
    private let directionLabel: UILabel = {
        let label = UILabel()
        label.text = StringConstant.direction
        label.textAlignment = .left
        label.font = .amazonFont(type: .bold, size: 16)
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()
    
    private let buttonContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(.closeIcon, for: .normal)
        button.tintColor = .closeButtonTintColor
        button.backgroundColor = .closeButtonBackgroundColor
        button.isUserInteractionEnabled = true
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(poiCardDismiss), for: .touchUpInside)
        return button
    }()
    
    private let directionPlaceholderView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.backgroundColor = .mapElementDiverColor
        return view
    }()
    
    private let durationPlaceholderView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.backgroundColor = .mapElementDiverColor
        return view
    }()
    
    private lazy var placeholderAnimator: PlaceholderAnimator = {
        let dataViews = [distanceLabel, durationLabel, durationIconView]
        let placeholderViews = [durationPlaceholderView, directionPlaceholderView]
        return PlaceholderAnimator(dataViews: dataViews, placeholderViews: placeholderViews)
    }()
    
    var scheduleDetailHeight = 60
    
    convenience init(titleTopOffset: CGFloat, isCloseButtonHidden: Bool) {
        self.init()
        self.titleTopOffset = titleTopOffset
        self.accessibilityIdentifier = ViewsIdentifiers.PoiCard.poiCardView
        setupViews()
        closeButton.isHidden = isCloseButtonHidden
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError(.errorInitWithCoder)
    }
    
    @objc private func poiCardDismiss() {
        delegate?.dismissPoiView()
        NotificationCenter.default.post(name: Notification.Name("POICardDismissed"), object: nil)
    }
    
    func setupViews() {
        self.addSubview(containerView)
        headerView.addSubview(closeButton)
        headerView.addSubview(poiTitle)
        
        containerView.addSubview(topStackView)
        containerView.addSubview(infoButton)
        
        topStackView.addArrangedSubview(headerView)
        topStackView.addArrangedSubview(stackView)
        
        stackView.addArrangedSubview(poiAddress)
        stackView.addSubview(copyIconButton)
        
        stackView.addArrangedSubview(errorLabel)
        stackView.addArrangedSubview(distanceValuesContainer)
        
        distanceValuesContainer.addSubview(durationIconView)
        distanceValuesContainer.addSubview(dotView)
        distanceValuesContainer.addSubview(durationLabel)
        distanceValuesContainer.addSubview(distanceLabel)
        
        stackView.addArrangedSubview(detailsStackView)
        
        detailsStackView.addArrangedSubview(detailsSeparatorView)
        
        detailsStackView.addArrangedSubview(scheduleTitleContainer)
        scheduleTitleContainer.addSubview(scheduleIconView)
        scheduleTitleContainer.addSubview(scheduleTitleLabel)
        scheduleTitleContainer.addSubview(expandIconView)
        
        detailsStackView.addArrangedSubview(scheduleValuesContainer)
        scheduleValuesContainer.addSubview(scheduleDetail)
        
        detailsStackView.addArrangedSubview(webValuesContainer)
        webValuesContainer.addSubview(webIconView)
        webValuesContainer.addSubview(webLabel)
        
        detailsStackView.addArrangedSubview(phoneValuesContainer)
        phoneValuesContainer.addSubview(phoneIconView)
        phoneValuesContainer.addSubview(phoneLabel)
        
        containerView.addSubview(directionButton)
        directionButton.addSubview(buttonContainerView)
        buttonContainerView.addSubview(directionIcon)
        buttonContainerView.addSubview(directionLabel)
        
        containerView.addSubview(directionPlaceholderView)
        containerView.addSubview(durationPlaceholderView)
       
        containerView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        
        topStackView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-5)
        }
        
        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.trailing.equalToSuperview().offset(-11)
            $0.height.width.equalTo(30)
        }
        
        poiTitle.snp.makeConstraints {
            $0.top.equalToSuperview().offset(titleTopOffset)
            $0.leading.equalToSuperview()
            $0.trailing.equalTo(closeButton.snp.leading).offset(-5)
            $0.height.equalTo(28)
            $0.bottom.equalToSuperview()
        }
        
        poiAddress.snp.makeConstraints {
            $0.height.greaterThanOrEqualTo(18)
        }
        
        copyIconButton.snp.makeConstraints {
            $0.height.equalTo(20)
            $0.width.equalTo(18)
            $0.leading.equalTo(poiAddress.snp.trailing).offset(10)
        }
        
        distanceValuesContainer.snp.makeConstraints {
            $0.height.equalTo(18)
        }
        
        distanceLabel.snp.makeConstraints {
            $0.top.bottom.leading.equalToSuperview()
        }
        
        dotView.snp.makeConstraints {
            $0.leading.equalTo(distanceLabel.snp.trailing).offset(10)
            $0.height.width.equalTo(3)
            $0.centerY.equalTo(distanceLabel.snp.centerY)
        }
        
        durationIconView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalTo(dotView.snp.leading).offset(10)
            $0.width.equalTo(18)
        }
        
        durationLabel.snp.makeConstraints {
            $0.top.bottom.trailing.equalToSuperview()
            $0.leading.equalTo(durationIconView.snp.trailing).offset(10)
        }
        
        detailsSeparatorView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.width.equalToSuperview().offset(10)
        }
        
        detailsStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
        }
        
        scheduleIconView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.width.equalTo(18)
        }
        
        scheduleTitleContainer.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
        }
        
        scheduleTitleLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalTo(scheduleIconView.snp.trailing).offset(10)
        }
        
        expandIconView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(12)
            $0.width.equalTo(14)
        }
        
        scheduleValuesContainer.snp.makeConstraints {
            $0.height.equalTo(scheduleDetailHeight)
        }
        
        scheduleDetail.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.leading.equalTo(scheduleIconView.snp.trailing).offset(10)
        }
        
        webIconView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalToSuperview()
            $0.width.equalTo(18)
        }
        
        webLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.leading.equalTo(webIconView.snp.trailing).offset(10)
        }
        
        phoneIconView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalToSuperview()
            $0.width.equalTo(18)
        }
        
        phoneLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.leading.equalTo(phoneIconView.snp.trailing).offset(10)
        }
        
        infoButton.snp.makeConstraints {
            $0.height.width.equalTo(13.5)
            $0.leading.equalTo(errorLabel.snp.trailing).offset(5)
            $0.centerY.equalTo(errorLabel.snp.centerY)
        }
        
        directionButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(48)
            $0.bottom.equalToSuperview().offset(-10)
        }
        
        buttonContainerView.snp.makeConstraints {
            $0.height.equalTo(22)
            $0.width.equalTo(120)
            $0.centerX.centerY.equalToSuperview()
        }
        
        directionIcon.snp.makeConstraints {
            $0.height.width.equalTo(22)
            $0.leading.equalToSuperview()
        }
        
        directionLabel.snp.makeConstraints {
            $0.height.equalTo(22)
            $0.width.equalTo(77)
            $0.leading.equalTo(directionIcon.snp.trailing).offset(19)
        }
        
        directionPlaceholderView.snp.makeConstraints {
            $0.centerY.equalTo(durationLabel.snp.centerY)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(8)
            $0.width.equalTo(40)
        }
        
        durationPlaceholderView.snp.makeConstraints {
            $0.centerY.equalTo(durationLabel.snp.centerY)
            $0.leading.equalTo(directionPlaceholderView.snp.trailing).offset(5)
            $0.height.equalTo(8)
            $0.width.equalTo(40)
        }
        
        directionPlaceholderView.layer.cornerRadius = 4
        durationPlaceholderView.layer.cornerRadius = 4
        
        webLabel.delegate = self
        phoneLabel.delegate = self
        
        chevronButtonAction()
    }
}

extension POICardView: UITextViewDelegate {
    @objc func directionButtonAction() {
        delegate?.showDirectionView(seconDestination: dataModel)
    }
    
    @objc private func copyButtonAction() {
        UIPasteboard.general.string = "\(poiTitle.text ?? ""), \(poiAddress.text ?? "")"
    }
    
    @objc private func infoButtonAction() {
        guard let errorInfoMessage else { return }
        let model = AlertModel(title: StringConstant.locationPermissionDenied, message: errorInfoMessage, cancelButton: nil)
        delegate?.showAlert(model)
    }
    
    @objc private func chevronButtonAction() {
        let labelWidth: CGFloat = scheduleDetail.frame.width // Use appropriate frame width
        let font = scheduleDetail.font ?? .amazonFont(type: .regular, size: 13)
        
        scheduleDetail.isHidden.toggle()
        expandIconView.setImage(scheduleDetail.isHidden ? .expandDownIcon : .expandUpIcon, for: .normal)
        scheduleDetailHeight = Int(scheduleDetail.isHidden ? 0 : calculateHeight(for: scheduleDetail.text, font: font, width: labelWidth))
        scheduleValuesContainer.snp.updateConstraints {
            $0.height.equalTo(scheduleDetailHeight)
        }
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return true
    }
}
