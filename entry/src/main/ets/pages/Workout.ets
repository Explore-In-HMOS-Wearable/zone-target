import { sensor, vibrator } from '@kit.SensorServiceKit'
import { abilityAccessCtrl, common } from '@kit.AbilityKit'
import { WorkoutSession } from '../model/WorkoutSession'
import { ZoneCalculator } from '../model/ZoneCalculator'
import { AudioService } from '../services/AudioService'
import { appSettings } from '../services/AppSettings'

@Component
export struct Workout {
  age: number = 30
  pathStack: NavPathStack = new NavPathStack()
  @State heartRate: number = 0
  @State status: Resource = ($r('app.string.tap_to_start'))
  @State steps: number = 0
  @State currentZone: number = 0
  @State listening: boolean = false
  @State session: WorkoutSession = new WorkoutSession()
  private timerId: number = -1
  private zoneCalc: ZoneCalculator = new ZoneCalculator(30)
  private stepBaseline: number = -1
  private audioService: AudioService | undefined = undefined
  private soundEnabled: boolean = true

  aboutToAppear(): void {
    this.zoneCalc = new ZoneCalculator(this.age)
    this.soundEnabled = appSettings.isSoundEnabled()
  }

  aboutToDisappear(): void {
    this.stopWorkout()
    this.audioService?.release()
  }

  build() {
    NavDestination() {
      Swiper() {
        //Card1 Heart Rate-BPM
        Column({ space: 6 }) {
          Text(`${this.heartRate}`)
            .fontSize(64)
            .fontWeight(FontWeight.Bold)
            .fontColor(ZoneCalculator.zoneColor(this.currentZone))

          Text($r('app.string.bpm'))
            .fontSize(16)
            .fontColor($r('app.color.text_secondary'))

          Text(ZoneCalculator.zoneLabel(this.currentZone))
            .fontSize(22)
            .fontWeight(FontWeight.Medium)
            .fontColor(ZoneCalculator.zoneColor(this.currentZone))
            .margin({ top: 8 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)

        //Card2 - Details: time + steps + stop
        Column({ space: 4 }) {
          //Time + Steps
          Column({ space: 2 }) {
            Text(this.session.formatTime())
              .fontSize(40)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
            Text($r('app.string.label_time'))
              .fontSize(13)
              .fontColor($r('app.color.text_secondary'))
            Text(`${this.steps}`)
              .fontSize(40)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
            Text($r('app.string.label_steps'))
              .fontSize(13)
              .fontColor($r('app.color.text_secondary'))
            Button(this.listening ? $r('app.string.btn_stop') : $r('app.string.btn_start'))
              .fontSize(15)
              .backgroundColor(this.listening ? $r('app.color.status_danger') : $r('app.color.zone_2'))
              .onClick(() => this.listening ? this.stopWorkout() : this.startWorkout())
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
        }
      }
      .vertical(true)
      .loop(false)
      .indicator(
        new DotIndicator()
          .color($r('app.color.text_secondary'))
          .selectedColor($r('app.color.text_primary'))
      )
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.bg_primary'))
    }
    .hideTitleBar(true)
    .onReady((ctx: NavDestinationContext) => {
      this.pathStack = ctx.pathStack
    })
  }

  private async requestPermission(): Promise<boolean> {
    const atManager = abilityAccessCtrl.createAtManager()
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext
    try {
      const result = await atManager.requestPermissionsFromUser(
        context,
        ['ohos.permission.READ_HEALTH_DATA', 'ohos.permission.ACTIVITY_MOTION']
      )
      return result.authResults[0] === 0 && result.authResults[1] === 0
    } catch (e) {
      this.status = ($r('app.string.permission_error'))
      return false
    }
  }

  private async startWorkout(): Promise<void> {
    if (this.listening) {
      return
    }
    const granted = await this.requestPermission()
    if (!granted) {
      this.status = ($r('app.string.permission_denied'))
      return
    }

    this.session.reset()
    this.currentZone = 0
    this.steps = 0
    this.stepBaseline = -1

    if (!this.audioService) {
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext
      this.audioService = new AudioService(context)
    }

    try {
      sensor.on(sensor.SensorId.HEART_RATE, (data: sensor.HeartRateResponse) => {
        const hr = data.heartRate
        this.heartRate = hr

        const newZone = this.zoneCalc.calculateZone(hr)
        if (newZone !== this.currentZone) {
          this.vibrateForZone(newZone, this.currentZone)
          if (this.soundEnabled) {
            this.audioService?.playZone(newZone)
          }
          this.currentZone = newZone
        }
        this.session.recordHeartRate(hr)
        this.status = ($r('app.string.status_reading'))
      })

      sensor.on(sensor.SensorId.PEDOMETER, (data: sensor.PedometerResponse) => {
        if (this.stepBaseline < 0) {
          this.stepBaseline = data.steps
        }
        this.steps = data.steps - this.stepBaseline
        this.session.updateSteps(this.steps)
      })
      this.listening = true
      this.startTimer()
    } catch (e) {
      this.status = ($r('app.string.sensor_unavailable'))
    }
  }

  private stopWorkout(): void {
    if (!this.listening) {
      return
    }
    sensor.off(sensor.SensorId.HEART_RATE)
    sensor.off(sensor.SensorId.PEDOMETER)
    this.stopTimer()
    this.listening = false
    this.status = ($r('app.string.status_stopped'))

    this.pathStack.pushPathByName('Summary', this.session.toJSON())
  }

  private startTimer(): void {
    this.timerId = setInterval(() => {
      this.session.tick(this.currentZone)
    }, 1000)
  }

  private stopTimer(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId)
      this.timerId = -1
    }
  }

  private vibrateForZone(newZone: number, oldZone: number): void {
    try {
      const goingUp = newZone > oldZone
      vibrator.startVibration(
        { type: 'time', duration: goingUp ? 300 : 150 },
        { id: 0, usage: 'alarm' }
      )
    } catch (e) {
    }
  }
}