//
//  Language.swift
//  Antoine
//
//  Created by Serena on 24/02/2023.
//  Code from: https://github.com/NSAntoine/Antoine/blob/main/Antoine/UI/PreferredLanguageViewController.swift
//

/*
 MIT License

 Copyright (c) 2024 Antoine

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import Foundation

struct Language {
	static var availableLanguages: [Language] {
		return Bundle.main.localizations.compactMap { languageCode in
			// Skip over 'Base', it means nothing
			guard languageCode != "Base",
				  let subtitle = Locale.current.localizedString(forLanguageCode: languageCode) else {
				return nil
			}
			
			let displayLocale = Locale(identifier: languageCode)
			guard let displayName = displayLocale.localizedString(forLanguageCode: languageCode)?.capitalized(with: displayLocale) else {
				return nil
			}
			
			return Language(displayName: displayName, subtitleText: subtitle, languageCode: languageCode)
		}
	}
	
	/// The display name, being the language's name in itself, such as 'русский' in Russian
	let displayName: String
	
	/// The subtitle, being the language's name in the current language,
	/// such as 'Russian' when the user is currently using English.
	let subtitleText: String
	
	/// The language code, such as 'ru'
	let languageCode: String
}
