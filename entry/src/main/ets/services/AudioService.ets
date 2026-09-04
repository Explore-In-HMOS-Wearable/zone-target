import { media } from '@kit.MediaKit'
import { audio } from '@kit.AudioKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { Context } from '@kit.AbilityKit'

export class AudioService {
  private context: Context
  private player: media.AVPlayer | undefined = undefined

  constructor(context: Context) {
    this.context = context
  }

  async playZone(zone: number): Promise<void> {
    if (zone < 1 || zone > 5) {
      return
    }
    const fileName = `zone_${zone}.mp3`
    try {
      if (this.player) {
        await this.player.reset()
      } else {
        this.player = await media.createAVPlayer()
        this.setupCallbacks()
      }
      const rawFd = this.context.resourceManager.getRawFdSync(fileName)
      this.player.fdSrc = {
        fd: rawFd.fd,
        offset: rawFd.offset,
        length: rawFd.length
      }
    } catch (error) {
      const e = error as BusinessError
      console.error(`playZone failed: ${e.code}`)
    }
  }

  async release(): Promise<void> {
    if (this.player) {
      await this.player.release()
      this.player = undefined
    }
  }

  private setupCallbacks(): void {
    if (!this.player) {
      return
    }
    this.player.on('stateChange', async (state: string) => {
      switch (state) {
        case 'initialized':
          await this.player!.prepare()
          break
        case 'prepared':
          await this.player!.play()
          break
        case 'completed':
          await this.player!.reset()
          break
      }
    })

    this.player.on('audioInterrupt', (info: audio.InterruptEvent) => {
      if (info.hintType === audio.InterruptHint.INTERRUPT_HINT_PAUSE ||
        info.hintType === audio.InterruptHint.INTERRUPT_HINT_STOP) {
        this.player?.pause()
      } else if (info.hintType === audio.InterruptHint.INTERRUPT_HINT_RESUME) {
        this.player?.play()
      }
    })

    this.player.on('audioOutputDeviceChangeWithInfo', (info: audio.AudioStreamDeviceChangeInfo) => {
      if (info.changeReason === audio.AudioStreamDeviceChangeReason.REASON_OLD_DEVICE_UNAVAILABLE) {
        this.player?.pause()
      }
    })
  }
}