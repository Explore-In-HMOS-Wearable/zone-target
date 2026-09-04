import { rdbHelper } from '../database/WorkoutRdbHelper'
import { WorkoutRecord } from '../model/WorkoutRecord'
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
export struct History {
  pathStack: NavPathStack = new NavPathStack()
  @State records: WorkoutRecord[] = []
  backOptions: ArcButtonOptions = new ArcButtonOptions({})

  async aboutToAppear(): Promise<void> {
    this.backOptions = new ArcButtonOptions({
      label: 'Back',
      status: ArcButtonStatus.NORMAL,
      position: ArcButtonPosition.BOTTOM_EDGE,
      styleMode: ArcButtonStyleMode.EMPHASIZED_LIGHT,
      fontSize: new LengthMetrics(14, LengthUnit.FP),
      shadowEnabled: true,
      onClick: () => {
        this.pathStack.pop()
      }
    })
    this.records = await rdbHelper.getAllWorkouts()
  }

  @Builder
  workoutCard(record: WorkoutRecord) {
    Column({ space: 6 }) {
      Row() {
        Text(CommonUtils.formatDateShort(record.dateMillis))
          .fontSize(13)
          .fontColor($r('app.color.text_secondary'))
        Blank()
        Text(CommonUtils.formatTime(record.durationSeconds))
          .fontSize(48)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
      }
      .width('100%')

      Row({ space: 12 }) {
        Row({ space: 3 }) {
          Text(`${record.averageHR}`)
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.zone_3'))
          Text('avg')
            .fontSize(10)
            .fontColor($r('app.color.text_secondary'))
        }

        Row({ space: 3 }) {
          Text(`${record.maxHR}`)
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.status_danger'))
          Text('max')
            .fontSize(10)
            .fontColor($r('app.color.text_secondary'))
        }

        Blank()
        Row({ space: 3 }) {
          Text(`${record.steps}`)
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
          Text('steps')
            .fontSize(10)
            .fontColor($r('app.color.text_secondary'))
        }
      }
      .width('100%')
    }
    .width('100%')
    .padding(14)
    .borderRadius(18)
    .backgroundColor($r('app.color.bg_button_secondary'))
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        List({ space: 10 }) {
          ListItem() {
            Text($r('app.string.history_title'))
              .fontSize(20)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_primary'))
              .textAlign(TextAlign.Center)
              .width('100%')
              .margin({ top: 12, bottom: 4 })
          }

          if (this.records.length === 0) {
            ListItem() {
              Text($r('app.string.history_empty'))
                .fontSize(14)
                .fontColor($r('app.color.text_secondary'))
                .margin({ top: 40 })
            }
          } else {
            ForEach(this.records, (record: WorkoutRecord) => {
              ListItem() {
                this.workoutCard(record)
              }
              .onClick(() => {
                this.pathStack.pushPathByName('WorkoutDetail', JSON.stringify(record))
              })
            }, (record: WorkoutRecord) => record.id.toString())
          }
          ListItem() {
            Row().height(60)
          }
        }
        .width('88%')
        .height('100%')
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)

        ArcButton({ options: this.backOptions })
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
}