//
//  DisplayTintViewCollectionCell.swift
//  pointercrate
//
//  Created by samara on 4/3/24.
//  Copyright (c) 2024 Samara M (khcrysalis)
//

import Foundation
import UIKit

class CollectionTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
	
	var selectedIndexPath: IndexPath?
	
	let collectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .horizontal
		layout.itemSize = CGSize(width: 120, height: 100)
		layout.minimumInteritemSpacing = 10
		
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.isPagingEnabled = false
		collectionView.backgroundColor = .clear
		return collectionView
	}()
	
	var collectionData = [String]()
	var collectionDataColors = [String]()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		collectionView.register(CollectionItemCell.self, forCellWithReuseIdentifier: "CollectionItemCell")
		collectionView.delegate = self
		collectionView.dataSource = self
		collectionView.allowsSelection = true
		collectionView.showsVerticalScrollIndicator = false
		collectionView.showsHorizontalScrollIndicator = false
		contentView.addSubview(collectionView)
		
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
			collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			collectionView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
		])
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setData(collectionData: [String], colors: [String]) {
		self.collectionData = collectionData
		self.collectionDataColors = colors
		collectionView.reloadData()
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return collectionData.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionItemCell", for: indexPath) as! CollectionItemCell
		cell.setData(title: collectionData[indexPath.item], colorHex: collectionDataColors[indexPath.item])
		
		let storedTintColor = Preferences.appTintColor.uiColor
		let storedCGColor = storedTintColor.cgColor
		
		if let storedColorIndex = collectionDataColors.firstIndex(where: { hex in
			let color = UIColor(hex: hex)
			return color.cgColor == storedCGColor
		}), indexPath.item == storedColorIndex {
			selectedIndexPath = indexPath
			cell.layer.borderWidth = 2.0
			cell.layer.borderColor = Preferences.appTintColor.uiColor.cgColor
			cell.layer.cornerRadius = 10.5
			cell.layer.cornerCurve = .continuous
		} else {
			cell.layer.borderColor = UIColor.clear.cgColor
			cell.layer.borderWidth = 0.0
			cell.layer.cornerCurve = .continuous
		}
		
		return cell
	}
	
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		selectedIndexPath = indexPath
		collectionView.reloadData()
		
		let selectedColorHex = collectionDataColors[indexPath.item]
		let selectedUIColor = UIColor(hex: selectedColorHex)
		Preferences.appTintColor = CodableColor(selectedUIColor)
		
		guard indexPath.item < collectionData.count else {
			return
		}

		_ = collectionData[indexPath.item]
		
        let keyWindow = UIApplication.shared.connectedScenes.compactMap { ($0 as? UIWindowScene)?.keyWindow }.last
        keyWindow?.tintColor = selectedUIColor
	}
}

class CollectionItemCell: UICollectionViewCell {
	let stackView: UIStackView = {
		let stackView = UIStackView()
		stackView.axis = .vertical
		stackView.alignment = .center
		stackView.spacing = 5
		return stackView
	}()
	
	let colorCircleView: UIView = {
		let view = UIView()
		return view
	}()
	
	let titleLabel: UILabel = {
		let label = UILabel()
		label.textAlignment = .center
		label.textColor = UIColor.secondaryLabel
		label.font = UIFont.systemFont(ofSize: 14)
		return label
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		contentView.addSubview(stackView)
		stackView.addArrangedSubview(colorCircleView)
		stackView.addArrangedSubview(titleLabel)
		
		stackView.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			stackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
			stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			
			colorCircleView.widthAnchor.constraint(equalToConstant: 30),
			colorCircleView.heightAnchor.constraint(equalToConstant: 30),
			
			titleLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor)
		])
		
		colorCircleView.layer.cornerRadius = 15
		colorCircleView.layer.borderWidth = 2.0
		colorCircleView.layer.borderColor = UIColor.black.withAlphaComponent(0.3).cgColor
		
		contentView.backgroundColor = .secondarySystemGroupedBackground
		contentView.layer.cornerRadius = 10.5
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setData(title: String, colorHex: String) {
		colorCircleView.backgroundColor = UIColor(hex: colorHex)
		titleLabel.text = title
	}
}
