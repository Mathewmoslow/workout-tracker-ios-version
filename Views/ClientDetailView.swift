import SwiftUI
import SwiftData
import Charts

struct ClientDetailView: View {
    let client: Client
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 0
    @State private var showingAddSession = false
    @State private var showingAddMeasurement = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Client Header Card
                ClientHeaderCard(client: client)
                
                // FitScore Dashboard
                if let fitScore = client.fitScore {
                    FitScoreDashboard(fitScore: fitScore)
                }
                
                // Tab Selection
                Picker("View", selection: $selectedTab) {
                    Text("Overview").tag(0)
                    Text("Progress").tag(1)
                    Text("Sessions").tag(2)
                    Text("Metrics").tag(3)
                    Text("Nutrition").tag(4)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Tab Content
                switch selectedTab {
                case 0:
                    OverviewTab(client: client)
                case 1:
                    ProgressTab(client: client)
                case 2:
                    SessionsTab(client: client)
                case 3:
                    MetricsTab(client: client)
                case 4:
                    NutritionTab(client: client)
                default:
                    EmptyView()
                }
            }
        }
        .navigationTitle(client.fullName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { showingAddSession = true }) {
                        Label("New Session", systemImage: "plus.circle")
                    }
                    Button(action: { showingAddMeasurement = true }) {
                        Label("Add Measurement", systemImage: "ruler")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }
}

struct ClientHeaderCard: View {
    let client: Client
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                // Profile Image Placeholder
                Circle()
                    .fill(LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Text(client.firstName.prefix(1) + client.lastName.prefix(1))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(client.fullName)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack {
                        Label("\(client.age) years", systemImage: "person")
                        Label(client.primaryGoal.rawValue, systemImage: "target")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    
                    HStack {
                        StatusBadge(
                            text: client.isActive ? "Active" : "Inactive",
                            color: client.isActive ? .green : .gray
                        )
                        StatusBadge(
                            text: client.subscriptionType.rawValue,
                            color: .blue
                        )
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
}

struct FitScoreDashboard: View {
    let fitScore: FitScore
    
    var body: some View {
        VStack(spacing: 16) {
            // Main FitScore Display
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                
                Circle()
                    .trim(from: 0, to: fitScore.overallScore / 1000)
                    .stroke(
                        LinearGradient(
                            colors: gradientColors(for: fitScore.overallScore),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1), value: fitScore.overallScore)
                
                VStack(spacing: 4) {
                    Text("\(Int(fitScore.overallScore))")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                    
                    Text(fitScore.scoreCategory.rawValue)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(fitScore.scoreCategory.color))
                    
                    HStack(spacing: 4) {
                        TrendIndicator(trend: fitScore.weeklyTrend)
                        Text("Weekly")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(width: 200, height: 200)
            
            // Component Scores Grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ScoreComponent(title: "Strength", score: fitScore.strengthScore, icon: "figure.strengthtraining.traditional")
                ScoreComponent(title: "Endurance", score: fitScore.enduranceScore, icon: "figure.run")
                ScoreComponent(title: "Mobility", score: fitScore.mobilityScore, icon: "figure.flexibility")
                ScoreComponent(title: "Body Comp", score: fitScore.bodyCompositionScore, icon: "figure")
                ScoreComponent(title: "Consistency", score: fitScore.consistencyScore, icon: "calendar.badge.checkmark")
                ScoreComponent(title: "Nutrition", score: fitScore.nutritionScore, icon: "fork.knife")
            }
            .padding(.horizontal)
            
            // Muscle Balance Visual
            MuscleBalanceView(
                upperBody: fitScore.upperBodyScore,
                lowerBody: fitScore.lowerBodyScore,
                core: fitScore.coreScore
            )
        }
        .padding(.vertical)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    func gradientColors(for score: Double) -> [Color] {
        switch score {
        case 900...1000:
            return [.purple, .pink]
        case 800..<900:
            return [.green, .blue]
        case 700..<800:
            return [.blue, .cyan]
        case 600..<700:
            return [.yellow, Color(.systemOrange)]
        default:
            return [Color(.systemOrange), .red]
        }
    }
}

struct ScoreComponent: View {
    let title: String
    let score: Double
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 4) {
                    Text("\(Int(score))")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    // Mini progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 4)
                            
                            Rectangle()
                                .fill(scoreColor(score))
                                .frame(width: geometry.size.width * (score / 100), height: 4)
                        }
                    }
                    .frame(height: 4)
                }
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(8)
    }
    
