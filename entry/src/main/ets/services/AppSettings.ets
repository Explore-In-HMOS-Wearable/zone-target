import { preferences } from '@kit.ArkData'

const STORE_NAME = 'zonetarget_settings'
const KEY_AGE = 'age'
const KEY_SOUND = 'sound_enabled'

export class AppSettings {
  private store: preferences.Preferences | null = null

  async init(context: Context): Promise<void> {
    try {
      this.store = await preferences.getPreferences(context, STORE_NAME)
    } catch (e) {
      console.error('AppSettings init failed')
    }
  }

  getAge(): number {
    if (!this.store) {
      return 30
    }
    return this.store.getSync(KEY_AGE, 30) as number
  }

  async setAge(age: number): Promise<void> {
    if (!this.store) {
      return
    }
    await this.store.put(KEY_AGE, age)
    await this.store.flush()
  }

  isSoundEnabled(): boolean {
    if (!this.store) {
      return true
    }
    return this.store.getSync(KEY_SOUND, true) as boolean
  }

  async setSoundEnabled(enabled: boolean): Promise<void> {
    if (!this.store) {
      return
    }
    await this.store.put(KEY_SOUND, enabled)
    await this.store.flush()
  }
}

export const appSettings = new AppSettings()