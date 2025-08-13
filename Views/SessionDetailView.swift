import SwiftUI
import SwiftData
import Charts

struct SessionDetailView: View {
    let session: Session
    @Environment(\.dismiss) private var dismiss
    @State private var selectedExercise: CompletedExercise?
    @State private var showingEditMode = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Session Overview Card
                    SessionOverviewCard(session: session)
                    
                    // Performance Metrics
                    PerformanceMetricsView(session: session)
                    
                    // Exercise Breakdown
                    ExerciseBreakdownView(
                        exercises: session.completedExercises,
                        onSelectExercise: { selectedExercise = $0 }
                    )
                    
                    // Session Quality Ratings
                    if hasQualityMetrics {
                        SessionQualityView(session: session)
                    }
                    
                    // Notes Section
                    if !session.trainerNotes.isEmpty || !session.clientFeedback.isEmpty {
                        NotesSection(session: session)
                    }
                    
                    // Environmental Factors
                    EnvironmentalFactorsView(session: session)
                }
                .padding()
            }
            .navigationTitle("Session Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingEditMode = true }) {
                        Image(systemName: "pencil")
                    }
                }
            }
            .sheet(item: $selectedExercise) { exercise in
                ExerciseDetailView(completedExercise: exercise)
            }
        }
    }
    
    var hasQualityMetrics: Bool {
        session.sessionRPE != nil ||
        session.preWorkoutEnergy != nil ||
        session.postWorkoutEnergy != nil ||
        session.focusLevel != nil ||
        session.techniqueQuality != nil
    }
}

struct SessionOverviewCard: View {
    let session: Session
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.workout.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack {
                        Label(session.date.formatted(date: .abbreviated, time: .shortened), 
                              systemImage: "calendar")
                        
                        if let endTime = session.endTime, let startTime = session.startTime {
                            Label(formatDuration(endTime.timeIntervalSince(startTime)), 
                                  systemImage: "clock")
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Completion Badge
                VStack {
                    CircularProgressView(
                        progress: session.completionRate / 100,
                        color: completionColor(session.completionRate),
                        size: 60
                    ) {
                        VStack(spacing: 0) {
                            Text("\(Int(session.completionRate))%")
                                .font(.headline)
                                .fontWeight(.bold)
                            Text("Complete")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            Divider()
            
            // Key Metrics Grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                MetricBox(title: "Total Volume", value: "\(Int(session.totalVolume)) kg", icon: "scalemass")
                MetricBox(title: "Total Sets", value: "\(session.totalSets)", icon: "number.square")
                MetricBox(title: "Total Reps", value: "\(session.totalReps)", icon: "arrow.up.arrow.down")
                MetricBox(title: "Avg Rest", value: "\(Int(session.averageRestTime))s", icon: "timer")
                
                if let calories = session.caloriesBurned {
                    MetricBox(title: "Calories", value: "\(calories)", icon: "flame")
                }
                
                MetricBox(title: "Intensity", value: "\(Int(session.intensityScore))", icon: "gauge")
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    func completionColor(_ rate: Double) -> Color {
        switch rate {
        case 90...100:
            return .brandSageGreen
        case 70..<90:
            return .brandSageGreen
        case 50..<70:
            return Color(.systemIndigo)
        default:
            return .brandError
        }
    }
    
    func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        if minutes < 60 {
            return "\(minutes) min"
        }
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        return "\(hours)h \(remainingMinutes)m"
    }
}

struct MetricBox: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.brandSageGreen)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(10)
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(8)
    }
}

struct PerformanceMetricsView: View {
    let session: Session
    @State private var selectedMetric = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Performance Analysis")
                .font(.headline)
            
            Picker("Metric", selection: $selectedMetric) {
                Text("Volume").tag(0)
                Text("Intensity").tag(1)
                Text("Rest Times").tag(2)
            }
            .pickerStyle(.segmented)
            