    func scoreColor(_ score: Double) -> Color {
        switch score {
        case 80...100:
            return .green
        case 60..<80:
            return .blue
        case 40..<60:
            return .yellow
        default:
            return Color(.systemIndigo)
        }
    }
}

struct MuscleBalanceView: View {
    let upperBody: Double
    let lowerBody: Double
    let core: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Muscle Balance")
                .font(.headline)
                .padding(.horizontal)
            
            HStack(spacing: 20) {
                MuscleGroupIndicator(
                    label: "Upper",
                    value: upperBody,
                    icon: "figure.arms.open"
                )
                
                MuscleGroupIndicator(
                    label: "Core",
                    value: core,
                    icon: "figure.core.training"
                )
                
                MuscleGroupIndicator(
                    label: "Lower",
                    value: lowerBody,
                    icon: "figure.strengthtraining.functional"
                )
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct MuscleGroupIndicator: View {
    let label: String
    let value: Double
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: value / 100)
                    .stroke(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.blue)
            }
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("\(Int(value))%")
                .font(.caption2)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
    }
}

struct StatusBadge: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(4)
    }
}

struct TrendIndicator: View {
    let trend: FitScore.Trend
    
    var body: some View {
        Text(trend.rawValue)
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(trendColor)
    }
    
    var trendColor: Color {
        switch trend {
        case .improving:
            return .brandSageGreen
        case .maintaining:
            return .brandLightGreen
        case .declining:
            return .brandError
        }
    }
}

// Tab Views
struct OverviewTab: View {
    let client: Client
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Quick Stats
            HStack(spacing: 16) {
                StatCard(
                    title: "Sessions",
                    value: "\(client.sessions.count)",
                    icon: "calendar"
                )
                
                StatCard(
                    title: "Weight",
                    value: "\(Int(client.currentWeight)) kg",
                    icon: "scalemass"
                )
                
                StatCard(
                    title: "BMI",
                    value: String(format: "%.1f", client.bmi),
                    icon: "figure"
                )
            }
            .padding(.horizontal)
            
