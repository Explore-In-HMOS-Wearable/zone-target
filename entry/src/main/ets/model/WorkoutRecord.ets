export interface WorkoutRecord {
  id: number
  dateMillis: number
  durationSeconds: number
  averageHR: number
  maxHR: number
  steps: number
  zoneSecondsJson: string
}