//
//  SourceAppTableViewCell.swift
//  feather
//
//  Created by samara on 5/22/24.
//  Copyright (c) 2024 Samara M (khcrysalis)
//

import Foundation
import UIKit
import Nuke

class AppTableViewCell: UITableViewCell {
	
	public var appDownload: AppDownload?
	private var progressObserver: NSObjectProtocol?

	private let progressLayer = CAShapeLayer()
	private var getButtonWidthConstraint: NSLayoutConstraint?
	private var buttonImage: UIImage?
	
	private let iconImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.layer.cornerRadius = 12
		imageView.layer.cornerCurve = .continuous
		imageView.layer.borderWidth = 1
		imageView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
		return imageView
	}()

	private let nameLabel: UILabel = {
		let label = UILabel()
		label.font = .boldSystemFont(ofSize: 16)
		label.numberOfLines = 1
		return label
	}()

	private let versionLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 13, weight: .regular)
		label.textColor = .gray
		label.numberOfLines = 2
		return label
	}()
	
	private let descriptionLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 13, weight: .regular)
		label.textColor = .gray
		label.numberOfLines = 20
		return label
	}()

	private let screenshotsScrollView: UIScrollView = {
		let scrollView = UIScrollView()
		scrollView.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
		scrollView.showsHorizontalScrollIndicator = false
		return scrollView
	}()

	private let screenshotsStackView: UIStackView = {
		let stackView = UIStackView()
		stackView.axis = .horizontal
		stackView.spacing = 10
		stackView.alignment = .center
		stackView.translatesAutoresizingMaskIntoConstraints = false
		return stackView
	}()
	
	let getButton: UIButton = {
		let button = UIButton(type: .system)
		button.layer.cornerRadius = 15
		button.layer.backgroundColor = UIColor.quaternarySystemFill.cgColor
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupViews()
		configureGetButtonArrow()
		configureProgressLayer()
		addObservers()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupViews() {
		let labelsStackView = UIStackView(arrangedSubviews: [nameLabel, versionLabel])
		labelsStackView.axis = .vertical
		labelsStackView.spacing = 1
		contentView.addSubview(iconImageView)
		contentView.addSubview(labelsStackView)
		contentView.addSubview(screenshotsScrollView)
		screenshotsScrollView.addSubview(screenshotsStackView)
		contentView.addSubview(getButton)
		contentView.addSubview(descriptionLabel)
		

		iconImageView.translatesAutoresizingMaskIntoConstraints = false
		labelsStackView.translatesAutoresizingMaskIntoConstraints = false
		screenshotsScrollView.translatesAutoresizingMaskIntoConstraints = false
		screenshotsStackView.translatesAutoresizingMaskIntoConstraints = false
		getButton.translatesAutoresizingMaskIntoConstraints = false
		descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

		getButtonWidthConstraint = getButton.widthAnchor.constraint(equalToConstant: 70)
		NSLayoutConstraint.activate([
			iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
			iconImageView.widthAnchor.constraint(equalToConstant: 52),
			iconImageView.heightAnchor.constraint(equalToConstant: 52),

			labelsStackView.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 15),
			labelsStackView.trailingAnchor.constraint(equalTo: getButton.leadingAnchor, constant: -15),
			labelsStackView.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
			labelsStackView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 15),
			
			getButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
			getButton.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
			getButtonWidthConstraint!,
			getButton.heightAnchor.constraint(equalToConstant: 30),
			
			descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
			descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),

			screenshotsScrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			screenshotsScrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

			screenshotsStackView.leadingAnchor.constraint(equalTo: screenshotsScrollView.leadingAnchor),
			screenshotsStackView.topAnchor.constraint(equalTo: screenshotsScrollView.topAnchor),
			screenshotsStackView.bottomAnchor.constraint(equalTo: screenshotsScrollView.bottomAnchor),
			screenshotsStackView.trailingAnchor.constraint(equalTo: screenshotsScrollView.trailingAnchor),
			screenshotsStackView.heightAnchor.constraint(equalTo: screenshotsScrollView.heightAnchor)
		])
	}

	private func configureGetButtonArrow() {
		let symbolConfig = UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)
		buttonImage = UIImage(systemName: "arrow.down", withConfiguration: symbolConfig)
		getButton.setImage(buttonImage, for: .normal)
		getButton.tintColor = .tintColor
	}

	private func configureGetButtonSquare() {
		let symbolConfig = UIImage.SymbolConfiguration(pointSize: 9, weight: .bold)
		buttonImage = UIImage(systemName: "square.fill", withConfiguration: symbolConfig)
		getButton.setImage(buttonImage, for: .normal)
		getButton.tintColor = .tintColor
	}

	private func configureProgressLayer() {
		progressLayer.strokeColor = UIColor.tintColor.cgColor
		progressLayer.lineWidth = 3.0
		progressLayer.fillColor = nil
		progressLayer.lineCap = .round
		progressLayer.strokeEnd = 0.0

		let circularPath = UIBezierPath(roundedRect: getButton.bounds, cornerRadius: 15)
		progressLayer.path = circularPath.cgPath
		getButton.layer.addSublayer(progressLayer)
	}
	
	private func addObservers() {
		progressObserver = NotificationCenter.default.addObserver(forName: .downloadProgressUpdated, object: nil, queue: .main) { [weak self] notification in
			guard let self = self,
				  let userInfo = notification.userInfo,
				  let uuid = userInfo["uuid"] as? String,
				  self.appDownload?.AppUUID == uuid else { return }
		}
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		updateProgressLayerPath()
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		getButton.layer.backgroundColor =  UIColor.quaternarySystemFill.cgColor
		updateProgressLayerPath()
	}

	deinit {
		if let observer = progressObserver {
			NotificationCenter.default.removeObserver(observer)
		}
	}
	
	func configure(with app: StoreAppsData) {
		var appname = app.name
		if app.bundleIdentifier.hasSuffix("Beta") {
			appname += " (Beta)"
		}
		
		nameLabel.text = appname

		let appVersion = (app.versions?.first?.version ?? app.version) ?? "1.0"
		var displayText = appVersion
		
		let appDate = (app.versions?.first?.date ?? app.versionDate) ?? ""
		if appDate != "" {
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
			
			if let date = dateFormatter.date(from: appDate) {
				let formattedDate = date.formatted(date: .numeric, time: .omitted)
				displayText += " • " + formattedDate
			} else {
				dateFormatter.dateFormat = "yyyy-MM-dd"
				if let date = dateFormatter.date(from: appDate) {
					let formattedDate = date.formatted(date: .numeric, time: .omitted)
					displayText += " • " + formattedDate
				}
			}
		}
		var descText = ""
		
		if Preferences.appDescriptionAppearence == 0 {
			let appSubtitle = app.subtitle ?? String.localized("SOURCES_CELLS_DEFAULT_SUBTITLE")
			displayText += " • " + appSubtitle
		} else if Preferences.appDescriptionAppearence == 1 {
			let appSubtitle = app.localizedDescription ?? String.localized("SOURCES_CELLS_DEFAULT_SUBTITLE")
			displayText += " • " + appSubtitle
		} else if Preferences.appDescriptionAppearence == 2 {
			let appSubtitle = app.subtitle ?? String.localized("SOURCES_CELLS_DEFAULT_SUBTITLE")
			displayText += " • " + appSubtitle
			descText = app.localizedDescription ?? (app.versions?[0].localizedDescription ?? String.localized("SOURCES_CELLS_DEFAULT_DESCRIPTION"))
		}
		descriptionLabel.text = descText
		versionLabel.text = displayText
		iconImageView.image = UIImage(named: "unknown")

		if let iconURL = app.iconURL {
			loadImage(from: iconURL) { image in
				DispatchQueue.main.async {
					self.iconImageView.image = image
				}
			}
		}

		screenshotsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

		if let screenshotUrls = app.screenshotURLs, !screenshotUrls.isEmpty, Preferences.appDescriptionAppearence != 2 {
			setupScreenshots(for: screenshotUrls)
		} else if Preferences.appDescriptionAppearence == 2 {
			setupDescription()
		} else {
			iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
		}
		updateDownloadState(uuid: app.bundleIdentifier)
	}

	private func setupScreenshots(for urls: [URL]) {
		let imageViews = urls.map { url -> UIImageView in
			let imageView = UIImageView()
			imageView.contentMode = .scaleAspectFill
			imageView.clipsToBounds = true
			imageView.layer.cornerRadius = 15
			imageView.layer.cornerCurve = .continuous
			imageView.translatesAutoresizingMaskIntoConstraints = false
			imageView.layer.borderWidth = 1
			imageView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
			let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleScreenshotTap(_:)))
			imageView.addGestureRecognizer(tapGesture)
			imageView.isUserInteractionEnabled = true
			return imageView
		}
		screenshotsScrollView.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 10).isActive = true
		screenshotsScrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15).isActive = true
		iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15).isActive = true
		
		imageViews.forEach { imageView in
			screenshotsStackView.addArrangedSubview(imageView)
			imageView.heightAnchor.constraint(equalTo: screenshotsScrollView.heightAnchor).isActive = true
		}

		loadImages(from: urls, into: imageViews)
	}
	
	private func setupDescription() {
		iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15).isActive = true
		descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15).isActive = true
		descriptionLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 15).isActive = true
	}
	
	@objc private func handleScreenshotTap(_ sender: UITapGestureRecognizer) {
		guard let tappedImageView = sender.view as? UIImageView,
			  let tappedImage = tappedImageView.image else {
			return
		}
		
		let fullscreenImageVC = SourceAppScreenshotViewController()
		fullscreenImageVC.image = tappedImage

		let navigationController = UINavigationController(rootViewController: fullscreenImageVC)
		navigationController.modalPresentationStyle = .fullScreen

		if let viewController = self.parentViewController {
			viewController.present(navigationController, animated: true, completion: nil)
		}
	}


	private func loadImages(from urls: [URL], into imageViews: [UIImageView]) {
		let dispatchGroup = DispatchGroup()

		for (index, url) in urls.enumerated() {
			dispatchGroup.enter()
			loadImage(from: url) { [weak self] image in
				guard let self = self else {
					dispatchGroup.leave()
					return
				}
				guard let image = image, index < imageViews.count else {
					dispatchGroup.leave()
					return
				}

				let imageView = imageViews[index]
				DispatchQueue.main.async {
					let aspectRatio = image.size.width / image.size.height
					let width = self.screenshotsScrollView.bounds.height * aspectRatio
					imageView.widthAnchor.constraint(equalToConstant: width).isActive = true
					Task { imageView.image = await image.byPreparingForDisplay() }
				}

				dispatchGroup.leave()
			}
		}
	}

	private func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
		let request = ImageRequest(url: url)

		if let cachedImage = ImagePipeline.shared.cache.cachedImage(for: request)?.image {
			completion(cachedImage)
		} else {
			ImagePipeline.shared.loadImage(
				with: request,
				queue: .global(),
				progress: nil
			) { result in
				switch result {
				case .success(let imageResponse):
					completion(imageResponse.image)
				case .failure:
					completion(nil)
				}
			}
		}
	}
	
	private func updateDownloadState(uuid: String?) {
		guard let appUUID = uuid else {
			return
		}
		
		DownloadTaskManager.shared.restoreTaskState(for: appUUID, cell: self)
				
		if let task = DownloadTaskManager.shared.task(for: appUUID) {
			switch task.state {
			case .inProgress(_):
				DispatchQueue.main.async {
					self.startDownload()
				}
			default:
				break
			}
		}
	}

	func updateProgress(to value: CGFloat) {
		DispatchQueue.main.async {
			self.progressLayer.strokeEnd = value
		}
	}

	func startDownload() {
		DispatchQueue.main.async {
			UIView.animate(withDuration: 0.3, animations: {
				self.getButtonWidthConstraint?.constant = 30
				self.layoutIfNeeded()
				self.configureGetButtonSquare()
				self.updateProgressLayerPath()
			})
		}
	}

	func stopDownload() {
		DispatchQueue.main.async {
			UIView.animate(withDuration: 0.3, animations: {
				self.getButtonWidthConstraint?.constant = 70
				self.progressLayer.strokeEnd = 0.0
				self.configureGetButtonArrow()
				self.layoutIfNeeded()
			})
		}
	}
	
	func cancelDownload() {
		DispatchQueue.main.async {
			self.stopDownload()
		}
	}

	private func updateProgressLayerPath() {
		let circularPath = UIBezierPath(roundedRect: getButton.bounds, cornerRadius: 15)
		progressLayer.path = circularPath.cgPath
	}
}


