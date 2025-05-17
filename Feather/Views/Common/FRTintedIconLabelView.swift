//
//  FRTintedIconLabelView.swift
//  Feather
//
//  Created by İsmail Carlık on 17.05.2025.
//
import SwiftUI

// MARK: View
struct FRTintedIconLabelView: View {

    var icon: FRTintedIconView
    var text: LocalizedStringKey
    var showLinkHint: Bool
    
    init(_ text: LocalizedStringKey, systemName: String, tintColor: Color = .accentColor, iconSize: CGFloat = 29, showLinkHint: Bool = false) {
        self.text = text
        self.icon = FRTintedIconView(systemName: systemName, tintColor: tintColor, iconSize: iconSize)
        self.showLinkHint = showLinkHint
    }
    
    init(_ text: LocalizedStringKey, name: String, tintColor: Color = .accentColor, iconSize: CGFloat = 29, showLinkHint: Bool = false) {
        self.text = text
        self.icon = FRTintedIconView(name: name, tintColor: tintColor, iconSize: iconSize)
        self.showLinkHint = showLinkHint
    }
    
    // MARK: Body
    var body: some View {
        HStack {
            self.icon
            Text(self.text)
            if self.showLinkHint {
                Spacer()
                Image(systemName: "arrow.up.right.square.fill")
                    .foregroundStyle(.accent)
            }
        }
    }
}
