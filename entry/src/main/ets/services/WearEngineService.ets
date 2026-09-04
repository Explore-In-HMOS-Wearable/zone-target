import { wearEngine } from '@kit.WearEngine';
import { util } from '@kit.ArkTS';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Context } from '@kit.AbilityKit';

export class WearEngineService {
  private phoneBundleName: string = 'TODO_BUNDLE_NAME'
  private phoneFingerprint: string = 'TODO_PHONE_FINGERPRINT'
  private deviceClient: wearEngine.DeviceClient;
  private p2pClient: wearEngine.P2pClient
  private targetDevice: wearEngine.Device | undefined;
  private textEncoder = new util.TextEncoder()

  constructor(context: Context) {
    this.deviceClient = wearEngine.getDeviceClient(context)
    this.p2pClient = wearEngine.getP2pClient(context)
  }

  async getConnectedDevice(): Promise<boolean> {
    try {
      const devices = await this.deviceClient.getConnectedDevices()
      hilog.info(0x0000, 'ZoneTarget', `Found ${devices.length} device(s)`)
      if (devices.length === 0) {
        return false
      }
      this.targetDevice = devices[0]
      return true
    } catch (error) {
      hilog.error(0x0000, 'ZoneTarget', `getConnectedDevices failed: ${error.code}`)
      return false
    }
  }

  async sendSummary(json: string): Promise<boolean> {
    if (!this.targetDevice) {
      const found = await this.getConnectedDevice()
      if (!found) {
        return false
      }
    }
    try {
      const message: wearEngine.P2pMessage = {
        content: this.textEncoder.encodeInto(json)
      }
      const appInfo: wearEngine.AppInfo = {
        bundleName: this.phoneBundleName,
        fingerprint: this.phoneFingerprint
      }
      const appParam: wearEngine.P2pAppParam = {
        remoteApp: appInfo
      }

      await this.p2pClient.sendMessage(this.targetDevice!.randomId, appParam, message)
      hilog.info(0x0000, 'ZoneTarget', 'Summary sent')
      return true
    } catch (error) {
      hilog.error(0x0000, 'ZoneTarget', `sendMessage failed: ${error.code}`)
      return false
    }
  }
}