class SourceAppScreenshotViewController: UIViewController {
	var image: UIImage?

	private let imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.layer.cornerRadius = 16
		imageView.layer.cornerCurve = .continuous
		imageView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
		imageView.layer.borderWidth = 1
		imageView.clipsToBounds = true
		return imageView
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .systemBackground
		
		view.addSubview(imageView)
		setupConstraints()
		
		imageView.image = image
		
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: String.localized("DONE"), style: .done, target: self, action: #selector(closeSheet))
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		updateImageViewSize()
	}
	
	private func setupConstraints() {
		NSLayoutConstraint.activate([
			imageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
			imageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
			imageView.widthAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.9),
			imageView.heightAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.9)
		])
	}
	
	private func updateImageViewSize() {
		guard let image = image else { return }
		let imageSize = image.size
		
		let maxWidth = view.safeAreaLayoutGuide.layoutFrame.width * 0.9
		let maxHeight = view.safeAreaLayoutGuide.layoutFrame.height * 0.9
		
		let aspectRatio = imageSize.width / imageSize.height
		let constrainedWidth = min(imageSize.width, maxWidth)
		let constrainedHeight = min(imageSize.height, maxHeight)
		
		let imageViewWidth = min(constrainedWidth, constrainedHeight * aspectRatio)
		let imageViewHeight = min(constrainedHeight, constrainedWidth / aspectRatio)
		
		imageView.frame.size = CGSize(width: imageViewWidth, height: imageViewHeight)
		imageView.center = view.center
	}
	
	@objc func closeSheet() {
		dismiss(animated: true)
	}
}
