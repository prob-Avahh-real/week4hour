import Foundation

// MARK: - DEAL Framework

/// Tim Ferriss 的 DEAL 框架
enum DEALPhase: String, CaseIterable, Codable {
    case definition   = "D · 定义"
    case elimination  = "E · 消除"
    case automation   = "A · 自动化"
    case liberation   = "L · 解放"

    var icon: String {
        switch self {
        case .definition:  "🎯"
        case .elimination: "✂️"
        case .automation:  "🤖"
        case .liberation:  "🕊️"
        }
    }

    var subtitle: String {
        switch self {
        case .definition:  "定义你想要的生活，而不是别人期待的生活"
        case .elimination: "用 80/20 法则砍掉 80% 的低价值事务"
        case .automation:  "建立自动运转的系统，让自己变得不必要"
        case .liberation:  "从办公室解放出来，实现地理自由"
        }
    }

    var order: Int {
        switch self {
        case .definition: 0; case .elimination: 1
        case .automation: 2; case .liberation: 3
        }
    }
}

// MARK: - Weekly Audit

struct TimeAuditEntry: Identifiable, Codable {
    var id = UUID()
    var activity: String
    var hours: Double
    var category: ActivityCategory
    var isHighValue: Bool   // 是否属于 20% 高价值活动
    var energyDrain: Int    // 1-5 精力消耗

    enum ActivityCategory: String, CaseIterable, Codable {
        case deepWork    = "深度工作"
        case meetings    = "会议"
        case email       = "邮件/消息"
        case admin       = "行政杂务"
        case learning    = "学习成长"
        case leisure     = "休息娱乐"
        case commute     = "通勤"
        case other       = "其他"

        var icon: String {
            switch self {
            case .deepWork: "🧠"; case .meetings: "👥"
            case .email: "📧";    case .admin: "📋"
            case .learning: "📚"; case .leisure: "🎮"
            case .commute: "🚗";  case .other: "❓"
            }
        }
    }
}

struct WeeklyAudit: Codable {
    var weekStart: Date
    var entries: [TimeAuditEntry] = []
    var targetWorkHours: Double = 4
    var insight: String = ""

    var totalHours: Double { entries.reduce(0) { $0 + $1.hours } }
    var highValueHours: Double { entries.filter(\.isHighValue).reduce(0) { $0 + $1.hours } }
    var lowValueHours: Double { totalHours - highValueHours }
    var paretoRatio: Double { totalHours > 0 ? highValueHours / totalHours : 0 }
    var hoursSaved: Double { max(0, totalHours - targetWorkHours) }
}

// MARK: - Elimination Challenge

struct EliminationRule: Identifiable, Codable {
    var id = UUID()
    var name: String
    var description: String
    var isActive: Bool = false
    var streak: Int = 0

    static let presets: [EliminationRule] = [
        EliminationRule(name: "信息斋戒", description: "早上 10 点前不看微信/邮件"),
        EliminationRule(name: "二分钟法则", description: "少于 2 分钟的事立刻做，不排队"),
        EliminationRule(name: "批量处理日", description: "每周只处理 2 次邮件（周三、周五）"),
        EliminationRule(name: "说不练习", description: "每天至少拒绝一次不重要的请求"),
        EliminationRule(name: "帕金森定律", description: "给任务设定比预期短一半的截止时间"),
        EliminationRule(name: "会议死刑", description: "所有会议不超过 15 分钟"),
        EliminationRule(name: "选择性无知", description: "不看新闻、不刷社交媒体时间线"),
    ]
}

// MARK: - Automation Builder

struct AutomationTemplate: Identifiable, Codable {
    var id = UUID()
    var name: String
    var category: AutomationCategory
    var description: String
    var steps: [String]
    var tools: [String]
    var isBuilt: Bool = false
    var estimatedHoursSaved: Double   // 每周节省的小时数

    enum AutomationCategory: String, CaseIterable, Codable {
        case email     = "邮件"
        case finance   = "财务"
        case schedule  = "日程"
        case content   = "内容"
        case customer  = "客户服务"
        case data      = "数据处理"

