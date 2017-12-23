use sakila;

/*  1a. Display the first and last names of all actors from the table `actor`.   */

select first_name, last_name
from actor

/*  1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`. */

drop table if exists Actor_Name;
create table Actor_Name (
    id INTEGER NOT NULL AUTO_INCREMENT,
    name VARCHAR(60) NOT NULL,
    PRIMARY KEY (id)
);
INSERT INTO Actor_Name (name)
SELECT concat(first_name, " ", last_name)
FROM actor;
SELECT * FROM Actor_Name;

/*  2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?  */

SELECT actor_id,first_name,last_name  
FROM actor
WHERE first_name LIKE '%Joe%';

/*  2b. Find all actors whose last name contain the letters `GEN`:  */

SELECT first_name,last_name  
FROM actor
WHERE last_name LIKE '%Gen%';

/* 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order: */

SELECT last_name, first_name  
FROM actor
WHERE last_name LIKE '%LI%';

/* 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:*/

SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

/* 3a. Add a `middle_name` column to the table `actor`. Position it between `first_name` and `last_name`. Hint: you will need to specify the data type.*/

ALTER TABLE Actor ADD middle_name VARCHAR (255) after first_name;
SELECT *
FROM Actor

/* 3b. You realize that some of these actors have tremendously long last names. Change the data type of the `middle_name` column to `blobs`.*/

ALTER TABLE Actor
RENAME COLUMN middle_name blobs;

/* 3c. Now delete the `middle_name` column.*/

ALTER TABLE Actor DROP COLUMN middle_name

/* 4a. List the last names of actors, as well as how many actors have that last name.*/

SELECT Last_Name, count(*)
FROM Actor
GROUP BY Last_Name
ORDER BY Last_Name
    
/* 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors*/
    
SELECT Last_Name, count(*) 
FROM Actor
GROUP BY Last_Name  
ORDER BY Last_Name
/* 4c. Oh, no! The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.*/
update my_table
set path = replace(path, 'GROUCH', 'HARPO')
    
/* 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`. Otherwise, change the first name to `MUCHO GROUCHO`, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO `MUCHO GROUCHO`, HOWEVER! (Hint: update the record using a unique identifier.)*/
/* 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?*/

describe sakila.address;

CREATE TABLE address (
  address_id   SMALLINT    UNSIGNED NOT NULL AUTO_INCREMENT,
  address      VARCHAR(50) NOT NULL,
  address2     VARCHAR(50) DEFAULT NULL,
  district     VARCHAR(20) NOT NULL,
  city_id      SMALLINT    UNSIGNED NOT NULL,
  postal_code  VARCHAR(10) DEFAULT NULL,
  phone        VARCHAR(20) NOT NULL,
  last_update  TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY  (address_id),
  KEY idx_fk_city_id (city_id),
  CONSTRAINT `fk_address_city` FOREIGN KEY (city_id) REFERENCES city (city_id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/* 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:*/

SELECT staff.first_name, staff.last_name, address.address  
FROM staff JOIN address ON staff.address_id = address.address_id;

/* 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`. */

SELECT payment.staff_id, staff.first_name, staff.last_name, SUM(payment.amount)  
FROM staff JOIN payment ON staff.staff_id = payment.staff_id
WHERE payment.payment_date LIKE '2005-08%'
group by staff.staff_id;  	
   
/* 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.*/
    
SELECT film.title, count(film_actor.actor_id)
FROM film join film_actor ON film.film_id = film_actor.film_id
GROUP BY film.title;
    
/* 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?*/

SELECT film.title, count(inventory.inventory_id)
FROM film join inventory ON film.film_id = inventory.film_id
WHERE title LIKE 'Hunchback Impossible';

/* 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:*/

SELECT customer.last_name, sum(payment.amount)
FROM payment JOIN customer on payment.customer_id = customer.customer_id
GROUP BY customer.last_name;

/* 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.*/ 

SELECT title
FROM film
WHERE (title LIKE 'q%' OR title LIKE 'k%')
AND language_id IN
    (
    SELECT language_id
    FROM language
    WHERE name = 'English'
    );

/* 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.*/

SELECT first_name, last_name
FROM actor
WHERE actor_id IN
(
  SELECT actor_id
  FROM film_actor
  WHERE film_id IN
  (
   SELECT film_id
   FROM film
   WHERE title = 'ALONE TRIP'
  )
);
   
/* 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.*/

SELECT first_name, last_name, email
FROM customer join address ON customer.address_id = address.address_id join city ON address.city_id = city.city_id join country ON city.country_id = country.country_id
WHERE country like 'Canada'

/* 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films.*/

SELECT title
FROM film
WHERE film_id IN
(
  SELECT film_id
  FROM film_category
  WHERE category_id IN
  (
   SELECT category_id
   FROM category
   WHERE name = 'Family'
  )
);
   
/* 7e. Display the most frequently rented movies in descending order.*/

SELECT film.title, count(rental.rental_date)
FROM film join inventory ON film.film_id = inventory.film_id join rental ON inventory.inventory_id = rental.inventory_id
GROUP BY film.title
ORDER BY count(rental.rental_date) DESC;
    
/* 7f. Write a query to display how much business, in dollars, each store brought in.*/

select * from sales_by_store;

/* 7g. Write a query to display for each store its store ID, city, and country.*/

SELECT store_id, city, country
FROM store join address ON store.address_id = address.address_id join city ON address.city_id = city.city_id join country ON city.country_id = country.country_id;

    
/* 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)*/

SELECT
  c.name AS category,
  SUM(p.amount) AS total_sales
FROM payment AS p
  INNER JOIN rental AS r ON p.rental_id = r.rental_id
  INNER JOIN inventory AS i ON r.inventory_id = i.inventory_id
  INNER JOIN film AS f ON i.film_id = f.film_id
  INNER JOIN film_category AS fc ON f.film_id = fc.film_id
  INNER JOIN category AS c ON fc.category_id = c.category_id
GROUP BY c.name
ORDER BY total_sales DESC
LIMIT 5;

/* 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.*/

CREATE VIEW sales_by_film_category_top_5
AS
SELECT
  c.name AS category,
  SUM(p.amount) AS total_sales
FROM payment AS p
  INNER JOIN rental AS r ON p.rental_id = r.rental_id
  INNER JOIN inventory AS i ON r.inventory_id = i.inventory_id
  INNER JOIN film AS f ON i.film_id = f.film_id
  INNER JOIN film_category AS fc ON f.film_id = fc.film_id
  INNER JOIN category AS c ON fc.category_id = c.category_id
GROUP BY c.name
ORDER BY total_sales DESC
LIMIT 5;
    
/* 8b. How would you display the view that you created in 8a?*/

SELECT * FROM sales_by_film_category_top_5

/* 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.*/

DROP VIEW sales_by_film_category_top_5;