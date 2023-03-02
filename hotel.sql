with step1 as (
select 	hotel_bookings."Name",
		hotel_bookings."City",
		hotel_bookings."Type", 
		hotel_bookings."ReviewsCount", 
		hotel_bookings."Rating", 
		hotel_bookings."Price",
		round(avg(hotel_bookings."Price") over(partition by hotel_bookings."City",hotel_bookings."Type"),0) as "Avg_Price_by_Type_by_City",
		count(hotel_bookings."Type") over(partition by hotel_bookings."City",hotel_bookings."Type") as "Unit_Count_by_Type_by_City"
from hotel_bookings
	)
, step2 as (
	select 	step1."Name",
			step1."City",
			step1."Type", 
			step1."ReviewsCount" as "# reviews", 
			step1."Rating", 
			step1."Price" as "Price (EUR)",
			step1."Avg_Price_by_Type_by_City" as "Avg price by type per city",
			case 
				when (step1."Avg_Price_by_Type_by_City" - step1."Price")/step1."Price" = 0.00 then 0
				else round(((step1."Avg_Price_by_Type_by_City" - step1."Price")/step1."Price"),2)
				end as "Pct diff",
			step1."Unit_Count_by_Type_by_City" as "# units by type per city"
	from step1
	where step1."ReviewsCount" is not null
	and step1."Rating" >= 7.0
	)
, step3 as ( 	
	select 	step2."Name",
			step2."City",
			step2."Type", 
			step2."# reviews", 
			step2."Rating", 
			step2."Price (EUR)",
			step2."Pct diff",
			max(step2."Pct diff") over(partition by step2."City",step2."Type") as "Best deal"
	from step2
	)
select 	step3."Name",
		step3."City",
		step3."Type",
		step3."# reviews",
		step3."Rating", 
		step3."Price (EUR)" as "Best deal"
from step3
where step3."Pct diff" = step3."Best deal"
order by step3."Best deal";
