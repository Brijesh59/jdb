import cron from "node-cron";
import "dotenv/config";

import "./api.js";
import { Database as db } from "./db.js";

const runEvery = 5; // run every 5 minutes

const startApplication = async () => {
  // CONNECT TO THE DATABASE
  await db.connect();

  // ADD DATA FROM API TO THE DATABASE
  db.addSTPData();

  // ADD DATA FROM API TO THE DATABASE EVERY 5 MIN
  cron.schedule(`*/${runEvery} * * * *`, () => {
    db.addSTPData();
  });

  // CALCULATE AVG. OF EVERYDAYS DATA AT 1:00 AM DAILY
  cron.schedule(`0 1 * * *`, () => {
    db.addSTPCalcData();
  });
};

startApplication();
