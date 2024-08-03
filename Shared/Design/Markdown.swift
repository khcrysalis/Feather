//
//  Markdownosaur.swift
//  Markdownosaur
//
//  Created by Christian Selig on 2021-11-02.
//

import UIKit
import Markdown

public struct Markdownosaur: MarkupVisitor {
	let baseFontSize: CGFloat = 12.0

	public init() {}
	
	public mutating func attributedString(from document: Document) -> NSAttributedString {
		return visit(document)
	}
	
	mutating public func defaultVisit(_ markup: Markup) -> NSAttributedString {
		let result = NSMutableAttributedString()
		
		for child in markup.children {
			result.append(visit(child))
		}
		
		return result
	}
	
	mutating public func visitText(_ text: Text) -> NSAttributedString {
		return NSAttributedString(string: text.plainText, attributes: [.font: UIFont.systemFont(ofSize: baseFontSize, weight: .regular)])
	}
	
	mutating public func visitEmphasis(_ emphasis: Emphasis) -> NSAttributedString {
		let result = NSMutableAttributedString()
		
		for child in emphasis.children {
			result.append(visit(child))
		}
		
		result.applyEmphasis()
		
		return result
	}
	
	mutating public func visitStrong(_ strong: Strong) -> NSAttributedString {
		let result = NSMutableAttributedString()
		
		for child in strong.children {
			result.append(visit(child))
		}
		
		result.applyStrong()
		
		return result
	}
	
	mutating public func visitParagraph(_ paragraph: Paragraph) -> NSAttributedString {
		let result = NSMutableAttributedString()
		
		for child in paragraph.children {
			result.append(visit(child))
		}
		
		if paragraph.hasSuccessor {
			result.append(paragraph.isContainedInList ? .singleNewline(withFontSize: baseFontSize) : .doubleNewline(withFontSize: baseFontSize))
		}
		
		return result
	}
	
	mutating public func visitHeading(_ heading: Heading) -> NSAttributedString {
		let result = NSMutableAttributedString()
		
		for child in heading.children {
			result.append(visit(child))
		}
		
		result.applyHeading(withLevel: heading.level)
		
		if heading.hasSuccessor {
			result.append(.doubleNewline(withFontSize: baseFontSize))
		}
		
		return result
	}
	
	mutating public func visitLink(_ link: Link) -> NSAttributedString {
		let result = NSMutableAttributedString()
		
		for child in link.children {
			result.append(visit(child))
		}
		
		let url = link.destination != nil ? URL(string: link.destination!) : nil
		
		result.applyLink(withURL: url)
		
		return result
	}
	
	mutating public func visitInlineCode(_ inlineCode: InlineCode) -> NSAttributedString {
		return NSAttributedString(string: inlineCode.code, attributes: [.font: UIFont.monospacedSystemFont(ofSize: baseFontSize - 1.0, weight: .regular), .foregroundColor: UIColor.systemGray])
	}
	
	public func visitCodeBlock(_ codeBlock: CodeBlock) -> NSAttributedString {
		let result = NSMutableAttributedString(string: codeBlock.code, attributes: [.font: UIFont.monospacedSystemFont(ofSize: baseFontSize - 1.0, weight: .regular), .foregroundColor: UIColor.systemGray])
		
		if codeBlock.hasSuccessor {
			result.append(.singleNewline(withFontSize: baseFontSize))
		}
	
		return result
	}
	
	mutating public func visitStrikethrough(_ strikethrough: Strikethrough) -> NSAttributedString {
		let result = NSMutableAttributedString()
		
		for child in strikethrough.children {
			result.append(visit(child))
		}
		
		result.applyStrikethrough()
		
		return result
	}
	
	mutating public func visitUnorderedList(_ unorderedList: UnorderedList) -> NSAttributedString {
		let result = NSMutableAttributedString()
		
		let font = UIFont.systemFont(ofSize: baseFontSize, weight: .regular)
				
		for listItem in unorderedList.listItems {
			var listItemAttributes: [NSAttributedString.Key: Any] = [:]
			
			let listItemParagraphStyle = NSMutableParagraphStyle()
			
			let baseLeftMargin: CGFloat = 15.0
			let leftMarginOffset = baseLeftMargin + (20.0 * CGFloat(unorderedList.listDepth))
			let spacingFromIndex: CGFloat = 8.0
			let bulletWidth = ceil(NSAttributedString(string: "•", attributes: [.font: font]).size().width)
			let firstTabLocation = leftMarginOffset + bulletWidth
			let secondTabLocation = firstTabLocation + spacingFromIndex
			
			listItemParagraphStyle.tabStops = [
				NSTextTab(textAlignment: .right, location: firstTabLocation),
				NSTextTab(textAlignment: .left, location: secondTabLocation)
			]
			
			listItemParagraphStyle.headIndent = secondTabLocation
			
			listItemAttributes[.paragraphStyle] = listItemParagraphStyle
			listItemAttributes[.font] = UIFont.systemFont(ofSize: baseFontSize, weight: .regular)
			listItemAttributes[.listDepth] = unorderedList.listDepth
			
			let listItemAttributedString = visit(listItem).mutableCopy() as! NSMutableAttributedString
			listItemAttributedString.insert(NSAttributedString(string: "\t•\t", attributes: listItemAttributes), at: 0)
			
			result.append(listItemAttributedString)
		}
		
		if unorderedList.hasSuccessor {
			result.append(.doubleNewline(withFontSize: baseFontSize))
		}
		
		return result
	}
	
