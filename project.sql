--deleting the tables
DROP TABLE trains CASCADE CONSTRAINTS;
DROP TABLE stations CASCADE CONSTRAINTS;
DROP TABLE route CASCADE CONSTRAINTS;
DROP TABLE dispatchers CASCADE CONSTRAINTS;
DROP TABLE disp_info CASCADE CONSTRAINTS;
DROP TABLE disp_salary CASCADE CONSTRAINTS;
DROP TABLE delays CASCADE CONSTRAINTS;

--creating the tables required for the project

CREATE TABLE trains(
    train_id varchar2(10) CONSTRAINT pk_tid PRIMARY KEY,
    train_capacity number(2) CONSTRAINT nn_tc NOT NULL,
    train_type varchar2(20)
);

CREATE TABLE stations(
    station_id varchar2(10) CONSTRAINT pk_sid PRIMARY KEY,
    station_name varchar2(50) CONSTRAINT nn_name NOT NULL
);

CREATE TABLE route(
    route_id number(5) CONSTRAINT pk_rid PRIMARY KEY,
    station_id varchar2(10) REFERENCES stations(station_id),
    train_id varchar2(10) REFERENCES trains(train_id),
    route_day DATE DEFAULT SYSDATE,
    route_hour TIMESTAMP DEFAULT SYSTIMESTAMP 
);

CREATE TABLE dispatchers(
    admin_id number(5) CONSTRAINT pk_aid PRIMARY KEY,
    first_name varchar2(20) CONSTRAINT nn_fn NOT NULL,
    last_name varchar2(20) CONSTRAINT nn_ln NOT NULL,
    email varchar2(50) CONSTRAINT ck_email CHECK(email LIKE '%@%'),
    phone varchar2(10),
    address varchar2(60) 
);

CREATE TABLE disp_info(
    disp_id number(5) REFERENCES dispatchers(admin_id),
    ranks varchar2(20),
    disp_info_id number(5) REFERENCES disp_info(disp_id),
    CONSTRAINT uk_did UNIQUE(disp_id)
);

CREATE TABLE disp_salary(
    salary number(5),
    commission_pct number(2,2),
    disp_id number(5) REFERENCES disp_info(disp_id),
    CONSTRAINT uk_diid UNIQUE(disp_id)
);

CREATE TABLE delays(
    delay_id number(5) CONSTRAINT pk_did PRIMARY KEY,
    route_id number(4) REFERENCES route(route_id),
    expected_arrival TIMESTAMP CONSTRAINT nn_exarr NOT NULL,
    actual_arrival TIMESTAMP DEFAULT NULL,
    expected_departure TIMESTAMP CONSTRAINT nn_exdep NOT NULL,
    actual_departure TIMESTAMP DEFAULT NULL,
    delay_explanation varchar2(100),
    delay_code number(4) DEFAULT 1000,
    admin_id number(5) REFERENCES dispatchers(admin_id)
);

--inserting values(some of the train id's are taken from www.cfrcalatori.ro 
--with some modified data)
INSERT INTO trains VALUES('R-E9213', 3, 'Regio Express');
INSERT INTO trains VALUES('R-E9208',2,'Regio Express');
INSERT INTO trains VALUES('R-E9214',1,'Regio Express');
INSERT INTO trains VALUES('IR1581', 4,'InterRegio');
INSERT INTO trains VALUES('IR1587', 2,'InterRegio');
INSERT INTO trains VALUES('IR1583', 4, 'InterRegio');
INSERT INTO trains VALUES('IR1826',3,'InterRegio');
INSERT INTO trains VALUES('IR1824', 4, 'InterRegio');
INSERT INTO trains VALUES('IC531', 6, 'InterCity');
INSERT INTO trains VALUES('IC533',1,'InterCity');
INSERT INTO trains VALUES('R9531', 1, 'Regio');
INSERT INTO trains VALUES('R9533', 1,'Regio');
INSERT INTO trains VALUES('R9535', 2,'Regio');

SELECT * FROM trains;

--populating the stations table with the following "routes":
--pitesti - bucuresti (92--)
INSERT INTO stations VALUES('PITE','Pitesti');
--bucuresti - constanta (15--)
INSERT INTO stations VALUES('BUCU-N','Bucuresti Nord');
INSERT INTO stations VALUES('CONS','Constanta');
--ploiesti vest - brasov(5--)
INSERT INTO stations VALUES('PLOI-V','Ploiesti Vest');
INSERT INTO stations VALUES('BRAS','Brasov');
--craiova - videle (18--)
INSERT INTO stations VALUES('CRAI','Craiova');
INSERT INTO stations VALUES('VIDE','Videle');
--bascov - curtea de arges (95--)
INSERT INTO stations VALUES('BASC','Bascov');
INSERT INTO stations VALUES('CU-D-A','Curtea de Arges');

