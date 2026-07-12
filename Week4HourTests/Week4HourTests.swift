import XCTest
@testable import Week4Hour

final class Week4HourTests: XCTestCase {
    func testDEALPhaseOrder() {
        let phases = DEALPhase.allCases.sorted { $0.order < $1.order }
        XCTAssertEqual(phases[0], .definition)
        XCTAssertEqual(phases[1], .elimination)
        XCTAssertEqual(phases[2], .automation)
        XCTAssertEqual(phases[3], .liberation)
    }

    func testWeeklyAuditPareto() {
        let entry1 = TimeAuditEntry(activity: "Deep Work", hours: 20, category: .deepWork, isHighValue: true, energyDrain: 3)
        let entry2 = TimeAuditEntry(activity: "Meetings", hours: 30, category: .meetings, isHighValue: false, energyDrain: 4)
        let audit = WeeklyAudit(weekStart: Date(), entries: [entry1, entry2], targetWorkHours: 4)
        XCTAssertEqual(audit.totalHours, 50)
        XCTAssertEqual(audit.highValueHours, 20)
        XCTAssertEqual(audit.paretoRatio, 0.4, accuracy: 0.01)
        XCTAssertEqual(audit.hoursSaved, 46)
    }

    func testDreamlineCalculation() {
        let dream1 = DreamItem(dream: "Travel", category: .doing, monthlyCost: 5000, oneTimeCost: 10000, isTarget: true)
        let dream2 = DreamItem(dream: "Workshop", category: .having, monthlyCost: 2000, oneTimeCost: 6000, isTarget: true)
        let dreamline = Dreamline(dreams: [dream1, dream2])
        let expectedMonthly = 5000.0 + 2000.0 + (10000.0 + 6000.0) / 12.0
        XCTAssertEqual(dreamline.targetMonthlyIncome, expectedMonthly, accuracy: 0.01)
        XCTAssertGreaterThan(dreamline.targetDailyIncome, 0)
    }

    func testEliminationRulePresets() {
        let presets = EliminationRule.presets
        XCTAssertGreaterThan(presets.count, 0)
        XCTAssertTrue(presets.contains { $0.name == "信息斋戒" })
        XCTAssertTrue(presets.contains { $0.name == "二分钟法则" })
    }

    func testAutomationTemplatePresets() {
        let presets = AutomationTemplate.presets
        XCTAssertGreaterThan(presets.count, 0)
        XCTAssertTrue(presets.contains { $0.name == "邮件自动分拣" })
    }

    func testUserProgressInitialState() {
        let progress = UserProgress()
        XCTAssertEqual(progress.currentPhase, .definition)
        XCTAssertGreaterThan(progress.activeRules.count, 0)
        XCTAssertGreaterThan(progress.automations.count, 0)
    }
}
