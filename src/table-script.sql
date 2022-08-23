CREATE TABLE IF NOT EXISTS departments (
	id serial PRIMARY KEY,
	department_name varchar(255),
  created_at timestamp NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS projects (
	id serial PRIMARY KEY,
	project_name varchar(255),
  department_id int REFERENCES departments (id),
  created_at timestamp NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS stp (
	id serial PRIMARY KEY,
  project_id int REFERENCES projects (id),
	stp_name varchar(255),
  prefix varchar(255) UNIQUE,
  capacity float,
  created_at timestamp NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS stp_data (
	id serial PRIMARY KEY,
	stp_id int REFERENCES stp (id),
  flow float,
  bod float,
  temperature float,
  timestamp varchar(20),
  nh4 float,
  cod float,
  ph float,
  tss float,
  created_at timestamp NOT NULL DEFAULT NOW(),
  UNIQUE (stp_id, timestamp)
);

CREATE TABLE IF NOT EXISTS stp_qual_accept (
	id serial PRIMARY KEY,
  ph float,
  tss float,
  bod float,
  cod float,
  og float,
  nh4 float,
  po4 float,
  flow float,
  temperature float,
  created_at timestamp NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS stp_data_calc (
	id serial PRIMARY KEY,
	stp_id int REFERENCES stp (id),
  date date UNIQUE,
  sewage_treated float,
  avg_bod float,
  avg_temperature float,
  avg_nh4 float,
  avg_cod float,
  avg_ph float,
  avg_tss float,
  created_at timestamp NOT NULL DEFAULT NOW()
);

-- INSERT DATA INTO TABLES

INSERT INTO stp_qual_accept
  ( ph, tss, bod, cod, og, nh4, po4, flow, temperature )
VALUES
  ( 9.1, 12.2, 12.3, 121.1, 11.3, 10.3, 2.3, 1.3, 0.3 );

INSERT INTO stp
  ( stp_name, prefix, capacity )
VALUES
  ( 'Keshopur Phase-I', 'KESHOPURPH1', 12 ),
  ( 'Keshopur Phase-II', 'KESHOPURPH2', 20 ),
  ( 'Keshopur Phase-III', 'KESHOPURPH3', 40 ),
  ( 'Rithala Ph. I', 'RITHALAPH1', 40 ),
  ( 'Rithala Ph. II', 'rithalaph2', 40 ),
  ( 'Coronation  Pillar(I&II)', 'CORONATIONPH1AND2', 20 ),
  ( 'Coronation Pillar-III', 'CORONATIONPH3', 10 ),
  ( 'Narela', 'narela', 10 ),
  ( 'Nilothi Phase-I', 'nilothiph1', 40 ),
  ( 'Nilothi Phase-II', 'NILOTHIPH2', 20 ),
  ( 'Najafgarh', 'NAJAFGARH', 5 ),
  ( 'Pappankakan Phase.I', 'PAPPANPH1', 20 ),
  ( 'Pappankakan Phase.II', 'papanph2', 20 ),
  ( 'Rohini', 'rohinisec25', 15 ),
  ( 'Kapashera', 'kapashera', 5 ),
  ( 'CWG Village', 'CWG', 1 ),
  ( 'DJB-Chilla', 'CHILLA', 9 ),
  ( 'DJB-Delhi Gate Nallah', 'DELHIGATEPH1', 10 ),
  ( 'DJB-Delhi Gate Nallah II', 'DELHIGATE2', 15 ),
  ( 'DJB-Dr Sen Nursing Home', 'DRSEN', 10 ),
  ( 'Ghitorni', 'ghitorni', 5 ),
  ( 'Yamuna Vihar Ph - 1', 'Yamunaph1', 10 ),
  ( 'Yamuna Vihar Phase-2', 'Yamunaph2', 10 ),
  ( 'Yamuna Vihar Ph - 3', 'yamunaph3', 25 ),
  ( 'Kondali Ph -1', 'NA', 10 ),
  ( 'DJB-Kondli Phase II', 'KONDLIPHASE2', 25 ),
  ( 'DJB-Kondli Phase IV', 'KONDLIPHASE4', 45 ),
  ( 'DJB-Mehrauli', 'MEHRAULI', 5 ),
  ( 'DJB-Molar Band', 'MOLARBAND', 0.66 ),
  ( 'DJB-Okhla Phase II', 'okhlaphii', 12 ),
  ( 'DJB-Okhla Phase III', 'okhlaphiii', 45 ),
  ( 'DJB-Okhla Phase IV', 'okhlaphiv', 37 ),
  ( 'DJB-Okhla Phase V', 'okhlaphv', 16 ),
  ( 'DJB-Okhla Phase VI', 'OKHLAPH6', 30 ),
  ( 'DJB-Vasant Kunj', 'VASANTKUNJ', 2.2 ),
  ( 'DJB-Vasant Kunj New', 'VASANTKUNJNW', 3 );
  

-- QUERIES

SELECT stp_id, s.stp_name, timestamp, sd.created_at, flow, bod, temperature, nh4, cod, ph, tss 
FROM stp_data sd
JOIN stp s ON s.id = sd.stp_id
GROUP BY stp_id, s.stp_name, timestamp, sd.created_at, flow, bod, temperature, nh4, cod, ph, tss
ORDER BY stp_id, timestamp ASC;