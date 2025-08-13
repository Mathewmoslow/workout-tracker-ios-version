import Foundation
import SwiftData

@Model
final class FitScore {
    var id: UUID
    var client: Client?
    var date: Date
    var overallScore: Double // 0-1000, like a credit score
    
    // Primary Components (each 0-100)
    var strengthScore: Double
    var enduranceScore: Double
    var mobilityScore: Double
    var bodyCompositionScore: Double
    var consistencyScore: Double
    
    // Secondary Components (each 0-100)
    var nutritionScore: Double
    var recoveryScore: Double
    var progressionScore: Double
    var techniqueScore: Double
    var mentalScore: Double
    
    // Muscle Group Balance Scores (0-100)
    var upperBodyScore: Double
    var lowerBodyScore: Double
    var coreScore: Double
    var muscleBalanceScore: Double
    
    // Trend Indicators
    var weeklyTrend: Trend
    var monthlyTrend: Trend
    var quarterlyTrend: Trend
    
    enum Trend: String, Codable {
        case improving = "↑"
        case maintaining = "→"
        case declining = "↓"
    }
    
    init(client: Client? = nil) {
        self.id = UUID()
        self.client = client
        self.date = Date()
        self.overallScore = 500 // Start at middle, like credit score
        
        // Initialize all scores at 50 (average)
        self.strengthScore = 50
        self.enduranceScore = 50
        self.mobilityScore = 50
        self.bodyCompositionScore = 50
        self.consistencyScore = 50
        self.nutritionScore = 50
        self.recoveryScore = 50
        self.progressionScore = 50
        self.techniqueScore = 50
        self.mentalScore = 50
        self.upperBodyScore = 50
        self.lowerBodyScore = 50
        self.coreScore = 50
        self.muscleBalanceScore = 50
        
        self.weeklyTrend = .maintaining
        self.monthlyTrend = .maintaining
        self.quarterlyTrend = .maintaining
    }
    
    // Calculate overall FitScore (0-1000 scale)
    func calculateOverallScore() {
        // Weight the components based on importance
        let primaryWeight = 0.5
        let secondaryWeight = 0.3
        let balanceWeight = 0.2
        
        let primaryAvg = (strengthScore + enduranceScore + mobilityScore + 
                         bodyCompositionScore + consistencyScore) / 5
        
        let secondaryAvg = (nutritionScore + recoveryScore + progressionScore + 
                           techniqueScore + mentalScore) / 5
        
        let balanceAvg = (upperBodyScore + lowerBodyScore + coreScore + 
                         muscleBalanceScore) / 4
        
        let weightedScore = (primaryAvg * primaryWeight + 
                            secondaryAvg * secondaryWeight + 
                            balanceAvg * balanceWeight)
        
        // Convert to 0-1000 scale with bonus for excellence
        overallScore = weightedScore * 10
        
        // Add bonus points for exceptional performance
        if primaryAvg > 90 { overallScore += 50 }
        if consistencyScore > 95 { overallScore += 25 }
        if progressionScore > 90 { overallScore += 25 }
        
        // Cap at 1000
        overallScore = min(overallScore, 1000)
    }
    
    // Update FitScore based on new measurements
    func updateFromMeasurements(client: Client) {
        // Update body composition score based on body fat and muscle mass
        if let bodyFat = client.bodyFatPercentage {
            // Lower body fat generally means better score, adjusted for gender
            let idealBodyFat = client.gender == .female ? 25.0 : 15.0
            let bodyFatDiff = abs(bodyFat - idealBodyFat)
            bodyCompositionScore = max(0, min(100, 100 - (bodyFatDiff * 3)))
        }
        
        // Update based on BMI
        let idealBMI = 22.5
        let bmiDiff = abs(client.bmi - idealBMI)
        let bmiScore = max(0, min(100, 100 - (bmiDiff * 5)))
        bodyCompositionScore = (bodyCompositionScore + bmiScore) / 2
        
        // Update muscle balance if muscle mass is available
        if let muscleMass = client.muscleMass {
            let muscleMassRatio = muscleMass / client.currentWeight
            let idealRatio = client.gender == .male ? 0.45 : 0.36
            let ratioDiff = abs(muscleMassRatio - idealRatio)
            muscleBalanceScore = max(0, min(100, 100 - (ratioDiff * 200)))
        }
        
        // Update consistency based on recent sessions
        let recentSessions = client.sessions.filter { session in
            let weekAgo = Date().addingTimeInterval(-7 * 24 * 60 * 60)
            return session.date > weekAgo
        }
        consistencyScore = min(100, Double(recentSessions.count) * 20)
        
        // Update strength score based on session performance
        if !client.sessions.isEmpty {
            let avgVolume = client.sessions.reduce(0) { $0 + $1.totalVolume } / Double(client.sessions.count)
            strengthScore = min(100, avgVolume / 100) // Normalize to 100kg average
        }
        
        // Recalculate overall score
        calculateOverallScore()
    }
    
    // Get score category (like credit score ranges)
    var scoreCategory: ScoreCategory {
        switch overallScore {
        case 900...1000:
            return .elite
        case 800..<900:
            return .excellent
        case 700..<800:
            return .good
        case 600..<700:
            return .fair
        case 500..<600:
            return .developing
        default:
            return .needsWork
        }
    }
    
    enum ScoreCategory: String {
        case elite = "Elite Athlete"
        case excellent = "Excellent"
        case good = "Good"
        case fair = "Fair"
        case developing = "Developing"
        case needsWork = "Needs Work"
        
