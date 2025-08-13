import SwiftUI
import SwiftData

struct ExercisesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Exercise.title) private var exercises: [Exercise]
    @State private var searchText = ""
    @State private var selectedBodyPart: String = "All"
    @State private var selectedEquipment: String = "All"
    @State private var selectedExercise: Exercise?
    @State private var showResults = false
    
    var bodyParts: [String] {
        ["All"] + Array(Set(exercises.map { $0.bodyPart })).sorted()
    }
    
    var equipment: [String] {
        ["All"] + Array(Set(exercises.map { $0.equipment })).sorted()
    }
    
    var filteredExercises: [Exercise] {
        // Only filter if user has initiated a search
        guard showResults else { return [] }
        
        return exercises.filter { exercise in
            let matchesSearch = searchText.isEmpty ||
                exercise.title.localizedCaseInsensitiveContains(searchText) ||
                exercise.desc.localizedCaseInsensitiveContains(searchText)
            
            let matchesBodyPart = selectedBodyPart == "All" || exercise.bodyPart == selectedBodyPart
            let matchesEquipment = selectedEquipment == "All" || exercise.equipment == selectedEquipment
            
            return matchesSearch && matchesBodyPart && matchesEquipment
        }.prefix(50).map { $0 } // Limit to 50 results for performance
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.brandSecondaryText)
                    TextField("Search exercises...", text: $searchText)
                        .onSubmit {
                            showResults = true
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            showResults = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.brandSecondaryText)
                        }
                    }
                    
                    Button("Search") {
                        showResults = true
                    }
                    .buttonStyle(BrandCompactButtonStyle(color: .brandSageGreen))
                }
                .padding(12)
                .background(Color.brandBackground)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.brandDivider, lineWidth: 1)
                )
                .padding()
                
                // Filters
                VStack(spacing: 8) {
                    // Body Part Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(bodyParts, id: \.self) { bodyPart in
                                ExerciseFilterChip(
                                    title: bodyPart,
                                    isSelected: selectedBodyPart == bodyPart,
                                    action: { 
                                        selectedBodyPart = bodyPart
                                        showResults = true
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Equipment Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(equipment, id: \.self) { item in
                                ExerciseFilterChip(
                                    title: item,
                                    isSelected: selectedEquipment == item,
                                    action: { 
                                        selectedEquipment = item
                                        showResults = true
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Exercise List
                if !showResults {
                    VStack(spacing: BrandSpacing.large) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(.brandLightGreen)
                        Text("Search Exercises")
                            .font(BrandTypography.title2)
                            .foregroundColor(.brandText)
                        Text("Enter a search term or select filters to find exercises")
                            .font(BrandTypography.subheadline)
                            .foregroundColor(.brandSecondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.brandBackground)
                } else if filteredExercises.isEmpty {
                    EmptyExercisesView()
                } else {
                    List(filteredExercises) { exercise in
                        ExerciseLibraryRow(exercise: exercise)
                            .listRowBackground(Color.brandCard)
                            .listRowSeparatorTint(.brandDivider)
                            .onTapGesture {
                                selectedExercise = exercise
                            }
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.brandBackground)
                }
            }
            .navigationTitle("Exercise Library")
            .navigationBarTitleDisplayMode(.inline)
            .brandNavigationBar()
            .sheet(item: $selectedExercise) { exercise in
                ExerciseDetailSheet(exercise: exercise)
            }
        }
        .task {
            // Import exercises if needed
            await ExerciseImporter.importExercises(to: modelContext.container)
        }
    }
}

struct ExerciseLibraryRow: View {
    let exercise: Exercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(exercise.title)
                .font(BrandTypography.headline)
                .foregroundColor(.brandText)
            
            HStack {
                Label(exercise.bodyPart, systemImage: "figure.strengthtraining.traditional")
                Label(exercise.equipment, systemImage: "dumbbell")
                
                Spacer()
                
                if exercise.rating > 0 {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.brandCoral)
                        Text(String(format: "%.1f", exercise.rating))
                            .font(BrandTypography.caption1)
                            .foregroundColor(.brandSecondaryText)
                    }
                }
            }
            .font(BrandTypography.caption1)
            .foregroundColor(.brandSecondaryText)
            
            if !exercise.desc.isEmpty {
                Text(exercise.desc)
                    .font(BrandTypography.caption1)
                    .foregroundColor(.brandSecondaryText)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}

struct ExerciseDetailSheet: View {
    let exercise: Exercise
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Exercise Header
                    VStack(alignment: .leading, spacing: 12) {
                        Text(exercise.title)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        HStack(spacing: 16) {
                            InfoBadge(icon: "figure.strengthtraining.traditional", text: exercise.bodyPart)
                            InfoBadge(icon: "dumbbell", text: exercise.equipment)
                            InfoBadge(icon: "chart.bar", text: exercise.level)
                        }
                        
                        if exercise.rating > 0 {
                            HStack {
                                ForEach(1...5, id: \.self) { star in
                                    Image(systemName: star <= Int(exercise.rating) ? "star.fill" : "star")
                                        .foregroundColor(.yellow)
                                }
                                Text(String(format: "%.1f", exercise.rating))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    
                    Divider()
                    
                    // Description
                    if !exercise.desc.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.headline)
                            
                            Text(exercise.desc)
                                .font(.body)
                        }
                        .padding()
                    }
                    
                    // Type
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Exercise Type")
                            .font(.headline)
                        
                        Text(exercise.type)
                            .font(.body)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    .padding()
                    
                    // Rating Description
                    if !exercise.ratingDesc.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Rating Notes")
                                .font(.headline)
                            
                            Text(exercise.ratingDesc)
                                .font(.body)
                                .foregroundColor(.secondary)
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

struct InfoBadge: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(BrandTypography.caption1)
            Text(text)
                .font(BrandTypography.caption1)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.brandLightGreen.opacity(0.2))
        .foregroundColor(.brandDarkGreen)
        .cornerRadius(6)
    }
}

struct EmptyExercisesView: View {
    var body: some View {
        VStack(spacing: BrandSpacing.large) {
            Image(systemName: "dumbbell")
                .font(.system(size: 60))
                .foregroundColor(.brandLightGreen)
            
            Text("No Exercises Found")
                .font(BrandTypography.title2)
                .foregroundColor(.brandText)
            
            Text("Try adjusting your filters or search terms")
                .font(BrandTypography.subheadline)
                .foregroundColor(.brandSecondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.brandBackground)
    }
}

struct ExerciseFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(BrandTypography.caption1)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.brandSageGreen : Color.brandBackground)
                .foregroundColor(isSelected ? .white : .brandText)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color.clear : Color.brandDivider, lineWidth: 1)
                )
        }
    }
}