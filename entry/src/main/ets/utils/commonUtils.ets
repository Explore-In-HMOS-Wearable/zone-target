export class CommonUtils {
  static formatTime(sec: number): string {
    const m = Math.floor(sec / 60)
    const s = sec % 60
    return `${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`
  }

  static formatDateShort(millis: number): string {
    const d = new Date(millis)
    return `${d.getDate()}/${d.getMonth() + 1}`
  }

  static formatDateFull(millis: number): string {
    const d = new Date(millis)
    return `${d.getDate()}/${d.getMonth() + 1}/${d.getFullYear()}`
  }

  static adjustAge(currentAge: number, degree: number): number {
    if (degree > 0) {
      return Math.min(100, currentAge + 1)
    } else if (degree < 0) {
      return Math.max(10, currentAge - 1)
    }
    return currentAge
  }
}