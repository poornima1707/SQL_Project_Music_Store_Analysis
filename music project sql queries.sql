/*	Question Set 1 - Easy */

/* Q1: Who is the senior most employee based on job title? */
select * from employee
order by levels desc
limit 1;
/* Q2: Which countries have the most Invoices? */

select billing_country , count(billing_country) as count from invoice
group by billing_country
order by count desc;
/* Q3: What are top 3 values of total invoice? */
select total from invoice
order by total desc 
limit 3;

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */
select billing_city, sum(total) as invoice_total 
from invoice
group by billing_city
order by invoice_total desc;

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

select c.customer_id, c.first_name, c.last_name , sum(i.total) as total
from customer as c 
join invoice as i 
on c.customer_id = i.customer_id
group by c.customer_id 
order by total desc
limit 1;

/* Question Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

/* Method 1 */
select DISTINCT email, first_name, last_name 
from customer 
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id IN(
	select track_id from track
	join genre on track.genre_id = genre.genre_id
	where genre.name = 'Rock' )
order by email;
/* Method 2 */

SELECT DISTINCT email AS Email,first_name AS First_Name, last_name AS LastName, genre.name AS Name
FROM customer
JOIN invoice ON invoice.customer_id = customer.customer_id
JOIN invoice_line ON invoice_line.invoice_id = invoice.invoice_id
JOIN track ON track.track_id = invoice_line.track_id
JOIN genre ON genre.genre_id = track.genre_id

WHERE genre.name LIKE 'Rock'
ORDER BY email;


/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

select artist.artist_id, artist.name, count(track.track_id) as c
from artist 
join album on artist.artist_id = album.artist_id
join track on album.album_id = track.album_id 
join genre on genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
group by artist.artist_id
order by c desc 
limit 10;


/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

SELECT name , milliseconds  
from track 
where milliseconds > (SELECT AVG(milliseconds) AS avg_track_length
	FROM track )
order by milliseconds desc;


/* Question Set 3 - Advance */

/* Q1: Find how much amount spent by each customer on on top artist? Write a query to return customer name, artist name and total spent */

with best_selling_artist as (
	select artist.artist_id as artist_id ,artist.name as artist_name ,
	sum(invoice_line.quantity*invoice_line.unit_price) as total_sales
	from invoice_line
	join track on track.track_id = invoice_line.track_id
	join album on album.album_id = track.album_id
	join artist on artist.artist_id = album.artist_id
	group by 1
	order by 3 desc 
	limit 1
)
select c.customer_id, c.first_name, c.last_name, bsa.artist_name, sum(il.unit_price*il.quantity) as amount_spent
from invoice as i 
join customer c on  c.customer_id = i.customer_id
join invoice_line il ON il.invoice_id = i.invoice_id
join track t ON t.track_id = il.track_id
join album alb ON alb.album_id = t.album_id
join best_selling_artist bsa on bsa.artist_id = alb.artist_id
group by 1,2,3,4
order by 5 desc;

/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

with popular_genre as 
(select  count(invoice_line.quantity)as purchases, customer.country, genre.name, genre.genre_id,
ROW_NUMBER() OVER (PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS Row_no
from invoice_line
join invoice on invoice_line.invoice_id = invoice.invoice_id 
JOIN customer ON customer.customer_id = invoice.customer_id
JOIN track ON track.track_id = invoice_line.track_id
JOIN genre ON genre.genre_id = track.genre_id
group by 2,3,4
ORDER BY 2 ASC, 1 DESC
)
select * from popular_genre where row_no = 1;

/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

with customer_with_country as (
select customer.customer_id, customer.first_name,customer.last_name,invoice.billing_country, sum(total)as total_spending,
ROW_NUMBER() OVER(PARTITION BY invoice.billing_country ORDER BY sum(total) DESC) AS ROW_NO
FROM invoice 
join customer ON customer.customer_id = invoice.customer_id
group by 1,2,3,4
order by 4 asc, 5 desc
 )
 select * from  customer_with_country where ROW_NO = 1	;