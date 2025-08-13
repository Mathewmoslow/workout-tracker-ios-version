# FitScore Explained

## Overview
FitScore is a comprehensive fitness assessment metric (0-1000 scale, similar to a credit score) that tracks and evaluates a client's overall fitness journey.

## Score Components & Weights

### Primary Components (50% weight)
- **Strength Score (0-100)**: Based on total volume lifted per session. Average of 5000kg per session = 100 score
- **Endurance Score (0-100)**: Currently initialized at 50, needs cardio/endurance session data
- **Mobility Score (0-100)**: Currently initialized at 50, needs flexibility/ROM assessments
- **Body Composition Score (0-100)**: Currently initialized at 50, needs body fat %, weight progress
- **Consistency Score (0-100)**: Based on training frequency. Target: 12 sessions/month (3x/week) = 100%

### Secondary Components (30% weight)
- **Nutrition Score (0-100)**: Requires NutritionLog tracking (calories, macros, adherence)
- **Recovery Score (0-100)**: Based on sleep hours, sleep quality, stress level, hydration
- **Progression Score (0-100)**: Measures volume improvement over time. 10% gain = perfect score
- **Technique Score (0-100)**: Average technique quality rating from sessions (1-10 scale × 10)
- **Mental Score (0-100)**: Based on mood, energy levels, mental resilience metrics

### Balance Components (20% weight)
- **Upper Body Score (0-100)**: Balance of upper body muscle development
- **Lower Body Score (0-100)**: Balance of lower body muscle development
- **Core Score (0-100)**: Core strength and stability metrics
- **Muscle Balance Score (0-100)**: Overall symmetry and balance between muscle groups

## Bonus Points
- +50 points if primary component average exceeds 90
- +25 points if consistency score exceeds 95%
- +25 points if progression score exceeds 90

## Score Categories
- **900-1000**: Elite Athlete (Purple)
- **800-899**: Excellent (Green)
- **700-799**: Good (Blue)
- **600-699**: Fair (Yellow)
- **500-599**: Developing (Orange)
- **Below 500**: Needs Work (Red)

## How Clients Improve Their FitScore

### Currently Implemented (Affects Score Now)
1. **Train Consistently**: Maintain 3+ sessions per week
2. **Increase Volume Progressively**: Gradual increase in weights and total volume
3. **Maintain Good Technique**: High technique ratings (8-10) during sessions
4. **Show Measurable Progress**: Consistent improvement in performance metrics

### Planned Features (Not Yet Implemented)
1. **Nutrition Tracking**: Log meals, calories, macros, supplements
2. **Lifestyle Tracking**: Sleep quality, stress management, recovery activities
3. **Body Measurements**: Regular body composition assessments
4. **Mobility Assessments**: Flexibility and range of motion tests
5. **Endurance Metrics**: Cardio performance tracking

## Calculation Details

### Overall Score Formula
```
Primary Average = (Strength + Endurance + Mobility + Body Comp + Consistency) / 5
Secondary Average = (Nutrition + Recovery + Progression + Technique + Mental) / 5
Balance Average = (Upper + Lower + Core + Muscle Balance) / 4

Weighted Score = (Primary × 0.5) + (Secondary × 0.3) + (Balance × 0.2)
Overall Score = (Weighted Score × 10) + Bonus Points
```

### Trend Indicators
- **Weekly Trend**: Based on last 7 days of activity
- **Monthly Trend**: Based on last 30 days of activity
- **Quarterly Trend**: Based on last 90 days of activity

Trends show as:
- ↑ Improving
- → Maintaining
- ↓ Declining

## Current Limitations
- Only session-based metrics are currently tracked
- Nutrition, lifestyle, and body measurement features need UI implementation
- Endurance and mobility scores start at default values
- Manual measurement entry not yet available

## Future Enhancements
- Integration with wearables for automatic data collection
- AI-powered recommendations based on score trends
- Comparative analytics with similar demographic groups
- Predictive modeling for goal achievement timelines