//
//  CalculationView.swift
//  isg_sure_os
//
//  Created by Codex on 18.03.2026.
//

import SwiftUI
import UIKit

struct CalculationView: View {
    private struct InfoChip: View {
        @Environment(\.colorScheme) private var colorScheme
        @Environment(\.pageScaleFactor) private var pageScaleFactor

        let title: String
        let value: String
        let tint: Color
        var isNeutral = false

        private var fillColor: Color {
            if colorScheme == .dark {
                return isNeutral ? Color.white.opacity(0.10) : tint.opacity(0.28)
            }

            return isNeutral ? Color.black.opacity(0.08) : tint.opacity(0.12)
        }

        private var strokeColor: Color {
            if colorScheme == .dark {
                return Color.white.opacity(0.14)
            }

            return isNeutral ? Color.black.opacity(0.12) : tint.opacity(0.18)
        }

        private var titleColor: Color {
            if colorScheme == .dark {
                return .white.opacity(0.82)
            }

            return .black.opacity(0.78)
        }

        private var valueColor: Color {
            if colorScheme == .dark {
                return .white
            }

            return .black.opacity(0.94)
        }

        private func scaled(_ value: CGFloat) -> CGFloat {
            pageScaled(value, by: pageScaleFactor)
        }

        var body: some View {
            VStack(alignment: .leading, spacing: scaled(4)) {
                Text(title.uppercased())
                    .font(.system(size: scaled(11), weight: .bold, design: .rounded))
                    .foregroundStyle(titleColor)

                Text(value)
                    .font(.system(size: scaled(15), weight: .semibold, design: .rounded))
                    .foregroundStyle(valueColor)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, scaled(14))
            .padding(.vertical, scaled(10))
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: scaled(16), style: .continuous)
                    .fill(fillColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: scaled(16), style: .continuous)
                    .stroke(strokeColor, lineWidth: 1)
                    .allowsHitTesting(false)
            )
        }
    }

    private struct RoleCardView: View {
        @Environment(\.colorScheme) private var colorScheme
        @Environment(\.pageScaleFactor) private var pageScaleFactor
        @State private var isShowingInfo = false

        let summary: RoleCalculationSummary

        private var cardBackgroundStyle: AnyShapeStyle {
            if colorScheme == .dark {
                return AnyShapeStyle(
                    Color(red: 0.10, green: 0.12, blue: 0.16)
                        .opacity(0.90)
                )
            }

            return AnyShapeStyle(Color.white.opacity(0.72))
        }

        private var cardStrokeColor: Color {
            if colorScheme == .dark {
                return Color.white.opacity(0.12)
            }

            return summary.role.accentColor.opacity(0.16)
        }

        private var titleTextColor: Color {
            if colorScheme == .dark {
                return .white.opacity(0.98)
            }

            return .black.opacity(0.94)
        }

        private var supportingTextColor: Color {
            if colorScheme == .dark {
                return .white.opacity(0.82)
            }

            return .black.opacity(0.72)
        }

        private var windowPanelStyle: AnyShapeStyle {
            if colorScheme == .dark {
                return AnyShapeStyle(Color.white.opacity(0.05))
            }

            return AnyShapeStyle(Color.white.opacity(0.90))
        }

        private var windowStrokeColor: Color {
            if colorScheme == .dark {
                return Color.white.opacity(0.10)
            }

            return .black.opacity(0.06)
        }

        private var windowTitleColor: Color {
            if colorScheme == .dark {
                return .white.opacity(0.96)
            }

            return .black.opacity(0.90)
        }

        private var windowHintColor: Color {
            if colorScheme == .dark {
                return .white.opacity(0.70)
            }

            return .black.opacity(0.60)
        }

        private var windowLineFill: Color {
            if colorScheme == .dark {
                return Color.white.opacity(0.06)
            }

            return summary.role.accentColor.opacity(0.08)
        }

        private var avatarSize: CGFloat {
            scaled(104)
        }

        private var supportingLines: [String] {
            (summary.supportingText ?? "")
                .split(separator: "\n")
                .map(String.init)
                .filter { !$0.isEmpty }
        }

        private func scaled(_ value: CGFloat) -> CGFloat {
            pageScaled(value, by: pageScaleFactor)
        }

        var body: some View {
            ZStack {
                frontFace
                    .opacity(isShowingInfo ? 0 : 1)

                backFace
                    .opacity(isShowingInfo ? 1 : 0)
                    .rotation3DEffect(
                        .degrees(180),
                        axis: (x: 0, y: 1, z: 0)
                    )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                ZStack(alignment: .top) {
                    RoundedRectangle(cornerRadius: scaled(34), style: .continuous)
                        .fill(cardBackgroundStyle)

                    RoundedRectangle(cornerRadius: scaled(34), style: .continuous)
                        .fill(summary.role.accentColor)
                        .frame(height: scaled(16))
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: scaled(34), style: .continuous)
                    .stroke(cardStrokeColor, lineWidth: 1)
                    .allowsHitTesting(false)
            )
            .shadow(
                color: colorScheme == .dark ? .clear : .black.opacity(0.08),
                radius: scaled(18),
                y: scaled(8)
            )
            .rotation3DEffect(
                .degrees(isShowingInfo ? 180 : 0),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.55
            )
            .contentShape(RoundedRectangle(cornerRadius: scaled(34), style: .continuous))
            .onTapGesture {
                guard !supportingLines.isEmpty else { return }

                withAnimation(.spring(response: 0.5, dampingFraction: 0.82)) {
                    isShowingInfo.toggle()
                }
            }
            .accessibilityAddTraits(.isButton)
            .accessibilityHint("Sonuç ve ek bilgi arasında geciş yapar.")
        }

        private var avatarView: some View {
            ZStack {
                Circle()
                    .fill(summary.role.avatarBackgroundColor)
                    .overlay(
                        Circle()
                            .stroke(summary.role.avatarStrokeColor, lineWidth: scaled(3))
                            .allowsHitTesting(false)
                    )

                Image(systemName: summary.role.avatarSymbol)
                    .font(.system(size: scaled(34), weight: .semibold))
                    .foregroundStyle(summary.role.accentColor)
            }
            .frame(width: avatarSize, height: avatarSize)
        }

        private var titleView: some View {
            Text(summary.role.displayName)
                .font(.system(size: scaled(34), weight: .bold, design: .rounded))
                .foregroundStyle(titleTextColor)
                .fixedSize(horizontal: false, vertical: true)
        }

        private var frontFace: some View {
            VStack(alignment: .leading, spacing: scaled(34)) {
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: scaled(22)) {
                        avatarView
                        titleView
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(alignment: .leading, spacing: scaled(18)) {
                        avatarView
                        titleView
                    }
                }

                VStack(alignment: .leading, spacing: scaled(26)) {
                    if let fullTimeText = summary.fullTimeText {
                        MetricRow(
                            title: "Tam Süreli:",
                            headline: fullTimeText,
                            headlineColor: summary.fullTimeValueColor,
                            secondaryText: nil,
                            tertiaryText: nil
                        )
                    }

                    MetricRow(
                        title: "Kısmi Süreli:",
                        headline: summary.partialHeadlineText,
                        headlineColor: summary.partialHeadlineColor,
                        secondaryText: summary.durationText,
                        tertiaryText: summary.minutesText
                    )
                }
            }
            .padding(.horizontal, scaled(34))
            .padding(.top, scaled(34))
            .padding(.bottom, scaled(30))
        }

        private var backFace: some View {
            VStack(alignment: .leading, spacing: scaled(22)) {
                windowHeader

                VStack(alignment: .leading, spacing: scaled(14)) {
                    Text(summary.role.displayName)
                        .font(.system(size: scaled(25), weight: .bold, design: .rounded))
                        .foregroundStyle(windowTitleColor)

                    ForEach(Array(supportingLines.enumerated()), id: \.offset) { item in
                        Text(item.element)
                            .font(.system(size: scaled(14), weight: .medium, design: .rounded))
                            .foregroundStyle(supportingTextColor)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, scaled(16))
                            .padding(.vertical, scaled(14))
                            .background(
                                RoundedRectangle(cornerRadius: scaled(18), style: .continuous)
                                    .fill(windowLineFill)
                            )
                    }
                }

                Text("Sonuç ekranına dönmek için dokunun.")
                    .font(.system(size: scaled(12), weight: .semibold, design: .rounded))
                    .foregroundStyle(windowHintColor)
            }
            .padding(.horizontal, scaled(34))
            .padding(.top, scaled(34))
            .padding(.bottom, scaled(30))
            .frame(maxWidth: .infinity, alignment: .leading)
        }

        private var windowHeader: some View {
            HStack(spacing: scaled(12)) {
                HStack(spacing: scaled(8)) {
                    windowDot(color: Color(red: 1.0, green: 0.37, blue: 0.32))
                    windowDot(color: Color(red: 1.0, green: 0.74, blue: 0.18))
                    windowDot(color: Color(red: 0.18, green: 0.80, blue: 0.44))
                }

                Spacer(minLength: scaled(12))

                Text("Bilgi Penceresi")
                    .font(.system(size: scaled(15), weight: .semibold, design: .rounded))
                    .foregroundStyle(windowTitleColor)
            }
            .padding(.horizontal, scaled(16))
            .padding(.vertical, scaled(14))
            .background(
                RoundedRectangle(cornerRadius: scaled(22), style: .continuous)
                    .fill(windowPanelStyle)
            )
            .overlay(
                RoundedRectangle(cornerRadius: scaled(22), style: .continuous)
                    .stroke(windowStrokeColor, lineWidth: 1)
                    .allowsHitTesting(false)
            )
        }

        private func windowDot(color: Color) -> some View {
            Circle()
                .fill(color)
                .frame(width: scaled(10), height: scaled(10))
        }
    }

    private struct MetricRow: View {
        @Environment(\.colorScheme) private var colorScheme
        @Environment(\.pageScaleFactor) private var pageScaleFactor

        let title: String
        let headline: String
        let headlineColor: Color
        let secondaryText: String?
        let tertiaryText: String?

        private var titleColor: Color {
            if colorScheme == .dark {
                return .white.opacity(0.90)
            }

            return .black.opacity(0.88)
        }

        private func scaled(_ value: CGFloat) -> CGFloat {
            pageScaled(value, by: pageScaleFactor)
        }

        var body: some View {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .top, spacing: scaled(16)) {
                    titleView

                    Spacer(minLength: scaled(16))

                    valueColumn(
                        alignment: .trailing,
                        textAlignment: .trailing,
                        frameAlignment: .trailing
                    )
                }

                VStack(alignment: .leading, spacing: scaled(12)) {
                    titleView

                    valueColumn(
                        alignment: .leading,
                        textAlignment: .leading,
                        frameAlignment: .leading
                    )
                }
            }
        }

        private var titleView: some View {
            Text(title)
                .font(.system(size: scaled(25), weight: .regular, design: .rounded))
                .foregroundStyle(titleColor)
                .fixedSize(horizontal: false, vertical: true)
        }

        private func valueColumn(
            alignment: HorizontalAlignment,
            textAlignment: TextAlignment,
            frameAlignment: Alignment
        ) -> some View {
            VStack(alignment: alignment, spacing: scaled(8)) {
                primaryValueView(
                    textAlignment: textAlignment,
                    stackAlignment: alignment
                )
                .foregroundStyle(headlineColor)
                .frame(maxWidth: .infinity, alignment: frameAlignment)

                if let secondaryText {
                    VStack(alignment: alignment, spacing: scaled(2)) {
                        Text(secondaryText)
                            .font(.system(size: scaled(23), weight: .semibold, design: .rounded))
                            .fixedSize(horizontal: false, vertical: true)

                        if let tertiaryText {
                            Text("(\(tertiaryText))")
                                .font(.system(size: scaled(20), weight: .medium, design: .rounded))
                                .foregroundStyle(headlineColor.opacity(0.88))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .foregroundStyle(headlineColor)
                    .frame(maxWidth: .infinity, alignment: frameAlignment)
                }
            }
        }

        @ViewBuilder
        private func primaryValueView(
            textAlignment: TextAlignment,
            stackAlignment: HorizontalAlignment
        ) -> some View {
            let parts = splitCountText(headline)

            if let count = parts.countPart, let label = parts.labelPart {
                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .firstTextBaseline, spacing: scaled(8)) {
                        Text(count)
                            .font(.system(size: scaled(35), weight: .bold, design: .rounded))

                        Text(label)
                            .font(.system(size: scaled(23), weight: .regular, design: .rounded))
                    }

                    VStack(alignment: stackAlignment, spacing: scaled(4)) {
                        Text(count)
                            .font(.system(size: scaled(35), weight: .bold, design: .rounded))

                        Text(label)
                            .font(.system(size: scaled(23), weight: .regular, design: .rounded))
                    }
                }
                .multilineTextAlignment(textAlignment)
                .fixedSize(horizontal: false, vertical: true)
            } else {
                Text(headline)
                    .font(.system(size: scaled(23), weight: .regular, design: .rounded))
                    .multilineTextAlignment(textAlignment)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }

        private func splitCountText(_ text: String) -> (countPart: String?, labelPart: String?) {
            let parts = text.split(separator: " ", maxSplits: 1).map(String.init)

            guard let first = parts.first, isNumeric(first) else {
                return (nil, nil)
            }

            let remaining = parts.count > 1 ? parts[1] : nil
            return (first, remaining)
        }

        private func isNumeric(_ text: String) -> Bool {
            let allowed = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: ".,"))
            return !text.isEmpty && text.unicodeScalars.allSatisfy { allowed.contains($0) }
        }
    }

    private struct ShareSnapshotView: View {
        @Environment(\.colorScheme) private var colorScheme
        @Environment(\.pageScaleFactor) private var pageScaleFactor

        let input: CalculationInput
        let result: CombinedCalculationResult
        let backgroundColors: [Color]

        private func scaled(_ value: CGFloat) -> CGFloat {
            pageScaled(value, by: pageScaleFactor)
        }

        var body: some View {
            ZStack {
                AppBackgroundView(
                    colors: backgroundColors,
                    imageFocus: .trailing
                )

                VStack(alignment: .leading, spacing: scaled(28)) {
                    VStack(alignment: .leading, spacing: scaled(8)) {
                        Text("İSG Personel Süreleri")
                            .font(.system(size: scaled(50), weight: .bold, design: .rounded))
                            .foregroundStyle(titleColor)

                        Text("Aylık Çalışma Süreleri")
                            .font(.system(size: scaled(24), weight: .semibold, design: .rounded))
                            .foregroundStyle(subtitleColor)
                    }

                    ViewThatFits(in: .horizontal) {
                        HStack(spacing: scaled(16)) {
                            summaryChips
                        }

                        VStack(alignment: .leading, spacing: scaled(12)) {
                            summaryChips
                        }
                    }

                    VStack(spacing: scaled(28)) {
                        ForEach(result.summaries) { summary in
                            RoleCardView(summary: summary)
                        }
                    }
                }
                .padding(scaled(40))
            }
            .frame(width: 1120)
        }

        private var summaryChips: some View {
            Group {
                InfoChip(
                    title: "Tehlike Sınıfı",
                    value: input.hazard.displayName,
                    tint: input.hazard.tint
                )

                InfoChip(
                    title: "Çalışan Sayısı",
                    value: input.employeeCount.formatted(),
                    tint: input.hazard.tint,
                    isNeutral: true
                )
            }
        }

        private var titleColor: Color {
            if colorScheme == .dark {
                return .white
            }

            return .black.opacity(0.96)
        }

        private var subtitleColor: Color {
            if colorScheme == .dark {
                return .white.opacity(0.82)
            }

            return .black.opacity(0.80)
        }
    }

    @Environment(\.colorScheme) private var colorScheme

    @AppStorage("page_scale") private var pageScale = 1.0

    let input: CalculationInput

    @State private var sharePayload: SharePayload?

    private var result: CombinedCalculationResult {
        ISGCalculator.calculateAll(input)
    }

    private var backgroundColors: [Color] {
        if colorScheme == .dark {
            return [
                Color(red: 0.05, green: 0.05, blue: 0.07),
                Color(red: 0.02, green: 0.02, blue: 0.03)
            ]
        }

        return [
            Color(red: 0.97, green: 0.97, blue: 0.99),
            Color(red: 0.92, green: 0.94, blue: 0.98)
        ]
    }

    private var titleColor: Color {
        if colorScheme == .dark {
            return .white.opacity(0.96)
        }

        return .black.opacity(0.94)
    }

    private var navigationBarBackground: Color {
        colorScheme == .dark ? .black : Color(red: 0.95, green: 0.96, blue: 0.98)
    }

    private var interfaceControlSize: ControlSize {
        switch pageScale {
        case ..<0.85:
            return .small
        case 1.2...:
            return .large
        default:
            return .regular
        }
    }

    private func scaled(_ value: CGFloat) -> CGFloat {
        pageScaled(value, by: pageScale)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: scaled(22)) {
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: scaled(12)) {
                        summaryChips
                    }

                    VStack(alignment: .leading, spacing: scaled(12)) {
                        summaryChips
                    }
                }
                .padding(.horizontal, scaled(20))

                Text("Aylık Çalışma Süreleri")
                    .font(.system(size: scaled(22), weight: .semibold, design: .rounded))
                    .foregroundStyle(titleColor)
                    .padding(.horizontal, scaled(20))

                LazyVStack(spacing: scaled(26)) {
                    ForEach(result.summaries) { summary in
                        RoleCardView(summary: summary)
                    }
                }
                .padding(.horizontal, scaled(16))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, scaled(20))
            .controlSize(interfaceControlSize)
            .animation(.easeInOut(duration: 0.2), value: pageScale)
        }
        .environment(\.pageScaleFactor, pageScale)
        .background {
            AppBackgroundView(
                colors: backgroundColors,
                imageFocus: .trailing
            )
        }
        .navigationTitle("Hesaplama")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(navigationBarBackground, for: .navigationBar)
        .toolbarColorScheme(colorScheme == .dark ? .dark : .light, for: .navigationBar)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                PageScaleControl(scale: $pageScale)

                Button {
                    shareResultImage()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                .accessibilityLabel("Sonucu görsel olarak paylaş")
            }
        }
        .sheet(item: $sharePayload) { payload in
            ActivityShareSheet(activityItems: payload.items)
        }
    }

    private var summaryChips: some View {
        Group {
            InfoChip(
                title: "Tehlike Sınıfı",
                value: input.hazard.displayName,
                tint: input.hazard.tint
            )

            InfoChip(
                title: "Çalışan Sayısı",
                value: input.employeeCount.formatted(),
                tint: input.hazard.tint,
                isNeutral: true
            )
        }
    }

    private func shareResultImage() {
        guard let image = renderShareImage() else { return }
        sharePayload = SharePayload(items: [image])
    }

    private func renderShareImage() -> UIImage? {
        let content = ShareSnapshotView(
            input: input,
            result: result,
            backgroundColors: backgroundColors
        )
        .environment(\.colorScheme, colorScheme)
        .environment(\.pageScaleFactor, 1.0)

        let renderer = ImageRenderer(content: content)
        renderer.scale = UIScreen.main.scale
        renderer.proposedSize = ProposedViewSize(width: 1120, height: nil)

        return renderer.uiImage
    }
}

#Preview {
    NavigationStack {
        CalculationView(
            input: CalculationInput(
                hazard: .tehlikeli,
                employeeCount: 285
            )
        )
    }
}