	mutating public func visitListItem(_ listItem: ListItem) -> NSAttributedString {
		let result = NSMutableAttributedString()
		
		for child in listItem.children {
			result.append(visit(child))
		}
		
		if listItem.hasSuccessor {
			result.append(.singleNewline(withFontSize: baseFontSize))
		}
		
		return result
	}
	
	mutating public func visitOrderedList(_ orderedList: OrderedList) -> NSAttributedString {
		let result = NSMutableAttributedString()
		
		for (index, listItem) in orderedList.listItems.enumerated() {
			var listItemAttributes: [NSAttributedString.Key: Any] = [:]
			
			let font = UIFont.systemFont(ofSize: baseFontSize, weight: .regular)
			let numeralFont = UIFont.monospacedDigitSystemFont(ofSize: baseFontSize, weight: .regular)
			
			let listItemParagraphStyle = NSMutableParagraphStyle()
			
			// Implement a base amount to be spaced from the left side at all times to better visually differentiate it as a list
			let baseLeftMargin: CGFloat = 15.0
			let leftMarginOffset = baseLeftMargin + (20.0 * CGFloat(orderedList.listDepth))
			
			// Grab the highest number to be displayed and measure its width (yes normally some digits are wider than others but since we're using the numeral mono font all will be the same width in this case)
			let highestNumberInList = orderedList.childCount
			let numeralColumnWidth = ceil(NSAttributedString(string: "\(highestNumberInList).", attributes: [.font: numeralFont]).size().width)
			
			let spacingFromIndex: CGFloat = 8.0
			let firstTabLocation = leftMarginOffset + numeralColumnWidth
			let secondTabLocation = firstTabLocation + spacingFromIndex
			
			listItemParagraphStyle.tabStops = [
				NSTextTab(textAlignment: .right, location: firstTabLocation),
				NSTextTab(textAlignment: .left, location: secondTabLocation)
			]
			
			listItemParagraphStyle.headIndent = secondTabLocation
			
			listItemAttributes[.paragraphStyle] = listItemParagraphStyle
			listItemAttributes[.font] = font
			listItemAttributes[.listDepth] = orderedList.listDepth

			let listItemAttributedString = visit(listItem).mutableCopy() as! NSMutableAttributedString
			
			// Same as the normal list attributes, but for prettiness in formatting we want to use the cool monospaced numeral font
			var numberAttributes = listItemAttributes
			numberAttributes[.font] = numeralFont
			
			let numberAttributedString = NSAttributedString(string: "\t\(index + 1).\t", attributes: numberAttributes)
			listItemAttributedString.insert(numberAttributedString, at: 0)
			
			result.append(listItemAttributedString)
		}
		
		if orderedList.hasSuccessor {
			result.append(orderedList.isContainedInList ? .singleNewline(withFontSize: baseFontSize) : .doubleNewline(withFontSize: baseFontSize))
		}
		
		return result
	}
	
	mutating public func visitBlockQuote(_ blockQuote: BlockQuote) -> NSAttributedString {
		let result = NSMutableAttributedString()
		
		for child in blockQuote.children {
			var quoteAttributes: [NSAttributedString.Key: Any] = [:]
			
			let quoteParagraphStyle = NSMutableParagraphStyle()
			
			let baseLeftMargin: CGFloat = 15.0
			let leftMarginOffset = baseLeftMargin + (20.0 * CGFloat(blockQuote.quoteDepth))
			
			quoteParagraphStyle.tabStops = [NSTextTab(textAlignment: .left, location: leftMarginOffset)]
			
			quoteParagraphStyle.headIndent = leftMarginOffset
			
			quoteAttributes[.paragraphStyle] = quoteParagraphStyle
			quoteAttributes[.font] = UIFont.systemFont(ofSize: baseFontSize, weight: .regular)
			quoteAttributes[.listDepth] = blockQuote.quoteDepth
			
			let quoteAttributedString = visit(child).mutableCopy() as! NSMutableAttributedString
			quoteAttributedString.insert(NSAttributedString(string: "\t", attributes: quoteAttributes), at: 0)
			
			quoteAttributedString.addAttribute(.foregroundColor, value: UIColor.systemGray)
			
			result.append(quoteAttributedString)
		}
		
		if blockQuote.hasSuccessor {
			result.append(.doubleNewline(withFontSize: baseFontSize))
		}
		
		return result
	}
}

