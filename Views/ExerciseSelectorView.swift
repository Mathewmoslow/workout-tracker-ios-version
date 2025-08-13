import SwiftUI
import SwiftData

struct ExerciseSelectorView: View {
    @Environment(\.dismiss) private var dismiss
    let exercises: [Exercise]
    let onSelectExercise: (Exercise) -> Void
    
    @State private var searchText = ""
    @State private var selectedBodyPart = "All"
    @State private var selectedEquipment = "All"
    @State private var selectedLevel = "All"
    
    var bodyParts: [String] {
        let parts = Set(exercises.compactMap { $0.bodyPart })
        return ["All"] + parts.sorted()
    }
    
    var equipment: [String] {
        let equip = Set(exercises.compactMap { $0.equipment })
        return ["All"] + equip.sorted()
    }
    
    let levels = ["All", "Beginner", "Intermediate", "Advanced"]
    
    var filteredExercises: [Exercise] {
        let filtered = exercises.filter { exercise in
            let matchesSearch = searchText.isEmpty || 
                exercise.title.localizedCaseInsensitiveContains(searchText) ||
                exercise.desc.localizedCaseInsensitiveContains(searchText)
            let matchesBodyPart = selectedBodyPart == "All" || exercise.bodyPart == selectedBodyPart
            let matchesEquipment = selectedEquipment == "All" || exercise.equipment == selectedEquipment
            let matchesLevel = selectedLevel == "All" || exercise.level == selectedLevel
            
            return matchesSearch && matchesBodyPart && matchesEquipment && matchesLevel
        }
        
        // If no search/filters, show common exercises first (rating >= 5.0)
        if searchText.isEmpty && selectedBodyPart == "All" && 
           selectedEquipment == "All" && selectedLevel == "All" {
            let common = filtered.filter { $0.rating >= 5.0 }.sorted { $0.title < $1.title }
            let others = filtered.filter { $0.rating < 5.0 }.sorted { $0.title < $1.title }
            return Array((common + others).prefix(300)) // Show more when filtered
        }
        
        // Otherwise show all filtered results
        return Array(filtered.sorted { $0.title < $1.title }.prefix(500))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        FilterPicker(
                            title: "Body Part",
                            selection: $selectedBodyPart,
                            options: bodyParts
                        )
                        
                        FilterPicker(
                            title: "Equipment",
                            selection: $selectedEquipment,
                            options: equipment
                        )
                        
                        FilterPicker(
                            title: "Level",
                            selection: $selectedLevel,
                            options: levels
                        )
                    }
                    .padding()
                }
                .background(Color(.systemGray6))
                
                // Exercise List
                List(filteredExercises) { exercise in
                    Button(action: {
                        onSelectExercise(exercise)
                        dismiss()
                    }) {
                        ExerciseListRow(exercise: exercise)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .searchable(text: $searchText, prompt: "Search \(exercises.count) exercises")
            }
            .navigationTitle("Exercise Library")
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

struct FilterPicker: View {
    let title: String
    @Binding var selection: String
    let options: [String]
    
    var body: some View {
        Menu {
            ForEach(options, id: \.self) { option in
                Button(action: { selection = option }) {
                    HStack {
                        Text(option)
                        if selection == option {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(selection)
                    .font(.caption)
                    .fontWeight(.medium)
                Image(systemName: "chevron.down")
                    .font(.caption2)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
    }
}

struct ExerciseListRow: View {
    let exercise: Exercise
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(exercise.title)
                        .font(.headline)
                    
                    if exercise.rating >= 5.0 {
                        Text("COMMON")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.brandSageGreen)
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    }
                    
                    Spacer()
                }
                
                HStack {
                    Text(exercise.bodyPart)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.brandSageGreen.opacity(0.1))
                        .cornerRadius(4)
                    
                    Text(exercise.equipment)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.brandSageGreen.opacity(0.1))
                        .cornerRadius(4)
                    
                    if !exercise.level.isEmpty {
                        Text(exercise.level)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.brandCoral.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
                
                if exercise.rating > 0 {
                    HStack(spacing: 4) {
                        RatingBar(rating: exercise.rating)
                        Text("\(exercise.rating, specifier: "%.1f")/10")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "plus.circle.fill")
                .font(.title2)
                .foregroundColor(.brandSageGreen)
        }
        .padding(.vertical, 4)
    }
}

struct RatingBar: View {
    let rating: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 4)
                
                Rectangle()
                    .fill(Color.brandSageGreen)
                    .frame(width: geometry.size.width * (rating / 10), height: 4)
            }
        }
        .frame(width: 60, height: 4)
        .cornerRadius(2)
    }
}

#Preview {
    ExerciseSelectorView(
        exercises: [],
        onSelectExercise: { _ in }
    )
}