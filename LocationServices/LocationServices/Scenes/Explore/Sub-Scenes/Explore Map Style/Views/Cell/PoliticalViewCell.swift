import UIKit

class PoliticalViewCell: UITableViewCell {
    private let containerView: UIView = UIView()
    private let contentCellView: UIView = UIView()
    private var itemIcon = UILabel()
    
    private var itemTitle: UILabel = {
        var label = UILabel()
        label.font = .amazonFont(type: .regular, size: 16)
        label.textColor = .mapDarkBlackColor
        label.applyLocaleDirection()
        label.text = StringConstant.politicalView
        return label
    }()
    
    private var itemSubtitle: UILabel = {
        var label = UILabel()
        label.font = .amazonFont(type: .regular, size: 13)
        label.textColor = .gray
        label.applyLocaleDirection()
        label.text = StringConstant.mapRepresentation
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError(String.errorInitWithCoder)
    }
    
    private func setupViews() {
        self.addSubview(containerView)
        containerView.addSubview(contentCellView)
        containerView.addSubview(itemIcon)
        contentCellView.addSubview(itemTitle)
        contentCellView.addSubview(itemSubtitle)
        
        containerView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        
        contentCellView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalTo(itemIcon.snp.trailing).offset(2)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview().offset(-10)
        }
        
        itemIcon.snp.makeConstraints {
            $0.width.height.equalTo(24)
            $0.leading.equalToSuperview().offset(5)
            $0.top.equalToSuperview().offset(10)
        }
        
        itemTitle.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(5)
            $0.top.equalToSuperview()
            $0.trailing.lessThanOrEqualToSuperview().offset(-12)
        }
        
        itemSubtitle.snp.makeConstraints {
            $0.top.equalTo(itemTitle.snp.bottom).offset(5)
            $0.leading.equalTo(itemIcon.snp.leading)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalTo(contentCellView.snp.bottom)
        }
    }

    func configure(with politicalView: PoliticalViewType) {
        let countryFlag = flag(country: politicalView.flagCode)
        if politicalView.flagCode.isEmpty {
            itemIcon.isHidden = true
        }
        else {
            itemIcon.isHidden = false
        }
        itemTitle.text = politicalView.countryCode
        itemIcon.text = countryFlag
        itemIcon.font = UIFont.systemFont(ofSize: 24)
        itemSubtitle.text = politicalView.politicalDescription
    }
    
    func flag(country: String) -> String {
        let base: UInt32 = 127397
        var s = ""
        for v in country.unicodeScalars {
            s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
        }
        return String(s)
    }
}
