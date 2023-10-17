//
//  UIViewController+Extension.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

extension UIViewController {
    private static let statusBarBlurViewTag = 111
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func blurStatusBar(includeAdditionalSafeArea: Bool = false) {
        guard view.viewWithTag(Self.statusBarBlurViewTag) == nil else { return }
        
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurView.tag = Self.statusBarBlurViewTag
        view.addSubview(blurView)
        
        var offset: CGFloat = 0
        
        if let navigationController, !navigationController.navigationBar.isHidden {
            offset += navigationController.navigationBar.frame.height
        }
        if !includeAdditionalSafeArea {
            offset += navigationController?.additionalSafeAreaInsets.top ?? 0
        }
        
        blurView.snp.makeConstraints {
            $0.top.trailing.leading.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(-offset)
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        // Handle keyboard show event
        self.updateBottomSheetHeight(to: getLargeDetentHeight())
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        // Handle keyboard hide event
    }
    
    private struct DetentHeights {
        static var small = DefaultDetentHeights.small
        static var medium = DefaultDetentHeights.medium
        static var large = DefaultDetentHeights.large
    }
    
    private struct DefaultDetentHeights {
        static var small = 0.1
        static var medium = 0.5
        static var large = 0.95
    }
    
    func getSmallDetentHeight() -> CGFloat {
        return self.parent!.view.frame.height * DetentHeights.small
    }
    
    func getMediumDetentHeight() -> CGFloat {
        return self.parent!.view.frame.height * DetentHeights.medium
    }
    
    func getLargeDetentHeight() -> CGFloat {
        return self.parent!.view.frame.height * DetentHeights.large
    }
    
   func createGrabberView() -> UIView {
        let grabberView = UIView()
       grabberView.accessibilityIdentifier = ViewsIdentifiers.General.bottomGrabberView
        grabberView.backgroundColor = .systemGray4
        grabberView.layer.cornerRadius = 2.5
        grabberView.translatesAutoresizingMaskIntoConstraints = false
        return grabberView
    }
    
    func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func dismissBottomSheet() {
        removeKeyboardObservers()
        self.view.removeFromSuperview()
    }
    
    func presentBottomSheet(parentController: UIViewController?) {
        addKeyboardObservers()
        if(parentController != nil){
            parentController?.addChild(self)
            parentController?.view.addSubview(self.view)
            self.didMove(toParent: parentController)
            self.view.snp.makeConstraints {
                $0.leading.equalTo(parentController!.view.snp.leading)
                $0.trailing.equalTo(parentController!.view.snp.trailing)
                $0.bottom.equalTo(parentController!.view.snp.bottom)
            }
        }
    }
    
    func enableBottomSheetGrab(smallHeight:CGFloat = DefaultDetentHeights.small, mediumHeight:CGFloat = DefaultDetentHeights.medium, largeHeight:CGFloat = DefaultDetentHeights.large) {
        
        DetentHeights.small = smallHeight
        DetentHeights.medium = mediumHeight
        DetentHeights.large = largeHeight
        
        let grabberView = createGrabberView()
        view.addSubview(grabberView)
        grabberView.snp.makeConstraints{
            $0.width.equalTo(36)
            $0.height.equalTo(5)
            $0.centerX.equalTo(view.snp.centerX)
            $0.top.equalTo(view.snp.top).offset(8)
        }
        
        let height = getMediumDetentHeight()
        
        self.view.snp.makeConstraints{
            $0.height.equalTo(height)
        }

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        self.view.addGestureRecognizer(panGestureRecognizer)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
       grabberView.addGestureRecognizer(tapGestureRecognizer)
        
        NotificationCenter.default.post(name: Notification.updateMapLayerItems, object:nil, userInfo: ["height": height+8])
    }
    
    func updateBottomSheetHeight(to height: CGFloat) {
        self.view.snp.updateConstraints{
            $0.height.equalTo(height)
        }
        if(height < getLargeDetentHeight()){
            dismissKeyboard()
            NotificationCenter.default.post(name: Notification.updateMapLayerItems, object:nil, userInfo: ["height": height+8])
        }
    }
    
    func setBottomSheetHeight(to height: CGFloat) {
        self.view.snp.makeConstraints {
            $0.height.equalTo(height)
        }
        if(height < getLargeDetentHeight()){
            dismissKeyboard()
            NotificationCenter.default.post(name: Notification.updateMapLayerItems, object:nil, userInfo: ["height": height+8])
        }
    }

    @objc private func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.view)
        let currentHeight = view.frame.height - translation.y

        let newHeight = max(min(currentHeight, getLargeDetentHeight()), getSmallDetentHeight())

        switch recognizer.state {
        case .changed:
            if(currentHeight < getLargeDetentHeight()){
                self.updateBottomSheetHeight(to: currentHeight)
                recognizer.setTranslation(.zero, in: view)
            }
        case .ended:
            let velocity = recognizer.velocity(in: view).y
            let targetDetentHeight = getTargetDetentHeight(newHeight: newHeight, velocity: velocity)

            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
                self.updateBottomSheetHeight(to: targetDetentHeight)
                self.parent?.view.layoutIfNeeded()
            }
        default:
            break
        }
    }

    private func getTargetDetentHeight(newHeight: CGFloat, velocity: CGFloat) -> CGFloat {
        let targetDetentHeight: CGFloat

        if abs(velocity) < 500 {
            targetDetentHeight = snapToNearestDetent(newHeight)
        } else {
            targetDetentHeight = snapToNextDetent(newHeight, velocity: velocity)
        }

        return targetDetentHeight
    }

    private func snapToNearestDetent(_ newHeight: CGFloat) -> CGFloat {
        let smallDiff = abs(newHeight - getSmallDetentHeight())
        let mediumDiff = abs(newHeight - getMediumDetentHeight())
        let largeDiff = abs(newHeight - getLargeDetentHeight())

        let minDiff = min(smallDiff, min(mediumDiff, largeDiff))

        switch minDiff {
        case smallDiff:
            return getSmallDetentHeight()
        case mediumDiff:
            return getMediumDetentHeight()
        default:
            return getLargeDetentHeight()
        }
    }

    private func snapToNextDetent(_ newHeight: CGFloat, velocity: CGFloat) -> CGFloat {
        let currentDetentHeight: CGFloat
        if newHeight < getMediumDetentHeight() {
            currentDetentHeight = getSmallDetentHeight()
        } else if newHeight < getLargeDetentHeight() {
            currentDetentHeight = getMediumDetentHeight()
        } else {
            currentDetentHeight = getLargeDetentHeight()
        }

        if velocity < 0 {
            return currentDetentHeight == getSmallDetentHeight() ? getMediumDetentHeight() : getLargeDetentHeight()
        } else {
            return currentDetentHeight == getLargeDetentHeight() ? getMediumDetentHeight() : getSmallDetentHeight()
        }
    }
    
    @objc private func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        let currentHeight = view.frame.height
        let targetDetentHeight: CGFloat

        if currentHeight >= getSmallDetentHeight() && currentHeight < getMediumDetentHeight() {
            targetDetentHeight = getMediumDetentHeight()
        } else if currentHeight >= getMediumDetentHeight() && currentHeight < getLargeDetentHeight() {
            targetDetentHeight = getLargeDetentHeight()
        } else {
            targetDetentHeight = getMediumDetentHeight()
        }

        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
            self.updateBottomSheetHeight(to: targetDetentHeight)
            self.view.layoutIfNeeded()
        }
    }
}

extension UIViewController: AlertPresentable {}
