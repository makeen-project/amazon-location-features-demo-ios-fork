import UIKit

class LeaveOptions: UIView {

    var viewModel: DirectionViewModel!
    var setLeaveNowHandler: Handler<Any>?
    
    private lazy var segmentControl: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["Leave now", "Leave at", "Arrive by"])
        segment.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        return segment
    }()

    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .inline
        return picker
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        //self.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.isUserInteractionEnabled = true
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError(.errorInitWithCoder)
    }
    
    private func setup() {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        self.addSubview(view)
        
//        view.snp.makeConstraints {
//            $0.top.equalToSuperview()
//            $0.width.equalToSuperview().multipliedBy(0.8)
//            $0.height.equalTo(200)
//        }
        
        view.addSubview(segmentControl)
        view.addSubview(datePicker)
        
        segmentControl.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.centerX.equalToSuperview()
        }
        
        datePicker.snp.makeConstraints {
            $0.top.equalTo(segmentControl.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }
        self.addSubview(view)
    }

    @objc private func segmentChanged() {
        // Handle segment control changes if needed
        //leaveNowCheckbox.setImage(UIImage(systemName: "square"), for: .normal)
        //leaveNowCheckbox.tag = 0
    }

    @objc private func setTapped() {
        if segmentControl.selectedSegmentIndex == 0 {
            viewModel.departNow = false
            viewModel.departureTime = nil
            viewModel.arrivalTime = datePicker.date
        }
        else if segmentControl.selectedSegmentIndex == 1 {
            viewModel.departNow = false
            viewModel.departureTime = datePicker.date
            viewModel.arrivalTime = nil
        }
        else if segmentControl.selectedSegmentIndex == 2 {
            viewModel.departNow = false
            viewModel.departureTime = nil
            viewModel.arrivalTime = datePicker.date
        }
        setLeaveNowHandler?([])
    }
}