SELECT * FROM stations;

--populating any table related to dispatchers
INSERT INTO dispatchers VALUES(41172,'Teea','Cranga', 'teea.cranga@gmail.com', '0734902342', 'Drumul Osiei 18-28');
INSERT INTO dispatchers VALUES(21031,'Alina','Popescu','alinapopescu22@yahoo.com','0775674343','Str. Zefirului 23');
INSERT INTO dispatchers VALUES(39823,'Alina','Vlaicu','alina233@gmail.com','0776442784','Str. Unirii 22-32');
INSERT INTO dispatchers VALUES(43058,'Adrian','Zarnoianu','adrian_z@gmail.com','0745566212','Str. Preciziei');
INSERT INTO dispatchers VALUES(32120,'Bianca','Dragan','anamaria_dragan@yahoo.com','0778348685','Str. Ion Minulescu');
INSERT INTO dispatchers VALUES(13013,'Andreea','Lificiu','lificiu.andre@gmail.com','0756467245','Str. Stejarului');
INSERT INTO dispatchers VALUES(65234,'Ana','Tudor','antudo@outlook.com','0788458212','Str. Lujerului');

SELECT * FROM dispatchers;

INSERT INTO disp_info VALUES(41172,'Admin',NULL);
INSERT INTO disp_info VALUES(21031,'OPERATOR',41172); 
INSERT INTO disp_info VALUES(39823,'DISPATCHER',21031);
INSERT INTO disp_info VALUES(43058,'DISPATCHER',21031);
INSERT INTO disp_info VALUES(32120,'Guest',39823);    
INSERT INTO disp_info VALUES(13013,'Guest',43058);
INSERT INTO disp_info VALUES(65234,'Guest',43058);

SELECT * FROM disp_info;

INSERT INTO disp_salary VALUES(12000,.5, 41172);
INSERT INTO disp_salary VALUES(9000,.4, 21031);
INSERT INTO disp_salary VALUES(3000,.15, 13013);

SELECT * FROM disp_salary;

ALTER TABLE disp_info
ADD first_name varchar2(20);
ALTER TABLE disp_info
ADD last_name varchar2(20);

UPDATE disp_info di
SET di.first_name=(SELECT d.first_name FROM dispatchers d WHERE d.admin_id=di.disp_id);

UPDATE disp_info di
SET di.last_name=(SELECT d.last_name FROM dispatchers d WHERE d.admin_id=di.disp_id);

SELECT * FROM disp_info;

ALTER TABLE dispatchers
DROP COLUMN first_name;

ALTER TABLE dispatchers
DROP COLUMN last_name;

SELECT * FROM dispatchers;

--before adding anything, i will alter the table so that it accepts the date the train arrives and the destination
ALTER TABLE route
ADD date_arrival TIMESTAMP DEFAULT SYSTIMESTAMP;
ALTER TABLE route
ADD destination varchar(10) REFERENCES stations(station_id);

--populating route
--(the odd ones go to station B, the even ones go back to station A)
INSERT INTO route VALUES(9201,'PITE','R-E9208',TO_DATE('03-01-2023', 'dd-mm-yyyy'),TO_TIMESTAMP('03-01-2023 14:00', 'dd-mm-yyyy hh24:mi'),TO_TIMESTAMP('03-01-2023 15:41','dd-mm-yyyy hh24:mi'),'BUCU-N');
INSERT INTO route VALUES(9202,'BUCU-N','R-E9213',TO_DATE('03-01-2023','dd-mm-yyyy'),TO_TIMESTAMP('03-01-2023 09:03','dd-mm-yyyy hh24:mi'),TO_TIMESTAMP('03-01-2023 10:53', 'dd-mm-yyyy hh24:mi'),'PITE');

INSERT INTO route VALUES(1501,'BUCU-N','IR1581',TO_DATE('04-01-2023','dd-mm-yyyy'),TO_TIMESTAMP('04-01-2023 10:12','dd-mm-yyyy hh24:mi'),TO_TIMESTAMP('04-01-2023 12:33','dd-mm-yyyy hh24:mi'),'CONS');
INSERT INTO route VALUES(1502,'CONS','IR1583',TO_DATE('07-01-2023','dd-mm-yyyy'),TO_TIMESTAMP('07-01-2023 11:30','dd-mm-yyyy hh24:mi'),TO_TIMESTAMP('07-01-2023 14:07','dd-mm-yyyy hh24:mi'),'BUCU-N');

