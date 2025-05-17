//
//  FRTintedIconView.swift
//  Feather
//
//  Created by İsmail Carlık on 17.05.2025.
//

import SwiftUI

// MARK: View
struct FRTintedIconView: View {
    var image: Image
    var tintColor: Color
    var iconSize: CGFloat

    init(name: String, tintColor: Color = .accentColor, iconSize: CGFloat = 29)
    {
        self.image = Image(name)
        self.tintColor = tintColor
        self.iconSize = iconSize
    }

    init(
        systemName: String,
        tintColor: Color = .accentColor,
        iconSize: CGFloat = 29
    ) {
        self.image = Image(systemName: systemName)
        self.tintColor = tintColor
        self.iconSize = iconSize
    }

    // MARK: Body
    var body: some View {
        self.image
            .resizable()
            .scaledToFit()
            .padding(self.iconSize / 8)
            .frame(width: self.iconSize, height: self.iconSize)
            .foregroundStyle(.white)
            .background(self.tintColor)
            .clipShape(
                RoundedRectangle(cornerRadius: iconSize * 0.2237, style: .continuous)
            )
    }
}
