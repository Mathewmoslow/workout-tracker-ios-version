import Foundation
import SwiftData

@Model
final class Exercise {
    var id: UUID
    var title: String
    var desc: String
    var type: String
    var bodyPart: String
    var equipment: String
    var level: String
    var rating: Double
    var ratingDesc: String
    
    init(
        title: String,
        desc: String = "",
        type: String = "Strength",
        bodyPart: String,
        equipment: String,
        level: String = "Intermediate",
        rating: Double = 0.0,
        ratingDesc: String = ""
    ) {
        self.id = UUID()
        self.title = title
        self.desc = desc
        self.type = type
        self.bodyPart = bodyPart
        self.equipment = equipment
        self.level = level
        self.rating = rating
        self.ratingDesc = ratingDesc
    }
}

@Model
final class WorkoutExercise {
    var id: UUID
    var exercise: Exercise
    var sets: [ExerciseSet]
    var supersetId: UUID?
    var orderIndex: Int
    var notes: String
    
    init(exercise: Exercise, sets: [ExerciseSet] = [], supersetId: UUID? = nil, orderIndex: Int = 0, notes: String = "") {
        self.id = UUID()
        self.exercise = exercise
        self.sets = sets
        self.supersetId = supersetId
        self.orderIndex = orderIndex
        self.notes = notes
    }
}

@Model
final class ExerciseSet: Identifiable {
    var id: UUID
    var setNumber: Int
    var reps: Int
    var weight: Double
    var weightUnit: WeightUnit
    var rest: Int // in seconds
    var rpe: Int? // Rate of Perceived Exertion (1-10)
    var isCompleted: Bool
    
    enum WeightUnit: String, Codable, CaseIterable {
        case lbs = "lbs"
        case kg = "kg"
        case bodyweight = "BW"
    }
    
    init(
        setNumber: Int = 1,
        reps: Int = 10,
        weight: Double = 0,
        weightUnit: WeightUnit = .lbs,
        rest: Int = 90,
        rpe: Int? = nil,
        isCompleted: Bool = false
    ) {
        self.id = UUID()
        self.setNumber = setNumber
        self.reps = reps
        self.weight = weight
        self.weightUnit = weightUnit
        self.rest = rest
        self.rpe = rpe
        self.isCompleted = isCompleted
    }
}