INSERT INTO route VALUES(502,'PLOI-V','IC531',TO_DATE('05-01-2023','dd-mm-yyyy'),TO_TIMESTAMP('05-01-2023 10:42','dd-mm-yyyy hh24:mi'),TO_TIMESTAMP('05-01-2023 12:34','dd-mm-yyyy hh24:mi'),'BRAS');
INSERT INTO route VALUES(501,'BRAS','IC533',TO_DATE('05-01-2023','dd-mm-yyyy'),TO_TIMESTAMP('05-01-2023 15:30','dd-mm-yyyy hh24:mi'),TO_TIMESTAMP('05-01-2023 17:44','dd-mm-yyyy hh24:mi'),'PLOI-V');

INSERT INTO route VALUES(1801,'CRAI','IR1824',TO_DATE('06-01-2023','dd-mm-yyyy'),TO_TIMESTAMP('06-01-2023 14:10','dd-mm-yyyy hh24:mi'),TO_TIMESTAMP('06-01-2023 15:30','dd-mm-yyyy hh24:mi'),'VIDE');
INSERT INTO route VALUES(1802,'VIDE','IR1826',TO_DATE('06-01-2023','dd-mm-yyyy'),TO_TIMESTAMP('08-01-2023 05:54','dd-mm-yyyy hh24:mi'),TO_TIMESTAMP('08-01-2023 08:37','dd-mm-yyyy hh24:mi'),'CRAI');

INSERT INTO route VALUES(9501,'BASC','R9531',TO_DATE('08-01-2023','dd-mm-yyyy'),TO_TIMESTAMP('08-01-2023 13:55','dd-mm-yyyy hh24:mi'),TO_TIMESTAMP('08-01-2023 14:40','dd-mm-yyyy hh24:mi'),'CU-D-A');
INSERT INTO route VALUES(9502,'CU-D-A','R9533',TO_DATE('05-01-2023','dd-mm-yyyy'),TO_TIMESTAMP('05-01-2023 12:30','dd-mm-yyyy hh24:mi'),TO_TIMESTAMP('05-01-2023 13:13','dd-mm-yyyy hh24:mi'),'BASC');

select * from route;

--populating delays
INSERT INTO delays VALUES(10,
                        1502,
                        TO_TIMESTAMP('04-01-2023 12:33','dd-mm-yyyy hh24:mi'),
                        TO_TIMESTAMP('04-01-2023 12:40','dd-mm-yyyy hh24:mi'),
                        TO_TIMESTAMP('04-01-2023 12:35','dd-mm-yyyy hh24:mi'),
                        TO_TIMESTAMP('04-01-2023 12:42','dd-mm-yyyy hh24:mi'),
                        'Unexpected stops until station Cernavoda Pod',
                        1002,
                        39823);
                      
INSERT INTO delays VALUES(11,
                        1502,
                        TO_TIMESTAMP('04-01-2023 14:07','dd-mm-yyyy hh24:mi'),
                        TO_TIMESTAMP('04-01-2023 14:16','dd-mm-yyyy hh24:mi'),
                        TO_TIMESTAMP('04-01-2023 14:16','dd-mm-yyyy hh24:mi'),   --reached bucuresti nord
                        null,                                                    --therefore we don't need departure
                        'Unexpected stops until station Cernavoda Pod',
                        1002,
                        32120);
INSERT INTO delays VALUES(12,
                         1801,
                         TO_TIMESTAMP('06-01-2023 14:10','dd-mm-yyyy hh24:mi'), --delay at the departure from craiova
                         null,                                                  --therefore we don't need a date for arrival
                         TO_TIMESTAMP('06-01-2023 14:10','dd-mm-yyyy hh24:mi'),
                         TO_TIMESTAMP('04-01-2023 14:30','dd-mm-yyyy hh24:mi'),
                         'Waiting for other train to reach Craiova station',
                         1001,
                         43058
                         );
INSERT INTO delays VALUES(13,
                         1801,
                         TO_TIMESTAMP('04-01-2023 14:30','dd-mm-yyyy hh24:mi'),
                         TO_TIMESTAMP('04-01-2023 14:55','dd-mm-yyyy hh24:mi'),
                         TO_TIMESTAMP('04-01-2023 14:32','dd-mm-yyyy hh24:mi'),
                         TO_TIMESTAMP('04-01-2023 14:57','dd-mm-yyyy hh24:mi'),
                        'Unexpected stops until Caracal',
                        1002,
                        43058
                         );
                        
