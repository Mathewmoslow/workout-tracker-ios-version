import Foundation
import SwiftData

@Model
final class Workout {
    var id: UUID
    var name: String
    var desc: String
    var workoutDescription: String  // Renamed to avoid conflict with @Model
    var category: String?
    var estimatedDuration: Int?
    @Relationship(deleteRule: .cascade) var exercises: [WorkoutExercise]
    var tags: [String] = []
    var createdAt: Date
    var updatedAt: Date
    var isFavorite: Bool
    
    init(
        name: String,
        desc: String = "",
        category: String? = nil,
        estimatedDuration: Int? = nil,
        exercises: [WorkoutExercise] = [],
        tags: [String] = [],
        isFavorite: Bool = false
    ) {
        self.id = UUID()
        self.name = name
        self.desc = desc
        self.workoutDescription = desc  // Keep in sync
        self.category = category
        self.estimatedDuration = estimatedDuration
        self.exercises = exercises
        self.tags = tags
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isFavorite = isFavorite
    }
    
    var exerciseCount: Int {
        exercises.count
    }
    
    var totalSets: Int {
        exercises.reduce(0) { $0 + $1.sets.count }
    }
    
    var hasSuperset: Bool {
        exercises.contains { $0.supersetId != nil }
    }
    
    var estimatedVolume: Int {
        // Rough estimate based on sets and average weight
        exercises.reduce(0) { total, exercise in
            total + exercise.sets.reduce(0) { setTotal, set in
                setTotal + Int(set.weight * Double(set.reps))
            }
        }
    }
}