        var icon: String {
            switch self {
            case .email: "📧"; case .finance: "💰"; case .schedule: "📅"
            case .content: "📝"; case .customer: "💬"; case .data: "📊"
            }
        }
    }

    static let presets: [AutomationTemplate] = [
        AutomationTemplate(
            name: "邮件自动分拣", category: .email,
            description: "用规则自动把邮件分为「需回复」「需阅读」「垃圾」三类",
            steps: ["创建 3 个文件夹", "设置发件人规则", "开启自动回复模板"],
            tools: ["Gmail Filters", "Spark", "Superhuman"],
            estimatedHoursSaved: 5
        ),
        AutomationTemplate(
            name: "自动记账 + 发票", category: .finance,
            description: "银行流水自动分类，发票 OCR 自动归档",
            steps: ["连接银行 API", "设置分类规则", "配置自动导出"],
            tools: ["快捷指令", "Numbers", "扫描宝"],
            estimatedHoursSaved: 3
        ),
        AutomationTemplate(
            name: "社交媒体自动排期", category: .content,
            description: "一次写完一周内容，定时自动发布",
            steps: ["批量创作 7 天内容", "设置发布时间表", "开启自动回复"],
            tools: ["Buffer", "Later", "快捷指令"],
            estimatedHoursSaved: 4
        ),
        AutomationTemplate(
            name: "常见问题自动回复", category: .customer,
            description: "整理 FAQ，设置关键词自动回复模板",
            steps: ["收集 Top 20 常见问题", "编写回复模板", "配置自动触发规则"],
            tools: ["TextExpander", "快捷指令", "企业微信机器人"],
            estimatedHoursSaved: 6
        ),
        AutomationTemplate(
            name: "数据报表自动生成", category: .data,
            description: "原始数据 → 自动清洗 → 可视化图表 → 定时发送",
            steps: ["确定数据源", "编写清洗脚本", "设置定时任务"],
            tools: ["Numbers 自动化", "快捷指令", "Pythonista"],
            estimatedHoursSaved: 8
        ),
    ]
}

// MARK: - Dreamline Calculator

struct DreamItem: Identifiable, Codable {
    var id = UUID()
    var dream: String
    var category: DreamCategory
    var monthlyCost: Double     // 实现这个梦想每月需要多少钱
    var oneTimeCost: Double     // 一次性费用
    var isTarget: Bool = false  // 是否标为当前目标

    enum DreamCategory: String, CaseIterable, Codable {
        case having  = "拥有"    // 物质
        case being   = "成为"    // 身份
        case doing   = "去做"    // 体验

        var icon: String {
            switch self {
            case .having: "🏠"; case .being: "🌟"; case .doing: "✈️"
            }
        }
    }
}

struct Dreamline: Codable {
    var dreams: [DreamItem] = []
    var targetMonthlyIncome: Double {
        dreams.filter(\.isTarget).reduce(0) { $0 + $1.monthlyCost }
            + dreams.filter(\.isTarget).reduce(0) { $0 + $1.oneTimeCost } / 12
    }
    var targetDailyIncome: Double {
        targetMonthlyIncome / 30
    }
}

// MARK: - Fear-Setting Exercise

struct FearItem: Identifiable, Codable {
    var id = UUID()
    var fear: String            // 你害怕的事情
    var prevent: String         // 如何预防
    var repair: String          // 如果真的发生了，如何修复
    var costOfInaction: String  // 如果不做这件事，6个月/1年/3年后的代价
    var severity: Int           // 1-10 实际严重程度（写下来通常会发现没那么可怕）
}

// MARK: - User Progress

struct UserProgress: Codable {
    var currentPhase: DEALPhase = .definition
    var weeklyAudits: [WeeklyAudit] = []
    var activeRules: [EliminationRule] = EliminationRule.presets
    var automations: [AutomationTemplate] = AutomationTemplate.presets
    var dreamline: Dreamline = Dreamline()
    var fearLog: [FearItem] = []
    var streak: Int = 0
    var startDate: Date = Date()
}