INSERT INTO delays VALUES(14,
                         1801,
                         TO_TIMESTAMP('04-01-2023 15:30','dd-mm-yyyy hh24:mi'),
                         TO_TIMESTAMP('04-01-2023 15:55','dd-mm-yyyy hh24:mi'),
                         TO_TIMESTAMP('04-01-2023 15:55','dd-mm-yyyy hh24:mi'),
                         null,
                         '-',
                        default,
                        43058
                         );                 
INSERT INTO delays VALUES(15,
                         9202,
                         TO_TIMESTAMP('03-01-2023 09:43','dd-mm-yyyy hh24:mi'),
                         TO_TIMESTAMP('03-01-2023 09:44','dd-mm-yyyy hh24:mi'),
                         TO_TIMESTAMP('03-01-2023 09:44','dd-mm-yyyy hh24:mi'),
                         TO_TIMESTAMP('03-01-2023 09:45','dd-mm-yyyy hh24:mi'),
                         'Small delay at Titu',
                        default,
                        13013
                         ); 
INSERT INTO delays VALUES(16,
                         9202,
                         TO_TIMESTAMP('04-01-2023 10:12','dd-mm-yyyy hh24:mi'),
                         null,
                         TO_TIMESTAMP('04-01-2023 10:13','dd-mm-yyyy hh24:mi'),
                         null,
                         'Broken Train Engine. Passengers will be transfered to another train.',
                        1003,       
                        13013
                         ); 
INSERT INTO delays VALUES(17,
                         9501,
                         TO_TIMESTAMP('08-01-2023 13:55','dd-mm-yyyy hh24:mi'),
                         null,
                        TO_TIMESTAMP('08-01-2023 13:55','dd-mm-yyyy hh24:mi'),
                         null,
                         'Departure was cancelled.',
                        1004,
                        43058
                         );   
INSERT INTO delays VALUES(18,
                         502,
                        TO_TIMESTAMP('05-01-2023 12:34','dd-mm-yyyy hh24:mi'),
                        TO_TIMESTAMP('05-01-2023 12:50','dd-mm-yyyy hh24:mi'),
                        TO_TIMESTAMP('05-01-2023 12:34','dd-mm-yyyy hh24:mi'),
                        null,
                         'Unexpected stops until station Brasov',
                        1001,
                        39823
                         );                         
select * from delays;
--4. Using DML statements:

--the regio trains will have 2 coaches from now on. modify the values 
UPDATE trains 
SET train_capacity=2
WHERE train_id LIKE 'R____';

SELECT * from trains;

--update the rank columns so that all the ranks have capital letters only 
UPDATE disp_info
SET ranks=UPPER(RANKS);

SELECT * FROM disp_info;

--one of the dispatchers wrote the wrong delay code for "Unexpected stops" at the delay number 13. Update the code.
UPDATE delays
SET delay_code=1001
WHERE delay_id=13;

SELECT * FROM delays;

--delete the dispatcher with the name Ana Tudor
DELETE FROM dispatchers 
WHERE admin_id='65234';

DELETE FROM disp_info
WHERE first_name='Ana' 
AND last_name='Tudor';

SELECT * FROM dispatchers;
SELECT * FROM disp_info;

--adding her back
INSERT INTO dispatchers VALUES(65234,'antudo@outlook.com','0788458212','Str. Lujerului');
INSERT INTO disp_info VALUES(65234,'Guest',43058,'Ana','Tudor');

-- update the salary table by raising the dispatchers's salary using the commision pct column
-- if dispatchers are not in the table, add them with the multiplier 0.1 and add it to the basic salary (3000)
MERGE INTO disp_salary s
USING (SELECT admin_id FROM delays GROUP BY admin_id ORDER BY admin_id) d
ON (s.disp_id = d.admin_id)
WHEN MATCHED THEN
UPDATE SET s.salary = s.salary + s.salary *s.commission_pct
WHEN NOT MATCHED THEN
INSERT (s.disp_id, salary, commission_pct)
VALUES (d.admin_id, 3000 + 3000 * 0.1, 0.1);

SELECT * FROM disp_salary;

--EXERCISE 5:
--5. Diverse and relevant SELECT statements for the project theme

--display the interregio trains
SELECT * 
FROM trains
WHERE train_id LIKE 'IR%';

