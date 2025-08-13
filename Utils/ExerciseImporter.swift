import Foundation
import SwiftData

struct ExerciseImporter {
    static func importExercises(to container: ModelContainer) async {
        let context = ModelContext(container)
        
        // Check if exercises already exist
        let descriptor = FetchDescriptor<Exercise>()
        let existingCount = (try? context.fetchCount(descriptor)) ?? 0
        
        if existingCount > 0 {
            print("Exercises already imported: \(existingCount)")
            return
        }
        
        // First, load the list of common exercise titles
        var commonExerciseTitles = Set<String>()
        if let commonUrl = Bundle.main.url(forResource: "common_exercises", withExtension: "json"),
           let commonData = try? Data(contentsOf: commonUrl) {
            do {
                let decoder = JSONDecoder()
                let commonExercises = try decoder.decode([CommonExerciseData].self, from: commonData)
                commonExerciseTitles = Set(commonExercises.map { $0.title.lowercased() })
                print("Loaded \(commonExerciseTitles.count) common exercise titles")
            } catch {
                print("Failed to load common exercises: \(error)")
            }
        }
        
        // Now load ALL exercises from the main database
        guard let url = Bundle.main.url(forResource: "exercises", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Could not load exercises.json")
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let exerciseData = try decoder.decode([ExerciseData].self, from: data)
            
            for item in exerciseData {
                let exercise = Exercise(
                    title: item.title,
                    desc: item.description ?? "",
                    type: item.type ?? "Strength",
                    bodyPart: item.bodyPart ?? "Other",
                    equipment: item.equipment ?? "Bodyweight",
                    level: item.level ?? "Intermediate",
                    rating: item.rating ?? 0.0,
                    ratingDesc: item.ratingDesc ?? ""
                )
                
                // Mark if this is a common exercise (for quick filtering)
                if commonExerciseTitles.contains(item.title.lowercased()) {
                    exercise.rating = 5.0 // Use rating to mark common exercises
                }
                
                context.insert(exercise)
            }
            
            try context.save()
            print("Successfully imported \(exerciseData.count) total exercises")
            print("(\(commonExerciseTitles.count) marked as common)")
        } catch {
            print("Failed to import exercises: \(error)")
        }
    }
}

// JSON structure for common exercises
struct CommonExerciseData: Codable {
    let title: String
    let category: String
    let primaryTargets: [String]
    let secondaryTargets: [String]
    let equipment: String
}

// JSON structure matching original exercises.json file  
struct ExerciseData: Codable {
    let id: Int
    let title: String
    let description: String?
    let type: String?
    let bodyPart: String?
    let equipment: String?
    let level: String?
    let rating: Double?
    let ratingDesc: String?
}