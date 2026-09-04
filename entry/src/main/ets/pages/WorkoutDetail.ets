import { WorkoutRecord } from '../model/WorkoutRecord'
import { ZoneCalculator } from '../model/ZoneCalculator'
import { WearEngineService } from '../services/WearEngineService'
import { common } from '@kit.AbilityKit'
import { CommonUtils } from '../utils/CommonUtils'
import {
  ArcButton,
  ArcButtonOptions,
  ArcButtonPosition,
  ArcButtonStatus,
  ArcButtonStyleMode,
  LengthMetrics,
  LengthUnit
} from '@kit.ArkUI'

@Component
export struct WorkoutDetail {
  recordJson: string = ''
  pathStack: NavPathStack = new NavPathStack()
  @State record: WorkoutRecord | null = null
  @State sendStatus: string = ''
  @State zoneSeconds: number[] = [0, 0, 0, 0, 0, 0]
  sendOptions: ArcButtonOptions = new ArcButtonOptions({})
  private wearService: WearEngineService | undefined = undefined

  aboutToAppear(): void {
    this.sendOptions = new ArcButtonOptions({
      label: 'Send to Phone',
      status: ArcButtonStatus.NORMAL,
      position: ArcButtonPosition.BOTTOM_EDGE,
      styleMode: ArcButtonStyleMode.EMPHASIZED_LIGHT,
      fontSize: new LengthMetrics(13, LengthUnit.FP),
      shadowEnabled: true,
      onClick: () => {
        this.sendToPhone()
      }
    })

    if (this.recordJson) {
      this.record = JSON.parse(this.recordJson) as WorkoutRecord
      this.zoneSeconds = JSON.parse(this.record.zoneSecondsJson) as number[]
    }
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext
    this.wearService = new WearEngineService(context)
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        List({ space: 12 }) {
          if (this.record) {
            ListItem() {
              Text(CommonUtils.formatDateFull(this.record.dateMillis))
                .fontSize(15)
                .fontColor($r('app.color.text_secondary'))
                .textAlign(TextAlign.Center)
                .width('100%')
                .margin({ top: 12 })
            }

            ListItem() {
              Column({ space: 4 }) {
                Text(CommonUtils.formatTime(this.record.durationSeconds))
                  .fontSize(44)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.text_primary'))
                Text($r('app.string.label_time'))
                  .fontSize(12)
                  .fontColor($r('app.color.text_secondary'))
              }
              .width('100%')
              .padding(16)
              .borderRadius(18)
              .backgroundColor($r('app.color.bg_button_secondary'))
            }

            ListItem() {
              Row() {
                Column({ space: 2 }) {
                  Text(`${this.record.averageHR}`)
                    .fontSize(24)
                    .fontWeight(FontWeight.Bold)
                    .fontColor($r('app.color.zone_3'))
                  Text('AVG').fontSize(10).fontColor($r('app.color.text_secondary'))
                }.layoutWeight(1)

                Column({ space: 2 }) {
                  Text(`${this.record.maxHR}`)
                    .fontSize(24).fontWeight(FontWeight.Bold)
                    .fontColor($r('app.color.status_danger'))
                  Text('MAX').fontSize(10).fontColor($r('app.color.text_secondary'))
                }.layoutWeight(1)

                Column({ space: 2 }) {
                  Text(`${this.record.steps}`)
                    .fontSize(24).fontWeight(FontWeight.Bold)
                    .fontColor($r('app.color.text_primary'))
                  Text('STEPS').fontSize(10).fontColor($r('app.color.text_secondary'))
                }.layoutWeight(1)
              }
            }
            .width('100%')
            .padding(16)
            .borderRadius(18)
            .backgroundColor($r('app.color.bg_button_secondary'))

            ListItem() {
              Column({ space: 8 }) {
                Text($r('app.string.zone_distribution'))
                  .fontSize(13)
                  .fontColor($r('app.color.text_secondary'))
                  .width('100%')
                ForEach([1, 2, 3, 4, 5], (zone: number) => {
                  Row({ space: 8 }) {
                    Text(ZoneCalculator.zoneLabel(zone))
                      .fontSize(11)
                      .fontColor(ZoneCalculator.zoneColor(zone))
                      .layoutWeight(1)
                    Text(CommonUtils.formatTime(this.zoneSeconds[zone]))
                      .fontSize(11)
                      .fontColor($r('app.color.text_secondary'))
                  }
                  .width('100%')
                }, (zone: number) => zone.toString())
              }
              .width('100%')
              .padding(16)
              .borderRadius(18)
              .backgroundColor($r('app.color.bg_button_secondary'))
            }

            ListItem() {
              Text(this.sendStatus)
                .fontSize(12)
                .fontColor($r('app.color.text_secondary'))
                .textAlign(TextAlign.Center)
                .width('100%')
            }
          }

          ListItem() {
            Row().height(60)
          }
        }
        .width('88%')
        .height('100%')
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)

        ArcButton({ options: this.sendOptions })
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.bg_primary'))
    }
    .hideTitleBar(true)
    .onReady((ctx: NavDestinationContext) => {
      this.pathStack = ctx.pathStack
    })
  }

  private async sendToPhone(): Promise<void> {
    if (!this.wearService || !this.record) {
      return
    }
    this.sendStatus = 'Sending...'
    const ok = await this.wearService.sendSummary(this.recordJson)
    this.sendStatus = ok ? 'Sent!' : 'Failed'
  }
}