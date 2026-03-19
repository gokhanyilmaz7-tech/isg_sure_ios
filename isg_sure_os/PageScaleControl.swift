//
//  PageScaleControl.swift
//  isg_sure_os
//
//  Created by Codex on 19.03.2026.
//

import SwiftUI

private struct PageScaleFactorKey: EnvironmentKey {
    static let defaultValue = 1.0
}

extension EnvironmentValues {
    var pageScaleFactor: Double {
        get { self[PageScaleFactorKey.self] }
        set { self[PageScaleFactorKey.self] = newValue }
    }
}

func pageScaled(_ value: CGFloat, by factor: Double) -> CGFloat {
    value * CGFloat(factor)
}

struct PageScaleControl: View {
    @Binding var scale: Double

    private let supportedScales: [Double] = [
        0.5, 0.6, 0.7, 0.8, 0.9,
        1.0,
        1.1, 1.2, 1.3, 1.4, 1.5
    ]

    var body: some View {
        HStack(spacing: 8) {
            Button {
                updateScale(to: previousScale)
            } label: {
                Text("A-")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .frame(minWidth: 30, minHeight: 30)
            }
            .disabled(isAtMinimum)
            .accessibilityLabel("Sayfayı küçült")

            Button {
                updateScale(to: nextScale)
            } label: {
                Text("A+")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .frame(minWidth: 30, minHeight: 30)
            }
            .disabled(isAtMaximum)
            .accessibilityLabel("Sayfayı büyüt")
        }
    }

    private var currentIndex: Int {
        supportedScales.enumerated().min(by: {
            abs($0.element - scale) < abs($1.element - scale)
        })?.offset ?? 1
    }

    private var previousScale: Double {
        supportedScales[max(currentIndex - 1, 0)]
    }

    private var nextScale: Double {
        supportedScales[min(currentIndex + 1, supportedScales.count - 1)]
    }

    private var isAtMinimum: Bool {
        currentIndex == 0
    }

    private var isAtMaximum: Bool {
        currentIndex == supportedScales.count - 1
    }

    private func updateScale(to newValue: Double) {
        withAnimation(.easeInOut(duration: 0.2)) {
            scale = newValue
        }
    }
}
