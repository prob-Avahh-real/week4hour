import SwiftUI

// MARK: - Colors

extension Color {
    static let w4Dark    = Color(red: 0.06, green: 0.06, blue: 0.08)
    static let w4Card    = Color(red: 0.11, green: 0.11, blue: 0.14)
    static let w4Gold    = Color(red: 0.90, green: 0.72, blue: 0.28)
    static let w4Mint    = Color(red: 0.15, green: 0.82, blue: 0.60)
    static let w4Crimson = Color(red: 0.88, green: 0.28, blue: 0.28)
    static let w4Sky     = Color(red: 0.30, green: 0.60, blue: 0.95)
    static let w4Violet  = Color(red: 0.62, green: 0.38, blue: 0.92)
    static let w4Text    = Color(red: 0.90, green: 0.90, blue: 0.93)
    static let w4Muted   = Color(red: 0.50, green: 0.50, blue: 0.55)
}

// MARK: - Content View

struct ContentView: View {
    @EnvironmentObject var vm: DEALViewModel

    var body: some View {
        TabView {
            DashboardTab(vm: vm)
                .tabItem { Label("仪表盘", systemImage: "gauge.with.dots.needle.33percent") }

            AuditTab(vm: vm)
                .tabItem { Label("时间审计", systemImage: "clock.arrow.2.circlepath") }

            EliminateTab(vm: vm)
                .tabItem { Label("消除", systemImage: "scissors") }

            AutomateTab(vm: vm)
                .tabItem { Label("自动化", systemImage: "gearshape.2.fill") }

            DreamTab(vm: vm)
                .tabItem { Label("梦想线", systemImage: "star.fill") }
        }
        .tint(.w4Gold)
    }
}

// MARK: - Dashboard Tab

struct DashboardTab: View {
    @ObservedObject var vm: DEALViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                Color.w4Dark.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 20) {
                        // 阶段环
                        phaseRing
                        // 统计卡片
                        statsRow
                        // 本周审计概览
                        auditPreview
                        // 活跃规则
                        activeRulesPreview

                        Spacer().frame(height: 80)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle("每周工作 4 小时")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var phaseRing: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.06), lineWidth: 16)
                    .frame(width: 180, height: 180)

                let progress = Double(vm.progress.currentPhase.order) / Double(DEALPhase.allCases.count - 1)
                Circle()
                    .trim(from: 0, to: max(0.01, progress))
                    .stroke(
                        AngularGradient(colors: [.w4Gold, .w4Mint, .w4Sky, .w4Violet],
                                        center: .center, startAngle: .degrees(-90), endAngle: .degrees(270)),
                        style: StrokeStyle(lineWidth: 16, lineCap: .round)
                    )
                    .frame(width: 180, height: 180)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 4) {
                    Text(vm.progress.currentPhase.icon).font(.system(size: 36))
                    Text(vm.progress.currentPhase.rawValue)
                        .font(.headline).foregroundStyle(.w4Text)
                    Text(vm.progress.currentPhase.subtitle)
                        .font(.caption2).foregroundStyle(.w4Muted)
                        .multilineTextAlignment(.center)
                        .frame(width: 140)
                }
            }

            if vm.progress.currentPhase != .liberation {
                Button { vm.advancePhase() } label: {
                    Text("进入下一阶段 →").font(.caption).foregroundStyle(.w4Gold)
                }
            }
        }
        .padding(.top, 16)
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            statCard("\(vm.progress.streak)", "连续天数", "flame.fill", .w4Crimson)
            statCard("\(Int(vm.totalHoursSaved))h", "已节省", "clock.badge.checkmark.fill", .w4Mint)
            statCard("¥\(Int(vm.progress.dreamline.targetDailyIncome))", "目标日入", "yensign.circle.fill", .w4Gold)
        }
    }

    private func statCard(_ value: String, _ label: String, _ icon: String, _ color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon).font(.title3).foregroundStyle(color)
            Text(value).font(.title3).fontWeight(.bold).foregroundStyle(.white)
            Text(label).font(.caption2).foregroundStyle(.w4Muted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(.w4Card)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var auditPreview: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("📊 本周时间分配").font(.headline).foregroundStyle(.w4Text)
            HStack(spacing: 4) {
                let highPct = Int(vm.currentAudit.paretoRatio * 100)
                Text("高价值 \(highPct)%").font(.caption).foregroundStyle(.w4Mint)
                Text("·").foregroundStyle(.w4Muted)
                Text("总计 \(String(format: "%.1f", vm.currentAudit.totalHours))h").font(.caption).foregroundStyle(.w4Muted)
                Text("·").foregroundStyle(.w4Muted)
                Text("目标 4h").font(.caption).foregroundStyle(.w4Gold)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4).fill(Color.white.opacity(0.06)).frame(height: 8)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(vm.currentAudit.paretoRatio >= 0.5 ? Color.w4Mint : Color.w4Crimson)
                        .frame(width: geo.size.width * vm.currentAudit.paretoRatio, height: 8)
                }
            }
            .frame(height: 8)
        }
        .padding(16).background(.w4Card).clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var activeRulesPreview: some View {
        let active = vm.progress.activeRules.filter(\.isActive)
        guard !active.isEmpty else { return AnyView(EmptyView()) }
        return AnyView(
            VStack(alignment: .leading, spacing: 10) {
                Text("✂️ 正在执行的规则").font(.headline).foregroundStyle(.w4Text)
                ForEach(active.prefix(3)) { rule in
                    HStack {
                        Text(rule.name).font(.subheadline).foregroundStyle(.w4Text)
                        Spacer()
                        Text("🔥 \(rule.streak)天").font(.caption).foregroundStyle(.w4Crimson)
                    }
                }
            }
            .padding(16).background(.w4Card).clipShape(RoundedRectangle(cornerRadius: 14))
        )
    }
}

