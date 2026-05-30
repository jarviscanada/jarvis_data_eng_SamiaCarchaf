# Introduction
This project contains SQL queries practiced using a PostgreSQL database
and the pgexercises.com exercises.  
The system models a Club Management Database, where members can book facilities (e.g., tennis courts, gyms) and have their usage and payments tracked.  

Key Technologies:  
* PostgreSQL - Database management system
* Docker - Containerization for isolated environment
* Bash - Command-line scripting for automation
* Git & GitHub - Version control and collaboration

# Setup Instructions
1. Start the PostgreSQL instance using Docker:
```bash
docker container start jrvs-psql
```
2. Load the sample data into the database:
```bash
psql -U postgres -h localhost -f clubdata.sql -d postgres -x -q
```
# Table Setup (DDL)
```postgresql
CREATE DATABASE exercises;
\c exercises;
CREATE SCHEMA cd;

CREATE TABLE cd.facilities(
    facid integer NOT NULL PRIMARY KEY,
    name varchar(100) NOT NULL,
    membercost numeric NOT NULL,
    guestcost numeric NOT NULL,
    initialoutlay numeric NOT NULL,
    monthlymaintenance numeric NOT NULL
);

CREATE TABLE cd.bookings(
    bookid integer NOT NULL PRIMARY KEY,
    facid integer NOT NULL,
    memid integer NOT NULL,
    starttime timestamp without time zone NOT NULL,
    slots integer NOT NULL
);

CREATE TABLE cd.members(
    memid integer NOT NULL PRIMARY KEY,
    surname varchar(200) NOT NULL,
    firstname varchar(200) NOT NULL,
    address varchar(300) NOT NULL,
    zipcode integer NOT NULL,
    telephone varchar(20) NOT NULL,
    recommendedby integer,
    joindate timestamp without time zone NOT NULL
);

ALTER TABLE ONLY cd.members
    ADD CONSTRAINT fk_members_recommandedby FOREIGN KEY (recommendedby) REFERENCES cd.members(memid) ON DELETE SET NULL;

ALTER TABLE ONLY cd.bookings
    ADD CONSTRAINT fk_bookings_memid FOREIGN KEY (memid) REFERENCES cd.members(memid);

ALTER TABLE ONLY cd.bookings
    ADD CONSTRAINT fk_facilities_facid FOREIGN KEY (facid) REFERENCES cd.facilities(facid);
```

# Practice SQL Queries

* Question 1: Add a new facility (Spa)

```postgresql
INSERT INTO cd.facilities (
    facid, name, membercost, guestcost, initialoutlay, monthlymaintenance
)
VALUES(
    9, 'Spa', 20, 30, 100000, 800
);
```

---

* Question 2: Add Spa with auto-generate facid

```postgresql
INSERT INTO cd.facilities(
    facid, name, membercost, guestcost, initialoutlay, monthlymaintenance
)
VALUES(
  (SELECT MAX(facid)+1 FROM cd.facilities),
  'Spa', 20, 30, 100000, 800
);
```

---

* Question 3: Fix Tennis Court 2 initial outlay

```postgresql
UPDATE cd.facilities
SET initialoutlay = 10000
WHERE name = 'Tennis Court 2';
```

---

* Question 4: Increase Tennis Court 2 prices by 10% over Court 1

```postgresql
UPDATE cd.facilities
SET membercost=(SELECT membercost * 1.1 FROM cd.facilities WHERE name='Tennis Court 1'),
	guestcost=(SELECT guestcost * 1.1 FROM cd.facilities WHERE name='Tennis Court 1')
WHERE name='Tennis Court 2';
```

---

* Question 5: Delete all bookings

```postgresql
DELETE FROM cd.bookings;
```

---

* Question 6: Delete member 37 who has never booked

```postgresql
DELETE FROM cd.members 
WHERE memid=37;
```

---

* Question 7: Facilities where member cost < 1/50th of maintenance

```postgresql
SELECT facid, name, membercost, monthlymaintenance
FROM cd.facilities
WHERE membercost < (monthlymaintenance/50) AND membercost > 0;
```

---

* Question 8: Facilities with Tennis in name

```postgresql
SELECT *
FROM cd.facilities
WHERE name LIKE '%Tennis%';
```

---

* Question 9: Retrieve facilities with IDs 1 and 5

```postgresql
SELECT *
FROM cd.facilities
WHERE facid IN (1,5);
```

---

* Question 10: Members who joined after September 1, 2012

```postgresql
SELECT memid, surname, firstname, joindate
FROM cd.members
WHERE joindate > '2012-09-01';
```

---

