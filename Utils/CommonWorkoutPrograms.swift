import Foundation
import SwiftData

struct CommonWorkoutPrograms {
    static func loadCommonPrograms(modelContext: ModelContext) {
        // Check if programs already exist
        let workoutDescriptor = FetchDescriptor<Workout>()
        let existingWorkouts = try? modelContext.fetch(workoutDescriptor)
        
        // Only load if we have very few workouts (less than 10)
        if let workouts = existingWorkouts, workouts.count >= 10 {
            print("Common workout programs already loaded")
            return
        }
        
        print("Loading common workout programs...")
        
        // Get exercises from database
        let exerciseDescriptor = FetchDescriptor<Exercise>()
        let exercises = (try? modelContext.fetch(exerciseDescriptor)) ?? []
        
        // Create all workout categories
        createBeginnerPrograms(exercises: exercises, modelContext: modelContext)
        createStrengthPrograms(exercises: exercises, modelContext: modelContext)
        createWeightLossPrograms(exercises: exercises, modelContext: modelContext)
        createAthleticPrograms(exercises: exercises, modelContext: modelContext)
        createMobilityPrograms(exercises: exercises, modelContext: modelContext)
        createSpecializedPrograms(exercises: exercises, modelContext: modelContext)
        
        // Save all programs
        do {
            try modelContext.save()
            print("Common workout programs loaded successfully!")
        } catch {
            print("Failed to save workout programs: \(error)")
        }
    }
    
    // Helper function to find exercise by partial name match
    private static func findExercise(_ name: String, in exercises: [Exercise]) -> Exercise? {
        return exercises.first { exercise in
            exercise.title.localizedCaseInsensitiveContains(name)
        }
    }
    
    // MARK: - Beginner Programs
    
