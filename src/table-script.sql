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
  ph_min float,
  ph_max float,
  tss float,
  bod float,
  cod float,
  og float,
  nh4 float,
  po4 float,
  temperature float,
  created_at timestamp NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS stp_data_calc (
	id serial PRIMARY KEY,
	stp_id int REFERENCES stp (id),
  date date,
  sewage_treated float,
  avg_bod float,
  avg_temperature float,
  avg_nh4 float,
  avg_cod float,
  avg_ph float,
  avg_tss float,
  created_at timestamp NOT NULL DEFAULT NOW()
  UNIQUE (stp_id, date)
);

-- INSERT DATA INTO TABLES

INSERT INTO stp_qual_accept
  ( ph_min, ph_max, tss, bod, cod, og, nh4, po4 )
VALUES
  ( 5.5, 9.0, 50, 30, 250, 10, 50, 5 );


INSERT INTO departments
  ( department_name )
VALUES
  ( 'Delhi Jal Board' ),
  ( 'Education' );


INSERT INTO projects
  ( project_name,  department_id)
VALUES
  ( 'Sewage Treatment Plant', 1 );


INSERT INTO stp
  ( project_id, stp_name, prefix, capacity )
VALUES
  ( 1, 'Keshopur Phase-I', 'KESHOPURPH1', 12 ),
  ( 1, 'Keshopur Phase-II', 'KESHOPURPH2', 20 ),
  ( 1, 'Keshopur Phase-III', 'KESHOPURPH3', 40 ),
  ( 1, 'Rithala Ph. I', 'RITHALAPH1', 40 ),
  ( 1, 'Rithala Ph. II', 'rithalaph2', 40 ),
  ( 1, 'Coronation  Pillar(I&II)', 'CORONATIONPH1AND2', 20 ),
  ( 1, 'Coronation Pillar-III', 'CORONATIONPH3', 10 ),
  ( 1, 'Narela', 'narela', 10 ),
  ( 1, 'Nilothi Phase-I', 'nilothiph1', 40 ),
  ( 1, 'Nilothi Phase-II', 'NILOTHIPH2', 20 ),
  ( 1, 'Najafgarh', 'NAJAFGARH', 5 ),
  ( 1, 'Pappankakan Phase.I', 'PAPPANPH1', 20 ),
  ( 1, 'Pappankakan Phase.II', 'papanph2', 20 ),
  ( 1, 'Rohini', 'rohinisec25', 15 ),
  ( 1, 'Kapashera', 'kapashera', 5 ),
  ( 1, 'CWG Village', 'CWG', 1 ),
  ( 1, 'DJB-Chilla', 'CHILLA', 9 ),
  ( 1, 'DJB-Delhi Gate Nallah', 'DELHIGATEPH1', 10 ),
  ( 1, 'DJB-Delhi Gate Nallah II', 'DELHIGATE2', 15 ),
  ( 1, 'DJB-Dr Sen Nursing Home', 'DRSEN', 10 ),
  ( 1, 'Ghitorni', 'ghitorni', 5 ),
  ( 1, 'Yamuna Vihar Ph - 1', 'Yamunaph1', 10 ),
  ( 1, 'Yamuna Vihar Phase-2', 'Yamunaph2', 10 ),
  ( 1, 'Yamuna Vihar Ph - 3', 'yamunaph3', 25 ),
  ( 1, 'Kondali Ph -1', 'NA', 10 ),
  ( 1, 'DJB-Kondli Phase II', 'KONDLIPHASE2', 25 ),
  ( 1, 'DJB-Kondli Phase IV', 'KONDLIPHASE4', 45 ),
  ( 1, 'DJB-Mehrauli', 'MEHRAULI', 5 ),
  ( 1, 'DJB-Molar Band', 'MOLARBAND', 0.66 ),
  ( 1, 'DJB-Okhla Phase II', 'okhlaphii', 12 ),
  ( 1, 'DJB-Okhla Phase III', 'okhlaphiii', 45 ),
  ( 1, 'DJB-Okhla Phase IV', 'okhlaphiv', 37 ),
  ( 1, 'DJB-Okhla Phase V', 'okhlaphv', 16 ),
  ( 1, 'DJB-Okhla Phase VI', 'OKHLAPH6', 30 ),
  ( 1, 'DJB-Vasant Kunj', 'VASANTKUNJ', 2.2 ),
  ( 1, 'DJB-Vasant Kunj New', 'VASANTKUNJNW', 3 );
  

-- QUERIES

SELECT stp_id, s.stp_name, timestamp, sd.created_at, flow, bod, temperature, nh4, cod, ph, tss 
FROM stp_data sd
JOIN stp s ON s.id = sd.stp_id
GROUP BY stp_id, s.stp_name, timestamp, sd.created_at, flow, bod, temperature, nh4, cod, ph, tss
HAVING DATE(timestamp) < '2022-08-23'
ORDER BY stp_id, timestamp ASC;