        var color: String {
            switch self {
            case .elite: return "purple"
            case .excellent: return "green"
            case .good: return "blue"
            case .fair: return "yellow"
            case .developing: return "orange"
            case .needsWork: return "red"
            }
        }
    }
    
    // Calculate individual component scores based on session data
    func updateFromSessions(_ sessions: [Session]) {
        guard !sessions.isEmpty else { return }
        
        // Consistency Score
        consistencyScore = calculateConsistencyScore(from: sessions)
        
        // Strength Score
        strengthScore = calculateStrengthScore(from: sessions)
        
        // Progression Score
        progressionScore = calculateProgressionScore(from: sessions)
        
        // Technique Score
        let avgTechnique = sessions.compactMap { $0.techniqueQuality }.reduce(0, +) / sessions.count
        techniqueScore = Double(avgTechnique) * 10
        
        // Update trends
        updateTrends(from: sessions)
        
        // Recalculate overall score
        calculateOverallScore()
    }
    
    private func calculateConsistencyScore(from sessions: [Session]) -> Double {
        let lastMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        let recentSessions = sessions.filter { $0.date > lastMonth }
        
        // Target: 12 sessions per month (3 per week)
        let targetSessions = 12.0
        let actualSessions = Double(recentSessions.count)
        
        return min((actualSessions / targetSessions) * 100, 100)
    }
    
    private func calculateStrengthScore(from sessions: [Session]) -> Double {
        // Calculate based on volume progression and max lifts
        let totalVolume = sessions.reduce(0) { $0 + $1.totalVolume }
        let avgVolume = totalVolume / Double(sessions.count)
        
        // Normalize to 0-100 (assuming 5000kg average is good)
        return min((avgVolume / 5000) * 100, 100)
    }
    
    private func calculateProgressionScore(from sessions: [Session]) -> Double {
        guard sessions.count >= 2 else { return 50 }
        
        let sortedSessions = sessions.sorted { $0.date < $1.date }
        let firstHalf = Array(sortedSessions.prefix(sessions.count / 2))
        let secondHalf = Array(sortedSessions.suffix(sessions.count / 2))
        
        let firstAvgVolume = firstHalf.reduce(0) { $0 + $1.totalVolume } / Double(firstHalf.count)
        let secondAvgVolume = secondHalf.reduce(0) { $0 + $1.totalVolume } / Double(secondHalf.count)
        
        let progressRate = ((secondAvgVolume - firstAvgVolume) / firstAvgVolume) * 100
        
        // Convert to 0-100 scale (10% improvement = 100 score)
        return min(max(progressRate * 10 + 50, 0), 100)
    }
    
    private func updateTrends(from sessions: [Session]) {
        // Calculate trends based on recent performance
        let now = Date()
        let weekAgo = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: now)!
        let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: now)!
        
        let lastWeekSessions = sessions.filter { $0.date > weekAgo }
        let lastMonthSessions = sessions.filter { $0.date > monthAgo }
        
        // Simple trend calculation based on session count and volume
        weeklyTrend = lastWeekSessions.count >= 3 ? .improving : 
                     lastWeekSessions.count >= 2 ? .maintaining : .declining
        
        monthlyTrend = lastMonthSessions.count >= 12 ? .improving :
                      lastMonthSessions.count >= 8 ? .maintaining : .declining
    }
}

// Nutrition tracking for FitScore
@Model
final class NutritionLog {
    var id: UUID
    var date: Date
    var calories: Int
    var protein: Double // grams
    var carbs: Double
    var fats: Double
    var fiber: Double
    var water: Double // liters
    var adherenceScore: Int // 1-10 how well they stuck to plan
    var mealTiming: MealTiming
    var supplements: [String]
    var notes: String
    
    enum MealTiming: String, Codable, CaseIterable {
        case excellent = "Excellent"
        case good = "Good"
        case fair = "Fair"
        case poor = "Poor"
    }
    
    init(date: Date = Date()) {
        self.id = UUID()
        self.date = date
        self.calories = 0
        self.protein = 0
        self.carbs = 0
        self.fats = 0
        self.fiber = 0
        self.water = 0
        self.adherenceScore = 5
        self.mealTiming = .fair
        self.supplements = []
        self.notes = ""
    }
}

// Lifestyle tracking for FitScore
@Model
final class LifestyleLog {
    var id: UUID
    var date: Date
    var sleepHours: Double
    var sleepQuality: Int // 1-10
    var stressLevel: Int // 1-10
    var energyLevel: Int // 1-10
    var steps: Int
    var activeMinutes: Int
    var alcoholUnits: Int
    var smokingStatus: Bool
    var hydrationLevel: Int // 1-10
    var moodScore: Int // 1-10
    var recoveryActivities: [String] // yoga, massage, stretching, etc.
    var notes: String
    
    init(date: Date = Date()) {
        self.id = UUID()
        self.date = date
        self.sleepHours = 7
        self.sleepQuality = 5
        self.stressLevel = 5
        self.energyLevel = 5
        self.steps = 0
        self.activeMinutes = 0
        self.alcoholUnits = 0
        self.smokingStatus = false
        self.hydrationLevel = 5
        self.moodScore = 5
        self.recoveryActivities = []
        self.notes = ""
    }
    
    var recoveryScore: Double {
        let sleepScore = min(sleepHours / 8, 1.0) * Double(sleepQuality)
        let stressScore = Double(10 - stressLevel)
        let hydrationScore = Double(hydrationLevel)
        
        return ((sleepScore + stressScore + hydrationScore) / 3) * 10
    }
}