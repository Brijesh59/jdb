import pkg from "pg";
import { fetchSTPData } from "./api.js";
import { roundToTwoDecimalPlaces, getPreviousDate } from "./helpers.js";

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
      "RUNNING addSTPData AT:",
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

  static async addSTPCalcData() {
    console.log("\n" + "-------------------------------");
    console.log(
      "RUNNING addSTPCalcData AT:",
      new Date().toLocaleDateString() + " " + new Date().toLocaleTimeString()
    );
    console.log("-------------------------------" + "\n");

    const client = Database.client;

    const query = {
      text: `
        SELECT stp_id, CAST(DATE(timestamp) AS varchar), timestamp, sd.created_at, flow, bod, temperature, nh4, cod, ph, tss 
        FROM stp_data sd
        GROUP BY stp_id, timestamp, sd.created_at, flow, bod, temperature, nh4, cod, ph, tss
        HAVING DATE(timestamp) = $1
        ORDER BY stp_id, timestamp ASC
      `,
      values: [getPreviousDate()],
    };

    let data = await client
      .query(query)
      .catch((err) => console.log(err.message));

    data = data?.rows;

    if (!data || data.length === 0) return;

    const avgData = {};

    // ADD
    data.forEach((stp_data) => {
      if (avgData[stp_data.stp_id]) {
        // UPDATE THE DATA
        avgData[stp_data.stp_id]["count"] += 1;
        avgData[stp_data.stp_id]["avg_flow"] += stp_data.flow || 0;
        avgData[stp_data.stp_id]["avg_bod"] += stp_data.bod || 0;
        avgData[stp_data.stp_id]["avg_temperature"] +=
          stp_data.temperature || 0;
        avgData[stp_data.stp_id]["avg_nh4"] += stp_data.nh4 || 0;
        avgData[stp_data.stp_id]["avg_cod"] += stp_data.cod || 0;
        avgData[stp_data.stp_id]["avg_ph"] += stp_data.ph || 0;
        avgData[stp_data.stp_id]["avg_tss"] += stp_data.tss || 0;
      } else {
        // ADD THE DATA
        avgData[stp_data.stp_id] = {
          count: 1,
          stp_id: stp_data.stp_id,
          date: stp_data.date,
          avg_flow: stp_data?.flow || 0,
          avg_bod: stp_data?.bod || 0,
          avg_temperature: stp_data?.temperature || 0,
          avg_nh4: stp_data?.nh4 || 0,
          avg_cod: stp_data?.cod || 0,
          avg_ph: stp_data?.ph || 0,
          avg_tss: stp_data?.tss || 0,
        };
      }
    });

    // AVG
    for (let key in avgData) {
      const count = avgData[key]["count"];
      avgData[key]["avg_flow"] = avgData[key]["avg_flow"] / count;
      avgData[key]["avg_bod"] = avgData[key]["avg_bod"] / count;
      avgData[key]["avg_temperature"] = avgData[key]["avg_temperature"] / count;
      avgData[key]["avg_nh4"] = avgData[key]["avg_nh4"] / count;
      avgData[key]["avg_cod"] = avgData[key]["avg_cod"] / count;
      avgData[key]["avg_ph"] = avgData[key]["avg_ph"] / count;
      avgData[key]["avg_tss"] = avgData[key]["avg_tss"] / count;
    }

    const dataArr = Object.values(avgData).map((dataEle) => ({
      stp_id: dataEle.stp_id,
      date: dataEle.date,
      sewage_treated:
        roundToTwoDecimalPlaces(dataEle.avg_flow) * 24 * 1000 * 0.264172, // in gallons
      avg_bod: roundToTwoDecimalPlaces(dataEle.avg_bod),
      avg_temperature: roundToTwoDecimalPlaces(dataEle.avg_temperature),
      avg_nh4: roundToTwoDecimalPlaces(dataEle.avg_nh4),
      avg_cod: roundToTwoDecimalPlaces(dataEle.avg_cod),
      avg_ph: roundToTwoDecimalPlaces(dataEle.avg_ph),
      avg_tss: roundToTwoDecimalPlaces(dataEle.avg_tss),
    }));

    const insertQuery = {
      text: `
      INSERT INTO stp_data_calc
        (stp_id, date, sewage_treated, avg_bod, avg_temperature, avg_nh4, avg_cod, avg_ph, avg_tss)
      VALUES
        ${dataArr
          .map((d) => {
            return `(${d.stp_id}, '${d.date}', ${d.sewage_treated}, ${d.avg_bod}, ${d.avg_temperature}, ${d.avg_nh4}, ${d.avg_cod}, ${d.avg_ph}, ${d.avg_tss})`;
          })
          .join(",")}
      `,
      values: [],
    };

    await client.query(insertQuery).catch((err) => console.log(err.message));
  }
}
