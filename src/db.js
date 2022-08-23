import pkg from "pg";
import { fetchSTPData } from "./api.js";

const { Client } = pkg;

export class Database {
  static client = null;

  static async connect() {
    if (Database.client) return;

    const client = new Client({
      host: process.env.DB_HOST,
      database: process.env.DB_NAME,
      port: process.env.DB_PORT,
      user: process.env.DB_USERNAME,
      password: process.env.DB_PASSWORD,
    });

    try {
      await client.connect();
      console.error("DATABASE CONNECTION SUCCESS ✅");
      Database.client = client;
    } catch (err) {
      console.error(err.message);
      process.exit(1);
    }
  }

  static async getStpIdAndPrefix() {
    const client = Database.client;
    if (!client) {
      console.error("DATABASE NOT CONNECTED ❌");
      return;
    }

    try {
      const res = await client.query(`SELECT id, prefix FROM stp`);
      return res.rows;
    } catch (err) {
      console.log(err.message);
    }
  }

  static async addSTPData() {
    console.log("\n" + "-------------------------------");
    console.log(
      "RUNNING AT:",
      new Date().toLocaleDateString() + " " + new Date().toLocaleTimeString()
    );
    console.log("-------------------------------" + "\n");

    const client = Database.client;

    if (!client) {
      console.error("DATABASE NOT CONNECTED ❌");
      return;
    }

    // STEP 1: GET stpId & prefix from stp table
    const stps = await Database.getStpIdAndPrefix();

    // STEP 2: GET stp data from api and dump into db
    for (const stp of stps) {
      const data = await fetchSTPData(stp.prefix);

      if (!data?.result?.length) {
        console.warn("NO DATA FOUND FOR => ", stp.prefix);
        continue;
      }

      const values = [];

      data?.result.forEach((dataElement) =>
        values.push([
          stp.id,
          dataElement.flow || null,
          dataElement.bod || null,
          dataElement.temperature || null,
          dataElement.timestamp || null,
          dataElement.nh4 || null,
          dataElement.cod || null,
          dataElement.ph || null,
          dataElement.tss || null,
        ])
      );

      const query = {
        text: "INSERT INTO stp_data(stp_id, flow, bod, temperature, timestamp, nh4, cod, ph, tss) VALUES($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING *",
        values: values[0],
      };

      try {
        await client.query(query);
        console.error("DATA DUMPED TO DATABASE for", stp.prefix);
      } catch (err) {
        console.log(err.message);
      }
    }
  }
}
