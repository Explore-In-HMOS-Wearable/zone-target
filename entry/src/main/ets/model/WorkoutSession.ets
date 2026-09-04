import { CommonUtils } from '../utils/CommonUtils'

export interface WorkoutSummary {
  durationSeconds: number
  averageHR: number
  maxHR: number
  zoneSeconds: number[]
  steps: number
}

export class WorkoutSession {
  elapsedSeconds: number = 0
  maxHR: number = 0
  steps: number = 0
  zoneSeconds: number[] = [0, 0, 0, 0, 0, 0]
  private hrSum: number = 0
  private hrCount: number = 0

  get averageHR(): number {
    if (this.hrCount === 0) {
      return 0
    }
    return Math.round(this.hrSum / this.hrCount)
  }

  reset(): void {
    this.elapsedSeconds = 0
    this.maxHR = 0
    this.hrSum = 0
    this.hrCount = 0
    this.steps = 0
    this.zoneSeconds = [0, 0, 0, 0, 0, 0]
  }

  tick(currentZone: number): void {
    this.elapsedSeconds++
    this.zoneSeconds[currentZone]++
  }

  updateSteps(steps: number): void {
    this.steps = steps
  }

  formatTime(): string {
    return CommonUtils.formatTime(this.elapsedSeconds)
  }

  recordHeartRate(hr: number): void {
    if (hr > 0) {
      if (hr > this.maxHR) {
        this.maxHR = hr
      }
      this.hrSum += hr
      this.hrCount++
    }
  }

  toSummary(): WorkoutSummary {
    return {
      durationSeconds: this.elapsedSeconds,
      averageHR: this.averageHR,
      maxHR: this.maxHR,
      steps: this.steps,
      zoneSeconds: this.zoneSeconds
    }
  }

  toJSON(): string {
    return JSON.stringify(this.toSummary())
  }
}