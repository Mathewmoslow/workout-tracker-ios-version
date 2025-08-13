import Foundation
import SwiftData

struct SampleDataLoader {
    static func loadSampleData(modelContext: ModelContext) {
        // Check if data already exists
        let clientDescriptor = FetchDescriptor<Client>()
        let existingClients = try? modelContext.fetch(clientDescriptor)
        
        if existingClients?.isEmpty == false {
            print("Sample data already loaded")
            return
        }
        
        print("Loading sample data...")
        
        // Load exercises first
        let exercises = loadSampleExercises(modelContext: modelContext)
        
        // Create sample clients
        _ = createSampleClients(modelContext: modelContext)
        
        // Create sample workouts
        _ = createSampleWorkouts(exercises: exercises, modelContext: modelContext)
        
        // Save all data
        do {
            try modelContext.save()
            print("Sample data loaded successfully!")
        } catch {
            print("Failed to save sample data: \(error)")
        }
    }
    
    private static func loadSampleExercises(modelContext: ModelContext) -> [Exercise] {
        var exercises: [Exercise] = []
        
        // Load common exercises for testing
        let sampleExerciseData = [
            ("Barbell Bench Press", "Compound upper body exercise targeting chest, shoulders, and triceps", "Strength", "Chest", "Barbell", "Intermediate", 4.5),
            ("Barbell Back Squat", "Compound lower body exercise targeting quadriceps, glutes, and hamstrings", "Strength", "Legs", "Barbell", "Intermediate", 4.7),
            ("Conventional Deadlift", "Full body compound movement targeting posterior chain", "Strength", "Back", "Barbell", "Advanced", 4.8),
            ("Pull-ups", "Upper body pulling exercise targeting lats and biceps", "Strength", "Back", "Body Weight", "Intermediate", 4.3),
            ("Overhead Press", "Vertical pressing movement targeting shoulders and triceps", "Strength", "Shoulders", "Barbell", "Intermediate", 4.2),
            ("Barbell Rows", "Horizontal pulling exercise targeting rhomboids and lats", "Strength", "Back", "Barbell", "Beginner", 4.1),
            ("Dumbbell Flyes", "Isolation exercise targeting chest muscles", "Strength", "Chest", "Dumbbell", "Beginner", 3.8),
            ("Leg Press", "Lower body pressing exercise", "Strength", "Legs", "Machine", "Beginner", 3.9),
            ("Lat Pulldowns", "Vertical pulling exercise targeting lats", "Strength", "Back", "Cable", "Beginner", 4.0),
            ("Dumbbell Shoulder Press", "Vertical pressing movement for shoulders", "Strength", "Shoulders", "Dumbbell", "Beginner", 4.1),
            ("Barbell Curls", "Isolation exercise for biceps", "Strength", "Arms", "Barbell", "Beginner", 3.5),
            ("Tricep Dips", "Bodyweight exercise targeting triceps", "Strength", "Arms", "Body Weight", "Intermediate", 3.7),
            ("Romanian Deadlift", "Hip hinge movement targeting hamstrings and glutes", "Strength", "Legs", "Barbell", "Intermediate", 4.4),
            ("Incline Dumbbell Press", "Upper chest focused pressing movement", "Strength", "Chest", "Dumbbell", "Intermediate", 4.0),
            ("Face Pulls", "Rear delt and rhomboid exercise", "Strength", "Shoulders", "Cable", "Beginner", 3.9),
            ("Leg Curls", "Isolation exercise for hamstrings", "Strength", "Legs", "Machine", "Beginner", 3.6),
            ("Calf Raises", "Isolation exercise for calves", "Strength", "Legs", "Machine", "Beginner", 3.4),
            ("Plank", "Core stability exercise", "Strength", "Abdominals", "Body Weight", "Beginner", 4.2),
            ("Russian Twists", "Rotational core exercise", "Strength", "Abdominals", "Body Weight", "Beginner", 3.8),
            ("Mountain Climbers", "Dynamic core and cardio exercise", "Cardio", "Abdominals", "Body Weight", "Intermediate", 4.0),
            ("Burpees", "Full body conditioning exercise", "Cardio", "Full Body", "Body Weight", "Advanced", 4.1),
            ("Jumping Jacks", "Cardiovascular warm-up exercise", "Cardio", "Full Body", "Body Weight", "Beginner", 3.5),
            ("High Knees", "Dynamic warm-up exercise", "Cardio", "Legs", "Body Weight", "Beginner", 3.3),
            ("Lunges", "Unilateral leg exercise", "Strength", "Legs", "Body Weight", "Beginner", 4.0),
            ("Push-ups", "Upper body bodyweight exercise", "Strength", "Chest", "Body Weight", "Beginner", 4.1)
        ]
        
        for (title, desc, type, bodyPart, equipment, level, rating) in sampleExerciseData {
            let exercise = Exercise(
                title: title,
                desc: desc,
                type: type,
                bodyPart: bodyPart,
                equipment: equipment,
                level: level,
                rating: rating,
                ratingDesc: rating >= 4.5 ? "Excellent" : rating >= 4.0 ? "Good" : rating >= 3.5 ? "Average" : "Fair"
            )
            exercises.append(exercise)
            modelContext.insert(exercise)
        }
        
        return exercises
    }
    
