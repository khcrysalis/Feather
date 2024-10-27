//
//  AppSigningTweakViewController.swift
//  feather
//
//  Created by samara on 8/15/24.
//  Copyright (c) 2024 Samara M (khcrysalis)
//

import Foundation
import UIKit
import UniformTypeIdentifiers

class SigningsTweakViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
	var tweaksToInject: [String] = [] {
		didSet {
			UIView.animate(withDuration: 0.3) {
				self.signingDataWrapper.signingOptions.toInject = self.tweaksToInject
				self.collectionView.reloadData()
			}
		}
	}
	
	var signingDataWrapper: SigningDataWrapper
	
	init(signingDataWrapper: SigningDataWrapper) {
		self.signingDataWrapper = signingDataWrapper
		
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .vertical
		layout.minimumLineSpacing = 16
		layout.minimumInteritemSpacing = 16
		layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
		super.init(collectionViewLayout: layout)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		title = String.localized("APP_SIGNING_TWEAK_VIEW_CONTROLLER_TITLE")
		navigationItem.largeTitleDisplayMode = .never
		collectionView.register(ProductCollectionViewCell.self, forCellWithReuseIdentifier: ProductCollectionViewCell.reuseIdentifier)

		navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(openDocuments))
		collectionView.backgroundColor = .systemBackground
		self.tweaksToInject = self.signingDataWrapper.signingOptions.toInject
	}
	
	@objc func openDocuments() {
		importFile()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension SigningsTweakViewController {
	override func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.tweaksToInject.count 
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let layout = collectionViewLayout as! UICollectionViewFlowLayout
		
		let numberOfColumns: CGFloat = 2
		let totalSpacing = layout.minimumInteritemSpacing * (numberOfColumns - 1)
		
		let sectionInsets = layout.sectionInset
		let availableWidth = collectionView.bounds.width - sectionInsets.left - sectionInsets.right - totalSpacing
		
		let cellWidth = availableWidth / numberOfColumns
		
		return CGSize(width: cellWidth, height: cellWidth)
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductCollectionViewCell.reuseIdentifier, for: indexPath) as! ProductCollectionViewCell
		let tweak = tweaksToInject[indexPath.item]
		cell.titleLabel.text = "\(URL(string: tweak)!.lastPathComponent)"
		
		return cell
	}
	
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		
		return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
			let deleteAction = UIAction(title: String.localized("DELETE"), image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
				self.tweaksToInject.remove(at: indexPath.item)
			}
			return UIMenu(title: "", children: [deleteAction])
		}
	}
}

extension SigningsTweakViewController: UIDocumentPickerDelegate {
	func importFile() {
		self.presentDocumentPicker(fileExtension: [
			UTType(filenameExtension: "deb")!,
			UTType(filenameExtension: "dylib")!
		])
	}
	
	func presentDocumentPicker(fileExtension: [UTType]) {
		let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: fileExtension, asCopy: true)
		documentPicker.delegate = self
		documentPicker.allowsMultipleSelection = false
		present(documentPicker, animated: true, completion: nil)
	}
	
	func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
		guard let selectedFileURL = urls.first else { return }
		
		Debug.shared.log(message: "\(selectedFileURL)")
		
		if !tweaksToInject.contains(where: { $0 == selectedFileURL.absoluteString }) {
			tweaksToInject.append(selectedFileURL.absoluteString)
		}
		
		collectionView.reloadData()
	}



	
	func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
		controller.dismiss(animated: true, completion: nil)
	}
}

class ProductCollectionViewCell: UICollectionViewCell {
	static let reuseIdentifier = "ProductCell"
	
	let imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFit
		imageView.image = UIImage(systemName: "doc")
		imageView.tintColor = .secondaryLabel.withAlphaComponent(0.2)
		return imageView
	}()
	
	let titleLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = .secondaryLabel
		label.textAlignment = .center
		label.numberOfLines = 0
		return label
	}()
	
	private lazy var stackView: UIStackView = {
		let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel])
		stackView.axis = .vertical
		stackView.spacing = 1
		stackView.translatesAutoresizingMaskIntoConstraints = false
		return stackView
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupViews()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setupViews() {
		contentView.addSubview(stackView)
		contentView.backgroundColor = .quaternarySystemFill
		contentView.layer.cornerRadius = 19
		contentView.layer.cornerCurve = .continuous
		contentView.layer.masksToBounds = true
		
		NSLayoutConstraint.activate([
			stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
			stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
			stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
			stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
			imageView.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.4),
			stackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
		])
	}
}


