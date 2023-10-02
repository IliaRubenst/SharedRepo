//
//  SymbolsListCell.swift
//  CyptoPulse
//
//  Created by Ilia Ilia on 27.09.2023.
//

import UIKit

class SymbolsListCell: UITableViewCell {
    static let identifier = "CustomCell"
    
    private let cellStackView = UIStackView()
    private let rightSideCellStackView = UIStackView()
    
    let symbolLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    
    private let volumeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    
    let percentChangeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(symbolLabel: String, priceLabel: String, volumeLabel: String, percentChangeLabel: String) {
        self.symbolLabel.text = symbolLabel
        self.priceLabel.text = priceLabel
        self.volumeLabel.text = volumeLabel
        self.percentChangeLabel.text = percentChangeLabel
    }
    
    private func setupUI() {
        self.contentView.addSubview(cellStackView)
        
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.textAlignment = .left
        
        volumeLabel.translatesAutoresizingMaskIntoConstraints = false
        volumeLabel.textAlignment = .left
        
        percentChangeLabel.translatesAutoresizingMaskIntoConstraints = false
        percentChangeLabel.textAlignment = .left
        
        rightSideCellStackView.addArrangedSubview(priceLabel)
        rightSideCellStackView.addArrangedSubview(volumeLabel)
        rightSideCellStackView.addArrangedSubview(percentChangeLabel)

        rightSideCellStackView.axis = .vertical
        rightSideCellStackView.distribution = .equalCentering
        rightSideCellStackView.alignment = .leading
        rightSideCellStackView.spacing = 0.5
        
        cellStackView.spacing = 0.5
        cellStackView.axis = .horizontal
        cellStackView.distribution = .fillEqually
        cellStackView.alignment = .center
        
        cellStackView.addArrangedSubview(symbolLabel)
        cellStackView.addArrangedSubview(rightSideCellStackView)
        
        cellStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cellStackView.topAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.topAnchor),
            cellStackView.bottomAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.bottomAnchor),
            cellStackView.leadingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leadingAnchor),
            cellStackView.trailingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.trailingAnchor)
        ])
    }
}