USE sakila;

-- CHALLENGE: Subqueries

-- ========================================================================================================================================================
-- 1. Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.
-- ========================================================================================================================================================
-- - To find the number of copies of a specific film in the inventory:

-- TABLES TO USE: 
-- film: Contains details about each film, including film_id and title.
SELECT film_id, title FROM film;
-- inventory: Contains information about the physical copies of each film, including inventory_id and film_id.
SELECT film_id, inventory_id, store_id FROM sakila.inventory;

-- APPROACH:
-- 1.1 Retrieve the film_id for "Hunchback Impossible".
-- 1.2 Count how many records exist in the inventory table for that film_id.

-- STEPS:
-- 1.1 Retrieve the Film ID for "Hunchback Impossible". 
-- Confirm that "Hunchback Impossible" is present in the film table.
-- Find the film_id for the title.
SELECT film_id, title FROM film 
WHERE title = 'Hunchback Impossible';

-- 1.2 Count the Inventory Items for the target film
-- Count the Copies: How many inventory items are associated with this film_id in the inventory table? 
-- Get the total number of inventory records (copies) associated with "Hunchback Impossible".
SELECT COUNT(inventory_id) AS number_of_copies 
FROM inventory 
WHERE film_id = (SELECT film_id FROM film WHERE title = 'Hunchback Impossible');
-- Subquery: (SELECT film_id FROM film WHERE title = 'Hunchback Impossible') calls the film_id for the desired film.
-- Main Query: The outer query uses the film_id from the subquery to count how many inventory items exist for that film.

-- Other approach using JOIN: Let's combine the queries: 
-- This version directly joins the film and inventory tables and counts the number of inventory items for the given title.
SELECT COUNT(i.inventory_id) AS number_of_copies 
FROM inventory i
JOIN film f ON i.film_id = f.film_id
WHERE f.title = 'Hunchback Impossible';

-- ========================================================================================================================================================
-- 2. List all films whose length is longer than the average length of all the films in the Sakila database.
-- ========================================================================================================================================================
-- This requires comparing each film's length to the average film length.
-- Useful for identifying films that are longer than typical films in the Sakila database.

-- TABLES TO USE: 
-- film: Contains details about each film, including film_id, title, and length.
SELECT film_id, title, length FROM sakila.film;

-- APPROACH:
-- 2.1 Use a subquery to calculate the average film length.
-- 3.1 Retrieve the films where their length is greater than this average.

-- STEPS:
-- 2.1 Calculate the average film length.
-- The average length of all films in the film table will be used to compare against the length of each individual film (understanding benchmark).
SELECT AVG(length) AS average_length 
FROM film;
-- 2.2 Use a subquery to filter films based on whether their length is greater than the average length.
-- The previous subquery calculates the average length and passes it to the main query.
-- Filter by Length: The main query filters the films to include only those with a length greater than the average calculated in the subquery.
SELECT title, length 
FROM film 
WHERE length > (SELECT AVG(length) FROM film);

-- ========================================================================================================================================================
-- 3. Use a subquery to display all actors who appear in the film "Alone Trip".
-- ========================================================================================================================================================
-- Useful to find all actors in a specific film.
-- Find and list all actors who appeared in the film titled "Alone Trip". 

-- TABLES TO USE: 
-- film: Contains details about each film, including film_id and title.
SELECT film_id, title FROM film;
-- actor: Contains details about each actor, including actor_id, first_name, and last_name.
SELECT actor_id, first_name, last_name FROM actor;
-- film_actor: Links actors to films via actor_id and film_id.
SELECT actor_id, film_id FROM film_actor;

-- APPROACH:
-- 3.1 Identify the film_id for "Alone Trip".
-- 3.2 Use that film_id in a subquery to find all actors associated with the film.
-- 3.3 Combine these steps into a final query that retrieves the names of all actors who appeared in the film.

