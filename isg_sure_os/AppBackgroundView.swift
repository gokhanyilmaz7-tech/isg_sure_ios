//
//  AppBackgroundView.swift
//  isg_sure_os
//
//  Created by Codex on 19.03.2026.
//

import SwiftUI

struct AppBackgroundView: View {
    enum ImageFocus {
        case leading
        case trailing
    }

    @Environment(\.colorScheme) private var colorScheme

    let colors: [Color]
    let imageFocus: ImageFocus

    private var imageAlignment: Alignment {
        switch imageFocus {
        case .leading:
            return .leading
        case .trailing:
            return .trailing
        }
    }

    private var imageOpacity: Double {
        colorScheme == .dark ? 0.10 : 0.14
    }

    var body: some View {
        GeometryReader { proxy in
            let imageWidth = max(proxy.size.width * 1.48, 620)

            ZStack {
                LinearGradient(
                    colors: colors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Image("BackgroundWorldMap")
                    .resizable()
                    .scaledToFit()
                    .frame(width: imageWidth)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: imageAlignment)
                    .offset(y: min(proxy.size.height * 0.12, 96))
                    .opacity(imageOpacity)
                    .accessibilityHidden(true)
            }
            .clipped()
            .ignoresSafeArea()
        }
        .allowsHitTesting(false)
    }
}
