import { appSettings } from '../services/AppSettings'
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
export struct Setup {
  pathStack: NavPathStack = new NavPathStack()
  @State age: number = 30
  startOptions: ArcButtonOptions = new ArcButtonOptions({})

  aboutToAppear(): void {
    this.age = appSettings.getAge()

    this.startOptions = new ArcButtonOptions({
      label: 'Start',
      status: ArcButtonStatus.NORMAL,
      position: ArcButtonPosition.BOTTOM_EDGE,
      styleMode: ArcButtonStyleMode.EMPHASIZED_LIGHT,
      fontSize: new LengthMetrics(15, LengthUnit.FP),
      shadowEnabled: true,
      onClick: () => {
        appSettings.setAge(this.age)
        this.pathStack.pushPathByName('Workout', `${this.age}`)
      }
    })
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        Column({ space: 2 }) {
          Text($r('app.string.setup_title'))
            .fontSize(16)
            .fontColor($r('app.color.text_primary'))
            .margin({ top: 12 })
          Text(`${this.age}`)
            .fontSize(60)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.zone_3'))
            .margin({ top: 6 })
          Text($r('app.string.crown_hint'))
            .fontSize(11)
            .fontColor($r('app.color.text_secondary'))
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .offset({ y: -20 })

        ArcButton({ options: this.startOptions })
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.bg_primary'))
      .focusable(true)
      .defaultFocus(true)
      .focusOnTouch(true)
      .onDigitalCrown((event: CrownEvent) => {
        event.stopPropagation()
        this.age = CommonUtils.adjustAge(this.age, event.degree)
      })
    }
    .hideTitleBar(true)
    .onReady((ctx: NavDestinationContext) => {
      this.pathStack = ctx.pathStack
    })
  }
}