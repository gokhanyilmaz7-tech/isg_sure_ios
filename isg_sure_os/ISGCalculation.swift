//
//  ISGCalculation.swift
//  isg_sure_os
//
//  Created by Codex on 18.03.2026.
//

import SwiftUI

enum Role: String, CaseIterable, Identifiable {
    case isgUzmani
    case isyeriHekimi
    case digerSaglikPersoneli

    var id: Self { self }

    var displayName: String {
        switch self {
        case .isgUzmani:
            return "İş Güvenliği Uzmanı"
        case .isyeriHekimi:
            return "İşyeri Hekimi"
        case .digerSaglikPersoneli:
            return "Diğer Sağlık Personeli"
        }
    }

    var accentColor: Color {
        switch self {
        case .isgUzmani:
            return Color(red: 0.09, green: 0.66, blue: 0.33)
        case .isyeriHekimi:
            return Color(red: 0.88, green: 0.29, blue: 0.23)
        case .digerSaglikPersoneli:
            return Color(red: 0.91, green: 0.70, blue: 0.02)
        }
    }

    var avatarBackgroundColor: Color {
        accentColor.opacity(0.14)
    }

    var avatarStrokeColor: Color {
        accentColor.opacity(0.24)
    }

    var avatarSymbol: String {
        switch self {
        case .isgUzmani:
            return "shield.lefthalf.filled"
        case .isyeriHekimi:
            return "stethoscope"
        case .digerSaglikPersoneli:
            return "cross.case.fill"
        }
    }

    var showsFullTimeRow: Bool {
        self != .digerSaglikPersoneli
    }
}

enum HazardClass: String, CaseIterable, Identifiable {
    case azTehlikeli
    case tehlikeli
    case cokTehlikeli

    var id: Self { self }

    var displayName: String {
        switch self {
        case .azTehlikeli:
            return "Az Tehlikeli"
        case .tehlikeli:
            return "Tehlikeli"
        case .cokTehlikeli:
            return "Çok Tehlikeli"
        }
    }

    var tint: Color {
        switch self {
        case .azTehlikeli:
            return Color(red: 0.18, green: 0.45, blue: 0.92)
        case .tehlikeli:
            return .orange
        case .cokTehlikeli:
            return .red
        }
    }
}

struct CalculationInput {
    let hazard: HazardClass
    let employeeCount: Int
}

struct CombinedCalculationResult {
    let input: CalculationInput
    let summaries: [RoleCalculationSummary]

