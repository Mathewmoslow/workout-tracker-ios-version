import SwiftUI
import SwiftData

struct ActiveSessionView: View {
    let session: Session
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentExerciseIndex = 0
    @State private var currentSetIndex = 0
    @State private var isResting = false
    @State private var restTimeRemaining = 0
    @State private var timer: Timer?
    @State private var sessionTimer: Timer?
    @State private var elapsedTime: TimeInterval = 0
    @State private var showingExerciseList = false
    @State private var showingSessionSummary = false
    
    var currentExercise: CompletedExercise? {
        guard currentExerciseIndex < session.completedExercises.count else { return nil }
        return session.completedExercises[currentExerciseIndex]
    }
    
    var currentSet: CompletedSet? {
        guard let exercise = currentExercise,
              currentSetIndex < exercise.sets.count else { return nil }
        return exercise.sets[currentSetIndex]
    }
    
    var progressPercentage: Double {
        let totalSets = session.completedExercises.flatMap { $0.sets }.count
        let completedSets = session.completedExercises.prefix(currentExerciseIndex).flatMap { $0.sets }.count + currentSetIndex
        return totalSets > 0 ? Double(completedSets) / Double(totalSets) : 0
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress Bar
                SessionProgressBar(progress: progressPercentage)
                
                // Timer and Stats
                SessionHeaderView(
                    elapsedTime: elapsedTime,
                    totalVolume: calculateTotalVolume(),
                    completedSets: calculateCompletedSets()
                )
                
                Divider()
                
                if isResting {
                    RestTimerView(
                        restTimeRemaining: restTimeRemaining,
                        onSkip: skipRest
                    )
                } else if let exercise = currentExercise, let set = currentSet {
                    // Current Exercise View
                    ActiveExerciseView(
                        exercise: exercise,
                        set: set,
                        exerciseIndex: currentExerciseIndex,
                        totalExercises: session.completedExercises.count,
                        setIndex: currentSetIndex,
                        totalSets: exercise.sets.count,
                        onCompleteSet: completeCurrentSet,
                        onUpdateSet: updateCurrentSet
                    )
                }
                
                Spacer()
                
                // Navigation Controls
                SessionNavigationControls(
                    canGoPrevious: currentExerciseIndex > 0 || currentSetIndex > 0,
                    canGoNext: !isLastSet(),
                    onPrevious: previousSet,
                    onNext: isResting ? skipRest : completeCurrentSet,
                    onShowList: { showingExerciseList = true }
                )
            }
            .navigationTitle("Active Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Pause") {
                        pauseSession()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("End") {
                        showingSessionSummary = true
                    }
                    .foregroundColor(.red)
                }
            }
            .sheet(isPresented: $showingExerciseList) {
                ExerciseListView(
                    exercises: session.completedExercises,
                    currentIndex: currentExerciseIndex,
                    onSelectExercise: jumpToExercise
                )
            }
            .sheet(isPresented: $showingSessionSummary) {
                SessionSummaryView(
                    session: session,
                    elapsedTime: elapsedTime,
                    onSave: saveAndEndSession,
                    onContinue: { showingSessionSummary = false }
                )
            }
            .onAppear {
                startSessionTimer()
            }
            .onDisappear {
                sessionTimer?.invalidate()
                timer?.invalidate()
            }
        }
    }
    
    func startSessionTimer() {
        sessionTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsedTime += 1
        }
    }
    
    func updateCurrentSet(reps: Int, weight: Double, rpe: Int?) {
        guard let set = currentSet else { return }
        set.reps = reps
        set.weight = weight
        set.rpe = rpe
        set.timestamp = Date()
    }
    
    func completeCurrentSet() {
        guard let exercise = currentExercise,
              let set = currentSet else { return }
        
        // Mark set as completed
        set.timestamp = Date()
        
        // Check if there are more sets in current exercise
        if currentSetIndex < exercise.sets.count - 1 {
            // Move to next set, start rest timer
            currentSetIndex += 1
            startRestTimer(duration: set.targetRest)
        } else {
            // Move to next exercise
            exercise.wasCompleted = true
            moveToNextExercise()
        }
        
        // Update session totals
        updateSessionTotals()
    }
    
    func moveToNextExercise() {
        if currentExerciseIndex < session.completedExercises.count - 1 {
            currentExerciseIndex += 1
            currentSetIndex = 0
            
            // Check if next exercise is part of a superset
            if let currentSuperset = currentExercise?.supersetId,
               let nextExercise = session.completedExercises[safe: currentExerciseIndex],
               nextExercise.supersetId == currentSuperset {
                // Shorter rest between superset exercises
                startRestTimer(duration: 30)
            } else {
                // Normal rest between exercises
                startRestTimer(duration: 90)
            }
        } else {
            // Session complete
            showingSessionSummary = true
        }
    }
    
    func previousSet() {
        if currentSetIndex > 0 {
            currentSetIndex -= 1
        } else if currentExerciseIndex > 0 {
            currentExerciseIndex -= 1
            currentSetIndex = session.completedExercises[currentExerciseIndex].sets.count - 1
        }
    }
    
    func startRestTimer(duration: Int) {
        isResting = true
        restTimeRemaining = duration
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if restTimeRemaining > 0 {
                restTimeRemaining -= 1
            } else {
                timer?.invalidate()
                isResting = false
                // Play sound or haptic feedback
            }
        }
    }
    
    func skipRest() {
        timer?.invalidate()
        isResting = false
        restTimeRemaining = 0
    }
    
    func jumpToExercise(_ index: Int) {
        currentExerciseIndex = index
        currentSetIndex = 0
        showingExerciseList = false
    }
    
    func pauseSession() {
        sessionTimer?.invalidate()
        timer?.invalidate()
        // Show pause screen
    }
    
    func saveAndEndSession() {
        session.endTime = Date()
        session.duration = elapsedTime
        updateSessionTotals()
        
        // Ensure client relationship is maintained
        if let client = session.client {
            // Update client's FitScore
            if let fitScore = client.fitScore {
                fitScore.updateFromSessions(client.sessions)
            }
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to save session: \(error)")
        }
        
        dismiss()
    }
    
    func updateSessionTotals() {
        session.totalVolume = calculateTotalVolume()
        session.totalSets = calculateCompletedSets()
        session.totalReps = session.completedExercises
            .flatMap { $0.sets }
            .reduce(0) { $0 + $1.reps }
    }
    
    func calculateTotalVolume() -> Double {
        session.completedExercises
            .flatMap { $0.sets }
            .reduce(0) { $0 + ($1.weight * Double($1.reps)) }
    }
    
    func calculateCompletedSets() -> Int {
        session.completedExercises
            .prefix(currentExerciseIndex)
            .flatMap { $0.sets }
            .count + currentSetIndex
    }
    
    func isLastSet() -> Bool {
        currentExerciseIndex == session.completedExercises.count - 1 &&
        currentSetIndex == (currentExercise?.sets.count ?? 0) - 1
    }
}