-- STEPS:
-- 3.1 Retrieve the Film ID for "Alone Trip"
-- Start by retrieving the film_id for the specific movie "Alone Trip".
SELECT film_id, title FROM film WHERE title = 'Alone Trip';
-- 3.2  List Actor IDs for the Retrieved Film ID
-- Use the film_id, let's find all actor_ids associated with "Alone Trip" in the film_actor table.
SELECT actor_id FROM film_actor 
WHERE film_id = (SELECT film_id FROM film WHERE title = 'Alone Trip');
-- 3.3 Retrieve Actor Names Using a Subquery
-- Subquery: Retrieves all actor_ids for the film "Alone Trip".
-- Main Query: Calls the first_name and last_name of the actors whose actor_ids were identified by the subquery.
SELECT a.first_name, a.last_name 
FROM actor AS a
WHERE a.actor_id IN (SELECT actor_id FROM film_actor 
					 WHERE film_id = (SELECT film_id FROM film WHERE title = 'Alone Trip'));

-- ========================================================================================================================================================
-- BONUS 4. Identify all movies categorized as family films.
-- ========================================================================================================================================================
-- To target movies under the "Family" category.

-- TABLES TO USE: 
-- film: Contains details about each film, including film_id and title.
-- film_category: Links films to categories via film_id and category_id.
-- category: Contains details about each category, including category_id and name

-- APPROACH:
-- 4.1 Retrieve the category_id for the "Family" category.
-- 4.2 Use the category_id to list the film_ids associated with the "Family" category.
-- 4.3 Combine these steps into a final query that retrieves the titles of all films in the "Family" category.

-- STEPS:
-- 4.1 Retrieve the category_id for the "Family" category.
-- Identifying the category_id associated with the "Family" category in order to use it to filter the films.
SELECT category_id, name FROM category WHERE name = 'Family';
-- 4.2 List Film IDs for the "Family" Category
-- Link Films to the Family Category: Check that the film_ids call for films categorized under "Family".
-- Middle Subquery: Using the category_id to find all film_ids in the film_category table that are associated with the "Family" category.
SELECT film_id FROM film_category 
WHERE category_id = (SELECT category_id FROM category WHERE name = 'Family');
-- 4.3 Retrieve Film Titles in the "Family" Category
-- 4.3.1 Using a SQL Query Using a Subquery:
-- Filtering the film table by those film_ids to retrieve the titles of all "Family" films.
-- -- Main Query: The main query filters the film table by selecting films where the film_id matches any of the film_ids found by the middle subquery.
SELECT title FROM film 
WHERE film_id IN (SELECT film_id FROM film_category 
				  WHERE category_id = (SELECT category_id FROM category WHERE name = 'Family'));
-- 4.3.2 Other way, it's to join the tables
-- The JOIN operations combine the film, film_category, and category tables, allowing you to filter films by their category.
-- Final Output: The main query retrieves the title of films that are categorized as "Family".
SELECT f.title FROM film AS f
JOIN film_category AS fc ON f.film_id = fc.film_id
JOIN category AS c ON fc.category_id = c.category_id
WHERE c.name = 'Family';

-- ========================================================================================================================================================
-- BONUS 5. Retrieve the name and email of customers from Canada using both subqueries and joins.
-- ========================================================================================================================================================
-- To retrieve the first name, last name, and email of customers who are from Canada. 

-- TABLES TO USE: 
-- customer: Contains details about each customer including customer_id, first_name, last_name, email, and address_id.
SELECT customer_id, first_name, last_name, email, address_id FROM customer;
-- address: Contains details about each address including address_id, city_id, and other address details.
SELECT address_id, city_id, district, city_id FROM address;
-- city: Contains details about each city including city_id and country_id.
SELECT city_id, city, country_id FROM city;
-- country: Contains details about each country including country_id and country name.
SELECT country_id, country FROM sakila.country;

-- APPROACH:
-- Filter customers by the country "Canada" and get customer details (first name, last name, and email).
-- 5.1 SQL Query (Using Join)
-- 5.2 SQL Query (Using Subquery)

-- 5.1 SQL Query (Using Join):
-- STEPS:
-- 5.1.1 Join Customer with Address: To get address information for each customer.
SELECT 
    c.first_name, 
    c.last_name, 
    c.email, 
    a.address_id 
FROM customer AS c
JOIN address AS a ON c.address_id = a.address_id;
-- 5.1.2 Add the City Table: In order to link each address with its city.
SELECT 
    c.first_name, 
    c.last_name, 
    c.email, 
    ci.city_id 
