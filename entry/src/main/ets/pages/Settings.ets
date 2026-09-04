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
export struct Settings {
  pathStack: NavPathStack = new NavPathStack()
  @State age: number = 30
  @State soundEnabled: boolean = true
  backOptions: ArcButtonOptions = new ArcButtonOptions({})

  aboutToAppear(): void {
    this.age = appSettings.getAge()
    this.soundEnabled = appSettings.isSoundEnabled()

    this.backOptions = new ArcButtonOptions({
      label: 'Done',
      status: ArcButtonStatus.NORMAL,
      position: ArcButtonPosition.BOTTOM_EDGE,
      styleMode: ArcButtonStyleMode.EMPHASIZED_LIGHT,
      fontSize: new LengthMetrics(14, LengthUnit.FP),
      shadowEnabled: true,
      onClick: () => {
        this.pathStack.pop()
      }
    })
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        List({ space: 12 }) {
          ListItem() {
            Text($r('app.string.menu_settings'))
              .fontSize(20)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_primary'))
              .textAlign(TextAlign.Center)
              .width('100%')
              .margin({ top: 12, bottom: 4 })
          }

          ListItem() {
            Column({ space: 6 }) {
              Text($r('app.string.label_age'))
                .fontSize(13)
                .fontColor($r('app.color.text_secondary'))
                .width('100%')
              Row() {
                Text(`${this.age}`)
                  .fontSize(36)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.zone_3'))
                  .layoutWeight(1)
                Text($r('app.string.crown_hint'))
                  .fontSize(10)
                  .fontColor($r('app.color.text_secondary'))
              }
              .width('100%')
            }
            .width('100%')
            .padding(16)
            .borderRadius(18)
            .backgroundColor($r('app.color.bg_button_secondary'))
          }

          ListItem() {
            Row() {
              Text($r('app.string.setting_sound'))
                .fontSize(15)
                .fontColor($r('app.color.text_primary'))
                .layoutWeight(1)
              Toggle({ type: ToggleType.Switch, isOn: this.soundEnabled })
                .onChange((isOn: boolean) => {
                  this.soundEnabled = isOn
                  appSettings.setSoundEnabled(isOn)
                })
                .selectedColor($r('app.color.zone_2'))
            }
            .width('100%')
            .padding(16)
            .borderRadius(18)
            .backgroundColor($r('app.color.bg_button_secondary'))
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