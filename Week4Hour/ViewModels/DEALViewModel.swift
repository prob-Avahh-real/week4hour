import SwiftUI
import Combine

@MainActor
final class DEALViewModel: ObservableObject {
    @Published var progress = UserProgress()
    @Published var currentAudit = WeeklyAudit(weekStart: Date().startOfWeek)

    private let storage = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init() { load() }

    // MARK: - Persistence

    func save() {
        guard let data = try? encoder.encode(progress) else { return }
        storage.set(data, forKey: "week4hour_progress")
        guard let auditData = try? encoder.encode(currentAudit) else { return }
        storage.set(auditData, forKey: "week4hour_audit")
    }

    private func load() {
        if let data = storage.data(forKey: "week4hour_progress"),
           let p = try? decoder.decode(UserProgress.self, from: data) {
            progress = p
        }
        if let data = storage.data(forKey: "week4hour_audit"),
           let a = try? decoder.decode(WeeklyAudit.self, from: data) {
            currentAudit = a
        }
    }

    // MARK: - Time Audit

    func addAuditEntry(_ entry: TimeAuditEntry) {
        currentAudit.entries.append(entry)
        currentAudit.insight = generateInsight()
        save()
    }

    func deleteAuditEntry(_ id: UUID) {
        currentAudit.entries.removeAll { $0.id == id }
        save()
    }

    private func generateInsight() -> String {
        let ratio = currentAudit.paretoRatio
        if ratio < 0.2 {
            return "⚠️ 高价值时间不到 20%——需要大幅砍掉低价值活动"
        } else if ratio < 0.5 {
            return "🔄 在正确的方向上，再砍掉 \(Int(currentAudit.lowValueHours)) 小时就能触达 4 小时目标"
        } else if currentAudit.totalHours <= 4 {
            return "🎉 你已经在 4 小时以内了！现在的重点是提高每小时的产出"
        } else {
            return "💪 高价值比例不错，压缩总时长到 4 小时还需要优化"
        }
    }

    // MARK: - Rules

    func toggleRule(_ id: UUID) {
        guard let idx = progress.activeRules.firstIndex(where: { $0.id == id }) else { return }
        progress.activeRules[idx].isActive.toggle()
        save()
    }

    func checkInRule(_ id: UUID) {
        guard let idx = progress.activeRules.firstIndex(where: { $0.id == id }) else { return }
        progress.activeRules[idx].streak += 1
        progress.streak += 1
        save()
    }

    // MARK: - Automation

    func toggleAutomation(_ id: UUID) {
        guard let idx = progress.automations.firstIndex(where: { $0.id == id }) else { return }
        progress.automations[idx].isBuilt.toggle()
        save()
    }

    var totalHoursSaved: Double {
        progress.automations.filter(\.isBuilt).reduce(0) { $0 + $1.estimatedHoursSaved }
    }

    // MARK: - Dreamline

    func addDream(_ item: DreamItem) {
        progress.dreamline.dreams.append(item)
        save()
    }

    func toggleDreamTarget(_ id: UUID) {
        guard let idx = progress.dreamline.dreams.firstIndex(where: { $0.id == id }) else { return }
        progress.dreamline.dreams[idx].isTarget.toggle()
        save()
    }

    // MARK: - Fear-Setting

    func addFear(_ item: FearItem) {
        progress.fearLog.append(item)
        save()
    }

    func advancePhase() {
        let all = DEALPhase.allCases
        if let idx = all.firstIndex(of: progress.currentPhase), idx + 1 < all.count {
            progress.currentPhase = all[idx + 1]
            save()
        }
    }
}

extension Date {
    var startOfWeek: Date {
        let cal = Calendar.current
        let comps = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return cal.date(from: comps) ?? self
    }
}
