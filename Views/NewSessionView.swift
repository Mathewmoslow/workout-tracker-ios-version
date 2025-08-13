import SwiftUI
import SwiftData

struct NewSessionView: View {
    let client: Client?
    var preselectedDate: Date = Date()
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var workouts: [Workout]
    @Query private var allClients: [Client]
    
    @State private var selectedClient: Client?
    @State private var selectedWorkout: Workout?
    @State private var sessionDate = Date()
    @State private var startTime = Date()
    @State private var location: Session.TrainingLocation = .gym
    @State private var notes = ""
    @State private var showingWorkoutPicker = false
    @State private var showingActiveSession = false
    @State private var activeSession: Session?
    
    var clients: [Client] {
        allClients.filter { $0.isActive }
    }
    
    init(client: Client? = nil, preselectedDate: Date = Date()) {
        self.client = client
        self.preselectedDate = preselectedDate
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Session Details") {
                    // Client Picker
                    Picker("Client", selection: $selectedClient) {
                        Text("Select Client").tag(nil as Client?)
                        ForEach(clients) { client in
                            Text(client.fullName).tag(client as Client?)
                        }
                    }
                    
                    // Workout Selection
                    HStack {
                        Text("Workout")
                        Spacer()
                        if let workout = selectedWorkout {
                            Text(workout.name)
                                .foregroundColor(.secondary)
                        } else {
                            Text("Select Workout")
                                .foregroundColor(.brandSecondaryText)
                        }
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showingWorkoutPicker = true
                    }
                    
                    // Date & Time
                    DatePicker("Date", selection: $sessionDate, displayedComponents: .date)
                    DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
                    
                    // Location
                    Picker("Location", selection: $location) {
                        ForEach(Session.TrainingLocation.allCases, id: \.self) { location in
                            Text(location.rawValue).tag(location)
                        }
                    }
                }
                
                Section("Pre-Session Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
                
                // Quick Templates
                if let client = selectedClient {
                    Section("Quick Templates") {
                        QuickTemplatesList(
                            client: client,
                            onSelectWorkout: { workout in
                                selectedWorkout = workout
                            }
                        )
                    }
                }
                
                // Add to Calendar Button
                Section {
                    Button(action: addToCalendar) {
                        HStack {
                            Image(systemName: "calendar.badge.plus")
                            Text("Add to Calendar")
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                    .disabled(selectedClient == nil || selectedWorkout == nil)
                    .foregroundColor(selectedClient == nil || selectedWorkout == nil ? .brandSecondaryText : .white)
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(selectedClient == nil || selectedWorkout == nil ? Color.brandSecondaryText.opacity(0.3) : Color.brandSageGreen)
                    )
                }
            }
            .navigationTitle("New Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingWorkoutPicker) {
                WorkoutPickerView(selectedWorkout: $selectedWorkout)
            }
            .fullScreenCover(isPresented: $showingActiveSession) {
                if let session = activeSession {
                    ActiveSessionView(session: session)
                }
            }
            .onAppear {
                selectedClient = client
                sessionDate = preselectedDate
            }
        }
    }
    
    func addToCalendar() {
        guard let client = selectedClient,
              let workout = selectedWorkout else { return }
        
        // Combine date and time properly in local timezone
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: sessionDate)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: startTime)
        
        var scheduledDateTime = DateComponents()
        scheduledDateTime.year = dateComponents.year
        scheduledDateTime.month = dateComponents.month
        scheduledDateTime.day = dateComponents.day
        scheduledDateTime.hour = timeComponents.hour
        scheduledDateTime.minute = timeComponents.minute
        scheduledDateTime.timeZone = TimeZone.current
        
        let finalDate = calendar.date(from: scheduledDateTime) ?? sessionDate
        
        // Create scheduled session (not started yet)
        let session = Session(
            client: client,
            workout: workout,
            date: finalDate
        )
        
        session.startTime = nil // Not started yet
        session.location = location
        session.trainerNotes = notes
        session.status = .scheduled
        
        // Initialize planned exercises from workout template
        session.completedExercises = workout.exercises.map { workoutExercise in
            let completed = CompletedExercise(exercise: workoutExercise.exercise)
            completed.supersetId = workoutExercise.supersetId
            
            // Initialize sets from template
            completed.sets = workoutExercise.sets.map { templateSet in
                CompletedSet(
                    setNumber: templateSet.setNumber,
                    targetReps: templateSet.reps,
                    targetWeight: templateSet.weight,
                    weightUnit: templateSet.weightUnit
                )
            }
            
            return completed
        }
        
        // Insert session first
        modelContext.insert(session)
        
        // Save the context to persist relationships
        do {
            try modelContext.save()
            print("Session scheduled for \(finalDate.formatted())")
        } catch {
            print("Failed to save session: \(error)")
        }
        
        dismiss()
    }
}

