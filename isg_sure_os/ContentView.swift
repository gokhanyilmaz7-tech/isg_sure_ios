//
//  ContentView.swift
//  isg_sure_os
//
//  Created by GökhanMacbook on 18.03.2026.
//

import SwiftUI
import UIKit

struct ContentView: View {
    private struct SurfaceSection<Content: View>: View {
        @Environment(\.colorScheme) private var colorScheme
        @Environment(\.pageScaleFactor) private var pageScaleFactor

        let title: String?
        let tint: Color
        let content: Content

        init(_ title: String? = nil, tint: Color, @ViewBuilder content: () -> Content) {
            self.title = title
            self.tint = tint
            self.content = content()
        }

        private var fillStyle: AnyShapeStyle {
            if colorScheme == .dark {
                return AnyShapeStyle(Color.white.opacity(0.05))
            }

            return AnyShapeStyle(tint.opacity(0.06))
        }

        private var strokeColor: Color {
            if colorScheme == .dark {
                return Color.white.opacity(0.08)
            }

            return tint.opacity(0.12)
        }

        private var titleColor: Color {
            if colorScheme == .dark {
                return .white.opacity(0.94)
            }

            return .black.opacity(0.88)
        }

        private func scaled(_ value: CGFloat) -> CGFloat {
            pageScaled(value, by: pageScaleFactor)
        }

