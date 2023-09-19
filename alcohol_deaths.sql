CREATE TABLE alcohol_consump(
   Country VARCHAR(14) NOT NULL,
   Alcohol NUMERIC(12,9), 
   Deaths  NUMERIC(4,0), 
   Heart   NUMERIC(3,0), 
   Liver   NUMERIC(11,9) 
);

INSERT INTO alcohol_consump(Country,Alcohol,Deaths,Heart,Liver) VALUES ('Australia',2.5,785,211,15.30000019);
INSERT INTO alcohol_consump(Country,Alcohol,Deaths,Heart,Liver) VALUES ('Austria',3.000000095,863,167,45.59999847);
INSERT INTO alcohol_consump(Country,Alcohol,Deaths,Heart,Liver) VALUES ('Belg. and Lux.',2.900000095,883,131,20.70000076);
INSERT INTO alcohol_consump(Country,Alcohol,Deaths,Heart,Liver) VALUES ('Canada',2.400000095,793,NULL,16.39999962);
INSERT INTO alcohol_consump(Country,Alcohol,Deaths,Heart,Liver) VALUES ('Denmark',2.900000095,971,220,23.89999962);
INSERT INTO alcohol_consump(Country,Alcohol,Deaths,Heart,Liver) VALUES ('Finland',0.800000012,970,297,19);
INSERT INTO alcohol_consump(Country,Alcohol,Deaths,Heart,Liver) VALUES ('France',9.100000381,751,11,37.90000153);
INSERT INTO alcohol_consump(Country,Alcohol,Deaths,Heart,Liver) VALUES ('Iceland',-0.800000012,743,211,11.19999981);
INSERT INTO alcohol_consump(Country,Alcohol,Deaths,Heart,Liver) VALUES ('Ireland',0.699999988,1000,300,6.5);
INSERT INTO alcohol_consump(Country,Alcohol,Deaths,Heart,Liver) VALUES ('Israel',0.600000024,-834,183,13.69999981);
INSERT INTO alcohol_consump(Country,Alcohol,Deaths,Heart,Liver) VALUES ('Italy',27.9000001,775,107,42.20000076);
INSERT INTO alcohol_consump(Country,Alcohol,Deaths,Heart,Liver) VALUES ('Japan',1.5,680,36,23.20000076);
INSERT INTO alcohol_consump(Country,Alcohol,Deaths,Heart,Liver) VALUES ('Netherlands',1.799999952,773,167,9.199999809);
INSERT INTO alcohol_consump(Country,Alcohol,Deaths,Heart,Liver) VALUES ('New Zealand',1.899999976,916,266,7.699999809);
INSERT INTO alcohol_consump(Country,Alcohol,Deaths,Heart,Liver) VALUES ('Norway',0.080000001,806,227,12.19999981);
INSERT INTO alcohol_consump(Country,Alcohol,Deaths,Heart,Liver) VALUES ('Spain',6.5,724,NULL,NULL);
INSERT INTO alcohol_consump(Country,Alcohol,Deaths,Heart,Liver) VALUES ('Sweden',1.600000024,743,207,11.19999981);
INSERT INTO alcohol_consump(Country,Alcohol,Deaths,Heart,Liver) VALUES ('Switzerland',5.800000191,693,115,20.29999924);
INSERT INTO alcohol_consump(Country,Alcohol,Deaths,Heart,Liver) VALUES ('UK',1.299999952,941,285,10.30000019);
INSERT INTO alcohol_consump(Country,Alcohol,Deaths,Heart,Liver) VALUES ('US',1.200000048,926,199,22.10000038);
INSERT INTO alcohol_consump(Country,Alcohol,Deaths,Heart,Liver) VALUES ('West Germany',2.700000048,861,172,36.70000076);


-- ******************************************************
-- Examine the whole table
-- ******************************************************
select * 
from alcohol_consump;



-- ******************************************************
-- Count how many values are missing in each column
-- ******************************************************
select count(*)
from alcohol_consump
where alcohol is null;     -- none

select count(*)
from alcohol_consump
where deaths is null;      -- none

select count(*)
from alcohol_consump
where heart is null;       -- 2 missing values

select count(*)
from alcohol_consump
where liver is null;       -- 1 missing value



