import Foundation
import SwiftData

@Model
final class Session {
    var id: UUID
    var date: Date
    @Relationship(inverse: \Client.sessions) var client: Client?
    var workout: Workout
    var startTime: Date?
    var endTime: Date?
    var duration: TimeInterval
    var status: SessionStatus?
    
    // Real-world session tracking
    var sessionType: SessionType?
    var focusArea: String?
    var lateMinutes: Int?
    var programId: String?
    
    // Session Performance Data
    var completedExercises: [CompletedExercise]
    var totalVolume: Double // Total weight lifted
    var totalReps: Int
    var totalSets: Int
    var caloriesBurned: Int?
    
    // Session Quality Metrics
    var sessionRPE: Int? // Overall session RPE (1-10)
    var preWorkoutEnergy: Int? // 1-10 scale
    var postWorkoutEnergy: Int? // 1-10 scale
    var focusLevel: Int? // 1-10 scale
    var techniqueQuality: Int? // 1-10 scale
    
    // Body Metrics
    var bodyWeight: Double?
    var bodyFatPercentage: Double?
    var heartRateAverage: Int?
    var heartRateMax: Int?
    
    // Session Notes
    var trainerNotes: String
    var clientFeedback: String
    var injuries: [String]
    var modifications: [String]
    
    // Environmental Factors
    var location: TrainingLocation
    var weather: WeatherCondition?
    var temperature: Double?
    
    enum SessionStatus: String, Codable, CaseIterable {
        case scheduled = "Scheduled"
        case inProgress = "In Progress"
        case completed = "Completed"
        case cancelled = "Cancelled"
    }
    
    enum TrainingLocation: String, Codable, CaseIterable {
        case gym = "Gym"
        case home = "Home"
        case outdoor = "Outdoor"
        case online = "Online"
        case studio = "Studio"
    }
    
    enum WeatherCondition: String, Codable, CaseIterable {
        case sunny = "Sunny"
        case cloudy = "Cloudy"
        case rainy = "Rainy"
        case snowy = "Snowy"
        case hot = "Hot"
        case cold = "Cold"
        case humid = "Humid"
    }
    
    enum SessionType: String, Codable, CaseIterable {
        case fullBody = "Full Body"
        case upperLower = "Upper/Lower"
        case lateralFocus = "Lateral Focus"
        case lowerBody = "Lower Body"
        case partnerSession = "Partner Session"
        case cardioCore = "Cardio/Core"
        case circuit = "Circuit"
        case recovery = "Recovery"
        case warmUp = "Warm-up"
        case hiit = "HIIT"
        case strength = "Strength"
        case functional = "Functional"
    }
    
    init(
        client: Client? = nil,
        workout: Workout,
        date: Date = Date()
    ) {
        self.id = UUID()
        self.date = date
        self.client = client
        self.workout = workout
        self.startTime = nil
        self.duration = 0
        self.status = .scheduled
        self.completedExercises = []
        self.totalVolume = 0
        self.totalReps = 0
        self.totalSets = 0
        self.trainerNotes = ""
        self.clientFeedback = ""
        self.injuries = []
        self.modifications = []
        self.location = .gym
    }
    
    // Get effective status (handles nil for legacy data)
    var effectiveStatus: SessionStatus {
        return status ?? .scheduled
    }
    
    // Calculate total volume from completed exercises
    var calculatedTotalVolume: Double {
        return completedExercises.reduce(0) { sessionTotal, exercise in
            sessionTotal + exercise.totalVolume
        }
    }
    
    // Update stored volume to match calculated volume
    func updateCalculatedValues() {
        totalVolume = calculatedTotalVolume
        totalReps = completedExercises.reduce(0) { sessionTotal, exercise in
            sessionTotal + exercise.sets.reduce(0) { $0 + $1.reps }
        }
        totalSets = completedExercises.reduce(0) { sessionTotal, exercise in
            sessionTotal + exercise.sets.count
        }
    }
    
    // Calculate session intensity score
    var intensityScore: Double {
        let rpeScore = Double(sessionRPE ?? 5) / 10.0
        let volumeScore = min(totalVolume / 10000, 1.0) // Normalize to 10,000kg max
        let durationScore = min(duration / 7200, 1.0) // Normalize to 2 hours max
        
        return (rpeScore * 0.4 + volumeScore * 0.4 + durationScore * 0.2) * 100
    }
    
    // Calculate technique score
    var techniqueScore: Double {
        guard let technique = techniqueQuality else { return 50.0 }
        return Double(technique) * 10
    }
    
    // Calculate completion rate
    var completionRate: Double {
        let plannedExercises = workout.exercises.count
        let completed = completedExercises.filter { $0.wasCompleted }.count
        return plannedExercises > 0 ? (Double(completed) / Double(plannedExercises)) * 100 : 0
    }
    
    // Calculate average rest time
    var averageRestTime: Double {
        let totalRest = completedExercises.flatMap { $0.sets }.reduce(0) { $0 + Double($1.actualRest ?? 90) }
        let setCount = completedExercises.flatMap { $0.sets }.count
        return setCount > 0 ? totalRest / Double(setCount) : 90
    }
}

@Model
final class CompletedExercise {
    var id: UUID
    var exercise: Exercise
    var sets: [CompletedSet]
    var wasCompleted: Bool
    var notes: String
    var formVideos: [Data]
    var supersetId: UUID?
    
    init(exercise: Exercise) {
        self.id = UUID()
        self.exercise = exercise
        self.sets = []
        self.wasCompleted = false
        self.notes = ""
        self.formVideos = []
    }
    
    var totalVolume: Double {
        sets.reduce(0) { $0 + ($1.weight * Double($1.reps)) }
    }
    
    var averageRPE: Double {
        let rpes = sets.compactMap { $0.rpe }
        return rpes.isEmpty ? 0 : Double(rpes.reduce(0, +)) / Double(rpes.count)
    }
}

@Model
final class CompletedSet {
    var id: UUID
    var setNumber: Int
    var targetReps: Int
    var reps: Int
    var targetWeight: Double
    var weight: Double
    var weightUnit: ExerciseSet.WeightUnit
    var targetRest: Int
    var actualRest: Int?
    var rpe: Int?
    var tempo: String? // e.g., "3-1-2-0" (eccentric-pause-concentric-pause)
    var notes: String
    var timestamp: Date
    
    // Real-world tracking fields
    var equipmentNotes: String?
    var formNotes: String?
    
    init(
        setNumber: Int,
        targetReps: Int,
        targetWeight: Double,
        weightUnit: ExerciseSet.WeightUnit = .lbs
    ) {
        self.id = UUID()
        self.setNumber = setNumber
        self.targetReps = targetReps
        self.reps = targetReps
        self.targetWeight = targetWeight
        self.weight = targetWeight
        self.weightUnit = weightUnit
        self.targetRest = 90
        self.notes = ""
        self.timestamp = Date()
        self.equipmentNotes = nil
        self.formNotes = nil
    }
    
    var performanceRatio: Double {
        let repsRatio = Double(reps) / Double(targetReps)
        let weightRatio = weight / targetWeight
        return (repsRatio + weightRatio) / 2
    }
}