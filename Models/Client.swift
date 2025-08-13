import Foundation
import SwiftData

@Model
final class Client {
    var id: UUID
    var firstName: String
    var lastName: String
    var email: String
    var phone: String
    var dateOfBirth: Date
    var gender: Gender
    var profileImage: Data?
    
    // Physical Metrics
    var height: Double // in cm
    var currentWeight: Double // in kg
    var targetWeight: Double // in kg
    var bodyFatPercentage: Double?
    var muscleMass: Double?
    var waterPercentage: Double?
    var boneMass: Double?
    var visceralFatLevel: Int?
    var metabolicAge: Int?
    var bmr: Int? // Basal Metabolic Rate
    
    // Circumference Measurements (in cm)
    var chestCircumference: Double?
    var waistCircumference: Double?
    var hipsCircumference: Double?
    var thighsCircumference: Double?
    var armsCircumference: Double?
    var calvesCircumference: Double?
    
    // Goals & Preferences
    var primaryGoal: FitnessGoal
    var secondaryGoals: [FitnessGoal] = []
    @Relationship(deleteRule: .cascade) var injuryHistory: [Injury] = []
    @Relationship(deleteRule: .cascade) var painPoints: [PainPoint] = []
    var medicalConditions: [String] = []
    var currentMedications: String
    var allergies: [String] = []
    @Relationship(deleteRule: .cascade) var emergencyContact: EmergencyContact?
    var preferredTrainingDays: [Int] = [] // 0 = Sunday, 6 = Saturday
    
    // Lifestyle Assessment
    var activityLevel: ActivityLevel
    var stressLevel: Int // 1-10
    var averageSleepHours: Double
    var nutritionQuality: NutritionQuality
    var smokingStatus: SmokingStatus
    var alcoholConsumption: AlcoholConsumption
    
    // Training Data
    @Relationship(deleteRule: .cascade) var sessions: [Session] = []
    @Relationship(deleteRule: .cascade) var measurements: [BodyMeasurement] = []
    @Relationship(deleteRule: .cascade) var progressPhotos: [ProgressPhoto] = []
    @Relationship(deleteRule: .cascade) var assessments: [FitnessAssessment] = []
    
    // FitScore Components
    @Relationship(deleteRule: .cascade) var fitScore: FitScore?
    @Relationship(deleteRule: .cascade) var nutritionLogs: [NutritionLog] = []
    @Relationship(deleteRule: .cascade) var lifestyleLogs: [LifestyleLog] = []
    
    // Subscription & Status
    var startDate: Date
    var isActive: Bool
    var subscriptionType: SubscriptionType
    var notes: String
    var trainerName: String
    
    // Real-world trainer relationships
    @Relationship(deleteRule: .cascade) var clientGoals: [ClientGoal] = []
    @Relationship(deleteRule: .cascade) var trainerNotes: [TrainerNote] = []
    @Relationship(deleteRule: .cascade) var progressMetrics: [ProgressMetric] = []
    
    enum Gender: String, Codable, CaseIterable {
        case male = "Male"
        case female = "Female"
        case other = "Other"
    }
    
    enum FitnessGoal: String, Codable, CaseIterable {
        case weightLoss = "Weight Loss"
        case muscleGain = "Muscle Gain"
        case strengthGain = "Strength Gain"
        case endurance = "Endurance"
        case athleticPerformance = "Athletic Performance"
        case generalFitness = "General Fitness"
        case rehabilitation = "Rehabilitation"
        case bodyRecomposition = "Body Recomposition"
    }
    
    enum SubscriptionType: String, Codable, CaseIterable {
        case monthly = "Monthly"
        case quarterly = "Quarterly"
        case annual = "Annual"
        case payPerSession = "Pay Per Session"
    }
    
    enum ActivityLevel: String, Codable, CaseIterable {
        case sedentary = "Sedentary"
        case lightlyActive = "Lightly Active"
        case moderatelyActive = "Moderately Active"
        case veryActive = "Very Active"
        case extremelyActive = "Extremely Active"
    }
    
    enum NutritionQuality: String, Codable, CaseIterable {
        case poor = "Poor"
        case fair = "Fair"
        case good = "Good"
        case excellent = "Excellent"
    }
    
    enum SmokingStatus: String, Codable, CaseIterable {
        case never = "Never"
        case former = "Former"
        case current = "Current"
    }
    
    enum AlcoholConsumption: String, Codable, CaseIterable {
        case none = "None"
        case occasional = "Occasional"
        case moderate = "Moderate"
        case heavy = "Heavy"
    }
    
    enum Trend: String {
        case improving = "↑"
        case maintaining = "→"
        case declining = "↓"
    }
    
