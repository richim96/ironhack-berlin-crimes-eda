-- 1 --
SELECT
    `Year`,
    SUM(
        Robbery +
        Street_robbery +
        Injury +
        Agg_assault +
        Threat +
        Theft +
        Car +
        From_car +
        Bike +
        Burglary +
        Fire +
        Arson +
        Damage +
        Graffiti +
        Drugs +
        Neighbour_disputes
    ) AS Total_crimes
FROM berlin_crimes
GROUP BY `Year`;


-- 2 --
SELECT
    `Year`,
    District,
    SUM(
        Robbery +
        Street_robbery +
        Injury +
        Agg_assault +
        Threat +
        Theft +
        Car +
        From_car +
        Bike +
        Burglary +
        Fire +
        Arson +
        Damage +
        Graffiti +
        Drugs +
        Neighbour_disputes
    ) AS Total_crimes
FROM berlin_crimes
GROUP BY `Year`, District
ORDER BY `Year` ASC, Total_crimes DESC;


-- 3 --
WITH violent_property_crime_by_district_cte AS (
    SELECT
        District,
        SUM(Robbery + Street_robbery + Injury + Agg_assault + Threat) AS Violent_crimes,
        SUM(
            Theft +
            Car +
            From_car +
            Bike +
            Burglary +
            Fire +
            Arson +
            Damage +
            Graffiti
        ) AS Property_crimes
    FROM berlin_crimes
    GROUP BY District
)

SELECT
    *,
    (Violent_crimes + Property_crimes) AS Total_crimes,
    ROUND(Violent_crimes * 1.0 / (Violent_crimes + Property_crimes), 2) AS Violent_ratio,
    ROUND(Property_crimes * 1.0 / (Violent_crimes + Property_crimes), 2) AS Property_ratio
FROM violent_property_crime_by_district_cte
ORDER BY District;


-- 4 --
WITH location_violent_crimes_by_year_cte AS (
    SELECT
        `Year`,
        `Location`,
        Code,
        District,
        SUM(Robbery + Street_robbery + Injury + Agg_assault + Threat) AS Violent_crimes
    FROM berlin_crimes
    GROUP BY `Year`, `Location`, Code
)
 
SELECT
    `Year`,
    `Location`,
    Code,
    District,
    MAX(Violent_crimes) AS Violent_crimes
FROM location_violent_crimes_by_year_cte
GROUP BY `Year`
ORDER BY `Year` ASC;


-- 5 --
SELECT
    `Location`,
    Code,
    District,
    CAST(ROUND(AVG(Drugs)) AS INT) AS Avg_drug_crimes
FROM berlin_crimes
WHERE `Year` BETWEEN 2016 AND 2019
GROUP BY `Location`, Code
ORDER BY Avg_drug_crimes DESC;


-- 6 --
SELECT
    District,
    Drugs,
    (Robbery + Street_robbery + Injury + Agg_assault + Threat) AS Violent_crimes
FROM berlin_crimes;


-- 7 --
WITH avg_crime_by_district_cte AS (
    SELECT
        District,
        CAST(ROUND(AVG(
            Robbery +
            Street_robbery +
            Injury +
            Agg_assault +
            Threat +
            Theft +
            Car +
            From_car +
            Bike +
            Burglary +
            Fire +
            Arson +
            Damage +
            Graffiti +
            Drugs +
            Neighbour_disputes
        )) AS INT) AS Avg_district_crimes
    FROM berlin_crimes
    GROUP BY District
),    
avg_crime_by_location_cte AS (
    SELECT
        District,
        `Location`,
        Code,
        CAST(ROUND(AVG(
            Robbery +
            Street_robbery +
            Injury +
            Agg_assault +
            Threat +
            Theft +
            Car +
            From_car +
            Bike +
            Burglary +
            Fire +
            Arson +
            Damage +
            Graffiti +
            Drugs +
            Neighbour_disputes
        )) AS INT) AS Avg_location_crimes
    FROM berlin_crimes
    GROUP BY `Location`, District
)
        
SELECT
    cl.District,
    cl.`Location`,
    cl.Code,
    cl.Avg_location_crimes,
    cd.Avg_district_crimes,
    cl.Avg_location_crimes - cd.Avg_district_crimes AS Surplus
FROM avg_crime_by_location_cte cl
JOIN avg_crime_by_district_cte cd
    ON cl.District = cd.District
WHERE
    cl.Avg_location_crimes > cd.Avg_district_crimes
    AND Surplus > 2000 -- Arbitrary threshold for more significant results
ORDER BY Surplus DESC;


-- 8 --
SELECT
    District,
    CAST(ROUND(AVG(Neighbour_disputes)) AS INT) AS Avg_neighbour_disputes
FROM berlin_crimes
WHERE `Year` BETWEEN 2014 AND 2018
GROUP BY District
ORDER BY Avg_neighbour_disputes DESC
LIMIT 1;


-- 9 --
WITH location_bike_theft_by_district_cte AS (
    SELECT
        District,
        `Location`,
        Code,
        SUM(Bike) AS Bike_theft
    FROM berlin_crimes
    GROUP BY District, `Location`, Code
)

SELECT
    District,
    `Location`,
    Code,
    MAX(Bike_theft) AS Bike_theft
FROM location_bike_theft_by_district_cte
GROUP BY District
ORDER BY Bike_theft DESC;


-- 10 --
WITH district_crime_by_year AS (
    SELECT
        `Year`,
        District,
        SUM(
            Robbery +
            Street_robbery +
            Injury +
            Agg_assault +
            Threat +
            Theft +
            Car +
            From_car +
            Bike +
            Burglary +
            Fire +
            Arson +
            Damage +
            Graffiti +
            Drugs +
            Neighbour_disputes
        ) AS Total_crimes
    FROM berlin_crimes
    GROUP BY `Year`, District
)
    
SELECT
    District,
    ROUND(
        SQRT(AVG(Total_crimes * Total_crimes) - AVG(Total_crimes) * AVG(Total_crimes)) -- Manual formulat for STDEV
            / AVG(Total_crimes) * 1.0
        , 4) AS Var_coeff
FROM district_crime_by_year
GROUP BY District
ORDER BY Var_coeff DESC
LIMIT 1;
