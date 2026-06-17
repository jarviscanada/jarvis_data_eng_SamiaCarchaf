INSERT INTO cd.facilities (
    facid, name, membercost, guestcost, initialoutlay, monthlymaintenance
)
VALUES(
          9, 'Spa', 20, 30, 100000, 800
);

INSERT INTO cd.facilities(
    facid, name, membercost, guestcost, initialoutlay, monthlymaintenance
)
VALUES(
    (SELECT MAX(facid)+1 FROM cd.facilities),
    'Spa', 20, 30, 100000, 800
);

UPDATE cd.facilities
SET initialoutlay = 10000
WHERE name = 'Tennis Court 2';

UPDATE cd.facilities
SET membercost=(SELECT membercost * 1.1 FROM cd.facilities WHERE name='Tennis Court 1'),
    guestcost=(SELECT guestcost * 1.1 FROM cd.facilities WHERE name='Tennis Court 1')
WHERE name='Tennis Court 2';

DELETE FROM cd.bookings;

DELETE FROM cd.members
WHERE memid=37;

SELECT facid, name, membercost, monthlymaintenance
FROM cd.facilities
WHERE membercost < (monthlymaintenance/50) AND membercost > 0;

SELECT *
FROM cd.facilities
WHERE name LIKE '%Tennis%';

SELECT *
FROM cd.facilities
WHERE facid IN (1,5);

SELECT memid, surname, firstname, joindate
FROM cd.members
WHERE joindate > '2012-09-01';

SELECT surname FROM cd.members
UNION
SELECT name FROM cd.facilities;

SELECT starttime
FROM cd.bookings
         JOIN cd.members ON cd.bookings.memid = cd.members.memid
WHERE surname='Farrell' AND firstname='David';

SELECT starttime as start, name
FROM cd.bookings
         join cd.facilities
              ON cd.facilities.facid = cd.bookings.facid
WHERE
    starttime >= '2012-09-21' AND
    starttime < '2012-09-22' AND
    name IN ('Tennis Court 2','Tennis Court 1')
ORDER BY start;

SELECT mb.firstname as memfname, mb.surname as memsname, mbr.firstname as recfname, mbr.surname as recsname
FROM cd.members mb
         LEFT JOIN cd.members mbr
                   ON mbr.memid = mb.recommendedby
ORDER BY memsname, memfname;

SELECT DISTINCT mbr.firstname, mbr.surname
FROM cd.members mb
         JOIN cd.members mbr
              ON mb.recommendedby = mbr.memid
ORDER BY mbr.surname, mbr.firstname;

SELECT DISTINCT mb.firstname ||' ' || mb.surname AS member,
                (SELECT mbr.firstname || ' ' || mbr.surname
                 FROM cd.members mbr
                 WHERE mbr.memid = mb.recommendedby)AS recommender
FROM cd.members mb
ORDER BY member;

SELECT recommendedby, COUNT(*)
FROM cd.members
where recommendedby is not null
GROUP BY recommendedby
ORDER BY recommendedby;

SELECT facid, SUM(slots) as "Total Slots"
FROM cd.bookings
GROUP BY facid
ORDER BY facid;

SELECT facid, sum(slots) as "Total Slots"
FROM cd.bookings
WHERE starttime >= '2012-09-01' AND starttime < '2012-10-01'
GROUP BY facid
ORDER BY "Total Slots";

SELECT facid, EXTRACT(month from starttime) AS month, sum(slots) as "Total Slots"
FROM cd.bookings
WHERE EXTRACT(year from starttime) = 2012
GROUP BY facid, month;

SELECT count(DISTINCT memid)
FROM cd.bookings;

SELECT surname, firstname, mb. memid, MIN(starttime)
FROM cd.members mb
         JOIN cd.bookings bk
              ON mb.memid = bk.memid
WHERE starttime >= '2012-09-01'
GROUP BY mb.memid
ORDER BY mb.memid;

SELECT count(*) OVER(), firstname, surname
FROM cd.members
ORDER BY joindate;

SELECT
    ROW_NUMBER()OVER(ORDER BY joindate),
    firstname,
    surname
FROM cd.members
ORDER BY joindate;

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

SELECT surname || ', ' || firstname as name
FROM cd.members;

SELECT memid, telephone
FROM cd.members
WHERE telephone LIKE '%(%';

SELECT SUBSTRING(surname, 1, 1) AS initial, COUNT(*) AS member_count
FROM cd.members
GROUP BY initial
ORDER BY initial;