// MARK: - Audit Tab

struct AuditTab: View {
    @ObservedObject var vm: DEALViewModel
    @State private var showAddEntry = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.w4Dark.ignoresSafeArea()
                List {
                    ForEach(vm.currentAudit.entries) { entry in
                        HStack {
                            Text(entry.category.icon).font(.title3)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(entry.activity).font(.subheadline).foregroundStyle(.w4Text)
                                Text("\(String(format: "%.1f", entry.hours))h · 精力消耗 \(entry.energyDrain)/5")
                                    .font(.caption).foregroundStyle(.w4Muted)
                            }
                            Spacer()
                            Image(systemName: entry.isHighValue ? "star.fill" : "star")
                                .foregroundStyle(entry.isHighValue ? .w4Gold : .w4Muted)
                        }
                    }
                    .onDelete { idx in
                        if let i = idx.first { vm.deleteAuditEntry(vm.currentAudit.entries[i].id) }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("时间审计")
            .toolbar {
                Button { showAddEntry = true } label: {
                    Image(systemName: "plus.circle.fill").foregroundStyle(.w4Gold)
                }
            }
            .sheet(isPresented: $showAddEntry) {
                AddAuditEntryView(vm: vm)
            }
        }
    }
}

struct AddAuditEntryView: View {
    @ObservedObject var vm: DEALViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var activity = ""
    @State private var hours: Double = 1
    @State private var category: TimeAuditEntry.ActivityCategory = .deepWork
    @State private var isHighValue = true
    @State private var energyDrain = 2.0

    var body: some View {
        NavigationStack {
            Form {
                TextField("你在做什么？", text: $activity)
                Picker("类别", selection: $category) {
                    ForEach(TimeAuditEntry.ActivityCategory.allCases, id: \.self) { c in
                        Text("\(c.icon) \(c.rawValue)").tag(c)
                    }
                }
                HStack { Text("耗时"); Slider(value: $hours, in: 0.25...12, step: 0.25); Text("\(String(format: "%.1f", hours))h").font(.caption) }
                Toggle("高价值活动（属于 20%）", isOn: $isHighValue)
                HStack { Text("精力消耗"); Slider(value: $energyDrain, in: 1...5, step: 1); Text("\(Int(energyDrain))/5").font(.caption) }
            }
            .navigationTitle("记录时间")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("取消") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("添加") {
                        vm.addAuditEntry(TimeAuditEntry(activity: activity, hours: hours, category: category, isHighValue: isHighValue, energyDrain: Int(energyDrain)))
                        dismiss()
                    }.disabled(activity.isEmpty)
                }
            }
        }
    }
}

