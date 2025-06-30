//
//  VariableBlurView.swift
//  VariableBlurView
//
//  Created by A. Zheng (github.com/aheze) on 5/29/23.
//  Copyright © 2023 A. Zheng. All rights reserved.
//
//  ---
//
//  MIT License
//
//  Copyright (c) 2023 A. Zheng
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
//  ---
//
//  This work is based off VariableBlurView by Janum Trivedi.
//  Original repository: https://github.com/jtrivedi/VariableBlurView
//  Original license:
//
//  Copyright (c) 2012-2023 Scott Chacon and others
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import UIKit
import SwiftUI

public class NBUIVariableBlurView: UIView {
	// MARK: - Private Properties
	private var filterClass: NSObjectProtocol {
		let encodedString = "Q0FGaWx0ZXI="
		let data = Data(base64Encoded: encodedString)!
		let string = String(data: data, encoding: .utf8)!
		
		return NSClassFromString(string) as AnyObject as! NSObjectProtocol
	}
	
	private var filterType: String {
		let encodedString = "dmFyaWFibGVCbHVy"
		let data = Data(base64Encoded: encodedString)!
		
		return String(data: data, encoding: .utf8)!
	}
	
	private var filterWithTypeSelector: Selector {
		let encodedString = "ZmlsdGVyV2l0aFR5cGU6"
		let data = Data(base64Encoded: encodedString)!
		let string = String(data: data, encoding: .utf8)!
		
		return Selector((string))
	}
	
	private var variableBlur: AnyObject!
	
	// MARK: - Public Properties
	public var blurRadius: CGFloat = 20 {
		willSet {
			variableBlur.setValue(newValue, forKey: "inputRadius")
		}
	}
	
	public var gradientMask: UIImage? = nil {
		willSet {
			variableBlur.setValue(newValue?.cgImage, forKey: "inputMaskImage")
		}
	}
	
	override public class var layerClass: AnyClass {
		let encodedString = "Q0FCYWNrZHJvcExheWVy"
		let data = Data(base64Encoded: encodedString)!
		let string = String(data: data, encoding: .utf8)!
		
		return NSClassFromString(string)!
	}
	
	// MARK: - init(frame:)
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupVariableBlurFilter()
	}
	
	// MARK: - init?(coder:)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Private Methods
	private func setupVariableBlurFilter() {
		variableBlur = filterClass.perform(filterWithTypeSelector, with: filterType).takeUnretainedValue()
		variableBlur.setValue(blurRadius, forKey: "inputRadius")
		variableBlur.setValue(true, forKey: "inputNormalizeEdges")
		variableBlur.setValue(gradientMask?.cgImage, forKey: "inputMaskImage")
		
		layer.filters = [variableBlur as! NSObject]
	}
}

/// A variable blur view.
public struct NBVariableBlurView: UIViewRepresentable {
	public init() {}
	public func makeUIView(context: Context) -> NBUIVariableBlurView {
		var view = NBUIVariableBlurView()
		
		let gradientMask = NBVariableBlurViewConstants.defaultGradientMask
		view = NBUIVariableBlurView(frame: .zero)
		view.gradientMask = gradientMask
		return view
	}
	
	public func updateUIView(_ uiView: NBUIVariableBlurView, context: Context) {}
}

public enum NBVariableBlurViewConstants {

	/// A gradient mask image (top is opaque, bottom is clear). The gradient includes easing.
	public static let defaultGradientMask: UIImage = {
		if
			let data = Data(base64Encoded: defaultMaskImageString, options: .ignoreUnknownCharacters),
			let image = UIImage(data: data)
		{
			return image
		} else {
			return UIImage(systemName: "xmark")!
		}
	}()

	/// The image encoded in base64 (from PNG data).
	public static let defaultMaskImageString = """
	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
	"""
}
