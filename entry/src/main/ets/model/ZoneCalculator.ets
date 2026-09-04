export class ZoneCalculator {
  private hrMax: number

  constructor(age: number) {
    this.hrMax = 220 - age
  }

  static zoneColor(zone: number): ResourceColor {
    switch (zone) {
      case 1:
        return $r('app.color.zone_1')
      case 2:
        return $r('app.color.zone_2')
      case 3:
        return $r('app.color.zone_3')
      case 4:
        return $r('app.color.zone_4')
      case 5:
        return $r('app.color.zone_5')
      default:
        return $r('app.color.zone_rest')
    }
  }

  static zoneLabel(zone: number): Resource {
    switch (zone) {
      case 1:
        return $r('app.string.zone_label_1')
      case 2:
        return $r('app.string.zone_label_2')
      case 3:
        return $r('app.string.zone_label_3')
      case 4:
        return $r('app.string.zone_label_4')
      case 5:
        return $r('app.string.zone_label_5')
      default:
        return $r('app.string.zone_label_rest')
    }
  }

  calculateZone(hr: number): number {
    if (hr <= 0) {
      return 0
    }

    const percent = (hr / this.hrMax) * 100
    if (percent < 50) {
      return 0
    }
    if (percent < 60) {
      return 1
    }
    if (percent < 70) {
      return 2
    }
    if (percent < 80) {
      return 3
    }
    if (percent < 90) {
      return 4
    }
    return 5
  }
}