// MARK: - Eliminate Tab

struct EliminateTab: View {
    @ObservedObject var vm: DEALViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                Color.w4Dark.ignoresSafeArea()
                List {
                    ForEach($vm.progress.activeRules) { $rule in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(rule.name).font(.headline).foregroundStyle(.w4Text)
                                Text(rule.description).font(.caption).foregroundStyle(.w4Muted)
                            }
                            Spacer()
                            VStack(spacing: 6) {
                                Toggle("", isOn: $rule.isActive).labelsHidden().tint(.w4Mint)
                                if rule.isActive {
                                    Button { vm.checkInRule(rule.id) } label: {
                                        Text("🔥 \(rule.streak)").font(.caption2).foregroundStyle(.w4Crimson)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("消除低价值事务")
        }
    }
}

// MARK: - Automate Tab

struct AutomateTab: View {
    @ObservedObject var vm: DEALViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                Color.w4Dark.ignoresSafeArea()
                List {
                    Section { Text("已建立 \(vm.progress.automations.filter(\.isBuilt).count) 个自动化 · 每周节省 \(Int(vm.totalHoursSaved)) 小时")
                            .font(.caption).foregroundStyle(.w4Mint) }
                    ForEach($vm.progress.automations) { $tpl in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(tpl.category.icon).font(.title2)
                                Text(tpl.name).font(.headline).foregroundStyle(.w4Text)
                                Spacer()
                                Toggle("", isOn: $tpl.isBuilt).labelsHidden().tint(.w4Mint)
                            }
                            if tpl.isBuilt {
                                Text(tpl.description).font(.caption).foregroundStyle(.w4Muted)
                                Text("节省 \(Int(tpl.estimatedHoursSaved))h/周 · 工具: \(tpl.tools.joined(separator: ", "))")
                                    .font(.caption2).foregroundStyle(.w4Gold)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("建立自动化系统")
        }
    }
}

// MARK: - Dream Tab

struct DreamTab: View {
    @ObservedObject var vm: DEALViewModel
    @State private var showAddDream = false
    @State private var showFearSetting = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.w4Dark.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 20) {
                        // Dreamline 总览
                        VStack(spacing: 12) {
                            Text("💰 梦想自由线").font(.headline).foregroundStyle(.w4Text)
                            Text("¥\(Int(vm.progress.dreamline.targetMonthlyIncome))/月")
                                .font(.system(size: 44, weight: .bold, design: .rounded))
                                .foregroundStyle(.w4Gold)
                            Text("每日需创收 ¥\(Int(vm.progress.dreamline.targetDailyIncome))")
                                .font(.caption).foregroundStyle(.w4Muted)
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity)
                        .background(.w4Card)
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                        // 梦想清单
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("🌟 梦想清单").font(.headline).foregroundStyle(.w4Text)
                                Spacer()
                                Button { showAddDream = true } label: {
                                    Image(systemName: "plus.circle.fill").foregroundStyle(.w4Gold)
                                }
                            }
                            if vm.progress.dreamline.dreams.isEmpty {
                                Text("写下你的梦想——拥有什么、成为谁、去哪里。然后算出价格。")
                                    .font(.caption).foregroundStyle(.w4Muted)
                                    .padding()
                            } else {
                                ForEach(vm.progress.dreamline.dreams) { dream in
                                    HStack {
                                        Text(dream.category.icon)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(dream.dream).font(.subheadline).foregroundStyle(.w4Text)
                                            Text("¥\(Int(dream.monthlyCost))/月").font(.caption).foregroundStyle(.w4Gold)
                                        }
                                        Spacer()
                                        Button { vm.toggleDreamTarget(dream.id) } label: {
                                            Image(systemName: dream.isTarget ? "checkmark.circle.fill" : "circle")
                                                .foregroundStyle(dream.isTarget ? .w4Mint : .w4Muted)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                        .padding(16).background(.w4Card).clipShape(RoundedRectangle(cornerRadius: 14))

                        // 恐惧设定
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("🧘 恐惧设定").font(.headline).foregroundStyle(.w4Text)
                                Spacer()
                                Button { showFearSetting = true } label: {
                                    Image(systemName: "plus.circle.fill").foregroundStyle(.w4Crimson)
                                }
                            }
                            if vm.progress.fearLog.isEmpty {
                                Text("\"恐惧设定\"是 Tim Ferriss 的核心练习——把你最害怕的事情写下来，你就会发现它们没那么可怕。")
                                    .font(.caption).foregroundStyle(.w4Muted).padding()
                            } else {
                                ForEach(vm.progress.fearLog) { fear in
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("😰 \(fear.fear)").font(.subheadline).foregroundStyle(.w4Text)
                                        Text("预防: \(fear.prevent)").font(.caption).foregroundStyle(.w4Mint)
                                        Text("修复: \(fear.repair)").font(.caption).foregroundStyle(.w4Sky)
                                        Text("严重程度: \(fear.severity)/10").font(.caption2).foregroundStyle(.w4Muted)
                                    }
                                    .padding(10).background(.w4Card).clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }
                        .padding(16).background(.w4Card).clipShape(RoundedRectangle(cornerRadius: 14))

                        Spacer().frame(height: 80)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle("梦想线 & 恐惧设定")
            .sheet(isPresented: $showAddDream) { AddDreamView(vm: vm) }
            .sheet(isPresented: $showFearSetting) { FearSettingView(vm: vm) }
        }
    }
}

// MARK: - Add Dream Sheet

struct AddDreamView: View {
    @ObservedObject var vm: DEALViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var dream = ""
    @State private var category: DreamItem.DreamCategory = .doing
    @State private var monthlyCost: Double = 5000

