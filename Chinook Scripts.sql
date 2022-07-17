/***
--> Digital Music Store - Data Analysis
Data Analysis project to help Chinook Digital Music Store to help how they can
optimize their business opportunities and to help answering business related questions.
***/

select * from Album; -- 347
select * from Artist; -- 275
select * from Customer; -- 59
select * from Employee; -- 8
select * from Genre; -- 25
select * from Invoice; -- 412
select * from InvoiceLine; -- 2240
select * from MediaType; -- 5
select * from Playlist; -- 18
select * from PlaylistTrack; -- 8715
select * from Track -- 3503
.


-- SQL Queries to answer some questions from the chinook database.
--1) Find the artist who has contributed with the maximum no of songs. Display the artist name and the no of albums.
    
	;WITH A as
    	(select alb.artistid
    	, count(1) as no_of_albums
    	, rank() over(order by count(1) desc) as rnk
    	from Album alb
    	group by alb.artistid)
    select art.name as artist_name, A.no_of_albums
    from A 
    join artist art on art.artistid = A.artistid
    where rnk = 1

--2) Display the name, email id, country of all listeners who love Jazz, Rock and Pop music.
    select concat (c.firstname,' ',c.lastname)customer_name,
    c.email, c.country, g.name as genre
    from InvoiceLine il
    join track t on t.trackid = il.trackid
    join genre g on g.genreid = t.genreid
    join Invoice i on i.invoiceid = il.invoiceid
    join customer c on c.customerid = i.customerid
    where g.name in ('Jazz', 'Rock', 'Pop');

--3) Identify all the albums who have less then 5 track under them.
   -- Display the album name, artist name and the no of tracks in the respective album.
      	
 
    select al.title as album_name, art.name as artist_name, count(1) as no_of_tracks
        from album al
        join track t on t.albumid = al.albumid
        join artist art on art.artistid = al.artistid
        group by al.title, art.name
        having count(1) < 5

--4) Which is the most popular and least popular genre?
   -- Popularity is defined based on how many times it has been purchased.
    select distinct
      first_value(g.name) over (order by count(1) desc) as most_popular
    , last_value(g.name) over (order by count(1) desc range between unbounded preceding and unbounded following ) as most_popular
    from InvoiceLine il
    join track t on t.trackid = il.trackid
    join genre g on g.genreid = t.genreid
    group by g.name
    order by 2 desc


--5) Find the employee who has supported the most no of customers. Display the employee name and designation
    select employee_name, title as designation
    from (
    	select concat (e.firstname,' ',e.lastname) as employee_name, e.title
    	, count(1) as no_of_customers
    	, rank() over(order by count(1) desc) as rnk
    	from Customer c
    	join employee e on e.employeeid=c.supportrepid
    	group by e.firstname,e.lastname, e.title) x
    where x.rnk=1

--6) Which city corresponds to the best customers?
    ;with temp as
    	(select city, sum(total) total_purchase_amt
    	, rank() over(order by sum(total) desc) as rnk
    	from Invoice i
    	join Customer c on c.Customerid = i.Customerid
    	group by city)
    select city
    from temp
    where rnk=1;

--7) The highest number of invoices belongs to which country?
    select country
    from (
    	select billingcountry as country, count(1) as no_of_invoice
    	, rank() over(order by count(1) desc) as rnk
    	from Invoice
    	group by billingcountry) x
    where x.rnk=1;

--8) Name the best customer (customer who spent the most money).
    select concat (c.firstname,' ',c.lastname) as customer_name
    from (
    	select customerid, sum(total) total_purchase
    	, rank() over(order by sum(total) desc) as rnk
    	from Invoice
    	group by customerid) x
    join customer c on c.customerid = x.customerid
    where rnk=1;

--9) Suppose you want to host a rock concert in a city and want to know which location should host it.
    --Query the dataset to find the city with the most rock-music listeners to answer this question.
    select I.billingcity, count(1)
    from Track T
    join Genre G on G.genreid = T.genreid
    join InvoiceLine IL on IL.trackid = T.trackid
    join Invoice I on I.invoiceid = IL.invoiceid
    where G.name = 'Rock'
    group by I.billingcity
    order by 2 desc;

--10) Display the track, album, artist and the genre for all tracks which are not purchased.
    select t.name as track_name, al.title as album_title, art.name as artist_name, g.name as genre
    from Track t
    join album al on al.albumid=t.albumid
    join artist art on art.artistid = al.artistid
    join genre g on g.genreid = t.genreid
    where not exists (select 1
    				 from InvoiceLine il
    				 where il.trackid = t.trackid); -- 1519 rows

--11) Find artists who have performed in multiple genres. Diplay the aritsts name and the genre.
    with temp as
    		(select distinct TOP 100 PERCENT  art.name as artist_name, g.name as genre
    		from Track t
    		join album al on al.albumid=t.albumid
    		join artist art on art.artistid = al.artistid
    		join genre g on g.genreid = t.genreid
    		order by 1,2),
    	final_artist as
    		(select artist_name
    		from temp t
    		group by artist_name
    		having count(1) > 1)
    select t.*
    from temp t
    join final_artist fa on fa.artist_name = t.artist_name
    order by 1,2;



--12) Identify if there are tracks more expensive than others. If there are then
    --display the track name along with the album title and artist name for these expensive tracks.
    select t.name as track_name, al.title as album_name, art.name as artist_name
    from Track t
    join album al on al.albumid = t.albumid
    join artist art on art.artistid = al.artistid
    where unitprice > (select min(unitprice) from Track)


