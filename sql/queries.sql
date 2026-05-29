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