            // Recent Sessions
            if !client.sessions.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent Sessions")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(client.sessions.prefix(3)) { session in
                        SessionRowView(session: session)
                    }
                }
            }
        }
        .padding(.vertical)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct SessionRowView: View {
    let session: Session
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(session.workout.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack {
                    Label("\(session.totalSets) sets", systemImage: "number")
                    Label("\(Int(session.totalVolume)) kg", systemImage: "scalemass")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(session.date, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}

// Placeholder for other tabs
struct ProgressTab: View {
    let client: Client
    var body: some View {
        Text("Progress charts and graphs")
            .padding()
    }
}

struct SessionsTab: View {
    let client: Client
    var body: some View {
        Text("Session history")
            .padding()
    }
}

struct MetricsTab: View {
    let client: Client
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddMeasurement = false
    @State private var selectedMetricType = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Current Stats
                CurrentMeasurementsCard(client: client)
                
                // Body Composition
                BodyCompositionCard(client: client)
                
                // Measurement History
                MeasurementHistoryView(client: client)
                
                // Add Measurement Button
                Button(action: { showingAddMeasurement = true }) {
                    Label("Add Measurement", systemImage: "plus.circle.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .sheet(isPresented: $showingAddMeasurement) {
            AddMeasurementView(client: client)
        }
    }
}

struct CurrentMeasurementsCard: View {
    let client: Client
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Current Measurements")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                MeasurementItem(title: "Weight", value: "\(Int(client.currentWeight)) kg", trend: client.weightTrend)
                MeasurementItem(title: "Body Fat", value: String(format: "%.1f%%", client.bodyFatPercentage ?? 0), trend: .maintaining)
                MeasurementItem(title: "BMI", value: String(format: "%.1f", client.bmi), trend: .maintaining)
                MeasurementItem(title: "Muscle Mass", value: String(format: "%.1f kg", client.muscleMass ?? 0), trend: .improving)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct MeasurementItem: View {
    let title: String
    let value: String
    let trend: Client.Trend
    
    var trendColor: Color {
        switch trend {
        case .improving:
            return .brandSageGreen
        case .maintaining:
            return .brandLightGreen
        case .declining:
            return .brandError
        }
    }
    
    var trendIcon: String {
        switch trend {
        case .improving:
            return "arrow.up.circle.fill"
        case .maintaining:
            return "equal.circle.fill"
        case .declining:
            return "arrow.down.circle.fill"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Image(systemName: trendIcon)
                    .font(.caption)
                    .foregroundColor(trendColor)
            }
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
        }
        .padding(12)
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(8)
    }
}

struct BodyCompositionCard: View {
    let client: Client
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Body Composition")
                .font(.headline)
            
            // Visual representation
            HStack(spacing: 20) {
                CompositionBar(
                    label: "Muscle",
                    percentage: client.muscleMassPercentage ?? 40,
                    color: .blue
                )
                
                CompositionBar(
                    label: "Fat",
                    percentage: client.bodyFatPercentage ?? 20,
                    color: Color(.systemIndigo)
                )
                
                CompositionBar(
                    label: "Water",
                    percentage: client.waterPercentage ?? 55,
                    color: Color(.systemTeal)
                )
                
                CompositionBar(
                    label: "Bone",
                    percentage: client.boneMassPercentage ?? 5,
                    color: .gray
                )
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct CompositionBar: View {
    let label: String
    let percentage: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .bottom) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 60, height: 120)
                    .cornerRadius(8)
                
                Rectangle()
                    .fill(color)
                    .frame(width: 60, height: 120 * (percentage / 100))
                    .cornerRadius(8)
            }
            
            Text("\(Int(percentage))%")
                .font(.caption)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

struct MeasurementHistoryView: View {
    let client: Client
    @State private var selectedPeriod = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Progress")
                    .font(.headline)
                
                Spacer()
                
                Picker("Period", selection: $selectedPeriod) {
                    Text("1M").tag(0)
                    Text("3M").tag(1)
                    Text("6M").tag(2)
                    Text("1Y").tag(3)
                }
                .pickerStyle(.segmented)
                .frame(width: 160)
            }
            
            // Placeholder for chart
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.tertiarySystemBackground))
                .frame(height: 200)
                .overlay(
                    Text("Weight & Body Fat Chart")
                        .foregroundColor(.secondary)
                )
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct AddMeasurementView: View {
    let client: Client
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var weight: String = ""
    @State private var bodyFat: String = ""
    @State private var muscleMass: String = ""
    @State private var waterPercentage: String = ""
    @State private var visceralFat: String = ""
    @State private var boneMass: String = ""
    @State private var metabolicAge: String = ""
    @State private var bmr: String = ""
    
    // Circumference measurements
    @State private var chest: String = ""
    @State private var waist: String = ""
    @State private var hips: String = ""
    @State private var thighs: String = ""
    @State private var arms: String = ""
    @State private var calves: String = ""
    
    @State private var measurementDate = Date()
    @State private var notes: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Measurements") {
                    HStack {
                        Label("Weight", systemImage: "scalemass")
                        Spacer()
                        TextField("kg", text: $weight)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Label("Body Fat %", systemImage: "percent")
                        Spacer()
                        TextField("%", text: $bodyFat)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Label("Muscle Mass", systemImage: "figure.strengthtraining.traditional")
                        Spacer()
                        TextField("kg", text: $muscleMass)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                }
                
                Section("Body Composition") {
                    HStack {
                        Label("Water %", systemImage: "drop")
                        Spacer()
                        TextField("%", text: $waterPercentage)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Label("Visceral Fat", systemImage: "chart.pie")
                        Spacer()
                        TextField("level", text: $visceralFat)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Label("Bone Mass", systemImage: "figure")
                        Spacer()
                        TextField("kg", text: $boneMass)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Label("Metabolic Age", systemImage: "flame")
                        Spacer()
                        TextField("years", text: $metabolicAge)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Label("BMR", systemImage: "bolt")
                        Spacer()
                        TextField("kcal", text: $bmr)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                }
                
                Section("Circumference Measurements") {
                    HStack {
                        Label("Chest", systemImage: "ruler")
                        Spacer()
                        TextField("cm", text: $chest)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Label("Waist", systemImage: "ruler")
                        Spacer()
                        TextField("cm", text: $waist)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Label("Hips", systemImage: "ruler")
                        Spacer()
                        TextField("cm", text: $hips)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Label("Thighs", systemImage: "ruler")
                        Spacer()
                        TextField("cm", text: $thighs)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Label("Arms", systemImage: "ruler")
                        Spacer()
                        TextField("cm", text: $arms)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Label("Calves", systemImage: "ruler")
                        Spacer()
                        TextField("cm", text: $calves)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                }
                
                Section("Additional Info") {
                    DatePicker("Measurement Date", selection: $measurementDate, displayedComponents: .date)
                    
                    VStack(alignment: .leading) {
                        Text("Notes")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextEditor(text: $notes)
                            .frame(minHeight: 80)
                    }
                }
            }
            .navigationTitle("Add Measurements")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveMeasurements()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    func saveMeasurements() {
        // Update client measurements
        if let weightValue = Double(weight) {
            client.currentWeight = weightValue
        }
        
        if let bodyFatValue = Double(bodyFat) {
            client.bodyFatPercentage = bodyFatValue
        }
        
        if let muscleMassValue = Double(muscleMass) {
            client.muscleMass = muscleMassValue
        }
        
        if let waterValue = Double(waterPercentage) {
            client.waterPercentage = waterValue
        }
        
        if let visceralFatValue = Int(visceralFat) {
            client.visceralFatLevel = visceralFatValue
        }
        
        if let boneMassValue = Double(boneMass) {
            client.boneMass = boneMassValue
        }
        
        if let metabolicAgeValue = Int(metabolicAge) {
            client.metabolicAge = metabolicAgeValue
        }
        
        if let bmrValue = Int(bmr) {
            client.bmr = bmrValue
        }
        
        // Update circumference measurements
        if let chestValue = Double(chest) {
            client.chestCircumference = chestValue
        }
        
        if let waistValue = Double(waist) {
            client.waistCircumference = waistValue
        }
        
        if let hipsValue = Double(hips) {
            client.hipsCircumference = hipsValue
        }
        
        if let thighsValue = Double(thighs) {
            client.thighsCircumference = thighsValue
        }
        
        if let armsValue = Double(arms) {
            client.armsCircumference = armsValue
        }
        
        if let calvesValue = Double(calves) {
            client.calvesCircumference = calvesValue
        }
        
        // Update FitScore based on new measurements
        if let fitScore = client.fitScore {
            fitScore.updateFromMeasurements(client: client)
        }
        
        try? modelContext.save()
        dismiss()
    }
}

struct NutritionTab: View {
    let client: Client
    var body: some View {
        Text("Nutrition and lifestyle tracking")
            .padding()
    }
}