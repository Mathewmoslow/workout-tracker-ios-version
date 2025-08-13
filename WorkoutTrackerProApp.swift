import SwiftUI
import SwiftData

@main
struct WorkoutTrackerProApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            // Workout models
            Workout.self,
            Exercise.self,
            WorkoutExercise.self,
            ExerciseSet.self,
            // Client models
            Client.self,
            Session.self,
            FitScore.self,
            Injury.self,
            PainPoint.self,
            EmergencyContact.self,
            BodyMeasurement.self,
            ProgressPhoto.self,
            FitnessAssessment.self,
            NutritionLog.self,
            LifestyleLog.self,
            // Enhanced trainer models
            ClientGoal.self,
            TrainerNote.self,
            ProgressMetric.self,
            // Session models
            CompletedExercise.self,
            CompletedSet.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            // Import exercise database on first launch
            if UserDefaults.standard.bool(forKey: "hasImportedExercises") == false {
                Task {
                    await ExerciseImporter.importExercises(to: container)
                    UserDefaults.standard.set(true, forKey: "hasImportedExercises")
                }
            }
            
            // Load real trainer data for testing (remove in production)
            if UserDefaults.standard.bool(forKey: "hasLoadedRealTrainerData") == false {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    RealTrainerDataLoader.loadRealTrainerData(modelContext: container.mainContext)
                    UserDefaults.standard.set(true, forKey: "hasLoadedRealTrainerData")
                }
            }
            
            // Load common workout programs for testing (remove in production)
            if UserDefaults.standard.bool(forKey: "hasLoadedCommonPrograms") == false {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    CommonWorkoutPrograms.loadCommonPrograms(modelContext: container.mainContext)
                    UserDefaults.standard.set(true, forKey: "hasLoadedCommonPrograms")
                }
            }
            
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            LaunchScreen()
        }
        .modelContainer(sharedModelContainer)
    }
}