FROM customer AS c
JOIN address AS a ON c.address_id = a.address_id
JOIN city AS ci ON a.city_id = ci.city_id;
-- 5.1.3 Join with the Country Table and Filter by "Canada": Results to include only customers from the target country.
SELECT 
    c.first_name, 
    c.last_name, 
    c.email 
FROM customer AS c
JOIN address AS a ON c.address_id = a.address_id
JOIN city AS ci ON a.city_id = ci.city_id
JOIN country AS co ON ci.country_id = co.country_id
WHERE co.country = 'Canada';

-- 5.2 SQL Query (Using Subquery):
-- STEPS:
-- 5.2.1 Identify the Country ID for Canada
SELECT country_id FROM country WHERE country = 'Canada';
-- 5.2.2 Use a Subquery to Filter Customers Based on the Country
-- Use Subqueries for Filtering: 
-- - The inner subquery finds the country_id for Canada, and the outer subquery identifies the relevant address_ids. 
-- - The main query then filters customers based on those addresses.
SELECT 
    first_name, 
    last_name, 
    email 
FROM customer 
WHERE address_id IN (SELECT a.address_id FROM address AS a
					 JOIN city AS ci ON a.city_id = ci.city_id
					 JOIN country AS co ON ci.country_id = co.country_id
					WHERE co.country = 'Canada');

-- ========================================================================================================================================================
-- BONUS 6. Determine which films were starred by the most prolific actor in the Sakila database.
-- ========================================================================================================================================================
-- To determine which actor has appeared in the most films (the most prolific actor).
-- And then list all the films that this actor has starred in.

-- TABLES TO USE: 
-- actor: Contains details about each actor, including actor_id, first_name, and last_name.
SELECT actor_id, first_name, last_name FROM actor;
-- film_actor: Links actors to films via actor_id and film_id.
SELECT actor_id, film_id FROM film_actor;
-- film: Contains details about each film, including film_id and title.
SELECT film_id, title FROM film;

-- APPROACH:
-- = First, identify the actor with the most films using a subquery.
-- = Then, find all films they starred in.

-- STEPS:
-- 6.1 Identify the Most Prolific Actor
-- To determine which actor has appeared in the most films. 
-- This involves counting the number of films associated with each actor in the film_actor table.
-- - Count Film Appearances: Counts the number of films (film_id) associated with each actor_id.
-- - Identify the Most Prolific Actor: By ordering the results in descending order and limiting the output to 1
-- - The query returns the actor_id of the actor with the most film appearances.
SELECT actor_id, 
	   COUNT(film_id) AS film_count 
FROM film_actor 
GROUP BY actor_id 
ORDER BY film_count DESC 
LIMIT 1;
-- 6.2 Link the Name of the Most Prolific Actor
-- Using the actor_id, retrieve the full name of the most prolific actor from the actor table.
SELECT first_name, last_name 
FROM actor 
WHERE actor_id = (SELECT actor_id FROM film_actor 
				  GROUP BY actor_id 
				  ORDER BY COUNT(film_id) DESC 
				  LIMIT 1);
-- 6.3 List All Films Starring the Most Prolific Actor
-- Let's use the actor_id of the most prolific actor to find all films they have appeared in, and retrieve the titles of these films.
-- - Subquery: The subquery identifies the actor_id of the most prolific actor by counting the number of films associated with each actor.
-- - Main Query: The main query retrieves the titles of all films where the actor_id matches that of the most prolific actor.
SELECT f.title FROM film AS f
JOIN film_actor AS fa ON f.film_id = fa.film_id
WHERE fa.actor_id = (SELECT fa.actor_id FROM film_actor AS fa
					 GROUP BY fa.actor_id 
					 ORDER BY COUNT(fa.film_id) DESC 
					 LIMIT 1);

-- ========================================================================================================================================================
-- BONUS 7. Find the films rented by the most profitable customer in the Sakila database.
-- ========================================================================================================================================================
-- To determine which customer has spent the most on rentals (the most profitable customer or the one with the highest total payments)
-- Then list all the films they have rented.