struct QuickTemplatesList: View {
    let client: Client
    let onSelectWorkout: (Workout) -> Void
    
    var suggestedWorkouts: [Workout] {
        // Get recent workouts from client's sessions
        let recentWorkouts = client.sessions
            .sorted { $0.date > $1.date }
            .prefix(5)
            .map { $0.workout }
        
        return Array(Set(recentWorkouts))
    }
    
    var body: some View {
        if !suggestedWorkouts.isEmpty {
            ForEach(suggestedWorkouts) { workout in
                QuickTemplateRow(
                    workout: workout,
                    lastUsed: lastUsedDate(for: workout)
                )
                .onTapGesture {
                    onSelectWorkout(workout)
                }
            }
        } else {
            Text("No recent workouts")
                .foregroundColor(.secondary)
                .italic()
        }
    }
    
    func lastUsedDate(for workout: Workout) -> Date? {
        client.sessions
            .filter { $0.workout.id == workout.id }
            .sorted { $0.date > $1.date }
            .first?.date
    }
}

struct QuickTemplateRow: View {
    let workout: Workout
    let lastUsed: Date?
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack {
                    Label("\(workout.exercises.count) exercises", systemImage: "figure.strengthtraining.traditional")
                    
                    if let date = lastUsed {
                        Label(date.formatted(.relative(presentation: .named)), systemImage: "clock")
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct WorkoutPickerView: View {
    @Binding var selectedWorkout: Workout?
    @Environment(\.dismiss) private var dismiss
    @Query private var workouts: [Workout]
    @State private var searchText = ""
    @State private var selectedCategory: String = "All"
    
    var categories: [String] {
        ["All"] + Array(Set(workouts.compactMap { $0.category })).sorted()
    }
    
    var filteredWorkouts: [Workout] {
        let filtered = workouts.filter { workout in
            let matchesSearch = searchText.isEmpty || 
                workout.name.localizedCaseInsensitiveContains(searchText) ||
                workout.desc.localizedCaseInsensitiveContains(searchText)
            
            let matchesCategory = selectedCategory == "All" || 
                workout.category == selectedCategory
            
            return matchesSearch && matchesCategory
        }
        
        return filtered.sorted { $0.name < $1.name }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search workouts...", text: $searchText)
                }
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding()
                
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(categories, id: \.self) { category in
                            FilterChip(
                                title: category,
                                isSelected: selectedCategory == category,
                                action: { selectedCategory = category }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 8)
                
                // Workouts List
                List(filteredWorkouts) { workout in
                    WorkoutRow(workout: workout, isSelected: selectedWorkout?.id == workout.id)
                        .onTapGesture {
                            selectedWorkout = workout
                            dismiss()
                        }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Select Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct WorkoutRow: View {
    let workout: Workout
    let isSelected: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(workout.name)
                    .font(.headline)
                    .foregroundColor(isSelected ? .brandSageGreen : .primary)
                
                if !workout.desc.isEmpty {
                    Text(workout.desc)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack(spacing: 12) {
                    Label("\(workout.exercises.count) exercises", systemImage: "figure.strengthtraining.traditional")
                    
                    if let category = workout.category {
                        Label(category, systemImage: "tag")
                    }
                    
                    if let duration = workout.estimatedDuration {
                        Label("\(duration) min", systemImage: "clock")
                    }
                }
                .font(.caption2)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.brandSageGreen)
            }
        }
        .padding(.vertical, 4)
    }
}