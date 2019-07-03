/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT name FROM
SB_COUNTRY_CLUB.Facilities
where membercost = 0


/* Q2: How many facilities do not charge a fee to members? */

SELECT count(*) FROM
SB_COUNTRY_CLUB.Facilities
where membercost = 0


/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT
facid
, name
, membercost
, monthlymaintenance
FROM
SB_COUNTRY_CLUB.Facilities
where membercost < 0.2*monthlymaintenance


/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT *
FROM SB_COUNTRY_CLUB.Facilities
where facid in (1,5)


/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT
name
, monthlymaintenance
, (case 
	when monthlymaintenance <= 100 then 'Cheap'
	when monthlymaintenance > 100 then 'Expensive'
   end) as MaintenanceLabel
FROM SB_COUNTRY_CLUB.Facilities

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT surname, firstname
FROM SB_COUNTRY_CLUB.Members
where joindate is not null 



/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

select distinct m.firstname, f.name
from SB_COUNTRY_CLUB.bookings b
JOIN SB_COUNTRY_CLUB.Facilities f
JOIN SB_COUNTRY_CLUB.members m
ON m.memid = b.memid
and b.facid = f.facid
and f.name like 'Tennis%'
order by 1


/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

select m.firstname
, f.name
, (f.membercost * b.slots ) as total_cost
from SB_COUNTRY_CLUB.bookings b
JOIN SB_COUNTRY_CLUB.Facilities f
JOIN SB_COUNTRY_CLUB.members m
where b.facid = f.facid
and m.memid = b.memid
and f.membercost * b.slots > 30
and date(b.starttime) = '2012-09-14'
and m.memid != 0
union
select m.firstname
, f.name
, (f.guestcost * b.slots ) as total_cost
from SB_COUNTRY_CLUB.bookings b
JOIN SB_COUNTRY_CLUB.Facilities f
JOIN SB_COUNTRY_CLUB.members m
where b.facid = f.facid
and m.memid = b.memid
and f.guestcost * b.slots > 30
and date(b.starttime) = '2012-09-14'
and m.memid = 0 
order by 3



/* Q9: This time, produce the same result as in Q8, but using a subquery. */

select
m.firstname
, cost.fac_name
, cost.total_member_or_guest_cost
from (select
	f.facid as fac_id
	, b.memid as member_id
	, f.name as fac_name
	, (CASE
		when (f.guestcost * b.slots) > 0 then (f.guestcost * b.slots)
		when (f.membercost * b.slots) > 0 then (f.membercost * b.slots)
	  end) as total_member_or_guest_cost
	from SB_COUNTRY_CLUB.bookings b
	JOIN SB_COUNTRY_CLUB.Facilities f
	where b.facid = f.facid) cost
JOIN SB_COUNTRY_CLUB.members m
ON m.memid = cost.member_id
and cost.total_member_or_guest_cost > 30


/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

select
cost.fac_name
, sum(cost.total_member_or_guest_cost)
from (select
	f.facid as fac_id
	, f.name as fac_name
	, (CASE
		when (f.guestcost * b.slots) > 0 then (f.guestcost * b.slots)
		when (f.membercost * b.slots) > 0 then (f.membercost * b.slots)
	  end) as total_member_or_guest_cost
	from SB_COUNTRY_CLUB.bookings b
	JOIN SB_COUNTRY_CLUB.Facilities f
	where b.facid = f.facid) cost
group by 1
having sum(cost.total_member_or_guest_cost) < 1000
order by 2