    private static func createSampleClients(modelContext: ModelContext) -> [Client] {
        var clients: [Client] = []
        
        // Client 1: Sarah Johnson - Weight Loss Goal
        let sarah = Client(
            firstName: "Sarah",
            lastName: "Johnson",
            email: "sarah.johnson@email.com",
            phone: "+1 (555) 123-4567",
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -32, to: Date())!,
            gender: .female,
            height: 165.0, // 5'5"
            currentWeight: 72.0, // 159 lbs
            targetWeight: 65.0, // 143 lbs
            primaryGoal: .weightLoss
        )
        
        // Fill in comprehensive data for Sarah
        sarah.secondaryGoals = [.generalFitness, .endurance]
        sarah.bodyFatPercentage = 28.5
        sarah.muscleMass = 22.3
        sarah.waterPercentage = 52.1
        sarah.boneMass = 2.4
        sarah.visceralFatLevel = 6
        sarah.metabolicAge = 35
        sarah.bmr = 1420
        
        sarah.chestCircumference = 89.0
        sarah.waistCircumference = 78.0
        sarah.hipsCircumference = 98.0
        sarah.thighsCircumference = 58.0
        sarah.armsCircumference = 28.0
        sarah.calvesCircumference = 36.0
        
        sarah.medicalConditions = ["Mild hypertension"]
        sarah.currentMedications = "Lisinopril 10mg daily"
        sarah.allergies = ["Shellfish", "Peanuts"]
        sarah.preferredTrainingDays = [1, 3, 5] // Mon, Wed, Fri
        
        sarah.activityLevel = .lightlyActive
        sarah.stressLevel = 7
        sarah.averageSleepHours = 6.5
        sarah.nutritionQuality = .fair
        sarah.smokingStatus = .never
        sarah.alcoholConsumption = .occasional
        sarah.subscriptionType = .monthly
        sarah.notes = "New to structured fitness. Prefers morning workouts. Has desk job."
        
        // Add emergency contact
        sarah.emergencyContact = EmergencyContact(
            name: "Michael Johnson",
            relationship: "Spouse",
            phone: "+1 (555) 123-4568",
            email: "michael.johnson@email.com"
        )
        
        // Add injury history
        sarah.injuryHistory = [
            Injury(type: "Lower back strain", severity: .mild, notes: "Occurred 6 months ago, fully recovered", isActive: false)
        ]
        
        // Add pain points
        sarah.painPoints = [
            PainPoint(location: "Lower back", painLevel: 3, frequency: .occasional, notes: "Mild discomfort after long sitting")
        ]
        
        // Add FitScore
        sarah.fitScore = FitScore(client: sarah)
        
        modelContext.insert(sarah)
        clients.append(sarah)
        
