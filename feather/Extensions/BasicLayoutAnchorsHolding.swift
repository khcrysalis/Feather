//
//  BasicLayoutAnchors.swift
//  pointercrate
//
//  Created by samara on 3/20/24.
//

import Foundation
import UIKit

/// A protocol describing a type which contains basic layout anchors
protocol BasicLayoutAnchorsHolding {
	var leadingAnchor: NSLayoutXAxisAnchor { get }
	var trailingAnchor: NSLayoutXAxisAnchor { get }
	var topAnchor: NSLayoutYAxisAnchor { get }
	var bottomAnchor: NSLayoutYAxisAnchor { get }
	var layoutMargins: UIEdgeInsets { get set } // Add layoutMargins property
}

extension BasicLayoutAnchorsHolding {
	/// Activates constraints to completely cover this view/guide over another.
	func constraintCompletely<Target: BasicLayoutAnchorsHolding>(to target: Target) {
		NSLayoutConstraint.activate([
			leadingAnchor.constraint(equalTo: target.leadingAnchor),
			trailingAnchor.constraint(equalTo: target.trailingAnchor),
			bottomAnchor.constraint(equalTo: target.bottomAnchor),
			topAnchor.constraint(equalTo: target.topAnchor)
		])
	}
	
	/// Sets layout margins for the view or guide
	func setLayoutMargins(_ margins: UIEdgeInsets) {
		guard let view = self as? UIView else { return }
		view.layoutMargins = margins
	}
}

extension UIView: BasicLayoutAnchorsHolding {}

extension UILayoutGuide: BasicLayoutAnchorsHolding {
	var layoutMargins: UIEdgeInsets {
		get {
			return .zero
		}
		set {
			guard let owningView = owningView else { return }
			owningView.layoutMargins = newValue
		}
	}
}
