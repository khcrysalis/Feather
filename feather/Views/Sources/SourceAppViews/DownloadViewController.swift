//
//  AppViewController.swift
//  feather
//
//  Created by samara on 5/29/24.
//

import Foundation
import UIKit

class DownloadViewController: UIViewController {
	public var collectionView: UICollectionView!
	private var activityIndicator: UIActivityIndicatorView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupNavigation()
		setupViews()
	}
	
	fileprivate func setupViews() {
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .vertical
		layout.minimumLineSpacing = 16
		layout.minimumInteritemSpacing = 10
		layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)

		self.collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
		self.collectionView.backgroundColor = UIColor(named: "Background")
		self.collectionView.delegate = self
		self.collectionView.dataSource = self
		self.collectionView.register(placeholderShit.self, forCellWithReuseIdentifier: "placeholderShit")
		self.view.addSubview(collectionView)
		
		NSLayoutConstraint.activate([
			collectionView.topAnchor.constraint(equalTo: view.topAnchor),
			collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])
//		
//		// empty text view
//		emptyStackView.isHidden = true
//		emptyStackView.title = "No Entries"
//		emptyStackView.text = "Check your internet connection and try again"
//		emptyStackView.translatesAutoresizingMaskIntoConstraints = false
//		view.addSubview(emptyStackView)
//
//		NSLayoutConstraint.activate([
//			emptyStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//			emptyStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
//		])
		
		self.activityIndicator = UIActivityIndicatorView(style: .medium)
		self.activityIndicator.center = view.center
		self.activityIndicator.hidesWhenStopped = true
		self.activityIndicator.startAnimating()
		self.view.addSubview(activityIndicator)
	}
	
	fileprivate func setupNavigation() {

	}
}

extension DownloadViewController: UICollectionViewDelegate, UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "placeholderShit", for: indexPath) as! placeholderShit
		cell.label.text = "app"
		cell.backgroundColor = .lightGray
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: 100, height: 100)
	}
}

class placeholderShit: UICollectionViewCell {
	let label: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		contentView.addSubview(label)
		
		NSLayoutConstraint.activate([
			label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
			label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
