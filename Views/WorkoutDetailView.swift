import SwiftUI
import SwiftData

struct WorkoutDetailView: View {
    let workout: Workout
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var showingEditMode = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Workout Header
                    VStack(alignment: .leading, spacing: 12) {
                        Text(workout.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        if !workout.desc.isEmpty {
                            Text(workout.desc)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        
                        // Workout Metadata
                        HStack(spacing: 16) {
                            if let category = workout.category {
                                Label(category, systemImage: "tag")
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                            }
                            
                            if let duration = workout.estimatedDuration {
                                Label("\(duration) min", systemImage: "clock")
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                            }
                            
                            if workout.isFavorite {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                            }
                        }
                        
                        // Tags
                        if !workout.tags.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(workout.tags, id: \.self) { tag in
                                        Text(tag)
                                            .font(.caption)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(Color.blue.opacity(0.1))
                                            .foregroundColor(.blue)
                                            .cornerRadius(12)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    
                    Divider()
                    
                    // Exercise List
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Exercises (\(workout.exercises.count))")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(Array(workout.exercises.enumerated()), id: \.element.id) { index, workoutExercise in
                            WorkoutExerciseDetailCard(
                                workoutExercise: workoutExercise,
                                exerciseNumber: index + 1
                            )
                        }
                    }
                    
                    // Stats Summary
                    VStack(spacing: 12) {
                        HStack {
                            WorkoutStatBox(
                                title: "Total Exercises",
                                value: "\(workout.exercises.count)",
                                icon: "figure.strengthtraining.traditional"
                            )
                            
                            WorkoutStatBox(
                                title: "Total Sets",
                                value: "\(workout.totalSets)",
                                icon: "number.square"
                            )
                            
                            WorkoutStatBox(
                                title: "Est. Volume",
                                value: "\(workout.estimatedVolume) kg",
                                icon: "scalemass"
                            )
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Workout Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showingEditMode = true }) {
                            Label("Edit", systemImage: "pencil")
                        }
                        
                        Button(action: { toggleFavorite() }) {
                            Label(
                                workout.isFavorite ? "Remove from Favorites" : "Add to Favorites",
                                systemImage: workout.isFavorite ? "star.slash" : "star"
                            )
                        }
                        
                        Divider()
                        
                        Button(role: .destructive, action: { showingDeleteAlert = true }) {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .alert("Delete Workout", isPresented: $showingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    deleteWorkout()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete this workout? This action cannot be undone.")
            }
            .sheet(isPresented: $showingEditMode) {
                // TODO: Add edit workout view
                Text("Edit Workout - Coming Soon")
            }
        }
    }
    
    func toggleFavorite() {
        workout.isFavorite.toggle()
        workout.updatedAt = Date()
        try? modelContext.save()
    }
    
    func deleteWorkout() {
        modelContext.delete(workout)
        try? modelContext.save()
        dismiss()
    }
}

struct WorkoutExerciseDetailCard: View {
    let workoutExercise: WorkoutExercise
    let exerciseNumber: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Exercise Header
            HStack {
                Text("\(exerciseNumber).")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(workoutExercise.exercise.title)
                        .font(.headline)
                    
                    HStack(spacing: 12) {
                        Label(workoutExercise.exercise.bodyPart, systemImage: "figure.strengthtraining.traditional")
                        Label(workoutExercise.exercise.equipment, systemImage: "dumbbell")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if workoutExercise.supersetId != nil {
                    Text("SS")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.purple.opacity(0.2))
                        .foregroundColor(.purple)
                        .cornerRadius(4)
                }
            }
            
            // Sets Details
            VStack(alignment: .leading, spacing: 8) {
                ForEach(workoutExercise.sets) { set in
                    HStack {
                        Text("Set \(set.setNumber)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(width: 60, alignment: .leading)
                        
                        HStack(spacing: 16) {
                            Label("\(set.reps) reps", systemImage: "repeat")
                            Label("\(Int(set.weight)) \(set.weightUnit.rawValue)", systemImage: "scalemass")
                            
                            if set.rest > 0 {
                                Label("\(set.rest)s rest", systemImage: "timer")
                            }
                        }
                        .font(.caption)
                        
                        Spacer()
                    }
                }
            }
            .padding(.leading, 35)
            
            // Notes
            if !workoutExercise.notes.isEmpty {
                Text(workoutExercise.notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 35)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct WorkoutStatBox: View {
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
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(12)
    }
}