--display the trains with 3 or more coaches
SELECT train_id
FROM trains
WHERE train_capacity>=3;

--display the regio-express and interregio trains
SELECT train_id
FROM trains
WHERE train_type NOT IN('InterCity','Regio');

--display the routes and their trains that are scheduled to leave between the hours 10:00 and 14:59
SELECT route_id, route_day, train_id from route
WHERE EXTRACT(HOUR FROM route_hour) BETWEEN 10 AND 14
ORDER BY route_day;

--display the dispatchers whose names start with 'A'
SELECT *
FROM disp_info
WHERE SUBSTR(first_name, 1,1)='A'; 

--display the trains and how many minutes of delay they had at both arrival and departure
SELECT r.train_id, r.route_id, NVL(ABS(EXTRACT(MINUTE FROM d.actual_arrival-d.expected_arrival)),-1) AS "The delays on arrival",
NVL(ABS(EXTRACT(MINUTE FROM d.actual_departure-d.expected_departure)),-1) AS "The delays on departure"
FROM delays d, route r
WHERE d.route_id=r.route_id
ORDER BY r.train_id;

--display the names of the dispatchers who do not have the role DISPATCHER in the database
SELECT first_name, last_name, di.disp_id  
FROM dispatchers d, disp_info di 
WHERE d.admin_id=di.disp_id AND di.ranks!='DISPATCHER';

--select all the trains and their routes(if they have one)
SELECT t.train_id, station_id, destination
FROM trains t, route r
WHERE t.train_id=r.train_id(+)
UNION
SELECT t.train_id, station_id, destination
FROM trains t, route r
WHERE t.train_id=r.train_id;

--select the dispatchers who haven't reported any delay
SELECT first_name, last_name, d.delay_id
FROM disp_info di, delays d
WHERE d.admin_id(+)=di.disp_id
MINUS
SELECT first_name, last_name, d.delay_id
FROM disp_info di, delays d
WHERE d.admin_id=di.disp_id;

-- display the trains and their status in the delay table(if there is no record of a train, it means it has no delays)
SELECT  train_id, r.route_id, delay_code,
DECODE (
delay_code,
1003,'broken train',
1004,'cancelled',
NULL, 'no records of delays',
'only had delays') AS "Status"
FROM route r, delays d
WHERE d.route_id(+)=r.route_id;

-- display the dispatchers and their salary status
SELECT DISTINCT d.disp_id, first_name, last_name, salary, CASE
WHEN SALARY <= 5000 THEN 'low salary'
WHEN SALARY <= 9000 THEN 'medium salary'
ELSE 'high salary' END AS "Salary status"
FROM disp_info d, disp_salary s
WHERE  d.disp_id= s.disp_id;

--display the admin's email and address
SELECT email, address
FROM dispatchers
WHERE admin_id=(SELECT disp_id 
                FROM disp_info
                WHERE disp_info_id IS NULL);

-- make a view to see the ids of the dispatchers who declared more than 1 delay
CREATE VIEW active_dispatchers
AS
SELECT di.admin_id, COUNT(d.admin_id) AS "Number of delays declared"
FROM dispatchers di,  delays d
WHERE d.admin_id = di.admin_id
GROUP BY di.admin_id
HAVING COUNT(d.admin_id) > 1;

SELECT * FROM active_dispatchers;
DROP VIEW active_dispatchers;

-- create an index on arrival dates for trains
CREATE INDEX arriv_dates_tr ON route(date_arrival);
SELECT * FROM user_indexes;
DROP INDEX arriv_dates_tr;

-- create a synonym for the dispatchers' salaries table
CREATE SYNONYM D_SL FOR disp_salary;
SELECT * FROM D_SL;
DROP SYNONYM D_SL;

--create a sequence for trains that go to ploiesti vest
CREATE SEQUENCE train_seq
START WITH 1804 INCREMENT BY 2
MAXVALUE 1898 NOCYCLE ORDER;

SELECT train_seq.NEXTVAL
FROM DUAL;

INSERT INTO route VALUES(train_seq.NEXTVAL,'PLOI-V','IR1824',SYSDATE,SYSTIMESTAMP,SYSTIMESTAMP,'BRAS');

SELECT * FROM ROUTE;
DROP SEQUENCE train_seq;

--Hierarchical queries 
-- display the ranks of the dispatchers
SELECT LEVEL, ranks, first_name, last_name, SYS_CONNECT_BY_PATH(first_name,'\') AS "Hierarchy" 
FROM disp_info
CONNECT BY PRIOR disp_info_id=disp_id
ORDER BY level;