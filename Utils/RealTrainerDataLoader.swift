import Foundation
import SwiftData

struct RealTrainerDataLoader {
    static func loadRealTrainerData(modelContext: ModelContext) {
        // Check if real data already exists
        var clientDescriptor = FetchDescriptor<Client>()
        clientDescriptor.predicate = #Predicate<Client> { $0.trainerName == "Aaron" }
        let existingClients = try? modelContext.fetch(clientDescriptor)
        
        if existingClients?.isEmpty == false {
            print("Real trainer data already loaded")
            return
        }
        
        print("Loading real trainer data...")
        
        // Load exercises that match the trainer's exercise database
        let exercises = loadTrainerExercises(modelContext: modelContext)
        
        // Create real clients
        let lindsey = createLindseyClient(modelContext: modelContext)
        let alex = createPerfectClient(modelContext: modelContext)
        let sarah = createStrugglingClient(modelContext: modelContext)
        
        // Create comprehensive data for all clients
        createLindseyGoals(client: lindsey, modelContext: modelContext)
        createLindseyTrainerNotes(client: lindsey, modelContext: modelContext)
        createLindseyProgressMetrics(client: lindsey, modelContext: modelContext)
        
        createAlexData(client: alex, modelContext: modelContext)
        createSarahData(client: sarah, modelContext: modelContext)
        
        // Create realistic workouts based on trainer's exercise database
        let workouts = createTrainerWorkouts(exercises: exercises, modelContext: modelContext)
        
        // Create sample sessions for all clients
        createLindseySessions(client: lindsey, workouts: workouts, exercises: exercises, modelContext: modelContext)
        createAlexSessions(client: alex, workouts: workouts, exercises: exercises, modelContext: modelContext)
        createSarahSessions(client: sarah, workouts: workouts, exercises: exercises, modelContext: modelContext)
        
        // Update FitScores with real session data
        updateLindseyFitScore(client: lindsey)
        updateClientFitScore(client: alex)
        updateClientFitScore(client: sarah)
        
        // Save all data
        do {
            try modelContext.save()
            print("Real trainer data loaded successfully!")
        } catch {
            print("Failed to save real trainer data: \(error)")
        }
    }
    