    var body: some View {
        NavigationStack {
            Form {
                TextField("你的梦想", text: $dream)
                Picker("类别", selection: $category) {
                    Text("🏠 拥有").tag(DreamItem.DreamCategory.having)
                    Text("🌟 成为").tag(DreamItem.DreamCategory.being)
                    Text("✈️ 去做").tag(DreamItem.DreamCategory.doing)
                }
                HStack { Text("月支出"); Slider(value: $monthlyCost, in: 100...50000, step: 100); Text("¥\(Int(monthlyCost))").font(.caption) }
            }
            .navigationTitle("添加梦想")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("取消") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("添加") {
                        vm.addDream(DreamItem(dream: dream, category: category, monthlyCost: monthlyCost, oneTimeCost: 0, isTarget: true))
                        dismiss()
                    }.disabled(dream.isEmpty)
                }
            }
        }
    }
}

// MARK: - Fear Setting Sheet

struct FearSettingView: View {
    @ObservedObject var vm: DEALViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var fear = ""
    @State private var prevent = ""
    @State private var repair = ""
    @State private var costOfInaction = ""
    @State private var severity: Double = 5

    var body: some View {
        NavigationStack {
            Form {
                Section("你害怕什么？") { TextField("定义你的恐惧", text: $fear) }
                Section("如何预防？") { TextField("预防措施", text: $prevent) }
                Section("如果发生如何修复？") { TextField("修复方案", text: $repair) }
                Section("不行动的代价") { TextField("6个月/1年/3年后的代价", text: $costOfInaction) }
                Section { HStack { Text("实际严重程度"); Slider(value: $severity, in: 1...10, step: 1); Text("\(Int(severity))/10") } }
            }
            .navigationTitle("恐惧设定")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("取消") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("记录") {
                        vm.addFear(FearItem(fear: fear, prevent: prevent, repair: repair, costOfInaction: costOfInaction, severity: Int(severity)))
                        dismiss()
                    }.disabled(fear.isEmpty)
                }
            }
        }
    }
}
