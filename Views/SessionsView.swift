import SwiftUI
import SwiftData

struct SessionsView: View {
    let client: Client? = nil  // Make it optional for general use
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Session.date, order: .reverse) private var allSessions: [Session]
    @State private var selectedSession: Session?
    @State private var showingNewSession = false
    @State private var searchText = ""
    @State private var filterByWorkout: Workout?
    
    var sessions: [Session] {
        if let client = client {
            return client.sessions
        } else {
            return allSessions
        }
    }
    
    var filteredSessions: [Session] {
        let sessions = self.sessions.sorted { $0.date > $1.date }
        
        if searchText.isEmpty && filterByWorkout == nil {
            return sessions
        }
        
        return sessions.filter { session in
            let matchesSearch = searchText.isEmpty || 
                session.workout.name.localizedCaseInsensitiveContains(searchText) ||
                session.trainerNotes.localizedCaseInsensitiveContains(searchText)
            
            let matchesWorkout = filterByWorkout == nil || 
                session.workout.id == filterByWorkout?.id
            
            return matchesSearch && matchesWorkout
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Stats Header
                SessionStatsHeader(sessions: sessions)
                
                // Search and Filter Bar
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search sessions...", text: $searchText)
                    }
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    
                    Menu {
                        Button("All Workouts") {
                            filterByWorkout = nil
                        }
                        Divider()
                        ForEach(uniqueWorkouts, id: \.id) { workout in
                            Button(workout.name) {
                                filterByWorkout = workout
                            }
                        }
                    } label: {
                        Label(filterByWorkout?.name ?? "Filter", systemImage: "line.3.horizontal.decrease.circle")
                            .font(.caption)
                    }
                }
                .padding()
                
                // Sessions List
                if filteredSessions.isEmpty {
                    EmptySessionsView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredSessions) { session in
                                SessionCard(session: session)
                                    .onTapGesture {
                                        selectedSession = session
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Training Sessions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingNewSession = true }) {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingNewSession) {
                NewSessionView(client: nil)
            }
            .sheet(item: $selectedSession) { session in
                SessionDetailView(session: session)
            }
        }
    }
    
    var uniqueWorkouts: [Workout] {
        let workoutIds = Set(sessions.map { $0.workout.id })
        return sessions
            .map { $0.workout }
            .filter { workoutIds.contains($0.id) }
            .uniqued()
    }
}

struct SessionStatsHeader: View {
    let sessions: [Session]
    
    var thisWeekSessions: Int {
        let weekAgo = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date())!
        return sessions.filter { $0.date > weekAgo }.count
    }
    
    var totalVolume: Double {
        sessions.reduce(0) { $0 + $1.totalVolume }
    }
    
    var averageIntensity: Double {
        guard !sessions.isEmpty else { return 0 }
        return sessions.reduce(0) { $0 + $1.intensityScore } / Double(sessions.count)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            StatsBox(
                value: "\(sessions.count)",
                label: "Total",
                icon: "number.circle",
                color: .blue
            )
            
            StatsBox(
                value: "\(thisWeekSessions)",
                label: "This Week",
                icon: "calendar",
                color: .green
            )
            
            StatsBox(
                value: formatVolume(totalVolume),
                label: "Volume",
                icon: "scalemass",
                color: Color(.systemTeal)
            )
            
            StatsBox(
                value: "\(Int(averageIntensity))",
                label: "Avg Intensity",
                icon: "flame",
                color: .red
            )
        }
        .padding()
        .background(Color(.secondarySystemBackground))
    }
    
    func formatVolume(_ volume: Double) -> String {
        if volume >= 1000 {
            return String(format: "%.1fk", volume / 1000)
        }
        return "\(Int(volume))"
    }
}

struct StatsBox: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct SessionCard: View {
    let session: Session
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.workout.name)
                        .font(.headline)
                    
                    Text(session.date, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Completion Rate Badge
                CircularProgressView(
                    progress: session.completionRate / 100,
                    color: completionColor(session.completionRate),
                    size: 40
                ) {
                    Text("\(Int(session.completionRate))%")
                        .font(.caption2)
                        .fontWeight(.bold)
                }
            }
            
            // Stats Row
            HStack(spacing: 20) {
                SessionStat(icon: "clock", value: formatDuration(session.duration))
                SessionStat(icon: "number", value: "\(session.totalSets) sets")
                SessionStat(icon: "arrow.up.arrow.down", value: "\(session.totalReps) reps")
                SessionStat(icon: "scalemass", value: "\(Int(session.totalVolume)) kg")
                
                if let rpe = session.sessionRPE {
                    SessionStat(icon: "gauge", value: "RPE \(rpe)")
                }
            }
            .font(.caption)
            
            // Exercise Summary
            if !session.completedExercises.isEmpty {
                HStack {
                    ForEach(session.completedExercises.prefix(3)) { exercise in
                        Text(exercise.exercise.title)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(.systemGray6))
                            .cornerRadius(4)
                    }
                    
                    if session.completedExercises.count > 3 {
                        Text("+\(session.completedExercises.count - 3)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Notes Preview
            if !session.trainerNotes.isEmpty {
                HStack {
                    Image(systemName: "note.text")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(session.trainerNotes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(12)
    }
    
    func completionColor(_ rate: Double) -> Color {
        switch rate {
        case 90...100:
            return .green
        case 70..<90:
            return .blue
        case 50..<70:
            return Color(.systemIndigo)
        default:
            return .red
        }
    }
    
    func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        if minutes < 60 {
            return "\(minutes)m"
        }
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        return "\(hours)h \(remainingMinutes)m"
    }
}

struct SessionStat: View {
    let icon: String
    let value: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(.secondary)
            Text(value)
        }
    }
}

struct EmptySessionsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Sessions Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start tracking workouts to see session history")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct CircularProgressView<Content: View>: View {
    let progress: Double
    let color: Color
    let size: CGFloat
    let content: () -> Content
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: 3)
                .frame(width: size, height: size)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.3), value: progress)
            
            content()
        }
    }
}

// Helper extension for array uniquing
extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}