    init(
        firstName: String,
        lastName: String,
        email: String,
        phone: String = "",
        dateOfBirth: Date,
        gender: Gender,
        height: Double,
        currentWeight: Double,
        targetWeight: Double,
        primaryGoal: FitnessGoal
    ) {
        self.id = UUID()
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
        self.dateOfBirth = dateOfBirth
        self.gender = gender
        self.height = height
        self.currentWeight = currentWeight
        self.targetWeight = targetWeight
        self.primaryGoal = primaryGoal
        self.secondaryGoals = []
        self.injuryHistory = []
        self.painPoints = []
        self.medicalConditions = []
        self.currentMedications = ""
        self.allergies = []
        self.emergencyContact = nil
        self.preferredTrainingDays = []
        self.activityLevel = .moderatelyActive
        self.stressLevel = 5
        self.averageSleepHours = 7.0
        self.nutritionQuality = .good
        self.smokingStatus = .never
        self.alcoholConsumption = .occasional
        self.sessions = []
        self.measurements = []
        self.progressPhotos = []
        self.assessments = []
        self.nutritionLogs = []
        self.lifestyleLogs = []
        self.startDate = Date()
        self.isActive = true
        self.subscriptionType = .monthly
        self.notes = ""
        self.trainerName = ""
    }
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    var age: Int {
        Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 0
    }
    
    var bmi: Double {
        guard height > 0 && currentWeight > 0 else { return 0 }
        let heightInMeters = height / 100
        return currentWeight / (heightInMeters * heightInMeters)
    }
    
    var weightProgress: Double {
        let totalChange = abs(targetWeight - currentWeight)
        let startWeight = sessions.first?.bodyWeight ?? currentWeight
        let currentChange = abs(startWeight - currentWeight)
        return totalChange > 0 ? (currentChange / totalChange) * 100 : 0
    }
    
    // Body Composition Percentages
    var muscleMassPercentage: Double? {
        guard let muscleMass = muscleMass, currentWeight > 0 else { return nil }
        return (muscleMass / currentWeight) * 100
    }
    
    var boneMassPercentage: Double? {
        guard let boneMass = boneMass, currentWeight > 0 else { return nil }
        return (boneMass / currentWeight) * 100
    }
    
    // Trend calculations (simplified for now)
    var weightTrend: Trend {
        // This should be calculated based on historical measurements
        // For now, return maintaining
        return .maintaining
    }
    
    var bodyFatTrend: Trend {
        // This should be calculated based on historical measurements
        return .maintaining
    }
    
    var muscleMassTrend: Trend {
        // This should be calculated based on historical measurements
        return .improving
    }
}

@Model
final class BodyMeasurement {
    var id: UUID
    var date: Date
    var weight: Double
    var bodyFatPercentage: Double?
    
    // Circumference measurements (in cm)
    var neck: Double?
    var shoulders: Double?
    var chest: Double?
    var leftBicep: Double?
    var rightBicep: Double?
    var leftForearm: Double?
    var rightForearm: Double?
    var waist: Double?
    var hips: Double?
    var leftThigh: Double?
    var rightThigh: Double?
    var leftCalf: Double?
    var rightCalf: Double?
    
    init(date: Date = Date(), weight: Double) {
        self.id = UUID()
        self.date = date
        self.weight = weight
    }
}

@Model
final class ProgressPhoto {
    var id: UUID
    var date: Date
    var frontPhoto: Data?
    var sidePhoto: Data?
    var backPhoto: Data?
    var notes: String
    
    init(date: Date = Date()) {
        self.id = UUID()
        self.date = date
        self.notes = ""
    }
}

@Model
final class FitnessAssessment {
    var id: UUID
    var date: Date
    
    // Strength Tests
    var benchPressMax: Double?
    var squatMax: Double?
    var deadliftMax: Double?
    var overheadPressMax: Double?
    
    // Endurance Tests
    var vo2Max: Double?
    var restingHeartRate: Int?
    var pushUpsMax: Int?
    var pullUpsMax: Int?
    var plankHoldSeconds: Int?
    
    // Flexibility
    var sitAndReachCm: Double?
    var shoulderFlexibility: String?
    
    // Performance
    var verticalJumpCm: Double?
    var sprintTime40Yards: Double?
    var agilityTestTime: Double?
    
    init(date: Date = Date()) {
        self.id = UUID()
        self.date = date
    }
}

@Model
final class Injury {
    var id: UUID
    var type: String
    var severity: InjurySeverity
    var dateOccurred: Date?
    var notes: String
    var isActive: Bool
    