    private static func loadTrainerExercises(modelContext: ModelContext) -> [Exercise] {
        var exercises: [Exercise] = []
        
        // Based on ExercisesTable.csv - real exercises used by the trainer
        let trainerExerciseData = [
            ("Back Squat", "Compound movement targeting quadriceps, glutes, and core stability", "Strength", "Legs", "Barbell", "Intermediate", 4.6),
            ("Calf Raise", "Isolation exercise for calf muscle development", "Strength", "Calves", "Body Weight", "Beginner", 3.8),
            ("Romanian Deadlift", "Hip hinge movement targeting hamstrings and glutes", "Strength", "Hamstrings", "Dumbbell", "Intermediate", 4.4),
            ("Single Leg RDL", "Unilateral hip hinge for balance and stability", "Strength", "Hamstrings", "Dumbbell", "Advanced", 4.2),
            ("Halo Press", "Combination shoulder and core exercise", "Strength", "Shoulders", "Kettlebell", "Intermediate", 3.9),
            ("Reverse Nordic Curl", "Eccentric quad strengthening exercise", "Strength", "Hamstrings", "Body Weight", "Advanced", 4.1),
            ("Push-up", "Classic bodyweight upper body exercise", "Strength", "Chest", "Body Weight", "Beginner", 4.3),
            ("Superman", "Posterior chain activation exercise", "Strength", "Back", "Body Weight", "Beginner", 3.7),
            ("Kettlebell Swing", "Power development and conditioning", "Power", "Full Body", "Kettlebell", "Intermediate", 4.5),
            ("Bench Dip", "Tricep isolation using bench", "Strength", "Triceps", "Bench", "Beginner", 3.6),
            ("Plank", "Core stability and endurance", "Strength", "Abdominals", "Body Weight", "Beginner", 4.2),
            ("Penguin Reach", "Core stability with rotation", "Strength", "Abdominals", "Body Weight", "Beginner", 3.8),
            ("Good Morning", "Hip hinge pattern for posterior chain", "Strength", "Hamstrings", "Barbell", "Intermediate", 4.0),
            ("TRX Reverse Nordic Curl", "Suspension trainer quad exercise", "Strength", "Hamstrings", "TRX", "Advanced", 4.1),
            ("Bird Dog", "Core stability and coordination", "Strength", "Abdominals", "Body Weight", "Beginner", 4.0),
            ("Lateral Step Down", "Unilateral leg strength and control", "Strength", "Legs", "Body Weight", "Intermediate", 3.9),
            ("Hammer Curl", "Bicep and forearm development", "Strength", "Arms", "Dumbbell", "Beginner", 3.5),
            ("Hip Thrust", "Glute activation and strength", "Strength", "Glutes", "Barbell", "Intermediate", 4.4),
            ("Glute Bridge", "Basic glute activation", "Strength", "Glutes", "Body Weight", "Beginner", 4.1),
            ("Seated Calf Raise", "Isolation calf exercise", "Strength", "Calves", "Machine", "Beginner", 3.7),
            ("Sumo Squat", "Wide stance squat variation", "Strength", "Legs", "Barbell", "Intermediate", 4.2),
            ("Deadlift", "Full body compound movement", "Strength", "Full Body", "Barbell", "Advanced", 4.8),
            ("Walking Lunge", "Dynamic unilateral leg exercise", "Strength", "Legs", "Dumbbell", "Intermediate", 4.1),
            ("Ball Slam", "Power and conditioning exercise", "Power", "Full Body", "Medicine Ball", "Intermediate", 4.0),
            ("Wall Ball", "Full body power exercise", "Power", "Full Body", "Medicine Ball", "Intermediate", 4.2),
            ("Russian Twist", "Rotational core exercise", "Strength", "Abdominals", "Weight", "Beginner", 3.8),
            ("Inverted Row", "Horizontal pulling exercise", "Strength", "Back", "Barbell", "Intermediate", 4.1),
            ("Band Tricep Extension", "Isolation tricep exercise", "Strength", "Arms", "Bands", "Beginner", 3.6),
            ("Band Lateral Leg Raise", "Hip abduction with resistance", "Strength", "Glutes", "Bands", "Beginner", 3.7),
            ("Bulgarian Split Squat", "Unilateral quad-dominant exercise", "Strength", "Legs", "Dumbbell", "Intermediate", 4.3),
            ("Pullover", "Lat and serratus isolation", "Strength", "Back", "Dumbbell", "Intermediate", 3.9),
            ("Farmer Carry", "Functional carrying exercise", "Strength", "Full Body", "Dumbbell", "Intermediate", 4.2),
            ("Pistol Squat", "Advanced single leg squat", "Strength", "Legs", "TRX", "Advanced", 4.4),
            ("Lying Leg Curl", "Hamstring isolation", "Strength", "Hamstrings", "Machine", "Beginner", 3.8),
            ("Donkey Kick", "Glute isolation exercise", "Strength", "Glutes", "Bands", "Beginner", 3.5),
            ("Clamshell", "Hip external rotation", "Strength", "Glutes", "Bands", "Beginner", 3.6),
            ("Wall Sit", "Isometric quad exercise", "Strength", "Legs", "Body Weight", "Beginner", 3.7),
            ("Mountain Climber", "Dynamic core and cardio", "Cardio", "Abdominals", "Body Weight", "Intermediate", 4.0),
            ("Chest Pass", "Power development for chest", "Power", "Chest", "Medicine Ball", "Intermediate", 3.8),
            ("Arnold Press", "Compound shoulder exercise", "Strength", "Shoulders", "Dumbbell", "Intermediate", 4.1),
            ("Rowing Machine", "Cardiovascular endurance", "Cardio", "Full Body", "Machine", "Beginner", 4.3),
            ("Ski Erg", "Upper body cardiovascular", "Cardio", "Full Body", "Machine", "Intermediate", 4.2)
        ]
        
        for (title, desc, type, bodyPart, equipment, level, rating) in trainerExerciseData {
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
    
    private static func createLindseyClient(modelContext: ModelContext) -> Client {
        let lindsey = Client(
            firstName: "Lindsey",
            lastName: "M",
            email: "lindsey.m@email.com",
            phone: "+1 (555) 987-6543",
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -34, to: Date())!,
            gender: .female,
            height: 168.0, // 5'6"
            currentWeight: 70.0, // 154 lbs
            targetWeight: 68.0, // 150 lbs
            primaryGoal: .strengthGain
        )
        
        // Real trainer data insights
        lindsey.trainerName = "Aaron"
        lindsey.secondaryGoals = [.generalFitness, .endurance]
        lindsey.notes = "Focus areas: Balance issues on left side, grip strength needs improvement, form corrections needed on various exercises. Progressing well overall."
        lindsey.isActive = true
        lindsey.startDate = Calendar.current.date(byAdding: .month, value: -9, to: Date())!
        
        // Realistic body composition for someone working with trainer
        lindsey.bodyFatPercentage = 24.5
        lindsey.muscleMass = 24.8
        lindsey.waterPercentage = 54.2
        lindsey.boneMass = 2.6
        lindsey.visceralFatLevel = 4
        lindsey.metabolicAge = 32
        lindsey.bmr = 1520
        
        // Circumference measurements
        lindsey.chestCircumference = 91.0
        lindsey.waistCircumference = 76.0
        lindsey.hipsCircumference = 96.0
        lindsey.thighsCircumference = 57.0
        lindsey.armsCircumference = 27.0
        lindsey.calvesCircumference = 36.0
        
        lindsey.medicalConditions = []
        lindsey.currentMedications = ""
        lindsey.allergies = []
        lindsey.preferredTrainingDays = [1, 3, 5] // Mon, Wed, Fri
        
        lindsey.activityLevel = .moderatelyActive
        lindsey.stressLevel = 5
        lindsey.averageSleepHours = 7.0
        lindsey.nutritionQuality = .good
        lindsey.smokingStatus = .never
        lindsey.alcoholConsumption = .occasional
        lindsey.subscriptionType = .monthly
        
        // Add emergency contact
        lindsey.emergencyContact = EmergencyContact(
            name: "John M",
            relationship: "Spouse",
            phone: "+1 (555) 987-6544"
        )
        
        // Add realistic injury/pain based on trainer notes
        lindsey.painPoints = [
            PainPoint(location: "Left side balance", painLevel: 4, frequency: .duringExercise, notes: "Noticeable during single leg work"),
            PainPoint(location: "Lower back", painLevel: 3, frequency: .occasional, notes: "Occasionally sore from daily activities")
        ]
        
        // Add FitScore and update it with session data
        lindsey.fitScore = FitScore(client: lindsey)
        
        modelContext.insert(lindsey)
        return lindsey
    }
    
    private static func updateLindseyFitScore(client: Client) {
        // Update FitScore after all sessions are created
        if let fitScore = client.fitScore {
            fitScore.updateFromSessions(client.sessions)
            fitScore.updateFromMeasurements(client: client)
        }
    }
    
    private static func createLindseyGoals(client: Client, modelContext: ModelContext) {
        // Based on Client_GoalsTable.csv
        let goals = [
            ClientGoal(goalType: .strength, description: "Improve grip strength for deadlifts", targetValue: 135, targetDate: Calendar.current.date(byAdding: .month, value: 3, to: Date())),
            ClientGoal(goalType: .balance, description: "Correct left side balance issues", targetValue: 100, targetDate: Calendar.current.date(byAdding: .month, value: 2, to: Date())),
            ClientGoal(goalType: .form, description: "Master pistol squat form", targetValue: 1, targetDate: Calendar.current.date(byAdding: .month, value: 4, to: Date())),
            ClientGoal(goalType: .endurance, description: "2-minute plank hold", targetValue: 120, targetDate: Calendar.current.date(byAdding: .month, value: 3, to: Date())),
            ClientGoal(goalType: .flexibility, description: "Improve adductor flexibility", targetDate: Calendar.current.date(byAdding: .month, value: 2, to: Date()))
        ]
        
        for goal in goals {
            goal.status = .inProgress
            goal.createdDate = Calendar.current.date(byAdding: .month, value: -2, to: Date())!
            client.clientGoals.append(goal)
            modelContext.insert(goal)
        }
    }
    
    private static func createLindseyTrainerNotes(client: Client, modelContext: ModelContext) {
        // Based on Trainer_NotesTable.csv
        let notes = [
            TrainerNote(noteType: .form, text: "Left side balance issues during single leg work", sessionId: "S001"),
            TrainerNote(noteType: .modification, text: "Switched from KB swings to reverse lunges due to hip issues", sessionId: "S003"),
            TrainerNote(noteType: .performance, text: "Grip strength limiting factor on deadlifts", sessionId: "S004"),
            TrainerNote(noteType: .medical, text: "Lower back sore from carrying kid - modified workout", sessionId: "S008"),
            TrainerNote(noteType: .program, text: "Need to add bounce exercises for adductors", sessionId: "S009"),
            TrainerNote(noteType: .equipment, text: "Needs gloves for better grip on bar", sessionId: "S014"),
            TrainerNote(noteType: .medical, text: "Right knee pain - continuing with modifications", sessionId: "S017"),
            TrainerNote(noteType: .technique, text: "In her head about form - breaking down movements", sessionId: "S021"),
            TrainerNote(noteType: .progress, text: "Strength weak but tried to go fast - regrouped with sets of 3", sessionId: "S021")
        ]
        
        for note in notes {
            note.createdDate = Calendar.current.date(byAdding: .day, value: -Int.random(in: 30...180), to: Date())!
            client.trainerNotes.append(note)
            modelContext.insert(note)
        }
    }
    
    private static func createLindseyProgressMetrics(client: Client, modelContext: ModelContext) {
        // Based on Progress_MetricsTable.csv
        let metrics = [
            ProgressMetric(metricType: .plankHold, value: 84, unit: "seconds", notes: "Good form maintained", sessionId: "S001"),
            ProgressMetric(metricType: .rowDistance, value: 325, unit: "meters", notes: "Average pace", sessionId: "S006"),
            ProgressMetric(metricType: .rowTime, value: 130, unit: "seconds", notes: "2:10 for 700m", sessionId: "S006"),
            ProgressMetric(metricType: .rowTime, value: 189, unit: "seconds", notes: "3:09 for 925m", sessionId: "S006"),
            ProgressMetric(metricType: .maxDeadlift, value: 115, unit: "lb", notes: "Grip failed before legs", sessionId: "S004"),
            ProgressMetric(metricType: .balanceAssessment, value: 60, unit: "percent", notes: "Better on right side", sessionId: "S009"),
            ProgressMetric(metricType: .plankHold, value: 92, unit: "seconds", notes: "1:32", sessionId: "S011"),
            ProgressMetric(metricType: .plankHold, value: 98, unit: "seconds", notes: "1:38 heavy", sessionId: "S011"),
            ProgressMetric(metricType: .skiDistance, value: 250, unit: "meters", notes: "1:30 time", sessionId: "S011")
        ]
        
        for metric in metrics {
            metric.recordedDate = Calendar.current.date(byAdding: .day, value: -Int.random(in: 30...180), to: Date())!
            client.progressMetrics.append(metric)
            modelContext.insert(metric)
        }
    }
    
    private static func createTrainerWorkouts(exercises: [Exercise], modelContext: ModelContext) -> [Workout] {
        var workouts: [Workout] = []
        
        // Helper function to find exercise by title
        func findExercise(_ title: String) -> Exercise? {
            return exercises.first { $0.title == title }
        }
        
        // Workout 1: Balance & Strength Focus (based on Lindsey's needs)
        let balanceWorkout = Workout(
            name: "Balance & Strength Focus",
            desc: "Workout targeting left side balance issues and grip strength",
            category: "Functional Training",
            estimatedDuration: 60,
            tags: ["Balance", "Strength", "Unilateral"]
        )
        
        var balanceExercises: [WorkoutExercise] = []
        
        if let backSquat = findExercise("Back Squat") {
            let workoutExercise = WorkoutExercise(exercise: backSquat, orderIndex: 0)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 10, weight: 75, rest: 180),
                ExerciseSet(setNumber: 2, reps: 12, weight: 75, rest: 180),
                ExerciseSet(setNumber: 3, reps: 12, weight: 75, rest: 180)
            ]
            balanceExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let singleLegRDL = findExercise("Single Leg RDL") {
            let workoutExercise = WorkoutExercise(exercise: singleLegRDL, orderIndex: 1)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 10, weight: 25, rest: 120),
                ExerciseSet(setNumber: 2, reps: 10, weight: 25, rest: 120),
                ExerciseSet(setNumber: 3, reps: 10, weight: 25, rest: 120)
            ]
            balanceExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let haloPress = findExercise("Halo Press") {
            let workoutExercise = WorkoutExercise(exercise: haloPress, orderIndex: 2)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 12, weight: 15, rest: 90),
                ExerciseSet(setNumber: 2, reps: 12, weight: 15, rest: 90),
                ExerciseSet(setNumber: 3, reps: 12, weight: 15, rest: 90)
            ]
            balanceExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let reverseNordic = findExercise("Reverse Nordic Curl") {
            let workoutExercise = WorkoutExercise(exercise: reverseNordic, orderIndex: 3)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 8, weight: 0, weightUnit: .bodyweight, rest: 120),
                ExerciseSet(setNumber: 2, reps: 12, weight: 0, weightUnit: .bodyweight, rest: 120),
                ExerciseSet(setNumber: 3, reps: 10, weight: 0, weightUnit: .bodyweight, rest: 120)
            ]
            balanceExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let plank = findExercise("Plank") {
            let workoutExercise = WorkoutExercise(exercise: plank, orderIndex: 4)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 84, weight: 0, weightUnit: .bodyweight, rest: 60) // 84 seconds based on real data
            ]
            balanceExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        balanceWorkout.exercises = balanceExercises
        modelContext.insert(balanceWorkout)
        workouts.append(balanceWorkout)
        
        // Workout 2: Power & Conditioning (based on session notes)
        let powerWorkout = Workout(
            name: "Power & Conditioning",
            desc: "High intensity workout with kettlebell swings and power movements",
            category: "Power Training",
            estimatedDuration: 45,
            tags: ["Power", "Conditioning", "Kettlebell"]
        )
        
        var powerExercises: [WorkoutExercise] = []
        
        if let kbSwings = findExercise("Kettlebell Swing") {
            let workoutExercise = WorkoutExercise(exercise: kbSwings, orderIndex: 0)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 12, weight: 35, rest: 120),
                ExerciseSet(setNumber: 2, reps: 10, weight: 35, rest: 120),
                ExerciseSet(setNumber: 3, reps: 12, weight: 35, rest: 120)
            ]
            powerExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let wallBall = findExercise("Wall Ball") {
            let workoutExercise = WorkoutExercise(exercise: wallBall, orderIndex: 1)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 15, weight: 14, rest: 90),
                ExerciseSet(setNumber: 2, reps: 12, weight: 14, rest: 90),
                ExerciseSet(setNumber: 3, reps: 10, weight: 14, rest: 90)
            ]
            powerExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let ballSlam = findExercise("Ball Slam") {
            let workoutExercise = WorkoutExercise(exercise: ballSlam, orderIndex: 2)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 20, weight: 12, rest: 60),
                ExerciseSet(setNumber: 2, reps: 15, weight: 12, rest: 60),
                ExerciseSet(setNumber: 3, reps: 12, weight: 12, rest: 60)
            ]
            powerExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let russianTwist = findExercise("Russian Twist") {
            let workoutExercise = WorkoutExercise(exercise: russianTwist, orderIndex: 3)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 30, weight: 10, rest: 45),
                ExerciseSet(setNumber: 2, reps: 25, weight: 10, rest: 45),
                ExerciseSet(setNumber: 3, reps: 20, weight: 10, rest: 45)
            ]
            powerExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        powerWorkout.exercises = powerExercises
        modelContext.insert(powerWorkout)
        workouts.append(powerWorkout)
        
        // Workout 3: Grip Strength & Deadlift Focus
        let gripWorkout = Workout(
            name: "Grip Strength & Deadlift Focus",
            desc: "Workout focusing on improving grip strength and deadlift performance",
            category: "Strength Training",
            estimatedDuration: 55,
            tags: ["Grip", "Deadlift", "Strength"]
        )
        
        var gripExercises: [WorkoutExercise] = []
        
        if let deadlift = findExercise("Deadlift") {
            let workoutExercise = WorkoutExercise(exercise: deadlift, orderIndex: 0)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 5, weight: 95, rest: 180),
                ExerciseSet(setNumber: 2, reps: 3, weight: 105, rest: 180),
                ExerciseSet(setNumber: 3, reps: 1, weight: 115, rest: 180) // Max effort based on real data
            ]
            gripExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let romanianDL = findExercise("Romanian Deadlift") {
            let workoutExercise = WorkoutExercise(exercise: romanianDL, orderIndex: 1)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 10, weight: 30, rest: 120),
                ExerciseSet(setNumber: 2, reps: 8, weight: 35, rest: 120),
                ExerciseSet(setNumber: 3, reps: 6, weight: 40, rest: 120)
            ]
            gripExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let farmerCarry = findExercise("Farmer Carry") {
            let workoutExercise = WorkoutExercise(exercise: farmerCarry, orderIndex: 2)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 40, weight: 35, rest: 120), // 40 steps
                ExerciseSet(setNumber: 2, reps: 30, weight: 40, rest: 120),
                ExerciseSet(setNumber: 3, reps: 20, weight: 45, rest: 120)
            ]
            gripExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        if let invRow = findExercise("Inverted Row") {
            let workoutExercise = WorkoutExercise(exercise: invRow, orderIndex: 3)
            workoutExercise.sets = [
                ExerciseSet(setNumber: 1, reps: 12, weight: 0, weightUnit: .bodyweight, rest: 90),
                ExerciseSet(setNumber: 2, reps: 10, weight: 0, weightUnit: .bodyweight, rest: 90),
                ExerciseSet(setNumber: 3, reps: 8, weight: 0, weightUnit: .bodyweight, rest: 90)
            ]
            gripExercises.append(workoutExercise)
            modelContext.insert(workoutExercise)
        }
        
        gripWorkout.exercises = gripExercises
        modelContext.insert(gripWorkout)
        workouts.append(gripWorkout)
        
        return workouts
    }
    
    private static func createLindseySessions(client: Client, workouts: [Workout], exercises: [Exercise], modelContext: ModelContext) {
        // Create a few sample sessions based on real session data
        let sessionData = [
            ("2024-11-25", "Full Body", balanceWorkoutIndex: 0, "Great session - 90% improvement. Balance issues on left side during RDL", 0),
            ("2024-12-18", "Full Body", balanceWorkoutIndex: 2, "Grip failed before legs on deadlifts", 0),
            ("2025-01-07", "Recovery", balanceWorkoutIndex: 1, "Sore lower back from carrying kid", 15)
        ]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        for (dateStr, sessionTypeStr, workoutIndex, notes, lateMinutes) in sessionData {
            guard let sessionDate = dateFormatter.date(from: dateStr),
                  workoutIndex < workouts.count else { continue }
            
            let session = Session(client: client, workout: workouts[workoutIndex], date: sessionDate)
            session.sessionType = Session.SessionType(rawValue: sessionTypeStr)
            session.trainerNotes = notes
            session.lateMinutes = lateMinutes > 0 ? lateMinutes : nil
            session.status = .completed
            session.duration = 3600 // 60 minutes
            
            // Add some realistic session metrics
            session.sessionRPE = Int.random(in: 6...8)
            session.techniqueQuality = Int.random(in: 7...9)
            
            // Initialize completed exercises from workout
            session.completedExercises = session.workout.exercises.map { workoutExercise in
                let completedExercise = CompletedExercise(exercise: workoutExercise.exercise)
                
                // Create completed sets with realistic form notes based on trainer data
                completedExercise.sets = workoutExercise.sets.enumerated().map { index, exerciseSet in
                    let completedSet = CompletedSet(
                        setNumber: index + 1,
                        targetReps: exerciseSet.reps,
                        targetWeight: exerciseSet.weight,
                        weightUnit: exerciseSet.weightUnit
                    )
                    
                    // Add realistic form notes based on exercise and Lindsey's issues
                    if workoutExercise.exercise.title == "Single Leg RDL" {
                        completedSet.formNotes = index == 0 ? "Left side balance issues" : 
                                                 index == 1 ? "Getting better" : "90% better by 3rd set"
                    } else if workoutExercise.exercise.title == "Push-up" {
                        completedSet.equipmentNotes = "Knee push-ups"
                    } else if workoutExercise.exercise.title == "Kettlebell Swing" {
                        completedSet.formNotes = "Perfect form upright?"
                    } else if workoutExercise.exercise.title == "Deadlift" && workoutIndex == 2 {
                        completedSet.formNotes = "Grip failed before legs"
                    }
                    
                    return completedSet
                }
                
                completedExercise.supersetId = workoutExercise.supersetId
                completedExercise.wasCompleted = true
                
                return completedExercise
            }
            
            // Update calculated values after setting up all exercises
            session.updateCalculatedValues()
            
            client.sessions.append(session)
            modelContext.insert(session)
        }
    }
    
    // MARK: - Perfect Client (Alex)
    
    private static func createPerfectClient(modelContext: ModelContext) -> Client {
        let alex = Client(
            firstName: "Alex",
            lastName: "Thompson",
            email: "alex.thompson@email.com",
            phone: "+1 (555) 123-9876",
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -28, to: Date())!,
            gender: .male,
            height: 185.0, // 6'1"
            currentWeight: 82.0, // 181 lbs (started at 88kg)
            targetWeight: 80.0, // 176 lbs
            primaryGoal: .athleticPerformance
        )
        
        // Perfect client characteristics
        alex.trainerName = "Aaron"
        alex.secondaryGoals = [.strengthGain, .muscleGain, .endurance]
        alex.notes = "Exceptional client. Highly motivated, consistent attendance, excellent form progression. Professional athlete mindset."
        alex.isActive = true
        alex.startDate = Calendar.current.date(byAdding: .month, value: -8, to: Date())!
        
        // Elite body composition metrics
        alex.bodyFatPercentage = 8.5
        alex.muscleMass = 38.2
        alex.waterPercentage = 62.1
        alex.boneMass = 3.4
        alex.visceralFatLevel = 1
        alex.metabolicAge = 22
        alex.bmr = 2100
        
        // Excellent circumference measurements showing progression
        alex.chestCircumference = 107.0
        alex.waistCircumference = 78.0
        alex.hipsCircumference = 98.0
        alex.thighsCircumference = 64.0
        alex.armsCircumference = 38.0
        alex.calvesCircumference = 40.0
        
        alex.medicalConditions = []
        alex.currentMedications = ""
        alex.allergies = []
        alex.preferredTrainingDays = [1, 2, 4, 5, 6] // 5 days/week
        
        alex.activityLevel = .extremelyActive
        alex.stressLevel = 3
        alex.averageSleepHours = 8.5
        alex.nutritionQuality = .excellent
        alex.smokingStatus = .never
        alex.alcoholConsumption = .none
        alex.subscriptionType = .annual
        
        // Emergency contact
        alex.emergencyContact = EmergencyContact(
            name: "Jessica Thompson",
            relationship: "Spouse",
            phone: "+1 (555) 123-9877",
            email: "jessica.thompson@email.com"
        )
        
        // No significant injuries or pain points
        alex.injuryHistory = []
        alex.painPoints = []
        
        // Multiple body measurements showing improvement
        let measurements = [
            (Calendar.current.date(byAdding: .month, value: -8, to: Date())!, 88.0, 12.0), // Starting
            (Calendar.current.date(byAdding: .month, value: -6, to: Date())!, 86.0, 10.5),
            (Calendar.current.date(byAdding: .month, value: -4, to: Date())!, 84.0, 9.2),
            (Calendar.current.date(byAdding: .month, value: -2, to: Date())!, 82.5, 8.8),
            (Date(), 82.0, 8.5) // Current
        ]
        
        for (date, weight, bodyFat) in measurements {
            let measurement = BodyMeasurement(date: date, weight: weight)
            measurement.bodyFatPercentage = bodyFat
            alex.measurements.append(measurement)
            modelContext.insert(measurement)
        }
        
        // FitScore
        alex.fitScore = FitScore(client: alex)
        
        modelContext.insert(alex)
        return alex
    }
    
    private static func createAlexData(client: Client, modelContext: ModelContext) {
        // Elite goals
        let goals = [
            ClientGoal(goalType: .strength, description: "Bench press 2x bodyweight (160kg)", targetValue: 160, targetDate: Calendar.current.date(byAdding: .month, value: 2, to: Date())),
            ClientGoal(goalType: .endurance, description: "Sub-6 minute mile", targetValue: 360, targetDate: Calendar.current.date(byAdding: .month, value: 3, to: Date())),
            ClientGoal(goalType: .strength, description: "Reach 8% body fat", targetValue: 8, targetDate: Calendar.current.date(byAdding: .month, value: 1, to: Date())),
            ClientGoal(goalType: .endurance, description: "Complete half marathon under 1:30", targetValue: 90, targetDate: Calendar.current.date(byAdding: .month, value: 4, to: Date())),
            ClientGoal(goalType: .coordination, description: "Master Olympic lifts", targetValue: 100, targetDate: Calendar.current.date(byAdding: .month, value: 6, to: Date()))
        ]
        
        for goal in goals {
            goal.status = .inProgress
            goal.createdDate = Calendar.current.date(byAdding: .month, value: -6, to: Date())!
            client.clientGoals.append(goal)
            modelContext.insert(goal)
        }
        
        // Excellent trainer notes
        let notes = [
            TrainerNote(noteType: .progress, text: "Incredible progress - increased bench from 100kg to 145kg in 6 months", sessionId: "AX001"),
            TrainerNote(noteType: .technique, text: "Perfect squat form achieved - textbook execution", sessionId: "AX003"),
            TrainerNote(noteType: .program, text: "Ready for advanced periodization program", sessionId: "AX005"),
            TrainerNote(noteType: .performance, text: "Hit new deadlift PR - 200kg with excellent form", sessionId: "AX008"),
            TrainerNote(noteType: .behavioral, text: "Extremely coachable, asks excellent questions", sessionId: "AX010"),
            TrainerNote(noteType: .progress, text: "Lost 6kg while gaining significant strength", sessionId: "AX012")
        ]
        
        for note in notes {
            note.createdDate = Calendar.current.date(byAdding: .day, value: -Int.random(in: 30...180), to: Date())!
            client.trainerNotes.append(note)
            modelContext.insert(note)
        }
        
        // Outstanding progress metrics
        let metrics = [
            ProgressMetric(metricType: .maxBench, value: 145, unit: "kg", notes: "New PR! Perfect form", sessionId: "AX008"),
            ProgressMetric(metricType: .maxSquat, value: 170, unit: "kg", notes: "Depth and control excellent", sessionId: "AX010"),
            ProgressMetric(metricType: .maxDeadlift, value: 200, unit: "kg", notes: "Smooth lockout", sessionId: "AX012"),
            ProgressMetric(metricType: .plankHold, value: 300, unit: "seconds", notes: "5 minute hold achieved", sessionId: "AX005"),
            ProgressMetric(metricType: .vo2Max, value: 55, unit: "ml/kg/min", notes: "Elite level cardio", sessionId: "AX007"),
            ProgressMetric(metricType: .bodyWeight, value: 82, unit: "kg", notes: "Target weight achieved", sessionId: "AX012"),
            ProgressMetric(metricType: .bodyFat, value: 8.5, unit: "percent", notes: "Excellent body composition", sessionId: "AX012")
        ]
        
        for metric in metrics {
            metric.recordedDate = Calendar.current.date(byAdding: .day, value: -Int.random(in: 30...180), to: Date())!
            client.progressMetrics.append(metric)
            modelContext.insert(metric)
        }
    }
    
    // MARK: - Struggling Client (Sarah)
    
    private static func createStrugglingClient(modelContext: ModelContext) -> Client {
        let sarah = Client(
            firstName: "Sarah",
            lastName: "Mitchell",
            email: "sarah.mitchell@email.com",
            phone: "+1 (555) 456-7890",
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -42, to: Date())!,
            gender: .female,
            height: 162.0, // 5'4"
            currentWeight: 78.0, // 172 lbs (started at 75kg)
            targetWeight: 65.0, // 143 lbs
            primaryGoal: .weightLoss
        )
        
        // Struggling client characteristics
        sarah.trainerName = "Aaron"
        sarah.secondaryGoals = [.generalFitness]
        sarah.notes = "Struggles with consistency. Stress eating issues. Work-life balance challenges affecting training frequency."
        sarah.isActive = true
        sarah.startDate = Calendar.current.date(byAdding: .month, value: -10, to: Date())!
        
        // Poor body composition metrics
        sarah.bodyFatPercentage = 35.2
        sarah.muscleMass = 18.5
        sarah.waterPercentage = 48.9
        sarah.boneMass = 2.1
        sarah.visceralFatLevel = 9
        sarah.metabolicAge = 48
        sarah.bmr = 1280
        
        // Measurements showing plateau/decline
        sarah.chestCircumference = 98.0
        sarah.waistCircumference = 88.0
        sarah.hipsCircumference = 105.0
        sarah.thighsCircumference = 65.0
        sarah.armsCircumference = 32.0
        sarah.calvesCircumference = 38.0
        
        sarah.medicalConditions = ["Type 2 diabetes", "High blood pressure", "Sleep apnea"]
        sarah.currentMedications = "Metformin 500mg, Lisinopril 10mg"
        sarah.allergies = ["Latex", "Shellfish"]
        sarah.preferredTrainingDays = [1, 3, 5] // Plans 3 days but often misses
        
        sarah.activityLevel = .sedentary
        sarah.stressLevel = 8
        sarah.averageSleepHours = 5.5
        sarah.nutritionQuality = .poor
        sarah.smokingStatus = .former
        sarah.alcoholConsumption = .moderate
        sarah.subscriptionType = .monthly
        
        // Emergency contact
        sarah.emergencyContact = EmergencyContact(
            name: "David Mitchell",
            relationship: "Spouse",
            phone: "+1 (555) 456-7891"
        )
        
        // Multiple injuries and pain points
        sarah.injuryHistory = [
            Injury(type: "Lower back strain", severity: .moderate, notes: "Recurring issue from poor posture", isActive: true),
            Injury(type: "Right knee pain", severity: .mild, notes: "Old sports injury flares up", isActive: true)
        ]
        
        sarah.painPoints = [
            PainPoint(location: "Lower back", painLevel: 6, frequency: .frequent, notes: "Worsens with stress"),
            PainPoint(location: "Right knee", painLevel: 4, frequency: .occasional, notes: "Worse in cold weather"),
            PainPoint(location: "Neck and shoulders", painLevel: 5, frequency: .constant, notes: "Desk job posture issues")
        ]
        
        // Body measurements showing weight gain over time
        let measurements = [
            (Calendar.current.date(byAdding: .month, value: -10, to: Date())!, 75.0, 32.0), // Starting
            (Calendar.current.date(byAdding: .month, value: -8, to: Date())!, 74.0, 31.5), // Initial improvement
            (Calendar.current.date(byAdding: .month, value: -6, to: Date())!, 76.0, 33.0), // Started gaining
            (Calendar.current.date(byAdding: .month, value: -4, to: Date())!, 77.0, 34.0), // Continued gain
            (Calendar.current.date(byAdding: .month, value: -2, to: Date())!, 78.0, 35.0), // Peak weight
            (Date(), 78.0, 35.2) // Current - no improvement
        ]
        
        for (date, weight, bodyFat) in measurements {
            let measurement = BodyMeasurement(date: date, weight: weight)
            measurement.bodyFatPercentage = bodyFat
            sarah.measurements.append(measurement)
            modelContext.insert(measurement)
        }
        
        // FitScore
        sarah.fitScore = FitScore(client: sarah)
        
        modelContext.insert(sarah)
        return sarah
    }
    
    private static func createSarahData(client: Client, modelContext: ModelContext) {
        // Modest goals with mixed progress
        let goals = [
            ClientGoal(goalType: .weightLoss, description: "Lose 10kg safely", targetValue: 68, targetDate: Calendar.current.date(byAdding: .month, value: 6, to: Date())),
            ClientGoal(goalType: .endurance, description: "Walk 30 minutes without breaks", targetValue: 30, targetDate: Calendar.current.date(byAdding: .month, value: 3, to: Date())),
            ClientGoal(goalType: .flexibility, description: "Touch toes without pain", targetDate: Calendar.current.date(byAdding: .month, value: 4, to: Date())),
            ClientGoal(goalType: .strength, description: "10 push-ups from knees", targetValue: 10, targetDate: Calendar.current.date(byAdding: .month, value: 2, to: Date())),
            ClientGoal(goalType: .balance, description: "Stand on one foot for 30 seconds", targetValue: 30, targetDate: Calendar.current.date(byAdding: .month, value: 2, to: Date()))
        ]
        
        for (index, goal) in goals.enumerated() {
            goal.status = index < 2 ? .paused : .inProgress // Some paused due to setbacks
            goal.createdDate = Calendar.current.date(byAdding: .month, value: -8, to: Date())!
            client.clientGoals.append(goal)
            modelContext.insert(goal)
        }
        
        // Challenging trainer notes
        let notes = [
            TrainerNote(noteType: .medical, text: "Diabetes flare-up affecting energy levels", sessionId: "SM001"),
            TrainerNote(noteType: .behavioral, text: "Stress eating due to work pressure", sessionId: "SM003"),
            TrainerNote(noteType: .modification, text: "Modified workout due to back pain", sessionId: "SM005"),
            TrainerNote(noteType: .form, text: "Form breaking down due to fatigue", sessionId: "SM007"),
            TrainerNote(noteType: .medical, text: "Sleep issues affecting recovery", sessionId: "SM009"),
            TrainerNote(noteType: .progress, text: "Plateau in weight loss - need diet review", sessionId: "SM011"),
            TrainerNote(noteType: .equipment, text: "Needs supportive shoes for knee pain", sessionId: "SM013"),
            TrainerNote(noteType: .behavioral, text: "Motivation low after setback", sessionId: "SM015")
        ]
        
        for note in notes {
            note.createdDate = Calendar.current.date(byAdding: .day, value: -Int.random(in: 30...280), to: Date())!
            client.trainerNotes.append(note)
            modelContext.insert(note)
        }
        
        // Poor/declining progress metrics
        let metrics = [
            ProgressMetric(metricType: .bodyWeight, value: 78, unit: "kg", notes: "Weight gain despite training", sessionId: "SM015"),
            ProgressMetric(metricType: .bodyFat, value: 35.2, unit: "percent", notes: "Increased from starting point", sessionId: "SM015"),
            ProgressMetric(metricType: .plankHold, value: 15, unit: "seconds", notes: "Struggling with core strength", sessionId: "SM010"),
            ProgressMetric(metricType: .cardioEndurance, value: 20, unit: "minutes", notes: "Can only walk 20 min before fatigue", sessionId: "SM012"),
            ProgressMetric(metricType: .flexibility, value: 30, unit: "percent", notes: "Limited range of motion", sessionId: "SM008"),
            ProgressMetric(metricType: .balanceAssessment, value: 25, unit: "percent", notes: "Poor single-leg stability", sessionId: "SM014")
        ]
        
        for metric in metrics {
            metric.recordedDate = Calendar.current.date(byAdding: .day, value: -Int.random(in: 30...280), to: Date())!
            client.progressMetrics.append(metric)
            modelContext.insert(metric)
        }
    }
    
    // MARK: - Session Creation for New Clients
    
    private static func createAlexSessions(client: Client, workouts: [Workout], exercises: [Exercise], modelContext: ModelContext) {
        // Alex trains 5x per week with excellent progression
        let sessionData = [
            // Week 1 (recent)
            (Calendar.current.date(byAdding: .day, value: -2, to: Date())!, "Strength", 0, "New bench PR! 145kg smooth rep", 0, 9, 9),
            (Calendar.current.date(byAdding: .day, value: -4, to: Date())!, "Full Body", 1, "Excellent energy today, all lifts moving well", 0, 8, 9),
            (Calendar.current.date(byAdding: .day, value: -6, to: Date())!, "Power Training", 2, "Power output improving week over week", 0, 8, 9),
            
            // Week 2
            (Calendar.current.date(byAdding: .day, value: -9, to: Date())!, "Strength", 0, "Squat depth perfect, 170kg for clean triple", 0, 8, 9),
            (Calendar.current.date(byAdding: .day, value: -11, to: Date())!, "Full Body", 1, "Recovery excellent, ready for intensity", 0, 7, 9),
            (Calendar.current.date(byAdding: .day, value: -13, to: Date())!, "Power Training", 2, "Explosive movement quality outstanding", 0, 8, 9),
            
            // Week 3
            (Calendar.current.date(byAdding: .day, value: -16, to: Date())!, "Strength", 0, "Deadlift moving like warm-up weight", 0, 8, 9),
            (Calendar.current.date(byAdding: .day, value: -18, to: Date())!, "Full Body", 1, "Form coaching minimal - technique locked in", 0, 7, 9),
            
            // Week 4
            (Calendar.current.date(byAdding: .day, value: -23, to: Date())!, "Power Training", 2, "Speed and power gains evident", 0, 8, 9),
            (Calendar.current.date(byAdding: .day, value: -25, to: Date())!, "Strength", 0, "Working weight increases every session", 0, 9, 9)
        ]
        
        createSessionsForClient(client: client, workouts: workouts, sessionData: sessionData, modelContext: modelContext, isElite: true)
    }
    
    private static func createSarahSessions(client: Client, workouts: [Workout], exercises: [Exercise], modelContext: ModelContext) {
        // Sarah trains inconsistently with declining performance
        let sessionData = [
            // Recent - sporadic attendance
            (Calendar.current.date(byAdding: .day, value: -12, to: Date())!, "Recovery", 1, "Back pain flare-up, modified session", 15, 4, 5),
            (Calendar.current.date(byAdding: .day, value: -25, to: Date())!, "Full Body", 0, "Low energy, work stress affecting performance", 10, 3, 4),
            (Calendar.current.date(byAdding: .day, value: -35, to: Date())!, "Full Body", 1, "Struggling with motivation", 0, 4, 5),
            
            // Earlier sessions - more consistent but plateaued
            (Calendar.current.date(byAdding: .day, value: -50, to: Date())!, "Full Body", 0, "Form regression noted", 0, 5, 6),
            (Calendar.current.date(byAdding: .day, value: -58, to: Date())!, "Recovery", 1, "Knee pain limiting lower body work", 0, 4, 5),
            (Calendar.current.date(byAdding: .day, value: -65, to: Date())!, "Full Body", 0, "Weight gain despite efforts", 0, 4, 5),
            
            // Older sessions - better attendance
            (Calendar.current.date(byAdding: .day, value: -80, to: Date())!, "Full Body", 1, "Initial progress seen", 0, 6, 7),
            (Calendar.current.date(byAdding: .day, value: -90, to: Date())!, "Full Body", 0, "Good form development", 0, 6, 7)
        ]
        
        createSessionsForClient(client: client, workouts: workouts, sessionData: sessionData, modelContext: modelContext, isElite: false)
    }
    
    private static func createSessionsForClient(client: Client, workouts: [Workout], sessionData: [(Date, String, Int, String, Int, Int, Int?)], modelContext: ModelContext, isElite: Bool) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        for (sessionDate, sessionTypeStr, workoutIndex, notes, lateMinutes, rpe, technique) in sessionData {
            guard workoutIndex < workouts.count else { continue }
            
            let session = Session(client: client, workout: workouts[workoutIndex], date: sessionDate)
            session.sessionType = Session.SessionType(rawValue: sessionTypeStr)
            session.trainerNotes = notes
            session.lateMinutes = lateMinutes > 0 ? lateMinutes : nil
            session.status = .completed
            session.duration = isElite ? Double.random(in: 3600...4500) : Double.random(in: 2400...3600) // Elite trains longer
            
            session.sessionRPE = rpe
            session.techniqueQuality = technique ?? (isElite ? Int.random(in: 8...10) : Int.random(in: 4...7))
            
            // Initialize completed exercises with realistic performance differences
            session.completedExercises = session.workout.exercises.map { workoutExercise in
                let completedExercise = CompletedExercise(exercise: workoutExercise.exercise)
                
                completedExercise.sets = workoutExercise.sets.enumerated().map { index, exerciseSet in
                    let completedSet = CompletedSet(
                        setNumber: index + 1,
                        targetReps: exerciseSet.reps,
                        targetWeight: exerciseSet.weight,
                        weightUnit: exerciseSet.weightUnit
                    )
                    
                    if isElite {
                        // Alex often exceeds targets
                        completedSet.weight = exerciseSet.weight * Double.random(in: 1.0...1.3)
                        completedSet.reps = max(exerciseSet.reps, Int(Double(exerciseSet.reps) * Double.random(in: 1.0...1.2)))
                        completedSet.formNotes = ["Perfect form", "Textbook execution", "Room for more weight"].randomElement()
                    } else {
                        // Sarah often falls short of targets
                        completedSet.weight = exerciseSet.weight * Double.random(in: 0.6...0.9)
                        completedSet.reps = max(1, Int(Double(exerciseSet.reps) * Double.random(in: 0.7...1.0)))
                        completedSet.formNotes = ["Form breaking down", "Fatigue limiting", "Modified for pain"].randomElement()
                    }
                    
                    return completedSet
                }
                
                completedExercise.supersetId = workoutExercise.supersetId
                completedExercise.wasCompleted = true
                
                return completedExercise
            }
            
            // Update calculated values
            session.updateCalculatedValues()
            
            client.sessions.append(session)
            modelContext.insert(session)
        }
    }
    
    // Generic FitScore update function
    private static func updateClientFitScore(client: Client) {
        if let fitScore = client.fitScore {
            fitScore.updateFromSessions(client.sessions)
            fitScore.updateFromMeasurements(client: client)
        }
    }
}