-- ******************************************************
-- Find nosiy data in each column, if any
-- ******************************************************
select *
from alcohol_consump
where alcohol < 0 ;     -- Iceland

select *
from alcohol_consump
where deaths < 0 ;      -- Isreal

select *
from alcohol_consump
where heart < 0 ;       -- none

select *
from alcohol_consump
where liver < 0 ;       -- none



-- ********************************************************
-- Fix the nosiy data in heart and liver columns and verify
-- ********************************************************
update alcohol_consump
set alcohol = abs(alcohol), deaths = abs(deaths);

select count(*)
from   alcohol_consump
where  (alcohol < 0) or (deaths < 0);



-- ******************************************************
-- Impute the missing values in heart and liver columns
-- using their averages. Verfiy the results.
-- ******************************************************
update alcohol_consump
set    heart = (select avg(heart) from alcohol_consump)
where  heart is null;

update alcohol_consump
set    liver = (select avg(liver) from alcohol_consump)
where  liver is null ;

select count(*)
from   alcohol_consump
where  (liver is null) or (heart is null);



-- ******************************************************************
-- Creat the India table
-- ******************************************************************
CREATE TABLE India(
   Country   VARCHAR(27) NOT NULL,
   Alcohol   NUMERIC(5,5),
   heart     NUMERIC(6,5),
   accidents NUMERIC(7,5)
);

INSERT INTO India(Country,Alcohol,heart,accidents) VALUES ('Andaman and Nicobar Islands',1.73,20312,2201);
INSERT INTO India(Country,Alcohol,heart,accidents) VALUES ('Andhra Pradesh',2.05,16723,29700);
INSERT INTO India(Country,Alcohol,heart,accidents) VALUES ('Arunachal Pradesh',1.98,13109,11251);
INSERT INTO India(Country,Alcohol,heart,accidents) VALUES ('Assam',0.91,8532,211250);
INSERT INTO India(Country,Alcohol,heart,accidents) VALUES ('Bihar',3.21,12372,375000);
INSERT INTO India(Country,Alcohol,heart,accidents) VALUES ('Chhattisgarh',2.03,28501,183207);
INSERT INTO India(Country,Alcohol,heart,accidents) VALUES ('Goa',5.79,19932,307291);



-- ******************************************************
-- Wrangle the heart column since it is per 10,000,000 
-- while previously it was per 100,000
-- ******************************************************
update India
set    heart = heart/100.00;


-- ******************************************************
-- Only two columns from India match our previous table,
-- so aggregate them, and then add the aggregated data
-- to appropriate columns in alcohol_consump
-- ******************************************************
insert into alcohol_consump values 
       ('India',
       (select avg(alcohol) from India),
       NULL,
       (select avg(heart)  from India),
       NULL);
       
       
-- ******************************************************
-- Impute the missing values in deaths and liver columns
-- using their averages. Verfiy the results.
-- ******************************************************       
update alcohol_consump
set    deaths = (select avg(deaths) from alcohol_consump)
where  deaths is null;

update alcohol_consump
set    liver = (select avg(liver) from alcohol_consump)
where  liver is null;




-- *****************************************************************
-- Discretize the wine consumption per capita into four categories:
--      0: less than or equal to 1.00 per capita 
--      1: more than 1.00 but less than or equal to 2.00 per capita 
--      2: more than 2.00 but less than or equal to 5.00 per capita 
--      3: more than 5.00 per capita 

-- Cannot use BETWEEN because it is inclusive
-- *****************************************************************

select Country, Alcohol,
   case
       when (alcohol <= 1.0)  then 0                         
       when (alcohol > 1.0) and (alcohol <= 2.0) then 1    
       when (alcohol > 2.0) and (alcohol <= 5.0) then 2  
       else   3
   end as Alcohol_Bin,
   Deaths, Heart, Liver
from alcohol_consump ;




-- ******************************************************************
-- Extra Credit
-- ******************************************************************
1) Replace Alcohol with Alcohol_Bin.

2) Use the 68-95-99 rule to identify any outliers in the Alcohol column.
   https://www.radfordmathematics.com/probabilities-and-statistics/normal-distributions/68-95-99.7-rule.html
   
3) Discretize the Deaths column using 5 bins: very high, high, moderate, low, very low

4) Is there a relationship between the discrete alcohol values (0, 1, 2, 3) and the new values for deaths?