* Question 11: Combined list of surnames and facility names

```postgresql
SELECT surname FROM cd.members
UNION
SELECT name FROM cd.facilities;
```

---

* Question 12: Start times for bookings by David Farrell

```postgresql
SELECT starttime
FROM cd.bookings
JOIN cd.members ON cd.bookings.memid = cd.members.memid 
WHERE surname='Farrell' AND firstname='David';
```

---

* Question 13: Bookings for tennis courts on 2012-09-21

```postgresql
SELECT starttime as start, name
FROM cd.bookings
	join cd.facilities 
		ON cd.facilities.facid = cd.bookings.facid
WHERE 
	starttime >= '2012-09-21' AND 
	starttime < '2012-09-22' AND
	name IN ('Tennis Court 2','Tennis Court 1')
ORDER BY start;
```

---

* Question 14: List all members and who recommended them

```postgresql
SELECT mb.firstname as memfname, mb.surname as memsname, mbr.firstname as recfname, mbr.surname as recsname
FROM cd.members mb
	LEFT JOIN cd.members mbr
		ON mbr.memid = mb.recommendedby
ORDER BY memsname, memfname;
```

---

* Question 15: List all members who have recommended another member

```postgresql
SELECT DISTINCT mbr.firstname, mbr.surname
FROM cd.members mb
	JOIN cd.members mbr
		ON mb.recommendedby = mbr.memid
ORDER BY mbr.surname, mbr.firstname;
```

---

* Question 16: List all members and their recommender without joins

```postgresql
SELECT DISTINCT mb.firstname ||' ' || mb.surname AS member,
	(SELECT mbr.firstname || ' ' || mbr.surname 
	 FROM cd.members mbr
	 WHERE mbr.memid = mb.recommendedby)AS recommender
FROM cd.members mb
ORDER BY member;
```

---

* Question 17: Count recommendations per member

```postgresql
SELECT recommendedby, COUNT(*)
FROM cd.members
where recommendedby is not null
GROUP BY recommendedby
ORDER BY recommendedby;
```

---

* Question 18: Total number of slots booked per facility

```postgresql
SELECT facid, SUM(slots) as "Total Slots"
FROM cd.bookings
GROUP BY facid
ORDER BY facid;
```

---

* Question 19: Total slots per facility in September 2012

```postgresql
SELECT facid, sum(slots) as "Total Slots" 
FROM cd.bookings
WHERE starttime >= '2012-09-01' AND starttime < '2012-10-01'
GROUP BY facid
ORDER BY "Total Slots";
```

---

* Question 20: Total slots per facility per month in 2012

```postgresql
SELECT facid, EXTRACT(month from starttime) AS month, sum(slots) as "Total Slots"
FROM cd.bookings
WHERE EXTRACT(year from starttime) = 2012
GROUP BY facid, month;
```

---

* Question 21: Count members who made at least one booking

```postgresql
SELECT count(DISTINCT memid)
FROM cd.bookings;
```

---

* Question 22: First booking after September 1st 2012 per member

```postgresql
SELECT surname, firstname, mb. memid, MIN(starttime) 
FROM cd.members mb
	JOIN cd.bookings bk
		ON mb.memid = bk.memid
WHERE starttime >= '2012-09-01'
GROUP BY mb.memid
ORDER BY mb.memid;
```

---

* Question 23: Total member count per join date

```postgresql
SELECT count(*) OVER(), firstname, surname
FROM cd.members
ORDER BY joindate;
```

---

* Question 24: Monotonically increasing list of members

```postgresql
SELECT 
	ROW_NUMBER()OVER(ORDER BY joindate),
	firstname,
	surname
FROM cd.members 
ORDER BY joindate;
```

---

* Question 25: Facility with highest total slots booked

```postgresql
SELECT facid, total
FROM (
  SELECT 
  	facid,
  	SUM(slots) as total,
  	RANK() OVER(ORDER BY SUM(slots) DESC) rank 
  FROM cd.bookings
  GROUP BY facid
  ) as ranked
WHERE rank=1;
```

---

* Question 26: Output names formatted as 'Surname, Firstname'

```postgresql
SELECT surname || ', ' || firstname as name
FROM cd.members;
```

---

* Question 27: Members with parentheses in telephone numbers

```postgresql
SELECT memid, telephone
FROM cd.members
WHERE telephone LIKE '%(%';
```

---

* Question 28: Count members by first letter of surname

```postgresql
SELECT SUBSTRING(surname, 1, 1) AS initial, COUNT(*) AS member_count
FROM cd.members
GROUP BY initial
ORDER BY initial;
```
