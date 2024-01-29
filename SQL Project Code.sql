
--Project context: The stakeholder is an aspiring app developer who needs data driven insights to decide on what app to build
-- The stakeholder specifically wants to know the answer to 3 questions based on our insights: Which App categories are most popular? How can user ratings be maximised? Should it be a paid or free app?


--Dataset: found on kaggle.com, Description of dataset: information about apps found in the apple store



CREATE TABLE applestore_description_table_combined AS

Select * FROM appleStore_description1
union ALL
SELECT * From appleStore_description2
union ALL
SELECT * From appleStore_description3
union all 
SELECT * From appleStore_description4

**EXPLORATORY DATA ANALYSIS**

-- checking the number of unique apps in both tables

Select count(DISTINCT id) as UniqueAppIDs
fROM AppleStore

Select count(DISTINCT id) as UniqueAppIDs
fROM applestore_description_table_combined

-- checking for any missing values in key fields

Select Count(*) As MissingValues
from AppleStore
Where track_name is null or user_rating is null or prime_genre is null

Select Count(*) As MissingValues
from applestore_description_table_combined
Where app_desc is null 

-- finding out the number of apps per genre

SELECT prime_genre, count(*) as NumApps
from AppleStore
group BY prime_genre
Order By Numapps DESC

-- getting an overview of the apps ratings

Select min(user_rating) as MinRating,
	   max(user_rating) as MaxRating,
       avg(user_rating) As AvgRating
FROM AppleStore

-- determining whether paid apps have higher ratings than free apps

Select case
			when price > 0 then 'Paid'
            else 'Free'
        End as App_Type,
        avg(user_rating) As Avg_Rating
From AppleStore
GROUP BY App_type

-- checking if apps with more languages have a higher average rating

Select Case
			When lang_num < 10 then '<10 languages'
            when lang_num BETWEEN 10 and 30 then '10-30 languages'
            else '>30 languages'
        end as 'language_bucket',
        avg(user_rating) as Avg_Rating
from AppleStore
group by language_bucket
order by Avg_rating DESC

-- checking for genres with low ratings 

select prime_genre,
       avg(user_rating) as Avg_Rating
from AppleStore
group by prime_genre
order by Avg_rating ASC
limit 10

-- checking to see if there is a correlation between length of the app description and the user rating

select CASE
			when length(b.app_desc) < 500 then 'short'
            when length(b.app_desc) between 500 and 1000 then 'medium'
            else 'long'
            end as description_length_bucket,
            avg(a.user_rating) as average_rating

from 
	AppleStore as A

join 
	applestore_description_table_combined as B
     
ON
	a.id = b.id
    
group by description_length_bucket
order by average_rating DESC

-- check the top rated apps for each genre

select 
	prime_genre,
    track_name,
    user_rating
from (
  	  SELECT
  	  prime_genre,
      track_name,
      user_rating,
      RANK() OVER(PARTITION BY prime_genre order by user_rating DESC, rating_count_tot DESC) AS rank
  	  FROM	
      AppleStore
    ) AS a
WHERE
a.rank = 1

-- Recommendations based on my analysis
--1 Paid apps have better ratings compared to unpaid apps
--2 Apps that have supporting language between 10 and 30 have better ratings, apps outside this range had a lower rating on average
--3 Finance and book apps have lower ratings which suggest users needs are not being fully met, there is a potential for oppurtunity in these genres
--4 Apps with a longer description have a positive correlation to ratings which likely suggest users apreciate a description of the apps features and capabilities before downloading it
--5 On average apps have a rating of 3.5 so a new app should aim for a rating above this to distinguish itself from the crowd
--6 The games and entertainment genre have a very high volume of apps which suggest possible market saturation and competition but also higher user demand