    enum InjurySeverity: String, Codable, CaseIterable {
        case mild = "Mild"
        case moderate = "Moderate"
        case severe = "Severe"
    }
    
    init(type: String, severity: InjurySeverity = .mild, notes: String = "", isActive: Bool = true) {
        self.id = UUID()
        self.type = type
        self.severity = severity
        self.dateOccurred = nil
        self.notes = notes
        self.isActive = isActive
    }
}

@Model
final class PainPoint {
    var id: UUID
    var location: String
    var painLevel: Int // 1-10
    var frequency: PainFrequency
    var notes: String
    
    enum PainFrequency: String, Codable, CaseIterable {
        case occasional = "Occasional"
        case frequent = "Frequent"
        case constant = "Constant"
        case duringExercise = "During Exercise"
        case afterExercise = "After Exercise"
    }
    
    init(location: String, painLevel: Int = 5, frequency: PainFrequency = .occasional, notes: String = "") {
        self.id = UUID()
        self.location = location
        self.painLevel = painLevel
        self.frequency = frequency
        self.notes = notes
    }
}

@Model
final class EmergencyContact {
    var id: UUID
    var name: String
    var relationship: String
    var phone: String
    var email: String?
    
    init(name: String, relationship: String, phone: String, email: String? = nil) {
        self.id = UUID()
        self.name = name
        self.relationship = relationship
        self.phone = phone
        self.email = email
    }
}

@Model
final class ClientGoal {
    var id: UUID
    var goalType: GoalType
    var goalDescription: String
    var targetValue: Double?
    var targetDate: Date?
    var status: GoalStatus
    var createdDate: Date
    var updatedDate: Date
    var notes: String
    
    enum GoalType: String, Codable, CaseIterable {
        case strength = "Strength"
        case balance = "Balance"
        case form = "Form"
        case endurance = "Endurance"
        case flexibility = "Flexibility"
        case weightLoss = "Weight Loss"
        case muscleGain = "Muscle Gain"
        case cardio = "Cardio"
        case mobility = "Mobility"
        case coordination = "Coordination"
    }
    
    enum GoalStatus: String, Codable, CaseIterable {
        case pending = "Pending"
        case inProgress = "In Progress"
        case completed = "Completed"
        case paused = "Paused"
        case cancelled = "Cancelled"
    }
    
    init(goalType: GoalType, description: String, targetValue: Double? = nil, targetDate: Date? = nil) {
        self.id = UUID()
        self.goalType = goalType
        self.goalDescription = description
        self.targetValue = targetValue
        self.targetDate = targetDate
        self.status = .pending
        self.createdDate = Date()
        self.updatedDate = Date()
        self.notes = ""
    }
}

@Model
final class TrainerNote {
    var id: UUID
    var noteType: NoteType
    var noteText: String
    var createdDate: Date
    var sessionId: String?
    
    enum NoteType: String, Codable, CaseIterable {
        case form = "Form"
        case modification = "Modification"
        case performance = "Performance"
        case medical = "Medical"
        case program = "Program"
        case equipment = "Equipment"
        case technique = "Technique"
        case progress = "Progress"
        case behavioral = "Behavioral"
        case general = "General"
    }
    
    init(noteType: NoteType, text: String, sessionId: String? = nil) {
        self.id = UUID()
        self.noteType = noteType
        self.noteText = text
        self.createdDate = Date()
        self.sessionId = sessionId
    }
}

@Model
final class ProgressMetric {
    var id: UUID
    var metricType: MetricType
    var metricValue: Double
    var unit: String
    var notes: String
    var recordedDate: Date
    var sessionId: String?
    
    enum MetricType: String, Codable, CaseIterable {
        case plankHold = "Plank_Hold"
        case rowDistance = "Row_Distance"
        case rowTime = "Row_Time"
        case maxDeadlift = "Max_Deadlift"
        case balanceAssessment = "Balance_Assessment"
        case skiDistance = "Ski_Distance"
        case bodyWeight = "Body_Weight"
        case bodyFat = "Body_Fat"
        case maxBench = "Max_Bench"
        case maxSquat = "Max_Squat"
        case vo2Max = "VO2_Max"
        case flexibility = "Flexibility"
        case cardioEndurance = "Cardio_Endurance"
        case strengthEndurance = "Strength_Endurance"
    }
    
    init(metricType: MetricType, value: Double, unit: String, notes: String = "", sessionId: String? = nil) {
        self.id = UUID()
        self.metricType = metricType
        self.metricValue = value
        self.unit = unit
        self.notes = notes
        self.recordedDate = Date()
        self.sessionId = sessionId
    }
}