        var body: some View {
            VStack(alignment: .leading, spacing: scaled(14)) {
                if let title {
                    Text(title)
                        .font(.system(size: scaled(18), weight: .semibold, design: .rounded))
                        .foregroundStyle(titleColor)
                }

                content
            }
            .padding(scaled(20))
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: scaled(26), style: .continuous)
                    .fill(fillStyle)
            )
            .overlay(
                RoundedRectangle(cornerRadius: scaled(26), style: .continuous)
                    .stroke(strokeColor, lineWidth: 1)
                    .allowsHitTesting(false)
            )
        }
    }

    private struct CapsuleLinkButton: View {
        @Environment(\.pageScaleFactor) private var pageScaleFactor

        let accessibilityLabel: String
        let destination: URL
        let tint: Color
        let systemImage: String?
        let iconText: String?

        private func scaled(_ value: CGFloat) -> CGFloat {
            pageScaled(value, by: pageScaleFactor)
        }

        var body: some View {
            Button {
                UIApplication.shared.open(destination)
            } label: {
                Group {
                    if let systemImage {
                        Image(systemName: systemImage)
                            .font(.system(size: scaled(14), weight: .bold))
                    } else if let iconText {
                        Text(iconText)
                            .font(.system(size: scaled(16)))
                    }
                }
                .foregroundStyle(tint)
                .frame(minWidth: scaled(36), minHeight: scaled(32))
                .padding(.horizontal, scaled(10))
                .background(
                    Capsule(style: .continuous)
                        .fill(tint.opacity(0.12))
                )
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(tint.opacity(0.18), lineWidth: 1)
                        .allowsHitTesting(false)
                )
            }
            .contentShape(Capsule(style: .continuous))
            .buttonStyle(.borderless)
            .accessibilityLabel(accessibilityLabel)
        }
    }

    private enum AppearanceMode: String, CaseIterable, Identifiable {
        case system
        case light
        case dark

        var id: Self { self }

        var title: String {
            switch self {
            case .system:
                return "Sistem"
            case .light:
                return "Açık"
            case .dark:
                return "Koyu"
            }
        }

        var colorScheme: ColorScheme? {
            switch self {
            case .system:
                return nil
            case .light:
                return .light
            case .dark:
                return .dark
            }
        }
    }

    @Environment(\.colorScheme) private var colorScheme

    @AppStorage("appearance_mode") private var appearanceModeRawValue = AppearanceMode.system.rawValue
    @AppStorage("page_scale") private var pageScale = 1.0

    @State private var selectedHazard: HazardClass = .azTehlikeli
    @State private var employeeCount = ""
    @State private var showCalculation = false

    @FocusState private var isEmployeeFieldFocused: Bool

    private let mevzuatLinkOne = URL(string: "https://www.mevzuat.gov.tr/mevzuat?MevzuatNo=16923&MevzuatTur=7&MevzuatTertip=5")!
    private let mevzuatLinkTwo = URL(string: "https://www.mevzuat.gov.tr/mevzuat?MevzuatNo=18615&MevzuatTur=7&MevzuatTertip=5")!

    private var employeeCountValue: Int {
        Int(employeeCount) ?? 0
    }

    private var employeeCountBinding: Binding<String> {
        Binding(
            get: { employeeCount },
            set: { newValue in
                employeeCount = newValue.filter(\.isNumber)
            }
        )
    }

    private var appearanceMode: AppearanceMode {
        get { AppearanceMode(rawValue: appearanceModeRawValue) ?? .system }
        set { appearanceModeRawValue = newValue.rawValue }
    }

    private var backgroundColors: [Color] {
        if colorScheme == .dark {
            return [
                Color(red: 0.10, green: 0.12, blue: 0.16),
                Color(red: 0.05, green: 0.06, blue: 0.09)
            ]
        }

        return [
            Color(red: 0.98, green: 0.97, blue: 0.93),
            Color(red: 0.95, green: 0.98, blue: 0.96)
        ]
    }

    private var primaryTextColor: Color {
        if colorScheme == .dark {
            return .white.opacity(0.96)
        }

        return .black.opacity(0.92)
    }

    private var secondaryTextColor: Color {
        if colorScheme == .dark {
            return .white.opacity(0.78)
        }

        return .black.opacity(0.72)
    }

    private var bottomInfoTextColor: Color {
        if colorScheme == .dark {
            return .white.opacity(0.94)
        }

        return .black
    }

    private var countFieldBackground: Color {
        if colorScheme == .dark {
            return Color.white.opacity(0.08)
        }

        return selectedHazard.tint.opacity(0.10)
    }

    private var calculationInput: CalculationInput {
        CalculationInput(
            hazard: selectedHazard,
            employeeCount: employeeCountValue
        )
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
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: scaled(16)) {
                    SurfaceSection("Çalışan Sayısı", tint: selectedHazard.tint) {
                        VStack(alignment: .leading, spacing: scaled(12)) {
                            Text("Güncel çalışan sayısını giriniz:")
                                .font(.system(size: scaled(13), weight: .semibold, design: .rounded))
                                .foregroundStyle(secondaryTextColor)

                            TextField("0", text: employeeCountBinding)
                                .keyboardType(.asciiCapableNumberPad)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .focused($isEmployeeFieldFocused)
                                .font(.system(size: scaled(46), weight: .bold, design: .rounded))
                                .foregroundStyle(primaryTextColor)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, scaled(18))
                                .padding(.vertical, scaled(24))
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: scaled(24), style: .continuous)
                                        .fill(countFieldBackground)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: scaled(24), style: .continuous)
                                        .stroke(selectedHazard.tint.opacity(0.22), lineWidth: 1)
                                        .allowsHitTesting(false)
                                )

                            Text("Sonra tehlike sınıfını seçiniz:")
                                .font(.system(size: scaled(13), weight: .regular, design: .rounded))
                                .foregroundStyle(secondaryTextColor)
                        }
                    }

                    SurfaceSection("Tehlike Sınıfı", tint: selectedHazard.tint) {
                        Picker("Tehlike Sınıfı", selection: $selectedHazard) {
                            ForEach(HazardClass.allCases) { hazard in
                                Text(hazard.displayName).tag(hazard)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    SurfaceSection(tint: selectedHazard.tint) {
                        Button {
                            isEmployeeFieldFocused = false
                            showCalculation = true
                        } label: {
                            Label("Hesapla", systemImage: "arrow.right.circle.fill")
                                .font(.system(size: scaled(20), weight: .semibold, design: .rounded))
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(employeeCountValue <= 0)

                        if employeeCountValue <= 0 {
                            Text("Devam etmek için hesapla butonuna basınız.")
                                .font(.system(size: scaled(13), weight: .regular, design: .rounded))
                                .foregroundStyle(secondaryTextColor)
                        }
                    }

                    SurfaceSection(tint: selectedHazard.tint) {
                        VStack(alignment: .leading, spacing: scaled(10)) {
                            Text("İşyerindeki çalışan sayısı ve işyerinin tehlike sınıfına göre işyerinde tam süreli ve/veya kısmi süreli iş güvenliği uzmanı, işyeri hekimi görevlendirilir.")
                                .font(.system(size: scaled(13), weight: .semibold, design: .rounded))
                                .foregroundStyle(bottomInfoTextColor)
                                .fixedSize(horizontal: false, vertical: true)

                            Text("Tam süreli görevlendirme haricinde kalan süreler için Kısmi Süreli iş güvenliği uzmanı, işyeri hekimi ile işyeri çok tehlikeli sınıfta ise diğer sağlık personeli görevlendirilir. (Tam zamanlı işyeri hekimi görevlendirilen işyerlerinde DSP görevlendirilme zorunluluğu yoktur.)")
                                .font(.system(size: scaled(13), weight: .semibold, design: .rounded))
                                .foregroundStyle(bottomInfoTextColor)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    SurfaceSection(tint: selectedHazard.tint) {
                        ViewThatFits(in: .horizontal) {
                            HStack(spacing: scaled(8)) {
                                Text("Görünüm")
                                    .font(.system(size: scaled(18), weight: .semibold, design: .rounded))

                                Spacer(minLength: scaled(8))

                                HStack(spacing: scaled(8)) {
                                    CapsuleLinkButton(
                                        accessibilityLabel: "İş güvenliği uzmanı mevzuat bağlantısı",
                                        destination: mevzuatLinkOne,
                                        tint: selectedHazard.tint,
                                        systemImage: nil,
                                        iconText: "⛑"
                                    )

                                    CapsuleLinkButton(
                                        accessibilityLabel: "İşyeri hekimi mevzuat bağlantısı",
                                        destination: mevzuatLinkTwo,
                                        tint: selectedHazard.tint,
                                        systemImage: "stethoscope",
                                        iconText: nil
                                    )
                                }
                            }

                            VStack(alignment: .leading, spacing: scaled(12)) {
                                Text("Görünüm")
                                    .font(.system(size: scaled(18), weight: .semibold, design: .rounded))

                                HStack(spacing: scaled(8)) {
                                    CapsuleLinkButton(
                                        accessibilityLabel: "İş güvenliği uzmanı mevzuat bağlantısı",
                                        destination: mevzuatLinkOne,
                                        tint: selectedHazard.tint,
                                        systemImage: nil,
                                        iconText: "⛑"
                                    )

                                    CapsuleLinkButton(
                                        accessibilityLabel: "İşyeri hekimi mevzuat bağlantısı",
                                        destination: mevzuatLinkTwo,
                                        tint: selectedHazard.tint,
                                        systemImage: "stethoscope",
                                        iconText: nil
                                    )
                                }
                            }
                        }

                        Picker("Tema", selection: $appearanceModeRawValue) {
                            ForEach(AppearanceMode.allCases) { mode in
                                Text(mode.title).tag(mode.rawValue)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
                .frame(maxWidth: .infinity)
                .controlSize(interfaceControlSize)
                .animation(.easeInOut(duration: 0.2), value: pageScale)
            }
            .padding(.horizontal, scaled(16))
            .padding(.vertical, scaled(16))
            .scrollDismissesKeyboard(.interactively)
            .environment(\.pageScaleFactor, pageScale)
            .background {
                AppBackgroundView(
                    colors: backgroundColors,
                    imageFocus: .leading
                )
            }
            .navigationTitle("İSG Personel Süreleri")
            .navigationDestination(isPresented: $showCalculation) {
                CalculationView(input: calculationInput)
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    PageScaleControl(scale: $pageScale)

                    Button {
                        resetForm()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                    }
                    .disabled(employeeCount.isEmpty && selectedHazard == .azTehlikeli)
                    .accessibilityLabel("Sıfırla")
                }

                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()

                    Button("Bitti") {
                        isEmployeeFieldFocused = false
                    }
                }
            }
        }
        .tint(selectedHazard.tint)
        .preferredColorScheme(appearanceMode.colorScheme)
    }

    private func resetForm() {
        selectedHazard = .azTehlikeli
        employeeCount = ""
        isEmployeeFieldFocused = false
    }
}

#Preview {
    ContentView()
}