            // Chart based on selected metric
            switch selectedMetric {
            case 0:
                VolumeChart(exercises: session.completedExercises)
            case 1:
                IntensityChart(exercises: session.completedExercises)
            case 2:
                RestTimeChart(exercises: session.completedExercises)
            default:
                EmptyView()
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct VolumeChart: View {
    let exercises: [CompletedExercise]
    
    var body: some View {
        Chart(exercises) { exercise in
            BarMark(
                x: .value("Exercise", String(exercise.exercise.title.prefix(10))),
                y: .value("Volume", exercise.totalVolume)
            )
            .foregroundStyle(Color.brandSageGreen.gradient)
        }
        .frame(height: 200)
    }
}

struct IntensityChart: View {
    let exercises: [CompletedExercise]
    
    var body: some View {
        Chart(exercises) { exercise in
            BarMark(
                x: .value("Exercise", String(exercise.exercise.title.prefix(10))),
                y: .value("RPE", exercise.averageRPE)
            )
            .foregroundStyle(Color.brandCoral.gradient)
        }
        .frame(height: 200)
    }
}

struct RestTimeChart: View {
    let exercises: [CompletedExercise]
    
    var chartData: [(String, Double)] {
        exercises.map { exercise in
            let avgRest = exercise.sets.compactMap { $0.actualRest }.reduce(0, +) / max(exercise.sets.count, 1)
            return (String(exercise.exercise.title.prefix(10)), Double(avgRest))
        }
    }
    
    var body: some View {
        Chart(chartData, id: \.0) { item in
            BarMark(
                x: .value("Exercise", item.0),
                y: .value("Rest (s)", item.1)
            )
            .foregroundStyle(Color.brandSageGreen.gradient)
        }
        .frame(height: 200)
    }
}

struct ExerciseBreakdownView: View {
    let exercises: [CompletedExercise]
    let onSelectExercise: (CompletedExercise) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Exercise Breakdown")
                .font(.headline)
            
            ForEach(exercises) { exercise in
                SessionExerciseRow(exercise: exercise)
                    .onTapGesture {
                        onSelectExercise(exercise)
                    }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct SessionExerciseRow: View {
    let exercise: CompletedExercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Exercise Name and Status
                HStack(spacing: 8) {
                    Image(systemName: exercise.wasCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(exercise.wasCompleted ? .brandSageGreen : .brandSecondaryText)
                    
                    Text(exercise.exercise.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    if exercise.supersetId != nil {
                        Text("SS")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.brandDarkGreen.opacity(0.2))
                            .foregroundColor(.brandDarkGreen)
                            .cornerRadius(4)
                    }
                }
                
                Spacer()
                
                // Volume
                Text("\(Int(exercise.totalVolume)) kg")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Sets Summary
            HStack(spacing: 8) {
                ForEach(exercise.sets) { set in
                    SetBadge(set: set)
                }
            }
            
            // Notes if present
            if !exercise.notes.isEmpty {
                Text(exercise.notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(8)
    }
}

struct SetBadge: View {
    let set: CompletedSet
    
    var performanceColor: Color {
        switch set.performanceRatio {
        case 0.95...:
            return .brandSageGreen
        case 0.8..<0.95:
            return .brandSageGreen
        case 0.6..<0.8:
            return Color(.systemIndigo)
        default:
            return .brandError
        }
    }
    
    var body: some View {
        VStack(spacing: 2) {
            Text("\(set.reps)")
                .font(.caption2)
                .fontWeight(.bold)
            
            Text("\(Int(set.weight))\(set.weightUnit.rawValue)")
                .font(.caption2)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(performanceColor.opacity(0.2))
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(performanceColor, lineWidth: 1)
        )
        .cornerRadius(4)
    }
}

struct SessionQualityView: View {
    let session: Session
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Session Quality")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                if let rpe = session.sessionRPE {
                    QualityMetric(title: "Overall RPE", value: rpe, maxValue: 10, color: .brandError)
                }
                
                if let preEnergy = session.preWorkoutEnergy {
                    QualityMetric(title: "Pre-Energy", value: preEnergy, maxValue: 10, color: .brandSageGreen)
                }
                
                if let postEnergy = session.postWorkoutEnergy {
                    QualityMetric(title: "Post-Energy", value: postEnergy, maxValue: 10, color: .brandSageGreen)
                }
                
                if let focus = session.focusLevel {
                    QualityMetric(title: "Focus", value: focus, maxValue: 10, color: .brandDarkGreen)
                }
                
                if let technique = session.techniqueQuality {
                    QualityMetric(title: "Technique", value: technique, maxValue: 10, color: Color.brandCoral)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct QualityMetric: View {
    let title: String
    let value: Int
    let maxValue: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 8)
                    .frame(width: 50, height: 50)
                
                Circle()
                    .trim(from: 0, to: Double(value) / Double(maxValue))
                    .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))
                
                Text("\(value)")
                    .font(.headline)
                    .fontWeight(.bold)
            }
        }
    }
}

struct NotesSection: View {
    let session: Session
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notes")
                .font(.headline)
            
            if !session.trainerNotes.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Label("Trainer Notes", systemImage: "person.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(session.trainerNotes)
                        .font(.subheadline)
                        .padding(10)
                        .background(Color(.tertiarySystemBackground))
                        .cornerRadius(8)
                }
            }
            