    private static func createBeginnerPrograms(exercises: [Exercise], modelContext: ModelContext) {
        // Program 1: Beginner - Full Body Foundation
        let beginnerFullBody = Workout(
            name: "Beginner - Full Body Foundation",
            desc: "Perfect starting point for new clients. Focus on fundamental movement patterns with bodyweight and light resistance.",
            category: "Beginner",
            estimatedDuration: 45,
            tags: ["Beginner", "Full Body", "Foundation"]
        )
        
        var fullBodyExercises: [WorkoutExercise] = []
        
        // Warm-up movement
        if let jumpingJacks = findExercise("Jumping Jacks", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: jumpingJacks, orderIndex: 0)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 30, weight: 0, weightUnit: .bodyweight, rest: 30)
            ]
            fullBodyExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        // Lower body
        if let gobletSquat = findExercise("Goblet Squat", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: gobletSquat, orderIndex: 1)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 12, weight: 20, rest: 90),
                ExerciseSet(setNumber: 2, reps: 10, weight: 20, rest: 90),
                ExerciseSet(setNumber: 3, reps: 8, weight: 25, rest: 90)
            ]
            fullBodyExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        // Upper body push
        if let pushups = findExercise("Push-up", in: exercises) ?? findExercise("Incline Push-up", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: pushups, orderIndex: 2)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 10, weight: 0, weightUnit: .bodyweight, rest: 60),
                ExerciseSet(setNumber: 2, reps: 8, weight: 0, weightUnit: .bodyweight, rest: 60),
                ExerciseSet(setNumber: 3, reps: 6, weight: 0, weightUnit: .bodyweight, rest: 60)
            ]
            fullBodyExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        // Upper body pull
        if let latPulldown = findExercise("Lat Pulldown", in: exercises) ?? findExercise("Inverted Row", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: latPulldown, orderIndex: 3)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 12, weight: 60, rest: 60),
                ExerciseSet(setNumber: 2, reps: 10, weight: 70, rest: 60),
                ExerciseSet(setNumber: 3, reps: 8, weight: 80, rest: 60)
            ]
            fullBodyExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        // Core
        if let plank = findExercise("Plank", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: plank, orderIndex: 4)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 30, weight: 0, weightUnit: .bodyweight, rest: 45),
                ExerciseSet(setNumber: 2, reps: 30, weight: 0, weightUnit: .bodyweight, rest: 45),
                ExerciseSet(setNumber: 3, reps: 30, weight: 0, weightUnit: .bodyweight, rest: 45)
            ]
            fullBodyExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        beginnerFullBody.exercises = fullBodyExercises
        modelContext.insert(beginnerFullBody)
        
        // Program 2: Beginner - Machine Circuit
        let machineCircuit = Workout(
            name: "Beginner - Machine Circuit",
            desc: "Safe introduction to resistance training using guided machines. Ideal for building confidence.",
            category: "Beginner",
            estimatedDuration: 40,
            tags: ["Beginner", "Machines", "Circuit"]
        )
        
        var machineExercises: [WorkoutExercise] = []
        
        if let legPress = findExercise("Leg Press", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: legPress, orderIndex: 0)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 15, weight: 100, rest: 60),
                ExerciseSet(setNumber: 2, reps: 12, weight: 120, rest: 60),
                ExerciseSet(setNumber: 3, reps: 10, weight: 140, rest: 60)
            ]
            machineExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let chestPress = findExercise("Chest Press", in: exercises) ?? findExercise("Machine Press", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: chestPress, orderIndex: 1)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 12, weight: 40, rest: 60),
                ExerciseSet(setNumber: 2, reps: 10, weight: 50, rest: 60),
                ExerciseSet(setNumber: 3, reps: 8, weight: 60, rest: 60)
            ]
            machineExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let seatedRow = findExercise("Seated Row", in: exercises) ?? findExercise("Cable Row", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: seatedRow, orderIndex: 2)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 12, weight: 60, rest: 60),
                ExerciseSet(setNumber: 2, reps: 10, weight: 70, rest: 60),
                ExerciseSet(setNumber: 3, reps: 8, weight: 80, rest: 60)
            ]
            machineExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let legCurl = findExercise("Leg Curl", in: exercises) ?? findExercise("Lying Leg Curl", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: legCurl, orderIndex: 3)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 15, weight: 40, rest: 45),
                ExerciseSet(setNumber: 2, reps: 12, weight: 50, rest: 45),
                ExerciseSet(setNumber: 3, reps: 10, weight: 60, rest: 45)
            ]
            machineExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        machineCircuit.exercises = machineExercises
        modelContext.insert(machineCircuit)
    }
    
    // MARK: - Strength Programs
    
    private static func createStrengthPrograms(exercises: [Exercise], modelContext: ModelContext) {
        // Program 1: Upper Body - Push Power
        let pushDay = Workout(
            name: "Upper Body - Push Power",
            desc: "Comprehensive push workout targeting chest, shoulders, and triceps for strength development.",
            category: "Strength Training",
            estimatedDuration: 75,
            tags: ["Push", "Upper Body", "Strength", "Hypertrophy"]
        )
        
        var pushExercises: [WorkoutExercise] = []
        
        if let benchPress = findExercise("Bench Press", in: exercises) ?? findExercise("Barbell Bench Press", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: benchPress, orderIndex: 0)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 8, weight: 135, rest: 180),
                ExerciseSet(setNumber: 2, reps: 6, weight: 155, rest: 180),
                ExerciseSet(setNumber: 3, reps: 6, weight: 165, rest: 180),
                ExerciseSet(setNumber: 4, reps: 4, weight: 175, rest: 180)
            ]
            pushExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let overheadPress = findExercise("Overhead Press", in: exercises) ?? findExercise("Shoulder Press", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: overheadPress, orderIndex: 1)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 8, weight: 95, rest: 120),
                ExerciseSet(setNumber: 2, reps: 8, weight: 105, rest: 120),
                ExerciseSet(setNumber: 3, reps: 6, weight: 115, rest: 120)
            ]
            pushExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let inclinePress = findExercise("Incline Dumbbell Press", in: exercises) ?? findExercise("Incline Press", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: inclinePress, orderIndex: 2)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 10, weight: 60, rest: 90),
                ExerciseSet(setNumber: 2, reps: 8, weight: 70, rest: 90),
                ExerciseSet(setNumber: 3, reps: 6, weight: 80, rest: 90)
            ]
            pushExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let dips = findExercise("Dips", in: exercises) ?? findExercise("Tricep Dips", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: dips, orderIndex: 3)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 12, weight: 0, weightUnit: .bodyweight, rest: 60),
                ExerciseSet(setNumber: 2, reps: 10, weight: 0, weightUnit: .bodyweight, rest: 60),
                ExerciseSet(setNumber: 3, reps: 8, weight: 0, weightUnit: .bodyweight, rest: 60)
            ]
            pushExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let lateralRaise = findExercise("Lateral Raise", in: exercises) ?? findExercise("Deltoid", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: lateralRaise, orderIndex: 4)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 15, weight: 15, rest: 45),
                ExerciseSet(setNumber: 2, reps: 12, weight: 20, rest: 45),
                ExerciseSet(setNumber: 3, reps: 10, weight: 25, rest: 45)
            ]
            pushExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        pushDay.exercises = pushExercises
        modelContext.insert(pushDay)
        
        // Program 2: Upper Body - Pull Power
        let pullDay = Workout(
            name: "Upper Body - Pull Power",
            desc: "Complete pull workout for back development, biceps, and posterior chain strength.",
            category: "Strength Training",
            estimatedDuration: 70,
            tags: ["Pull", "Back", "Biceps", "Strength"]
        )
        
        var pullExercises: [WorkoutExercise] = []
        
        if let deadlift = findExercise("Deadlift", in: exercises) ?? findExercise("Conventional Deadlift", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: deadlift, orderIndex: 0)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 5, weight: 185, rest: 240),
                ExerciseSet(setNumber: 2, reps: 5, weight: 225, rest: 240),
                ExerciseSet(setNumber: 3, reps: 3, weight: 265, rest: 240),
                ExerciseSet(setNumber: 4, reps: 1, weight: 295, rest: 240)
            ]
            pullExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let pullups = findExercise("Pull-up", in: exercises) ?? findExercise("Pullup", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: pullups, orderIndex: 1)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 8, weight: 0, weightUnit: .bodyweight, rest: 120),
                ExerciseSet(setNumber: 2, reps: 6, weight: 0, weightUnit: .bodyweight, rest: 120),
                ExerciseSet(setNumber: 3, reps: 5, weight: 0, weightUnit: .bodyweight, rest: 120)
            ]
            pullExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let barbellRow = findExercise("Barbell Row", in: exercises) ?? findExercise("Bent Over Row", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: barbellRow, orderIndex: 2)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 10, weight: 135, rest: 90),
                ExerciseSet(setNumber: 2, reps: 8, weight: 155, rest: 90),
                ExerciseSet(setNumber: 3, reps: 6, weight: 175, rest: 90)
            ]
            pullExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let facePulls = findExercise("Face Pull", in: exercises) ?? findExercise("Rear Delt", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: facePulls, orderIndex: 3)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 15, weight: 60, rest: 60),
                ExerciseSet(setNumber: 2, reps: 15, weight: 70, rest: 60),
                ExerciseSet(setNumber: 3, reps: 12, weight: 80, rest: 60)
            ]
            pullExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let curls = findExercise("Barbell Curl", in: exercises) ?? findExercise("Bicep Curl", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: curls, orderIndex: 4)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 12, weight: 65, rest: 45),
                ExerciseSet(setNumber: 2, reps: 10, weight: 75, rest: 45),
                ExerciseSet(setNumber: 3, reps: 8, weight: 85, rest: 45)
            ]
            pullExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        pullDay.exercises = pullExercises
        modelContext.insert(pullDay)
        
        // Program 3: Lower Body - Leg Day
        let legDay = Workout(
            name: "Lower Body - Leg Day",
            desc: "Comprehensive lower body workout for quad, hamstring, glute, and calf development.",
            category: "Strength Training",
            estimatedDuration: 80,
            tags: ["Legs", "Lower Body", "Strength", "Power"]
        )
        
        var legExercises: [WorkoutExercise] = []
        
        if let squat = findExercise("Back Squat", in: exercises) ?? findExercise("Barbell Squat", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: squat, orderIndex: 0)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 8, weight: 185, rest: 180),
                ExerciseSet(setNumber: 2, reps: 6, weight: 225, rest: 180),
                ExerciseSet(setNumber: 3, reps: 6, weight: 245, rest: 180),
                ExerciseSet(setNumber: 4, reps: 4, weight: 265, rest: 180)
            ]
            legExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let romanianDL = findExercise("Romanian Deadlift", in: exercises) ?? findExercise("RDL", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: romanianDL, orderIndex: 1)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 10, weight: 135, rest: 120),
                ExerciseSet(setNumber: 2, reps: 8, weight: 155, rest: 120),
                ExerciseSet(setNumber: 3, reps: 6, weight: 185, rest: 120)
            ]
            legExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let lunges = findExercise("Walking Lunge", in: exercises) ?? findExercise("Lunge", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: lunges, orderIndex: 2)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 12, weight: 40, rest: 90),
                ExerciseSet(setNumber: 2, reps: 10, weight: 50, rest: 90),
                ExerciseSet(setNumber: 3, reps: 8, weight: 60, rest: 90)
            ]
            legExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let legPress = findExercise("Leg Press", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: legPress, orderIndex: 3)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 15, weight: 360, rest: 90),
                ExerciseSet(setNumber: 2, reps: 12, weight: 450, rest: 90),
                ExerciseSet(setNumber: 3, reps: 10, weight: 540, rest: 90)
            ]
            legExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let calfRaise = findExercise("Calf Raise", in: exercises) ?? findExercise("Standing Calf Raise", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: calfRaise, orderIndex: 4)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 20, weight: 135, rest: 45),
                ExerciseSet(setNumber: 2, reps: 15, weight: 155, rest: 45),
                ExerciseSet(setNumber: 3, reps: 12, weight: 185, rest: 45)
            ]
            legExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        legDay.exercises = legExercises
        modelContext.insert(legDay)
    }
    
    // MARK: - Weight Loss/Conditioning Programs
    
    private static func createWeightLossPrograms(exercises: [Exercise], modelContext: ModelContext) {
        // Program 1: HIIT Circuit - Fat Burner
        let hiitCircuit = Workout(
            name: "HIIT Circuit - Fat Burner",
            desc: "High-intensity interval training for maximum calorie burn and metabolic conditioning.",
            category: "Weight Loss",
            estimatedDuration: 30,
            tags: ["HIIT", "Cardio", "Fat Loss", "Circuit"]
        )
        
        var hiitExercises: [WorkoutExercise] = []
        
        if let burpees = findExercise("Burpee", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: burpees, orderIndex: 0)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 10, weight: 0, weightUnit: .bodyweight, rest: 30),
                ExerciseSet(setNumber: 2, reps: 8, weight: 0, weightUnit: .bodyweight, rest: 30),
                ExerciseSet(setNumber: 3, reps: 6, weight: 0, weightUnit: .bodyweight, rest: 30)
            ]
            hiitExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let mountainClimbers = findExercise("Mountain Climber", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: mountainClimbers, orderIndex: 1)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 30, weight: 0, weightUnit: .bodyweight, rest: 30),
                ExerciseSet(setNumber: 2, reps: 25, weight: 0, weightUnit: .bodyweight, rest: 30),
                ExerciseSet(setNumber: 3, reps: 20, weight: 0, weightUnit: .bodyweight, rest: 30)
            ]
            hiitExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let kbSwings = findExercise("Kettlebell Swing", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: kbSwings, orderIndex: 2)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 20, weight: 35, rest: 45),
                ExerciseSet(setNumber: 2, reps: 15, weight: 35, rest: 45),
                ExerciseSet(setNumber: 3, reps: 12, weight: 35, rest: 45)
            ]
            hiitExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let jumpingJacks = findExercise("Jumping Jack", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: jumpingJacks, orderIndex: 3)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 40, weight: 0, weightUnit: .bodyweight, rest: 30),
                ExerciseSet(setNumber: 2, reps: 35, weight: 0, weightUnit: .bodyweight, rest: 30),
                ExerciseSet(setNumber: 3, reps: 30, weight: 0, weightUnit: .bodyweight, rest: 30)
            ]
            hiitExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let ballSlams = findExercise("Ball Slam", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: ballSlams, orderIndex: 4)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 15, weight: 20, rest: 45),
                ExerciseSet(setNumber: 2, reps: 12, weight: 20, rest: 45),
                ExerciseSet(setNumber: 3, reps: 10, weight: 20, rest: 45)
            ]
            hiitExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        hiitCircuit.exercises = hiitExercises
        modelContext.insert(hiitCircuit)
        
        // Program 2: Metabolic Conditioning
        let metcon = Workout(
            name: "Metabolic Conditioning - Total Body",
            desc: "Full-body metabolic workout combining strength and cardio for optimal fat loss.",
            category: "Weight Loss",
            estimatedDuration: 45,
            tags: ["MetCon", "Full Body", "Conditioning", "Fat Loss"]
        )
        
        var metconExercises: [WorkoutExercise] = []
        let supersetId1 = UUID()
        let supersetId2 = UUID()
        
        // Superset 1A
        if let thrusters = findExercise("Thruster", in: exercises) ?? findExercise("Squat to Press", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: thrusters, supersetId: supersetId1, orderIndex: 0)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 12, weight: 65, rest: 0),
                ExerciseSet(setNumber: 2, reps: 10, weight: 75, rest: 0),
                ExerciseSet(setNumber: 3, reps: 8, weight: 85, rest: 0)
            ]
            metconExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        // Superset 1B
        if let rowing = findExercise("Rowing Machine", in: exercises) ?? findExercise("Row", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: rowing, supersetId: supersetId1, orderIndex: 1)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 250, weight: 0, weightUnit: .bodyweight, rest: 90), // 250m
                ExerciseSet(setNumber: 2, reps: 250, weight: 0, weightUnit: .bodyweight, rest: 90),
                ExerciseSet(setNumber: 3, reps: 250, weight: 0, weightUnit: .bodyweight, rest: 90)
            ]
            metconExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        // Superset 2A
        if let boxJumps = findExercise("Box Jump", in: exercises) ?? findExercise("Step Up", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: boxJumps, supersetId: supersetId2, orderIndex: 2)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 15, weight: 0, weightUnit: .bodyweight, rest: 0),
                ExerciseSet(setNumber: 2, reps: 12, weight: 0, weightUnit: .bodyweight, rest: 0),
                ExerciseSet(setNumber: 3, reps: 10, weight: 0, weightUnit: .bodyweight, rest: 0)
            ]
            metconExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        // Superset 2B
        if let pushups = findExercise("Push-up", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: pushups, supersetId: supersetId2, orderIndex: 3)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 15, weight: 0, weightUnit: .bodyweight, rest: 60),
                ExerciseSet(setNumber: 2, reps: 12, weight: 0, weightUnit: .bodyweight, rest: 60),
                ExerciseSet(setNumber: 3, reps: 10, weight: 0, weightUnit: .bodyweight, rest: 60)
            ]
            metconExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        metcon.exercises = metconExercises
        modelContext.insert(metcon)
    }
    
    // MARK: - Athletic/Sport-Specific Programs
    
    private static func createAthleticPrograms(exercises: [Exercise], modelContext: ModelContext) {
        // Program 1: Athletic Performance - Power Development
        let powerProgram = Workout(
            name: "Athletic Performance - Power Development",
            desc: "Explosive movements for athletic power, speed, and performance enhancement.",
            category: "Athletic Performance",
            estimatedDuration: 60,
            tags: ["Power", "Athletic", "Explosive", "Sports"]
        )
        
        var powerExercises: [WorkoutExercise] = []
        
        if let powerClean = findExercise("Power Clean", in: exercises) ?? findExercise("Clean", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: powerClean, orderIndex: 0)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 3, weight: 135, rest: 180),
                ExerciseSet(setNumber: 2, reps: 3, weight: 155, rest: 180),
                ExerciseSet(setNumber: 3, reps: 2, weight: 175, rest: 180),
                ExerciseSet(setNumber: 4, reps: 1, weight: 185, rest: 180)
            ]
            powerExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let boxJump = findExercise("Box Jump", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: boxJump, orderIndex: 1)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 5, weight: 0, weightUnit: .bodyweight, rest: 120),
                ExerciseSet(setNumber: 2, reps: 5, weight: 0, weightUnit: .bodyweight, rest: 120),
                ExerciseSet(setNumber: 3, reps: 3, weight: 0, weightUnit: .bodyweight, rest: 120)
            ]
            powerExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let medicineBallThrow = findExercise("Medicine Ball", in: exercises) ?? findExercise("Ball Slam", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: medicineBallThrow, orderIndex: 2)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 10, weight: 20, rest: 90),
                ExerciseSet(setNumber: 2, reps: 8, weight: 20, rest: 90),
                ExerciseSet(setNumber: 3, reps: 6, weight: 25, rest: 90)
            ]
            powerExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let jumpSquat = findExercise("Jump Squat", in: exercises) ?? findExercise("Squat Jump", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: jumpSquat, orderIndex: 3)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 8, weight: 0, weightUnit: .bodyweight, rest: 90),
                ExerciseSet(setNumber: 2, reps: 6, weight: 0, weightUnit: .bodyweight, rest: 90),
                ExerciseSet(setNumber: 3, reps: 5, weight: 0, weightUnit: .bodyweight, rest: 90)
            ]
            powerExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        powerProgram.exercises = powerExercises
        modelContext.insert(powerProgram)
        
        // Program 2: Sport-Specific - Running/Endurance
        let runnerProgram = Workout(
            name: "Sport-Specific - Runner's Strength",
            desc: "Targeted strength training for runners to improve performance and prevent injury.",
            category: "Athletic Performance",
            estimatedDuration: 50,
            tags: ["Running", "Endurance", "Injury Prevention"]
        )
        
        var runnerExercises: [WorkoutExercise] = []
        
        if let singleLegSquat = findExercise("Pistol Squat", in: exercises) ?? findExercise("Single Leg", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: singleLegSquat, orderIndex: 0)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 10, weight: 0, weightUnit: .bodyweight, rest: 60),
                ExerciseSet(setNumber: 2, reps: 8, weight: 0, weightUnit: .bodyweight, rest: 60),
                ExerciseSet(setNumber: 3, reps: 6, weight: 0, weightUnit: .bodyweight, rest: 60)
            ]
            runnerExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let hipThrust = findExercise("Hip Thrust", in: exercises) ?? findExercise("Glute Bridge", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: hipThrust, orderIndex: 1)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 15, weight: 135, rest: 60),
                ExerciseSet(setNumber: 2, reps: 12, weight: 155, rest: 60),
                ExerciseSet(setNumber: 3, reps: 10, weight: 185, rest: 60)
            ]
            runnerExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let calfRaise = findExercise("Calf Raise", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: calfRaise, orderIndex: 2)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 20, weight: 0, weightUnit: .bodyweight, rest: 45),
                ExerciseSet(setNumber: 2, reps: 15, weight: 25, rest: 45),
                ExerciseSet(setNumber: 3, reps: 12, weight: 35, rest: 45)
            ]
            runnerExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let plank = findExercise("Plank", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: plank, orderIndex: 3)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 60, weight: 0, weightUnit: .bodyweight, rest: 45),
                ExerciseSet(setNumber: 2, reps: 45, weight: 0, weightUnit: .bodyweight, rest: 45),
                ExerciseSet(setNumber: 3, reps: 30, weight: 0, weightUnit: .bodyweight, rest: 45)
            ]
            runnerExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        runnerProgram.exercises = runnerExercises
        modelContext.insert(runnerProgram)
    }
    
    // MARK: - Mobility/Rehabilitation Programs
    
    private static func createMobilityPrograms(exercises: [Exercise], modelContext: ModelContext) {
        // Program 1: Mobility & Recovery
        let mobilityProgram = Workout(
            name: "Mobility & Recovery - Full Body",
            desc: "Gentle movements for flexibility, mobility, and active recovery between intense sessions.",
            category: "Recovery",
            estimatedDuration: 30,
            tags: ["Mobility", "Recovery", "Flexibility", "Stretching"]
        )
        
        var mobilityExercises: [WorkoutExercise] = []
        
        if let catCow = findExercise("Cat", in: exercises) ?? findExercise("Stretch", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: catCow, orderIndex: 0)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 10, weight: 0, weightUnit: .bodyweight, rest: 30)
            ]
            mobilityExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let birdDog = findExercise("Bird Dog", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: birdDog, orderIndex: 1)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 10, weight: 0, weightUnit: .bodyweight, rest: 30),
                ExerciseSet(setNumber: 2, reps: 10, weight: 0, weightUnit: .bodyweight, rest: 30)
            ]
            mobilityExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let hipCircles = findExercise("Hip", in: exercises) ?? findExercise("Hip Rotation", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: hipCircles, orderIndex: 2)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 10, weight: 0, weightUnit: .bodyweight, rest: 30),
                ExerciseSet(setNumber: 2, reps: 10, weight: 0, weightUnit: .bodyweight, rest: 30)
            ]
            mobilityExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let shoulderRolls = findExercise("Shoulder Roll", in: exercises) ?? findExercise("Shoulder Circle", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: shoulderRolls, orderIndex: 3)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 10, weight: 0, weightUnit: .bodyweight, rest: 30)
            ]
            mobilityExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        mobilityProgram.exercises = mobilityExercises
        modelContext.insert(mobilityProgram)
        
        // Program 2: Lower Back Rehabilitation
        let backRehab = Workout(
            name: "Rehabilitation - Lower Back Focus",
            desc: "Therapeutic exercises for lower back pain relief and core stabilization.",
            category: "Rehabilitation",
            estimatedDuration: 35,
            tags: ["Rehab", "Lower Back", "Core", "Therapeutic"]
        )
        
        var rehabExercises: [WorkoutExercise] = []
        
        if let deadBug = findExercise("Dead Bug", in: exercises) ?? findExercise("Core", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: deadBug, orderIndex: 0)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 10, weight: 0, weightUnit: .bodyweight, rest: 45),
                ExerciseSet(setNumber: 2, reps: 8, weight: 0, weightUnit: .bodyweight, rest: 45)
            ]
            rehabExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let gluteBridge = findExercise("Glute Bridge", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: gluteBridge, orderIndex: 1)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 15, weight: 0, weightUnit: .bodyweight, rest: 45),
                ExerciseSet(setNumber: 2, reps: 12, weight: 0, weightUnit: .bodyweight, rest: 45),
                ExerciseSet(setNumber: 3, reps: 10, weight: 0, weightUnit: .bodyweight, rest: 45)
            ]
            rehabExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let clamshell = findExercise("Clamshell", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: clamshell, orderIndex: 2)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 15, weight: 0, weightUnit: .bodyweight, rest: 30),
                ExerciseSet(setNumber: 2, reps: 12, weight: 0, weightUnit: .bodyweight, rest: 30)
            ]
            rehabExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let wallSit = findExercise("Wall Sit", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: wallSit, orderIndex: 3)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 30, weight: 0, weightUnit: .bodyweight, rest: 60),
                ExerciseSet(setNumber: 2, reps: 30, weight: 0, weightUnit: .bodyweight, rest: 60)
            ]
            rehabExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        backRehab.exercises = rehabExercises
        modelContext.insert(backRehab)
    }
    
    // MARK: - Specialized Programs
    
    private static func createSpecializedPrograms(exercises: [Exercise], modelContext: ModelContext) {
        // Program 1: Senior Fitness
        let seniorFitness = Workout(
            name: "Senior Fitness - Functional Movement",
            desc: "Safe, low-impact exercises for older adults focusing on balance, strength, and daily activities.",
            category: "Specialized",
            estimatedDuration: 40,
            tags: ["Senior", "Low Impact", "Balance", "Functional"]
        )
        
        var seniorExercises: [WorkoutExercise] = []
        
        if let chairSquat = findExercise("Squat", in: exercises) ?? findExercise("Box Squat", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: chairSquat, orderIndex: 0)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 10, weight: 0, weightUnit: .bodyweight, rest: 60),
                ExerciseSet(setNumber: 2, reps: 8, weight: 0, weightUnit: .bodyweight, rest: 60)
            ]
            seniorExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let wallPushup = findExercise("Incline Push-up", in: exercises) ?? findExercise("Wall Push", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: wallPushup, orderIndex: 1)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 10, weight: 0, weightUnit: .bodyweight, rest: 60),
                ExerciseSet(setNumber: 2, reps: 8, weight: 0, weightUnit: .bodyweight, rest: 60)
            ]
            seniorExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let marchInPlace = findExercise("March", in: exercises) ?? findExercise("High Knee", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: marchInPlace, orderIndex: 2)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 20, weight: 0, weightUnit: .bodyweight, rest: 45)
            ]
            seniorExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let heelRaise = findExercise("Calf Raise", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: heelRaise, orderIndex: 3)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 15, weight: 0, weightUnit: .bodyweight, rest: 45),
                ExerciseSet(setNumber: 2, reps: 12, weight: 0, weightUnit: .bodyweight, rest: 45)
            ]
            seniorExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        seniorFitness.exercises = seniorExercises
        modelContext.insert(seniorFitness)
        
        // Program 2: Prenatal/Postnatal
        let prenatalFitness = Workout(
            name: "Prenatal/Postnatal - Safe Strengthening",
            desc: "Modified exercises safe for pregnancy and postpartum recovery with core and pelvic floor focus.",
            category: "Specialized",
            estimatedDuration: 35,
            tags: ["Prenatal", "Postnatal", "Core", "Pelvic Floor"]
        )
        
        var prenatalExercises: [WorkoutExercise] = []
        
        if let modifiedSquat = findExercise("Goblet Squat", in: exercises) ?? findExercise("Sumo Squat", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: modifiedSquat, orderIndex: 0)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 12, weight: 15, rest: 60),
                ExerciseSet(setNumber: 2, reps: 10, weight: 15, rest: 60)
            ]
            prenatalExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let sidePlank = findExercise("Side Plank", in: exercises) ?? findExercise("Modified Plank", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: sidePlank, orderIndex: 1)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 20, weight: 0, weightUnit: .bodyweight, rest: 45),
                ExerciseSet(setNumber: 2, reps: 15, weight: 0, weightUnit: .bodyweight, rest: 45)
            ]
            prenatalExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let clamshell = findExercise("Clamshell", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: clamshell, orderIndex: 2)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 15, weight: 0, weightUnit: .bodyweight, rest: 30),
                ExerciseSet(setNumber: 2, reps: 15, weight: 0, weightUnit: .bodyweight, rest: 30)
            ]
            prenatalExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let catCow = findExercise("Cat", in: exercises) ?? findExercise("Bird Dog", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: catCow, orderIndex: 3)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 10, weight: 0, weightUnit: .bodyweight, rest: 30),
                ExerciseSet(setNumber: 2, reps: 10, weight: 0, weightUnit: .bodyweight, rest: 30)
            ]
            prenatalExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        prenatalFitness.exercises = prenatalExercises
        modelContext.insert(prenatalFitness)
        
        // Program 3: Core Specialization
        let coreProgram = Workout(
            name: "Core Specialization - 6-Pack Builder",
            desc: "Intensive core workout targeting all abdominal muscles for strength and definition.",
            category: "Specialized",
            estimatedDuration: 25,
            tags: ["Core", "Abs", "Six Pack", "Definition"]
        )
        
        var coreExercises: [WorkoutExercise] = []
        
        if let hangingLegRaise = findExercise("Leg Raise", in: exercises) ?? findExercise("Hanging", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: hangingLegRaise, orderIndex: 0)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 12, weight: 0, weightUnit: .bodyweight, rest: 60),
                ExerciseSet(setNumber: 2, reps: 10, weight: 0, weightUnit: .bodyweight, rest: 60),
                ExerciseSet(setNumber: 3, reps: 8, weight: 0, weightUnit: .bodyweight, rest: 60)
            ]
            coreExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let russianTwist = findExercise("Russian Twist", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: russianTwist, orderIndex: 1)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 20, weight: 25, rest: 45),
                ExerciseSet(setNumber: 2, reps: 15, weight: 35, rest: 45),
                ExerciseSet(setNumber: 3, reps: 12, weight: 45, rest: 45)
            ]
            coreExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let plank = findExercise("Plank", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: plank, orderIndex: 2)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 60, weight: 0, weightUnit: .bodyweight, rest: 45),
                ExerciseSet(setNumber: 2, reps: 45, weight: 0, weightUnit: .bodyweight, rest: 45),
                ExerciseSet(setNumber: 3, reps: 30, weight: 0, weightUnit: .bodyweight, rest: 45)
            ]
            coreExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let bicycleCrunch = findExercise("Bicycle", in: exercises) ?? findExercise("Crunch", in: exercises) {
            let workoutExercise = WorkoutExercise(exercise: bicycleCrunch, orderIndex: 3)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 30, weight: 0, weightUnit: .bodyweight, rest: 30),
                ExerciseSet(setNumber: 2, reps: 25, weight: 0, weightUnit: .bodyweight, rest: 30),
                ExerciseSet(setNumber: 3, reps: 20, weight: 0, weightUnit: .bodyweight, rest: 30)
            ]
            coreExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        coreProgram.exercises = coreExercises
        modelContext.insert(coreProgram)
    }
}