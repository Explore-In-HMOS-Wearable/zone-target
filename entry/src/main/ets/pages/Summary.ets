import { WorkoutSummary } from '../model/WorkoutSession'
import { ZoneCalculator } from '../model/ZoneCalculator'
import { rdbHelper } from '../database/WorkoutRdbHelper'
import { WorkoutRecord } from '../model/WorkoutRecord'
import { WearEngineService } from '../services/WearEngineService'
import { common } from '@kit.AbilityKit'
import { CommonUtils } from '../utils/CommonUtils'

@Component
export struct Summary {
  summaryJson: string = ''
  pathStack: NavPathStack = new NavPathStack()
  @State summary: WorkoutSummary | null = null
  private wearService: WearEngineService | undefined = undefined

  aboutToAppear(): void {
    if (this.summaryJson) {
      this.summary = JSON.parse(this.summaryJson) as WorkoutSummary
      this.saveToDatabase();
    }
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext
    this.wearService = new WearEngineService(context)
  }

  build() {
    NavDestination() {
      Column() {
        Text($r('app.string.summary_title'))
          .fontSize(20)
          .fontColor($r('app.color.text_primary'))
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        if (this.summary) {
          Text(CommonUtils.formatTime(this.summary.durationSeconds))
            .fontSize(28)
            .fontColor($r('app.color.text_primary'))
          Text(`Avg ${this.summary.averageHR}  ·  Max ${this.summary.maxHR}`)
            .fontSize(16)
            .fontColor($r('app.color.text_secondary'))
          Text(`${this.summary.steps} steps`)
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))

          ForEach([1, 2, 3, 4, 5], (zone: number) => {
            Row() {
              Text(ZoneCalculator.zoneLabel(zone))
                .fontSize(12)
                .fontColor(ZoneCalculator.zoneColor(zone))
                .layoutWeight(1)
              Text(CommonUtils.formatTime(this.summary!.zoneSeconds[zone]))
                .fontSize(12)
                .fontColor($r('app.color.text_secondary'))
            }
            .width('80%')
          }, (zone: number) => zone.toString())
        }
        Button($r('app.string.btn_back'))
          .fontSize(13)
          .onClick(() => this.pathStack.pop())
        Button($r('app.string.btn_history'))
          .fontSize(12)
          .height(32)
          .backgroundColor($r('app.color.bg_button_secondary'))
          .onClick(() => {
            this.pathStack.pushPathByName('History', '')
          })
          .margin({ top: 4 })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r('app.color.bg_primary'))
    }
    .hideTitleBar(true)
    .onReady((ctx: NavDestinationContext) => {
      this.pathStack = ctx.pathStack
    })
  }

  private async saveToDatabase(): Promise<void> {
    if (!this.summary) {
      return
    }
    const record: WorkoutRecord = {
      id: 0,
      dateMillis: Date.now(),
      durationSeconds: this.summary.durationSeconds,
      averageHR: this.summary.averageHR,
      maxHR: this.summary.maxHR,
      steps: this.summary.steps,
      zoneSecondsJson: JSON.stringify(this.summary.zoneSeconds)
    }
    await rdbHelper.insertWorkout(record)
  }
}