    var shareText: String {
        var lines = [
            "İSG Personel Süreleri",
            "Tehlike Sınıfı: \(input.hazard.displayName)",
            "Çalışan Sayısı: \(input.employeeCount.formatted())",
            ""
        ]

        for summary in summaries {
            lines.append(summary.shareSection)
            lines.append("")
        }

        return lines
            .joined(separator: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct RoleCalculationSummary: Identifiable {
    let role: Role
    let hazard: HazardClass
    let employeeCount: Int
    let fullTimePeople: Int?
    let partialPeople: Int?
    let partialMinutes: Int?
    let note: String?
    let legalNote: String?
    let unavailableReason: String?

    var id: Role { role }

    var isAvailable: Bool {
        unavailableReason == nil
    }

    private var neutralResultColor: Color {
        Color(red: 0.56, green: 0.62, blue: 0.72)
    }

    private var unavailableDisplayText: String {
        if role == .digerSaglikPersoneli && hazard != .cokTehlikeli {
            return "Zorunlu Değil"
        }

        return "Belirtilmemiş"
    }

    var fullTimeText: String? {
        guard role.showsFullTimeRow else { return nil }
        guard isAvailable else { return unavailableDisplayText }
        guard let fullTimePeople else { return "Gerekli Değil" }
        return fullTimePeople > 0 ? "\(fullTimePeople) Kişi" : "Gerekli Değil"
    }

    var fullTimeValueColor: Color {
        if let fullTimePeople, fullTimePeople > 0 {
            return role.accentColor
        }

        return neutralResultColor
    }

    var partialHeadlineText: String {
        guard isAvailable else { return unavailableDisplayText }
        guard let partialPeople else { return "Gerekli Değil" }
        return partialPeople > 0 ? "\(partialPeople) Kişi" : "Gerekli Değil"
    }

    var partialHeadlineColor: Color {
        if !isAvailable {
            return neutralResultColor
        }

        if let partialPeople, partialPeople > 0 {
            return role.accentColor
        }

        return neutralResultColor
    }

    var durationText: String? {
        guard let partialMinutes, partialMinutes > 0 else { return nil }
        return Self.durationString(minutes: partialMinutes)
    }

    var minutesText: String? {
        guard let partialMinutes, partialMinutes > 0 else { return nil }
        return "\(partialMinutes.formatted()) dk"
    }

    var supportingText: String? {
        let texts = [unavailableReason, note, legalNote].compactMap { $0 }
        return texts.isEmpty ? nil : texts.joined(separator: "\n")
    }

    var shareSection: String {
        var lines = [role.displayName]

        if let fullTimeText {
            lines.append("Tam Gün (Aylık): \(fullTimeText)")
        }

        lines.append("Kısmi Süreli: \(partialHeadlineText)")

        if let durationText {
            lines.append(durationText)
        }

        if let minutesText {
            lines.append(minutesText)
        }

        if let supportingText {
            lines.append(supportingText)
        }

        return lines.joined(separator: "\n")
    }

    private static func durationString(minutes: Int) -> String {
        let hours = minutes / 60
        let remainder = minutes % 60
        return "\(hours.formatted()) saat \(remainder.formatted()) dk"
    }
}

enum ISGCalculator {
    static func calculateAll(_ input: CalculationInput) -> CombinedCalculationResult {
        let normalizedInput = CalculationInput(
            hazard: input.hazard,
            employeeCount: max(input.employeeCount, 0)
        )

        return CombinedCalculationResult(
            input: normalizedInput,
            summaries: Role.allCases.map { calculate(role: $0, input: normalizedInput) }
        )
    }

    private static func calculate(role: Role, input: CalculationInput) -> RoleCalculationSummary {
        if let unavailableReason = unavailableReason(for: role, input: input) {
            return RoleCalculationSummary(
                role: role,
                hazard: input.hazard,
                employeeCount: input.employeeCount,
                fullTimePeople: role.showsFullTimeRow ? 0 : nil,
                partialPeople: nil,
                partialMinutes: nil,
                note: nil,
                legalNote: legalNote(for: role, hazard: input.hazard),
                unavailableReason: unavailableReason
            )
        }

        let totalMinutes = totalMinutes(for: role, input: input)
        let fullTimeThreshold = fullTimeThreshold(for: role, hazard: input.hazard)
        let fullTimePeople = fullTimeThreshold.map { input.employeeCount / $0 }
        let remainderEmployees = fullTimeThreshold.map { input.employeeCount % $0 }

        let partialMinutes: Int?
        if let fullTimePeople, let remainderEmployees {
            if fullTimePeople == 0 {
                partialMinutes = totalMinutes
            } else if remainderEmployees > 0 {
                partialMinutes = remainderEmployees * perEmployeeMinutes(for: role, input: input)
            } else {
                partialMinutes = 0
            }
        } else {
            partialMinutes = totalMinutes
        }

        let partialPeople = (partialMinutes ?? 0) > 0 ? 1 : 0

        return RoleCalculationSummary(
            role: role,
            hazard: input.hazard,
            employeeCount: input.employeeCount,
            fullTimePeople: fullTimePeople,
            partialPeople: partialPeople,
            partialMinutes: partialMinutes,
            note: planningNote(
                for: role,
                fullTimePeople: fullTimePeople,
                partialMinutes: partialMinutes
            ),
            legalNote: legalNote(for: role, hazard: input.hazard),
            unavailableReason: nil
        )
    }

    private static func unavailableReason(for role: Role, input: CalculationInput) -> String? {
        guard role == .digerSaglikPersoneli else {
            return nil
        }

        if input.hazard != .cokTehlikeli {
            return "Bu tehlike sınıfında diğer sağlık personeli görevlendirmesi zorunlu değil."
        }

        if input.employeeCount < 10 {
            return "Çok tehlikeli sınıfta diğer sağlık personeli süreleri 10 çalışan ve üzeri için tanımlanıyor."
        }

        return nil
    }

    private static func totalMinutes(for role: Role, input: CalculationInput) -> Int {
        input.employeeCount * perEmployeeMinutes(for: role, input: input)
    }

    private static func perEmployeeMinutes(for role: Role, input: CalculationInput) -> Int {
        switch role {
        case .isgUzmani:
            switch input.hazard {
            case .azTehlikeli:
                return 10
            case .tehlikeli:
                return 20
            case .cokTehlikeli:
                return 40
            }
        case .isyeriHekimi:
            switch input.hazard {
            case .azTehlikeli:
                return 5
            case .tehlikeli:
                return 10
            case .cokTehlikeli:
                return 15
            }
        case .digerSaglikPersoneli:
            if input.employeeCount >= 250 {
                return 20
            }

            if input.employeeCount >= 50 {
                return 15
            }

            return 10
        }
    }

    private static func fullTimeThreshold(for role: Role, hazard: HazardClass) -> Int? {
        switch role {
        case .isgUzmani:
            switch hazard {
            case .azTehlikeli:
                return 1000
            case .tehlikeli:
                return 500
            case .cokTehlikeli:
                return 250
            }
        case .isyeriHekimi:
            switch hazard {
            case .azTehlikeli:
                return 2000
            case .tehlikeli:
                return 1000
            case .cokTehlikeli:
                return 750
            }
        case .digerSaglikPersoneli:
            return nil
        }
    }

    private static func planningNote(for role: Role, fullTimePeople: Int?, partialMinutes: Int?) -> String? {
        guard role != .digerSaglikPersoneli else {
            return nil
        }

        guard let fullTimePeople, let partialMinutes else {
            return nil
        }

        if fullTimePeople == 0 {
            return "Tam gün zorunluluğu oluşmadığı için süre kısmi süreli planlanır."
        }

        if partialMinutes == 0 {
            return "Kalan kısmi süre ihtiyacı bulunmuyor."
        }

        return "Tam gün personel dışında kalan süre ayrıca kısmi süreli planlanmalıdır."
    }

    private static func legalNote(for role: Role, hazard: HazardClass) -> String? {
        switch role {
        case .isgUzmani:
            let minutes: Int
            let threshold: Int

            switch hazard {
            case .azTehlikeli:
                minutes = 10
                threshold = 1000
            case .tehlikeli:
                minutes = 20
                threshold = 500
            case .cokTehlikeli:
                minutes = 40
                threshold = 250
            }

            return "\(hazard.displayName) sınıfta iş güvenliği uzmanı için kişi başı süre \(minutes) dk/ay, tam gün eşik \(threshold.formatted()) çalışandır."
        case .isyeriHekimi:
            let minutes: Int
            let threshold: Int

            switch hazard {
            case .azTehlikeli:
                minutes = 5
                threshold = 2000
            case .tehlikeli:
                minutes = 10
                threshold = 1000
            case .cokTehlikeli:
                minutes = 15
                threshold = 750
            }

            return "\(hazard.displayName) sınıfta işyeri hekimi için kişi başı süre \(minutes) dk/ay, tam gün eşik \(threshold.formatted()) çalışandır."
        case .digerSaglikPersoneli where hazard == .cokTehlikeli:
            return "Çok tehlikeli sınıfta diğer sağlık personeli için 10-49 çalışan aralığında 10 dk, 50-249 aralığında 15 dk, 250 ve üzeri için 20 dk kişi başı/ay esas alınır."
        case .digerSaglikPersoneli:
            return "Diğer sağlık personeli süreleri mevzuatta çok tehlikeli sınıf için çalışan aralıklarına göre tanımlanır."
        }
    }
}
