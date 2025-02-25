/**
2. Which bus stop has the smallest population within 800 meters?

  **The queries to #1 & #2 should generate relations with a single row, with the following structure:**

  ```sql
  (
      stop_name text, -- The name of the station
      estimated_pop_800m integer, -- The population within 800 meters
      the_geom geometry(Point, 4326) -- The geometry of the bus stop
  )
  ```
**/
with bus_stop_geom as (		
select stop_id, stop_name, ST_SetSRID(ST_Point(stop_lon, stop_lat),4326) As geometry
	FfromROM septa_bus_stops
),
bus_stop_block_group as (
	select b.stop_id, b.stop_name, bg.geoid10 as geoid
	from bus_stop_geom as b
	join census_block_groups as bg
	on ST_Intersects(
		ST_Buffer(ST_Transform(b.geometry, 32129),800),
		ST_Transform(bg.geometry,32129)
	)
),
census_population_adj as (
	select SUBSTRING(p.id, 10) as geoid, total
	from census_population as p
)
select b.stop_name, SUM(cp.total) as estimated_pop_800m
from bus_stop_block_group as b
join census_population_adj as cp using(geoid)
group by b.stop_name
order by estimated_pop_800m desc
limit 1