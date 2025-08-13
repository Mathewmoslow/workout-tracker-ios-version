import SwiftUI
import SwiftData

struct CreateWorkoutView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allExercises: [Exercise]
    
    @State private var workoutName = ""
    @State private var workoutDescription = ""
    @State private var selectedTags: Set<String> = []
    @State private var workoutExercises: [WorkoutExercise] = []
    @State private var showingExerciseSelector = false
    @State private var selectedForSuperset: Set<UUID> = []
    @State private var exerciseToEdit: WorkoutExercise?
    
    let availableTags = ["Strength", "Hypertrophy", "Power", "Endurance", "Circuit", "Superset", "Full Body", "Upper", "Lower", "Push", "Pull"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Workout Details") {
                    TextField("Workout Name", text: $workoutName)
                    TextField("Description (Optional)", text: $workoutDescription, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Tags") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(availableTags, id: \.self) { tag in
                                TagButton(tag: tag, isSelected: selectedTags.contains(tag)) {
                                    if selectedTags.contains(tag) {
                                        selectedTags.remove(tag)
                                    } else {
                                        selectedTags.insert(tag)
                                    }
                                }
                            }
                        }
                    }
                }
                
                Section("Exercises") {
                    if workoutExercises.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "figure.strengthtraining.traditional")
                                .font(.largeTitle)
                                .foregroundColor(.brandSecondaryText)
                            Text("No exercises added")
                                .foregroundColor(.secondary)
                            Button("Add Exercise") {
                                showingExerciseSelector = true
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical)
                    } else {
                        ForEach(groupedExercises(), id: \.0) { groupId, exercises in
                            VStack(alignment: .leading, spacing: 8) {
                                if exercises.count > 1 {
                                    // Superset header
                                    HStack {
                                        Label("Superset", systemImage: "link")
                                            .font(.caption)
                                            .foregroundColor(.brandSageGreen)
                                        Spacer()
                                        Button("Break Apart") {
                                            breakSuperset(groupId)
                                        }
                                        .font(.caption)
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.brandSageGreen.opacity(0.1))
                                    .cornerRadius(6)
                                }
                                
                                ForEach(exercises) { exercise in
                                    WorkoutExerciseRow(
                                        exercise: exercise,
                                        isSelected: selectedForSuperset.contains(exercise.id),
                                        showCheckbox: exercises.count == 1,
                                        onToggleSelection: {
                                            if selectedForSuperset.contains(exercise.id) {
                                                selectedForSuperset.remove(exercise.id)
                                            } else {
                                                selectedForSuperset.insert(exercise.id)
                                            }
                                        },
                                        onEdit: {
                                            exerciseToEdit = exercise
                                        },
                                        onRemove: {
                                            workoutExercises.removeAll { $0.id == exercise.id }
                                        }
                                    )
                                }
                            }
                        }
                        
                        HStack {
                            Button("Add More Exercises") {
                                showingExerciseSelector = true
                            }
                            
                            if selectedForSuperset.count >= 2 {
                                Button(action: createSuperset) {
                                    Label("Create Superset (\(selectedForSuperset.count))", systemImage: "link")
                                }
                                .buttonStyle(.borderedProminent)
                                .controlSize(.small)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Create Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveWorkout()
                    }
                    .disabled(workoutName.isEmpty || workoutExercises.isEmpty)
                }
            }
            .sheet(isPresented: $showingExerciseSelector) {
                ExerciseSelectorView(
                    exercises: allExercises,
                    onSelectExercise: { exercise in
                        let workoutExercise = WorkoutExercise(
                            exercise: exercise,
                            sets: [],
                            orderIndex: workoutExercises.count
                        )
                        workoutExercises.append(workoutExercise)
                        exerciseToEdit = workoutExercise
                    }
                )
            }
            .sheet(item: $exerciseToEdit) { exercise in
                if let index = workoutExercises.firstIndex(where: { $0.id == exercise.id }) {
                    ExerciseSetEditor(workoutExercise: $workoutExercises[index])
                }
            }
        }
    }
    
    private func groupedExercises() -> [(UUID, [WorkoutExercise])] {
        var groups: [UUID: [WorkoutExercise]] = [:]
        
        for exercise in workoutExercises {
            let key = exercise.supersetId ?? exercise.id
            if groups[key] == nil {
                groups[key] = []
            }
            groups[key]?.append(exercise)
        }
        
        return groups.sorted { $0.value.first?.orderIndex ?? 0 < $1.value.first?.orderIndex ?? 0 }
    }
    
    private func createSuperset() {
        let supersetId = UUID()
        for exerciseId in selectedForSuperset {
            if let index = workoutExercises.firstIndex(where: { $0.id == exerciseId }) {
                workoutExercises[index].supersetId = supersetId
            }
        }
        selectedForSuperset.removeAll()
    }
    
    private func breakSuperset(_ groupId: UUID) {
        for index in workoutExercises.indices {
            if workoutExercises[index].supersetId == groupId {
                workoutExercises[index].supersetId = nil
            }
        }
    }
    
    private func saveWorkout() {
        let workout = Workout(
            name: workoutName,
            desc: workoutDescription,
            exercises: workoutExercises,
            tags: Array(selectedTags)
        )
        
        modelContext.insert(workout)
        try? modelContext.save()
        dismiss()
    }
}

struct TagButton: View {
    let tag: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(tag)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.brandSageGreen : Color.brandDivider.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(15)
        }
    }
}

struct WorkoutExerciseRow: View {
    let exercise: WorkoutExercise
    let isSelected: Bool
    let showCheckbox: Bool
    let onToggleSelection: () -> Void
    let onEdit: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        HStack {
            if showCheckbox {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .foregroundColor(isSelected ? .brandSageGreen : .brandSecondaryText)
                    .onTapGesture {
                        onToggleSelection()
                    }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.exercise.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if !exercise.sets.isEmpty {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(exercise.sets.prefix(3)) { set in
                            HStack(spacing: 4) {
                                Text("Set \(set.setNumber):")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                if set.weightUnit == .bodyweight {
                                    Text("BW × \(set.reps)")
                                        .font(.caption)
                                } else {
                                    Text("\(set.reps) × \(Int(set.weight))\(set.weightUnit.rawValue)")
                                        .font(.caption)
                                }
                                if let rpe = set.rpe {
                                    Text("RPE \(rpe)")
                                        .font(.caption2)
                                        .foregroundColor(Color.brandCoral)
                                }
                            }
                        }
                        if exercise.sets.count > 3 {
                            Text("... and \(exercise.sets.count - 3) more sets")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                } else {
                    Text("Tap to configure sets")
                        .font(.caption)
                        .foregroundColor(Color.brandCoral)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                onEdit()
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: onEdit) {
                    Image(systemName: "pencil.circle")
                        .foregroundColor(.brandSageGreen)
                }
                
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.brandError.opacity(0.6))
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    CreateWorkoutView()
        .modelContainer(for: [Workout.self, Exercise.self], inMemory: true)
}