-- TABLES TO USE: 
-- customer: Contains details about each customer, including customer_id, first_name, and last_name.
SELECT customer_id, first_name, last_name FROM customer;
-- payment: Contains details about payments made by customers, including payment_id, customer_id, and amount.
SELECT payment_id, customer_id, amount FROM payment;
-- rental: Contains details about each rental transaction, including rental_id, inventory_id, and customer_id.
SELECT rental_id, inventory_id, customer_id FROM rental;
-- inventory: Contains information about the physical copies of each film, including inventory_id and film_id.
SELECT inventory_id, film_id FROM inventory;
-- film: Contains details about each film, including film_id and title.
SELECT film_id, title FROM sakila.film;

-- APPROACH:
-- = Identify the most profitable customer by summing their payments (the customer with the highest total sum payment).
-- = Use the customer_id of the most profitable customer to list all the films they have rented.

-- STEPS:
-- 7.1 Identify the Most Profitable Customer
-- To determine which customer has made the largest total payment, let's sum up the payments associated with each customer in the payment table.
SELECT customer_id, 
	-- To get the total payments made by each customer.
	   SUM(amount) AS total_spent 
FROM payment 
GROUP BY customer_id 
-- By ordering the results in descending order 
ORDER BY total_spent DESC 
-- and limiting the output to 1, it's possible to get the customer_id of the customer who has spent the most.
LIMIT 1;

-- 7.2 Retrieve the Name of the Most Profitable Customer (using the customer_id)
SELECT first_name, last_name 
FROM customer 
WHERE customer_id = (SELECT customer_id FROM payment 
					 GROUP BY customer_id 
					 ORDER BY SUM(amount) DESC 
					 LIMIT 1);

-- 7.3 List All Films Rented by the Most Profitable Customer
-- Let's use the customer_id of the most profitable customer to find all films they have rented, and retrieve the titles of these films.
SELECT f.title 
-- Main Query: The main query retrieves the titles of all films where the customer_id matches that of the most profitable customer.
FROM film AS f
JOIN inventory AS i ON f.film_id = i.film_id
JOIN rental AS r ON i.inventory_id = r.inventory_id
JOIN customer AS c ON r.customer_id = c.customer_id
-- Subquery: This identifies the customer_id of the most profitable customer by summing up the payment amounts for each customer.
WHERE c.customer_id = (SELECT p.customer_id FROM payment AS p
					   GROUP BY p.customer_id 
					   ORDER BY SUM(p.amount) DESC 
					   LIMIT 1);

-- ========================================================================================================================================================
-- BONUS 8. Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client.
-- ========================================================================================================================================================
-- To find customers who spent more than the average.

-- TABLE TO USE: 
-- payment: Contains details about payments made by customers, including payment_id, customer_id, and amount.
SELECT payment_id, customer_id, amount FROM payment;

-- APPROACH:
-- = Use a subquery to calculate the average total spending.
-- = Filter customers who spent more than this average.

-- STEPS:
-- 8.1 Calculate the total amount spent by each customer.
-- Let's sum the payment amounts associated with each customer_id in the payment table.
SELECT 
    customer_id, 
    SUM(amount) AS total_amount_spent 
FROM payment 
GROUP BY customer_id;

-- 8.2 Calculate the Average Total Amount Spent by all customers
-- This average will be used to filter out customers who have spent less than this value.
SELECT AVG(total_amount_spent) AS average_spent 
FROM (SELECT SUM(amount) AS total_amount_spent FROM payment 
      GROUP BY customer_id) AS total_amount_spent_by_customer;

-- 8.3 Filter the subquery and retrieve the customer_id and total_amount_spent for customers who spent more than the average.
SELECT 
    customer_id, 
    -- Total_amount_spent for customers who have spent more than the average.
    SUM(amount) AS total_amount_spent 
FROM payment
GROUP BY customer_id 
-- Here let's filter the results so only customers who have spent more than the average are included.
-- Not including customers who spent less than or equal to the average amount.
HAVING SUM(amount) > (SELECT AVG(total_amount_spent) 
					-- Calculates the average of total amount spent by each customer.
					  FROM (SELECT SUM(amount) AS total_amount_spent 
							FROM payment 
                            --  Calculates the total amount spent by each customer.
							GROUP BY customer_id) AS avg_total_amount_spent_by_customer);
