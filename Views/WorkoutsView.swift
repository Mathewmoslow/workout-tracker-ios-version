import SwiftUI
import SwiftData

struct WorkoutsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    @Query private var workouts: [Workout]
    @State private var searchText = ""
    @State private var showingCreateWorkout = false
    @State private var selectedWorkout: Workout?
    
    var filteredWorkouts: [Workout] {
        if searchText.isEmpty {
            return workouts
        } else {
            return workouts.filter { workout in
                workout.name.localizedCaseInsensitiveContains(searchText) ||
                workout.desc.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredWorkouts) { workout in
                    WorkoutRowView(workout: workout)
                        .listRowBackground(Color.brandCard(colorScheme))
                        .listRowSeparatorTint(.brandDivider(colorScheme))
                        .onTapGesture {
                            selectedWorkout = workout
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                deleteWorkout(workout)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            
                            Button {
                                duplicateWorkout(workout)
                            } label: {
                                Label("Duplicate", systemImage: "doc.on.doc")
                            }
                            .tint(.brandSageGreen)
                        }
                }
            }
            .listStyle(PlainListStyle())
            .background(Color.brandBackground(colorScheme))
            .navigationTitle("Workouts")
            .navigationBarTitleDisplayMode(.large)
            .brandNavigationBar()
            .searchable(text: $searchText, prompt: "Search workouts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreateWorkout = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.brandSageGreen)
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingCreateWorkout) {
                CreateWorkoutView()
            }
            .sheet(item: $selectedWorkout) { workout in
                WorkoutDetailView(workout: workout)
            }
        }
    }
    
    private func deleteWorkout(_ workout: Workout) {
        withAnimation {
            modelContext.delete(workout)
            try? modelContext.save()
        }
    }
    
    private func duplicateWorkout(_ workout: Workout) {
        let newWorkout = Workout(
            name: "\(workout.name) (Copy)",
            desc: workout.desc,
            exercises: workout.exercises,
            tags: workout.tags
        )
        modelContext.insert(newWorkout)
        try? modelContext.save()
    }
}

struct WorkoutRowView: View {
    let workout: Workout
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(workout.name)
                    .font(BrandTypography.headline)
                    .foregroundColor(.brandText(colorScheme))
                
                Spacer()
                
                if workout.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundColor(.brandCoral)
                        .font(.caption)
                }
            }
            
            if !workout.desc.isEmpty {
                Text(workout.desc)
                    .font(BrandTypography.caption1)
                    .foregroundColor(.brandSecondaryText(colorScheme))
                    .lineLimit(2)
            }
            
            HStack {
                Label("\(workout.exerciseCount) exercises", systemImage: "figure.strengthtraining.traditional")
                    .font(BrandTypography.caption1)
                    .foregroundColor(.brandSecondaryText(colorScheme))
                
                if workout.hasSuperset {
                    BrandBadge(text: "Superset", color: .brandCoral)
                }
            }
            
            if !workout.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(workout.tags, id: \.self) { tag in
                            Text(tag)
                                .font(BrandTypography.caption2)
                                .fontWeight(.medium)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.brandLightGreen.opacity(0.3))
                                .foregroundColor(.brandDarkGreen)
                                .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    WorkoutsView()
        .modelContainer(for: Workout.self, inMemory: true)
}