        // Client 2: Marcus Rodriguez - Muscle Gain Goal
        let marcus = Client(
            firstName: "Marcus",
            lastName: "Rodriguez",
            email: "marcus.rodriguez@email.com",
            phone: "+1 (555) 234-5678",
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -26, to: Date())!,
            gender: .male,
            height: 178.0, // 5'10"
            currentWeight: 75.0, // 165 lbs
            targetWeight: 82.0, // 181 lbs
            primaryGoal: .muscleGain
        )
        
        // Fill in comprehensive data for Marcus
        marcus.secondaryGoals = [.strengthGain, .athleticPerformance]
        marcus.bodyFatPercentage = 12.8
        marcus.muscleMass = 35.2
        marcus.waterPercentage = 58.7
        marcus.boneMass = 3.2
        marcus.visceralFatLevel = 3
        marcus.metabolicAge = 23
        marcus.bmr = 1850
        
        marcus.chestCircumference = 102.0
        marcus.waistCircumference = 81.0
        marcus.hipsCircumference = 95.0
        marcus.thighsCircumference = 61.0
        marcus.armsCircumference = 35.0
        marcus.calvesCircumference = 38.0
        
        marcus.medicalConditions = []
        marcus.currentMedications = ""
        marcus.allergies = []
        marcus.preferredTrainingDays = [1, 2, 4, 6] // Mon, Tue, Thu, Sat
        
        marcus.activityLevel = .veryActive
        marcus.stressLevel = 4
        marcus.averageSleepHours = 8.0
        marcus.nutritionQuality = .excellent
        marcus.smokingStatus = .never
        marcus.alcoholConsumption = .moderate
        marcus.subscriptionType = .quarterly
        marcus.notes = "Experienced lifter looking to add lean mass. Focuses on compound movements."
        
        // Add emergency contact
        marcus.emergencyContact = EmergencyContact(
            name: "Elena Rodriguez",
            relationship: "Mother",
            phone: "+1 (555) 234-5679",
            email: "elena.rodriguez@email.com"
        )
        
        // Add injury history
        marcus.injuryHistory = [
            Injury(type: "Right shoulder impingement", severity: .moderate, notes: "Resolved with physical therapy", isActive: false)
        ]
        
        // Add FitScore
        marcus.fitScore = FitScore(client: marcus)
        
        modelContext.insert(marcus)
        clients.append(marcus)
        
        // Client 3: Emma Chen - Athletic Performance Goal
        let emma = Client(
            firstName: "Emma",
            lastName: "Chen",
            email: "emma.chen@email.com",
            phone: "+1 (555) 345-6789",
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -29, to: Date())!,
            gender: .female,
            height: 170.0, // 5'7"
            currentWeight: 68.0, // 150 lbs
            targetWeight: 70.0, // 154 lbs
            primaryGoal: .athleticPerformance
        )
        
        // Fill in comprehensive data for Emma
        emma.secondaryGoals = [.strengthGain, .endurance]
        emma.bodyFatPercentage = 18.2
        emma.muscleMass = 28.9
        emma.waterPercentage = 56.3
        emma.boneMass = 2.8
        emma.visceralFatLevel = 2
        emma.metabolicAge = 25
        emma.bmr = 1620
        
        emma.chestCircumference = 86.0
        emma.waistCircumference = 71.0
        emma.hipsCircumference = 94.0
        emma.thighsCircumference = 55.0
        emma.armsCircumference = 26.0
        emma.calvesCircumference = 35.0
        
        emma.medicalConditions = ["Exercise-induced asthma"]
        emma.currentMedications = "Albuterol inhaler as needed"
        emma.allergies = ["Latex"]
        emma.preferredTrainingDays = [0, 2, 4, 6] // Sun, Tue, Thu, Sat
        
        emma.activityLevel = .extremelyActive
        emma.stressLevel = 6
        emma.averageSleepHours = 7.5
        emma.nutritionQuality = .good
        emma.smokingStatus = .never
        emma.alcoholConsumption = .none
        emma.subscriptionType = .annual
        emma.notes = "Competitive runner training for marathon. Needs sport-specific conditioning."
        
        // Add emergency contact
        emma.emergencyContact = EmergencyContact(
            name: "David Chen",
            relationship: "Brother",
            phone: "+1 (555) 345-6790",
            email: "david.chen@email.com"
        )
        
        // Add injury history
        emma.injuryHistory = [
            Injury(type: "IT band syndrome", severity: .moderate, notes: "Recurring issue, managed with stretching", isActive: true),
            Injury(type: "Ankle sprain", severity: .mild, notes: "Fully healed", isActive: false)
        ]
        
        // Add pain points
        emma.painPoints = [
            PainPoint(location: "Right IT band", painLevel: 4, frequency: .duringExercise, notes: "Tightness during long runs"),
            PainPoint(location: "Left knee", painLevel: 2, frequency: .afterExercise, notes: "Minor soreness after high mileage")
        ]
        
        // Add FitScore
        emma.fitScore = FitScore(client: emma)
        
        modelContext.insert(emma)
        clients.append(emma)
        
        return clients
    }
    
    private static func createSampleWorkouts(exercises: [Exercise], modelContext: ModelContext) -> [Workout] {
        var workouts: [Workout] = []
        
        // Helper function to find exercise by title
        func findExercise(_ title: String) -> Exercise? {
            return exercises.first { $0.title == title }
        }
        
        // Workout 1: Push Day (Chest, Shoulders, Triceps)
        let pushWorkout = Workout(
            name: "Push Day - Chest, Shoulders, Triceps",
            desc: "Upper body pushing movements targeting chest, shoulders, and triceps",
            category: "Strength Training",
            estimatedDuration: 75,
            tags: ["Push", "Upper Body", "Strength"]
        )
        
        var pushExercises: [WorkoutExercise] = []
        
        if let benchPress = findExercise("Barbell Bench Press") {
            let workoutExercise = WorkoutExercise(exercise: benchPress, orderIndex: 0)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 8, weight: 135, rest: 180),
                ExerciseSet(setNumber: 2, reps: 8, weight: 145, rest: 180),
                ExerciseSet(setNumber: 3, reps: 6, weight: 155, rest: 180),
                ExerciseSet(setNumber: 4, reps: 6, weight: 155, rest: 180)
            ]
            pushExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let inclinePress = findExercise("Incline Dumbbell Press") {
            let workoutExercise = WorkoutExercise(exercise: inclinePress, orderIndex: 1)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 10, weight: 60, rest: 120),
                ExerciseSet(setNumber: 2, reps: 10, weight: 65, rest: 120),
                ExerciseSet(setNumber: 3, reps: 8, weight: 70, rest: 120)
            ]
            pushExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let shoulderPress = findExercise("Overhead Press") {
            let workoutExercise = WorkoutExercise(exercise: shoulderPress, orderIndex: 2)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 8, weight: 95, rest: 120),
                ExerciseSet(setNumber: 2, reps: 8, weight: 105, rest: 120),
                ExerciseSet(setNumber: 3, reps: 6, weight: 115, rest: 120)
            ]
            pushExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let flyes = findExercise("Dumbbell Flyes") {
            let workoutExercise = WorkoutExercise(exercise: flyes, orderIndex: 3)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 12, weight: 25, rest: 90),
                ExerciseSet(setNumber: 2, reps: 12, weight: 30, rest: 90),
                ExerciseSet(setNumber: 3, reps: 10, weight: 35, rest: 90)
            ]
            pushExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let tricepDips = findExercise("Tricep Dips") {
            let workoutExercise = WorkoutExercise(exercise: tricepDips, orderIndex: 4)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 12, weight: 0, weightUnit: .bodyweight, rest: 60),
                ExerciseSet(setNumber: 2, reps: 10, weight: 0, weightUnit: .bodyweight, rest: 60),
                ExerciseSet(setNumber: 3, reps: 8, weight: 0, weightUnit: .bodyweight, rest: 60)
            ]
            pushExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        pushWorkout.exercises = pushExercises
        modelContext.insert(pushWorkout)
        workouts.append(pushWorkout)
        
        // Workout 2: Pull Day (Back, Biceps)
        let pullWorkout = Workout(
            name: "Pull Day - Back & Biceps",
            desc: "Upper body pulling movements targeting back and biceps",
            category: "Strength Training",
            estimatedDuration: 70,
            tags: ["Pull", "Upper Body", "Back", "Biceps"]
        )
        
        var pullExercises: [WorkoutExercise] = []
        
        if let deadlift = findExercise("Conventional Deadlift") {
            let workoutExercise = WorkoutExercise(exercise: deadlift, orderIndex: 0)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 5, weight: 185, rest: 240),
                ExerciseSet(setNumber: 2, reps: 5, weight: 205, rest: 240),
                ExerciseSet(setNumber: 3, reps: 3, weight: 225, rest: 240),
                ExerciseSet(setNumber: 4, reps: 1, weight: 245, rest: 240)
            ]
            pullExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let pullups = findExercise("Pull-ups") {
            let workoutExercise = WorkoutExercise(exercise: pullups, orderIndex: 1)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 8, weight: 0, weightUnit: .bodyweight, rest: 180),
                ExerciseSet(setNumber: 2, reps: 6, weight: 0, weightUnit: .bodyweight, rest: 180),
                ExerciseSet(setNumber: 3, reps: 5, weight: 0, weightUnit: .bodyweight, rest: 180)
            ]
            pullExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let rows = findExercise("Barbell Rows") {
            let workoutExercise = WorkoutExercise(exercise: rows, orderIndex: 2)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 10, weight: 135, rest: 120),
                ExerciseSet(setNumber: 2, reps: 8, weight: 155, rest: 120),
                ExerciseSet(setNumber: 3, reps: 6, weight: 175, rest: 120)
            ]
            pullExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let latPulldowns = findExercise("Lat Pulldowns") {
            let workoutExercise = WorkoutExercise(exercise: latPulldowns, orderIndex: 3)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 12, weight: 140, rest: 90),
                ExerciseSet(setNumber: 2, reps: 10, weight: 160, rest: 90),
                ExerciseSet(setNumber: 3, reps: 8, weight: 180, rest: 90)
            ]
            pullExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let curls = findExercise("Barbell Curls") {
            let workoutExercise = WorkoutExercise(exercise: curls, orderIndex: 4)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 12, weight: 65, rest: 60),
                ExerciseSet(setNumber: 2, reps: 10, weight: 75, rest: 60),
                ExerciseSet(setNumber: 3, reps: 8, weight: 85, rest: 60)
            ]
            pullExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let facePulls = findExercise("Face Pulls") {
            let workoutExercise = WorkoutExercise(exercise: facePulls, orderIndex: 5)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 15, weight: 60, rest: 60),
                ExerciseSet(setNumber: 2, reps: 15, weight: 70, rest: 60),
                ExerciseSet(setNumber: 3, reps: 12, weight: 80, rest: 60)
            ]
            pullExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        pullWorkout.exercises = pullExercises
        modelContext.insert(pullWorkout)
        workouts.append(pullWorkout)
        
        // Workout 3: Leg Day
        let legWorkout = Workout(
            name: "Leg Day - Quads, Glutes, Hamstrings",
            desc: "Lower body focused workout targeting all major leg muscles",
            category: "Strength Training",
            estimatedDuration: 80,
            tags: ["Legs", "Lower Body", "Quads", "Glutes", "Hamstrings"]
        )
        
        var legExercises: [WorkoutExercise] = []
        
        if let squat = findExercise("Barbell Back Squat") {
            let workoutExercise = WorkoutExercise(exercise: squat, orderIndex: 0)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 8, weight: 155, rest: 180),
                ExerciseSet(setNumber: 2, reps: 8, weight: 175, rest: 180),
                ExerciseSet(setNumber: 3, reps: 6, weight: 195, rest: 180),
                ExerciseSet(setNumber: 4, reps: 6, weight: 205, rest: 180)
            ]
            legExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let rdl = findExercise("Romanian Deadlift") {
            let workoutExercise = WorkoutExercise(exercise: rdl, orderIndex: 1)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 10, weight: 135, rest: 120),
                ExerciseSet(setNumber: 2, reps: 8, weight: 155, rest: 120),
                ExerciseSet(setNumber: 3, reps: 6, weight: 175, rest: 120)
            ]
            legExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let legPress = findExercise("Leg Press") {
            let workoutExercise = WorkoutExercise(exercise: legPress, orderIndex: 2)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 15, weight: 270, rest: 120),
                ExerciseSet(setNumber: 2, reps: 12, weight: 315, rest: 120),
                ExerciseSet(setNumber: 3, reps: 10, weight: 360, rest: 120)
            ]
            legExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let lunges = findExercise("Lunges") {
            let workoutExercise = WorkoutExercise(exercise: lunges, orderIndex: 3)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 12, weight: 0, weightUnit: .bodyweight, rest: 90),
                ExerciseSet(setNumber: 2, reps: 10, weight: 25, rest: 90),
                ExerciseSet(setNumber: 3, reps: 8, weight: 35, rest: 90)
            ]
            legExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let legCurls = findExercise("Leg Curls") {
            let workoutExercise = WorkoutExercise(exercise: legCurls, orderIndex: 4)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 15, weight: 80, rest: 60),
                ExerciseSet(setNumber: 2, reps: 12, weight: 95, rest: 60),
                ExerciseSet(setNumber: 3, reps: 10, weight: 110, rest: 60)
            ]
            legExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let calfRaises = findExercise("Calf Raises") {
            let workoutExercise = WorkoutExercise(exercise: calfRaises, orderIndex: 5)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 20, weight: 135, rest: 60),
                ExerciseSet(setNumber: 2, reps: 18, weight: 155, rest: 60),
                ExerciseSet(setNumber: 3, reps: 15, weight: 175, rest: 60)
            ]
            legExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        legWorkout.exercises = legExercises
        modelContext.insert(legWorkout)
        workouts.append(legWorkout)
        
        // Workout 4: Full Body HIIT with Superset
        let hiitWorkout = Workout(
            name: "Full Body HIIT Circuit",
            desc: "High intensity interval training with supersets for full body conditioning",
            category: "HIIT",
            estimatedDuration: 45,
            tags: ["HIIT", "Full Body", "Conditioning", "Superset", "Cardio"]
        )
        
        var hiitExercises: [WorkoutExercise] = []
        let supersetId = UUID() // Common superset ID for grouped exercises
        
        // Superset A1: Push-ups
        if let pushups = findExercise("Push-ups") {
            let workoutExercise = WorkoutExercise(exercise: pushups, supersetId: supersetId, orderIndex: 0)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 15, weight: 0, weightUnit: .bodyweight, rest: 30),
                ExerciseSet(setNumber: 2, reps: 12, weight: 0, weightUnit: .bodyweight, rest: 30),
                ExerciseSet(setNumber: 3, reps: 10, weight: 0, weightUnit: .bodyweight, rest: 30),
                ExerciseSet(setNumber: 4, reps: 8, weight: 0, weightUnit: .bodyweight, rest: 30)
            ]
            hiitExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        // Superset A2: Burpees (same superset ID)
        if let burpees = findExercise("Burpees") {
            let workoutExercise = WorkoutExercise(exercise: burpees, supersetId: supersetId, orderIndex: 1)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 10, weight: 0, weightUnit: .bodyweight, rest: 90),
                ExerciseSet(setNumber: 2, reps: 8, weight: 0, weightUnit: .bodyweight, rest: 90),
                ExerciseSet(setNumber: 3, reps: 6, weight: 0, weightUnit: .bodyweight, rest: 90),
                ExerciseSet(setNumber: 4, reps: 5, weight: 0, weightUnit: .bodyweight, rest: 90)
            ]
            hiitExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        // Single exercise: Mountain Climbers
        if let mountainClimbers = findExercise("Mountain Climbers") {
            let workoutExercise = WorkoutExercise(exercise: mountainClimbers, orderIndex: 2)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 30, weight: 0, weightUnit: .bodyweight, rest: 60),
                ExerciseSet(setNumber: 2, reps: 25, weight: 0, weightUnit: .bodyweight, rest: 60),
                ExerciseSet(setNumber: 3, reps: 20, weight: 0, weightUnit: .bodyweight, rest: 60)
            ]
            hiitExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        // Single exercise: Jumping Jacks
        if let jumpingJacks = findExercise("Jumping Jacks") {
            let workoutExercise = WorkoutExercise(exercise: jumpingJacks, orderIndex: 3)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 40, weight: 0, weightUnit: .bodyweight, rest: 45),
                ExerciseSet(setNumber: 2, reps: 35, weight: 0, weightUnit: .bodyweight, rest: 45),
                ExerciseSet(setNumber: 3, reps: 30, weight: 0, weightUnit: .bodyweight, rest: 45)
            ]
            hiitExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        // Single exercise: Plank
        if let plank = findExercise("Plank") {
            let workoutExercise = WorkoutExercise(exercise: plank, orderIndex: 4)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 45, weight: 0, weightUnit: .bodyweight, rest: 60), // 45 seconds
                ExerciseSet(setNumber: 2, reps: 60, weight: 0, weightUnit: .bodyweight, rest: 60), // 60 seconds
                ExerciseSet(setNumber: 3, reps: 30, weight: 0, weightUnit: .bodyweight, rest: 60)  // 30 seconds
            ]
            hiitExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        hiitWorkout.exercises = hiitExercises
        modelContext.insert(hiitWorkout)
        workouts.append(hiitWorkout)
        
        return workouts
    }
}