            if !session.clientFeedback.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Label("Client Feedback", systemImage: "bubble.left.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(session.clientFeedback)
                        .font(.subheadline)
                        .padding(10)
                        .background(Color(.tertiarySystemBackground))
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct EnvironmentalFactorsView: View {
    let session: Session
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Environmental Factors")
                .font(.headline)
            
            HStack(spacing: 16) {
                EnvironmentalFactor(
                    icon: "location.fill",
                    label: "Location",
                    value: session.location.rawValue
                )
                
                if let weather = session.weather {
                    EnvironmentalFactor(
                        icon: "cloud.fill",
                        label: "Weather",
                        value: weather.rawValue
                    )
                }
                
                if let temp = session.temperature {
                    EnvironmentalFactor(
                        icon: "thermometer",
                        label: "Temp",
                        value: "\(Int(temp))°C"
                    )
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct EnvironmentalFactor: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.brandSageGreen)
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ExerciseDetailView: View {
    let completedExercise: CompletedExercise
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Exercise Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text(completedExercise.exercise.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        HStack {
                            Label(completedExercise.exercise.bodyPart, systemImage: "figure.strengthtraining.traditional")
                            Label(completedExercise.exercise.equipment, systemImage: "dumbbell")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .padding()
                    
                    // Sets Detail
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Set Performance")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(completedExercise.sets) { set in
                            SetDetailRow(set: set)
                        }
                    }
                    
                    // Summary Stats
                    VStack(spacing: 12) {
                        HStack {
                            ExerciseStatCard(title: "Total Volume", value: "\(Int(completedExercise.totalVolume)) kg")
                            ExerciseStatCard(title: "Avg RPE", value: String(format: "%.1f", completedExercise.averageRPE))
                        }
                    }
                    .padding()
                    
                    // Notes
                    if !completedExercise.notes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.headline)
                            
                            Text(completedExercise.notes)
                                .font(.body)
                                .padding()
                                .background(Color(.tertiarySystemBackground))
                                .cornerRadius(8)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Exercise Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SetDetailRow: View {
    let set: CompletedSet
    
    var body: some View {
        HStack {
            // Set Number
            Text("Set \(set.setNumber)")
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(width: 60, alignment: .leading)
            
            // Performance
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 12) {
                    // Reps
                    HStack(spacing: 4) {
                        Text("\(set.reps)")
                            .fontWeight(.bold)
                        Text("reps")
                            .foregroundColor(.secondary)
                    }
                    
                    // Weight
                    HStack(spacing: 4) {
                        Text("\(Int(set.weight))")
                            .fontWeight(.bold)
                        Text(set.weightUnit.rawValue)
                            .foregroundColor(.secondary)
                    }
                    
                    // RPE if available
                    if let rpe = set.rpe {
                        HStack(spacing: 4) {
                            Text("RPE")
                                .foregroundColor(.secondary)
                            Text("\(rpe)")
                                .fontWeight(.bold)
                                .foregroundColor(rpeColor(rpe))
                        }
                    }
                }
                .font(.caption)
                
                // Target vs Actual
                HStack(spacing: 8) {
                    Text("Target: \(set.targetReps)×\(Int(set.targetWeight))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    // Performance indicator
                    PerformanceIndicator(ratio: set.performanceRatio)
                }
            }
            
            Spacer()
            
            // Rest time
            if let rest = set.actualRest {
                VStack(alignment: .trailing) {
                    Text("\(rest)s")
                        .font(.caption)
                        .fontWeight(.medium)
                    Text("rest")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(8)
        .padding(.horizontal)
    }
    
    func rpeColor(_ rpe: Int) -> Color {
        switch rpe {
        case 1...4:
            return .brandSageGreen
        case 5...7:
            return Color(.systemIndigo)
        default:
            return .brandError
        }
    }
}

struct PerformanceIndicator: View {
    let ratio: Double
    
    var color: Color {
        switch ratio {
        case 0.95...:
            return .brandSageGreen
        case 0.8..<0.95:
            return .brandSageGreen
        case 0.6..<0.8:
            return Color(.systemIndigo)
        default:
            return .brandError
        }
    }
    
    var icon: String {
        switch ratio {
        case 1.05...:
            return "arrow.up.circle.fill"
        case 0.95..<1.05:
            return "checkmark.circle.fill"
        default:
            return "arrow.down.circle.fill"
        }
    }
    
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: icon)
                .font(.caption)
            Text("\(Int(ratio * 100))%")
                .font(.caption2)
        }
        .foregroundColor(color)
    }
}

struct ExerciseStatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
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
        .cornerRadius(8)
    }
}