struct SessionProgressBar: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * progress)
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
        }
        .frame(height: 4)
    }
}

struct SessionHeaderView: View {
    let elapsedTime: TimeInterval
    let totalVolume: Double
    let completedSets: Int
    
    var body: some View {
        HStack(spacing: 20) {
            // Timer
            VStack(spacing: 4) {
                Image(systemName: "clock")
                    .font(.caption)
                Text(formatTime(elapsedTime))
                    .font(.headline)
                    .fontWeight(.bold)
                    .monospacedDigit()
            }
            
            Divider()
                .frame(height: 30)
            
            // Volume
            VStack(spacing: 4) {
                Image(systemName: "scalemass")
                    .font(.caption)
                Text("\(Int(totalVolume)) kg")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Divider()
                .frame(height: 30)
            
            // Sets
            VStack(spacing: 4) {
                Image(systemName: "number.square")
                    .font(.caption)
                Text("\(completedSets) sets")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
        }
        .padding()
        .foregroundColor(.secondary)
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct ActiveExerciseView: View {
    let exercise: CompletedExercise
    let set: CompletedSet
    let exerciseIndex: Int
    let totalExercises: Int
    let setIndex: Int
    let totalSets: Int
    let onCompleteSet: () -> Void
    let onUpdateSet: (Int, Double, Int?) -> Void
    
    @State private var currentReps: Int
    @State private var currentWeight: Double
    @State private var currentRPE: Int = 5
    @State private var showingRPEPicker = false
    
    init(exercise: CompletedExercise, set: CompletedSet, exerciseIndex: Int, totalExercises: Int, setIndex: Int, totalSets: Int, onCompleteSet: @escaping () -> Void, onUpdateSet: @escaping (Int, Double, Int?) -> Void) {
        self.exercise = exercise
        self.set = set
        self.exerciseIndex = exerciseIndex
        self.totalExercises = totalExercises
        self.setIndex = setIndex
        self.totalSets = totalSets
        self.onCompleteSet = onCompleteSet
        self.onUpdateSet = onUpdateSet
        self._currentReps = State(initialValue: set.targetReps)
        self._currentWeight = State(initialValue: set.targetWeight)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Exercise Header
            VStack(spacing: 8) {
                Text("Exercise \(exerciseIndex + 1) of \(totalExercises)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(exercise.exercise.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                HStack {
                    Label(exercise.exercise.bodyPart, systemImage: "figure.strengthtraining.traditional")
                    Label(exercise.exercise.equipment, systemImage: "dumbbell")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                if exercise.supersetId != nil {
                    Text("SUPERSET")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.purple.opacity(0.2))
                        .foregroundColor(.purple)
                        .cornerRadius(4)
                }
            }
            .padding()
            
            // Set Information
            VStack(spacing: 12) {
                Text("Set \(setIndex + 1) of \(totalSets)")
                    .font(.headline)
                
                // Set Progress Indicators
                HStack(spacing: 8) {
                    ForEach(0..<totalSets, id: \.self) { index in
                        Circle()
                            .fill(index < setIndex ? Color.green : 
                                  index == setIndex ? Color.blue : 
                                  Color.gray.opacity(0.3))
                            .frame(width: 10, height: 10)
                    }
                }
            }
            
            // Input Controls
            VStack(spacing: 24) {
                // Reps Control
                VStack(spacing: 8) {
                    Text("REPS")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 20) {
                        Button(action: { if currentReps > 1 { currentReps -= 1 } }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.title)
                                .foregroundColor(.blue)
                        }
                        
                        Text("\(currentReps)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .frame(minWidth: 80)
                        
                        Button(action: { currentReps += 1 }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Text("Target: \(set.targetReps)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                // Weight Control
                VStack(spacing: 8) {
                    Text("WEIGHT (\(set.weightUnit.rawValue))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 20) {
                        Button(action: { if currentWeight > 0 { currentWeight -= 2.5 } }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.title)
                                .foregroundColor(.blue)
                        }
                        
                        Text(String(format: "%.1f", currentWeight))
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .frame(minWidth: 120)
                        
                        Button(action: { currentWeight += 2.5 }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Text("Target: \(Int(set.targetWeight))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                // RPE Selection
                Button(action: { showingRPEPicker = true }) {
                    HStack {
                        Text("RPE")
                        Spacer()
                        Text("\(currentRPE)")
                            .fontWeight(.bold)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Complete Set Button
            Button(action: {
                onUpdateSet(currentReps, currentWeight, currentRPE)
                onCompleteSet()
            }) {
                Text("Complete Set")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .sheet(isPresented: $showingRPEPicker) {
            RPEPickerView(selectedRPE: $currentRPE)
        }
    }
}

struct RestTimerView: View {
    let restTimeRemaining: Int
    let onSkip: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            Text("REST")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
            
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                    .frame(width: 200, height: 200)
                
                Circle()
                    .trim(from: 0, to: Double(restTimeRemaining) / 90.0)
                    .stroke(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: restTimeRemaining)
                
                Text("\(restTimeRemaining)")
                    .font(.system(size: 60, weight: .bold, design: .rounded))
            }
            
            Text("seconds remaining")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button(action: onSkip) {
                Text("Skip Rest")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
            }
            
            Spacer()
        }
        .padding()
    }
}

struct SessionNavigationControls: View {
    let canGoPrevious: Bool
    let canGoNext: Bool
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onShowList: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Button(action: onPrevious) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .frame(width: 60, height: 60)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(30)
            }
            .disabled(!canGoPrevious)
            .opacity(canGoPrevious ? 1 : 0.3)
            
            Button(action: onShowList) {
                Image(systemName: "list.bullet")
                    .font(.title2)
                    .frame(width: 60, height: 60)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(30)
            }
            
            Spacer()
            
            Button(action: onNext) {
                HStack {
                    Text("Next")
                        .fontWeight(.medium)
                    Image(systemName: "chevron.right")
                }
                .font(.title3)
                .foregroundColor(.white)
                .padding(.horizontal, 30)
                .frame(height: 60)
                .background(Color.blue)
                .cornerRadius(30)
            }
            .disabled(!canGoNext)
            .opacity(canGoNext ? 1 : 0.3)
        }
        .padding()
    }
}

struct ExerciseListView: View {
    let exercises: [CompletedExercise]
    let currentIndex: Int
    let onSelectExercise: (Int) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List(exercises.indices, id: \.self) { index in
                let exercise = exercises[index]
                HStack {
                    // Status Icon
                    Image(systemName: exercise.wasCompleted ? "checkmark.circle.fill" : 
                          index == currentIndex ? "play.circle.fill" : "circle")
                        .foregroundColor(exercise.wasCompleted ? .green : 
                                       index == currentIndex ? .blue : .gray)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(exercise.exercise.title)
                            .font(.headline)
                        
                        Text("\(exercise.sets.count) sets")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if exercise.supersetId != nil {
                        Text("SS")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.purple.opacity(0.2))
                            .foregroundColor(.purple)
                            .cornerRadius(4)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    onSelectExercise(index)
                }
            }
            .navigationTitle("Exercises")
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

struct RPEPickerView: View {
    @Binding var selectedRPE: Int
    @Environment(\.dismiss) private var dismiss
    
    let rpeDescriptions = [
        1: "Very Easy",
        2: "Easy",
        3: "Moderate",
        4: "Somewhat Hard",
        5: "Hard",
        6: "Harder",
        7: "Very Hard",
        8: "Extremely Hard",
        9: "Near Maximum",
        10: "Maximum Effort"
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Rate of Perceived Exertion")
                    .font(.headline)
                    .padding()
                
                ForEach(1...10, id: \.self) { value in
                    Button(action: {
                        selectedRPE = value
                        dismiss()
                    }) {
                        HStack {
                            Text("\(value)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .frame(width: 40)
                            
                            Text(rpeDescriptions[value] ?? "")
                                .font(.subheadline)
                            
                            Spacer()
                            
                            if selectedRPE == value {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.secondarySystemBackground))
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
            }
            .navigationTitle("Select RPE")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SessionSummaryView: View {
    let session: Session
    let elapsedTime: TimeInterval
    let onSave: () -> Void
    let onContinue: () -> Void
    
    @State private var sessionRPE: Int = 5
    @State private var notes = ""
    @State private var clientFeedback = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Summary Stats
                    VStack(spacing: 16) {
                        Text("Session Complete!")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        HStack(spacing: 20) {
                            SummaryStatBox(
                                title: "Duration",
                                value: formatTime(elapsedTime),
                                icon: "clock"
                            )
                            
                            SummaryStatBox(
                                title: "Volume",
                                value: "\(Int(session.totalVolume)) kg",
                                icon: "scalemass"
                            )
                            
                            SummaryStatBox(
                                title: "Sets",
                                value: "\(session.totalSets)",
                                icon: "number"
                            )
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                    .padding()
                    
                    // Session RPE
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Overall Session RPE")
                            .font(.headline)
                        
                        Picker("RPE", selection: $sessionRPE) {
                            ForEach(1...10, id: \.self) { value in
                                Text("\(value)").tag(value)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding()
                    
                    // Notes
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Trainer Notes")
                            .font(.headline)
                        
                        TextEditor(text: $notes)
                            .frame(minHeight: 100)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    .padding()
                    
                    // Client Feedback
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Client Feedback")
                            .font(.headline)
                        
                        TextEditor(text: $clientFeedback)
                            .frame(minHeight: 100)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    .padding()
                }
            }
            .navigationTitle("Session Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Continue") {
                        onContinue()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save & End") {
                        session.sessionRPE = sessionRPE
                        session.trainerNotes = notes
                        session.clientFeedback = clientFeedback
                        onSave()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct SummaryStatBox: View {
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
    }
}

// Helper extension
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}