import SwiftUI
import SwiftData

struct ExerciseSetEditor: View {
    @Binding var workoutExercise: WorkoutExercise
    @Environment(\.dismiss) private var dismiss
    
    @State private var sets: [ExerciseSet] = []
    @State private var defaultReps = 10
    @State private var defaultWeight = 0.0
    @State private var defaultWeightUnit: ExerciseSet.WeightUnit = .lbs
    @State private var defaultRest = 90
    @State private var defaultRPE = 7
    @State private var useBodyweight = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Exercise") {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(workoutExercise.exercise.title)
                                .font(.headline)
                            if !workoutExercise.exercise.desc.isEmpty {
                                Text(workoutExercise.exercise.desc)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                    }
                }
                
                Section("Quick Setup") {
                    HStack {
                        Text("Sets")
                        Stepper("\(sets.count)", value: Binding(
                            get: { sets.count },
                            set: { newCount in
                                adjustSetCount(to: newCount)
                            }
                        ), in: 1...10)
                    }
                    
                    Toggle("Bodyweight Exercise", isOn: $useBodyweight)
                        .onChange(of: useBodyweight) { _, newValue in
                            if newValue {
                                defaultWeightUnit = .bodyweight
                                defaultWeight = 0
                                updateAllSets()
                            } else {
                                defaultWeightUnit = .lbs
                                updateAllSets()
                            }
                        }
                    
                    if !useBodyweight {
                        HStack {
                            Text("Default Weight")
                            TextField("Weight", value: $defaultWeight, format: .number)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.decimalPad)
                                .frame(width: 80)
                            
                            Picker("Unit", selection: $defaultWeightUnit) {
                                Text("lbs").tag(ExerciseSet.WeightUnit.lbs)
                                Text("kg").tag(ExerciseSet.WeightUnit.kg)
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 100)
                        }
                    }
                    
                    HStack {
                        Text("Default Reps")
                        TextField("Reps", value: $defaultReps, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.numberPad)
                            .frame(width: 60)
                    }
                    
                    HStack {
                        Text("Rest (seconds)")
                        TextField("Rest", value: $defaultRest, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.numberPad)
                            .frame(width: 60)
                    }
                    
                    HStack {
                        Text("RPE (1-10)")
                        Stepper("\(defaultRPE)", value: $defaultRPE, in: 1...10)
                    }
                    
                    Button("Apply to All Sets") {
                        updateAllSets()
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                Section("Sets") {
                    ForEach(sets.indices, id: \.self) { index in
                        SetRowEditor(
                            set: $sets[index],
                            setNumber: index + 1,
                            isBodyweight: useBodyweight
                        )
                    }
                    .onDelete(perform: deleteSets)
                }
                
                Section("Notes") {
                    TextField("Exercise notes (optional)", text: $workoutExercise.notes, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle("Configure Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        workoutExercise.sets = sets
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
        .onAppear {
            if workoutExercise.sets.isEmpty {
                // Initialize with 3 sets by default
                for i in 1...3 {
                    sets.append(ExerciseSet(
                        setNumber: i,
                        reps: defaultReps,
                        weight: defaultWeight,
                        weightUnit: defaultWeightUnit,
                        rest: defaultRest,
                        rpe: defaultRPE
                    ))
                }
            } else {
                sets = workoutExercise.sets
                // Set defaults from first set
                if let firstSet = sets.first {
                    defaultReps = firstSet.reps
                    defaultWeight = firstSet.weight
                    defaultWeightUnit = firstSet.weightUnit
                    defaultRest = firstSet.rest
                    defaultRPE = firstSet.rpe ?? 7
                    useBodyweight = firstSet.weightUnit == .bodyweight
                }
            }
        }
    }
    
    private func adjustSetCount(to newCount: Int) {
        let currentCount = sets.count
        
        if newCount > currentCount {
            // Add sets
            for i in (currentCount + 1)...newCount {
                sets.append(ExerciseSet(
                    setNumber: i,
                    reps: defaultReps,
                    weight: defaultWeight,
                    weightUnit: defaultWeightUnit,
                    rest: defaultRest,
                    rpe: defaultRPE
                ))
            }
        } else if newCount < currentCount {
            // Remove sets from the end
            sets = Array(sets.prefix(newCount))
            // Update set numbers
            for i in sets.indices {
                sets[i].setNumber = i + 1
            }
        }
    }
    
    private func updateAllSets() {
        for index in sets.indices {
            sets[index].reps = defaultReps
            sets[index].weight = useBodyweight ? 0 : defaultWeight
            sets[index].weightUnit = defaultWeightUnit
            sets[index].rest = defaultRest
            sets[index].rpe = defaultRPE
        }
    }
    
    private func deleteSets(at offsets: IndexSet) {
        sets.remove(atOffsets: offsets)
        // Update set numbers
        for i in sets.indices {
            sets[i].setNumber = i + 1
        }
    }
}

struct SetRowEditor: View {
    @Binding var set: ExerciseSet
    let setNumber: Int
    let isBodyweight: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Set \(setNumber)")
                    .font(.headline)
                Spacer()
            }
            
            HStack(spacing: 16) {
                VStack(alignment: .leading) {
                    Text("Reps")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Reps", value: $set.reps, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                        .frame(width: 50)
                }
                
                if !isBodyweight {
                    VStack(alignment: .leading) {
                        Text("Weight")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        HStack(spacing: 4) {
                            TextField("Weight", value: $set.weight, format: .number)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.decimalPad)
                                .frame(width: 60)
                            Text(set.weightUnit.rawValue)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                VStack(alignment: .leading) {
                    Text("Rest")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack(spacing: 4) {
                        TextField("Rest", value: $set.rest, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.numberPad)
                            .frame(width: 50)
                        Text("sec")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                VStack(alignment: .leading) {
                    Text("RPE")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("RPE", value: Binding(
                        get: { set.rpe ?? 0 },
                        set: { set.rpe = $0 > 0 ? $0 : nil }
                    ), format: .number)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                        .frame(width: 40)
                }
            }
        }
        .padding(.vertical, 4)
    }
}