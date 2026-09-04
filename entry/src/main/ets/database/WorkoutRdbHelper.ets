import { relationalStore } from '@kit.ArkData'
import { BusinessError } from '@kit.BasicServicesKit'
import { WorkoutRecord } from '../model/WorkoutRecord'

const DB_NAME = 'ZoneTarget.db'
const TABLE = 'workouts'

export class WorkoutRdbHelper {
  private rdbStore: relationalStore.RdbStore | null = null

  async init(context: Context): Promise<void> {
    const config: relationalStore.StoreConfig = {
      name: DB_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    }
    try {
      this.rdbStore = await relationalStore.getRdbStore(context, config)
      await this.createTable()
    } catch (err) {
      const e = err as BusinessError
      console.error(`DB init failed: ${e.message}`)
    }
  }

  async insertWorkout(record: WorkoutRecord): Promise<number> {
    if (!this.rdbStore) {
      return -1
    }
    const bucket: relationalStore.ValuesBucket = {
      date_millis: record.dateMillis,
      duration_seconds: record.durationSeconds,
      average_hr: record.averageHR,
      max_hr: record.maxHR,
      steps: record.steps,
      zone_seconds_json: record.zoneSecondsJson
    }
    try {
      return await this.rdbStore.insert(TABLE, bucket)
    } catch (err) {
      const e = err as BusinessError
      console.error(`Insert failed: ${e.message}`)
      return -1
    }
  }

  async getAllWorkouts(): Promise<WorkoutRecord[]> {
    if (!this.rdbStore) {
      return []
    }
    const predicates = new relationalStore.RdbPredicates(TABLE)
    predicates.orderByDesc('date_millis')

    const records: WorkoutRecord[] = []
    try {
      const resultSet = await this.rdbStore.query(predicates)
      while (resultSet.goToNextRow()) {
        records.push({
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          dateMillis: resultSet.getLong(resultSet.getColumnIndex('date_millis')),
          durationSeconds: resultSet.getLong(resultSet.getColumnIndex('duration_seconds')),
          averageHR: resultSet.getLong(resultSet.getColumnIndex('average_hr')),
          maxHR: resultSet.getLong(resultSet.getColumnIndex('max_hr')),
          steps: resultSet.getLong(resultSet.getColumnIndex('steps')),
          zoneSecondsJson: resultSet.getString(resultSet.getColumnIndex('zone_seconds_json'))
        })
      }
      resultSet.close()
    } catch (err) {
      const e = err as BusinessError
      console.error(`Query failed: ${e.message}`)
    }
    return records
  }

  private async createTable(): Promise<void> {
    const sql = `CREATE TABLE IF NOT EXISTS ${TABLE} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date_millis INTEGER NOT NULL,
      duration_seconds INTEGER NOT NULL,
      average_hr INTEGER NOT NULL,
      max_hr INTEGER NOT NULL,
      steps INTEGER NOT NULL,
      zone_seconds_json TEXT NOT NULL
     )`
    await this.rdbStore!.executeSql(sql)
  }
}

export const rdbHelper = new WorkoutRdbHelper()