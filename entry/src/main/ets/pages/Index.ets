import { Setup } from './Setup'
import { Workout } from './Workout'
import { Summary } from './Summary'
import { History } from './History'
import { WorkoutDetail } from './WorkoutDetail'
import { Settings } from './Settings'

@Entry
@Component
struct Index {
  pathStack: NavPathStack = new NavPathStack()

  @Builder
  PageMap(name: string, param: string) {
    if (name === 'Setup') {
      Setup()
    } else if (name === 'Workout') {
      Workout({ age: parseInt(param) })
    } else if (name === 'Summary') {
      Summary({ summaryJson: param })
    } else if (name === 'History') {
      History()
    } else if (name === 'WorkoutDetail') {
      WorkoutDetail({ recordJson: param })
    } else if (name === 'Settings') {
      Settings()
    }
  }

  @Builder
  menuItem(labelKey: Resource, route: string, accentColor: Resource) {
    Row({ space: 12 }) {
      Circle({ width: 10, height: 10 })
        .fill(accentColor)
      Text(labelKey)
        .fontSize(17)
        .fontColor($r('app.color.text_primary'))
        .layoutWeight(1)
    }
    .width('100%')
    .padding({
      left: 18,
      right: 18,
      top: 16,
      bottom: 16
    })
    .borderRadius(18)
    .backgroundColor($r('app.color.bg_button_secondary'))
    .onClick(() => {
      this.pathStack.pushPathByName(route, '')
    })
  }

  build() {
    Navigation(this.pathStack) {
      List({ space: 10 }) {
        ListItem() {
          Text($r('app.string.app_name'))
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.zone_3'))
            .textAlign(TextAlign.Center)
            .width('100%')
            .margin({ top: 14, bottom: 6 })
        }

        ListItem() {
          this.menuItem($r('app.string.menu_workout'), 'Setup', $r('app.color.zone_2'))
        }

        ListItem() {
          this.menuItem($r('app.string.menu_history'), 'History', $r('app.color.zone_3'))
        }

        ListItem() {
          this.menuItem($r('app.string.menu_settings'), 'Settings', $r('app.color.zone_4'))
        }

        ListItem() {
          Row().height(20)
        }
      }
      .width('88%')
      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .hideTitleBar(true)
    .navDestination(this.PageMap)
  }
}