// MARK: - Extensions Land

extension NSMutableAttributedString {
	func applyEmphasis() {
		enumerateAttribute(.font, in: NSRange(location: 0, length: length), options: []) { value, range, stop in
			guard let font = value as? UIFont else { return }
			
			let newFont = font.apply(newTraits: .traitItalic)
			addAttribute(.font, value: newFont, range: range)
		}
	}
	
	func applyStrong() {
		enumerateAttribute(.font, in: NSRange(location: 0, length: length), options: []) { value, range, stop in
			guard let font = value as? UIFont else { return }
			
			let newFont = font.apply(newTraits: .traitBold)
			addAttribute(.font, value: newFont, range: range)
		}
	}
	
	func applyLink(withURL url: URL?) {
		addAttribute(.foregroundColor, value: UIColor.systemBlue)
		
		if let url = url {
			addAttribute(.link, value: url)
		}
	}
	
	func applyBlockquote() {
		addAttribute(.foregroundColor, value: UIColor.systemGray)
	}
	
	func applyHeading(withLevel headingLevel: Int) {
		enumerateAttribute(.font, in: NSRange(location: 0, length: length), options: []) { value, range, stop in
			guard let font = value as? UIFont else { return }
			
			let newFont = font.apply(newTraits: .traitBold, newPointSize: 18.0 - CGFloat(headingLevel * 2))
			addAttribute(.font, value: newFont, range: range)
		}
	}
	
	func applyStrikethrough() {
		addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue)
	}
}

extension UIFont {
	func apply(newTraits: UIFontDescriptor.SymbolicTraits, newPointSize: CGFloat? = nil) -> UIFont {
		var existingTraits = fontDescriptor.symbolicTraits
		existingTraits.insert(newTraits)
		
		guard let newFontDescriptor = fontDescriptor.withSymbolicTraits(existingTraits) else { return self }
		return UIFont(descriptor: newFontDescriptor, size: newPointSize ?? pointSize)
	}
}

extension ListItemContainer {
	/// Depth of the list if nested within others. Index starts at 0.
	var listDepth: Int {
		var index = 0

		var currentElement = parent

		while currentElement != nil {
			if currentElement is ListItemContainer {
				index += 1
			}

			currentElement = currentElement?.parent
		}
		
		return index
	}
}

extension BlockQuote {
	/// Depth of the quote if nested within others. Index starts at 0.
	var quoteDepth: Int {
		var index = 0

		var currentElement = parent

		while currentElement != nil {
			if currentElement is BlockQuote {
				index += 1
			}

			currentElement = currentElement?.parent
		}
		
		return index
	}
}

extension NSAttributedString.Key {
	static let listDepth = NSAttributedString.Key("ListDepth")
	static let quoteDepth = NSAttributedString.Key("QuoteDepth")
}

extension NSMutableAttributedString {
	func addAttribute(_ name: NSAttributedString.Key, value: Any) {
		addAttribute(name, value: value, range: NSRange(location: 0, length: length))
	}
	
	func addAttributes(_ attrs: [NSAttributedString.Key : Any]) {
		addAttributes(attrs, range: NSRange(location: 0, length: length))
	}
}

extension Markup {
	/// Returns true if this element has sibling elements after it.
	var hasSuccessor: Bool {
		guard let childCount = parent?.childCount else { return false }
		return indexInParent < childCount - 1
	}
	
	var isContainedInList: Bool {
		var currentElement = parent

		while currentElement != nil {
			if currentElement is ListItemContainer {
				return true
			}

			currentElement = currentElement?.parent
		}
		
		return false
	}
}

extension NSAttributedString {
	static func singleNewline(withFontSize fontSize: CGFloat) -> NSAttributedString {
		return NSAttributedString(string: "\n", attributes: [.font: UIFont.systemFont(ofSize: fontSize, weight: .regular)])
	}
	
	static func doubleNewline(withFontSize fontSize: CGFloat) -> NSAttributedString {
		return NSAttributedString(string: "\n\n", attributes: [.font: UIFont.systemFont(ofSize: fontSize, weight: .regular)])
	}
}
