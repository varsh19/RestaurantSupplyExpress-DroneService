-- CS4400: Introduction to Database Systems (Atlanta, GA - Fall 2022)
-- Project Phase III: Stored Procedures SHELL [v0] Wednesday, November 30, 2022
set global transaction isolation level serializable;
set global SQL_MODE = 'ANSI,TRADITIONAL';
set names utf8mb4;
set SQL_SAFE_UPDATES = 0;

use restaurant_supply_express;
-- -----------------------------------------------------------------------------
-- stored procedures and views
-- -----------------------------------------------------------------------------
/* Standard Procedure: If one or more of the necessary conditions for a procedure to
be executed is false, then simply have the procedure halt execution without changing
the database state. Do NOT display any error messages, etc. */

-- [1] add_owner()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new owner.  A new owner must have a unique
username. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_owner;
delimiter //
create procedure add_owner (in ip_username varchar(40), in ip_first_name varchar(100),
	in ip_last_name varchar(100), in ip_address varchar(500), in ip_birthdate date)
sp_main: begin
    -- ensure new owner has a unique username
 if ip_username in (select username from employees)
then leave sp_main; end if;
insert into users values (ip_username, ip_first_name, ip_last_name, ip_address, ip_birthdate);
if ip_username in (select username from restaurant_owners)
then leave sp_main; end if;
insert into restaurant_owners values (ip_username);
end //
delimiter ;

-- [2] add_employee()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new employee without any designated pilot or
worker roles.  A new employee must have a unique username unique tax identifier. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_employee;
delimiter //
create procedure add_employee (in ip_username varchar(40), in ip_first_name varchar(100),
	in ip_last_name varchar(100), in ip_address varchar(500), in ip_birthdate date,
    in ip_taxID varchar(40), in ip_hired date, in ip_employee_experience integer,
    in ip_salary integer)
sp_main: begin
    -- ensure new owner has a unique username
if ip_username in (select username from employees)
then leave sp_main; end if;
insert into users values (ip_username, ip_first_name, ip_last_name, ip_address, ip_birthdate);
if ip_username in (select username from restaurant_owners)
then leave sp_main; end if;
insert into restaurant_owners values (ip_username);
    -- ensure new employee has a unique tax identifier
if ip_taxID in (select taxID from employees)
then leave sp_main; end if;
insert into employees values (ip_username, ip_taxID, ip_hired, ip_employee_experience, ip_salary);
end //
delimiter ;

-- [3] add_pilot_role()
-- -----------------------------------------------------------------------------
/* This stored procedure adds the pilot role to an existing employee.  The pilot
role cannot be added if they're already a worker. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_pilot_role;
delimiter //
create procedure add_pilot_role (in ip_username varchar(40), in ip_licenseID varchar(40),
	in ip_pilot_experience integer)
sp_main: begin
    -- ensure new employee exists
if not exists (select username from pilots where username = ip_username)
then leave sp_main; end if;
    -- ensure new pilot has a unique licence identifier
if not exists (select licenseID from pilots where licenseID = ip_licenseID)
then leave sp_main; end if;
end //
delimiter ;

-- [4] add_worker_role()
-- -----------------------------------------------------------------------------
/* This stored procedure adds the worker role to an existing employee. The
worker role cannot be added if they're already a pilot. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_worker_role;
delimiter //
create procedure add_worker_role (in ip_username varchar(40))
sp_main: begin
    -- ensure new employee exists
if ip_username in (select username from workers)
then leave sp_main; end if;
insert into workers values(ip_username);
end //
delimiter ;

-- [5] add_ingredient()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new ingredient.  A new ingredient must have a
unique barcode. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_ingredient;
delimiter //
create procedure add_ingredient (in ip_barcode varchar(40), in ip_iname varchar(100),
	in ip_weight integer)
sp_main: begin
	-- ensure new ingredient doesn't already exist
if ip_barcode in (select barcode from ingredients)
then leave sp_main; end if;
insert into ingredients values (ip_barcode, ip_iname, ip_weight);
end //
delimiter ;

-- [6] add_drone()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new drone.  A new drone must be assigned 
to a valid delivery service and must have a unique tag.  Also, it must be flown
by a valid pilot initially (i.e., pilot works for the same service), but the pilot
can switch the drone to working as part of a swarm later. And the drone's starting
location will always be the delivery service's home base by default. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_drone;
delimiter //
create procedure add_drone (in ip_id varchar(40), in ip_tag integer, in ip_fuel integer,
	in ip_capacity integer, in ip_sales integer, in ip_flown_by varchar(40))
sp_main: begin
	-- ensure new drone doesn't already exist
if ip_id and ip_tag in (select id and tag from drones)
then leave sp_main; end if;
set @hover = (select home_base from delivery_services where id=ip_id);
insert into drones values (ip_id, ip_tag, ip_fuel, ip_capacity, ip_sales, ip_flown_by, null, null, @hover); 
 	-- ensure that the delivery service exists
if not exists (select id from drones where id = ip_id)
then leave sp_main; end if;
    -- ensure that a valid pilot will control the drone
if not exists (select flown_by from drones where flown_by = ip_flown_by)
then leave sp_main; end if;
end //
delimiter ;

-- [7] add_restaurant()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new restaurant.  A new restaurant must have a
unique (long) name and must exist at a valid location, and have a valid rating.
And a resturant is initially "independent" (i.e., no owner), but will be assigned
an owner later for funding purposes. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_restaurant;
delimiter //
create procedure add_restaurant (in ip_long_name varchar(40), in ip_rating integer,
	in ip_spent integer, in ip_location varchar(40))
sp_main: begin
	-- ensure new restaurant doesn't already exist
if exists (select long_name from restaurants where long_name = ip_long_name)
then leave sp_main; end if;
    -- ensure that the location is valid
if ip_location not in (select location from restaurants)
then leave sp_main; end if;
    -- ensure that the rating is valid (i.e., between 1 and 5 inclusively)
if ip_rating not in (1,2,3,4,5)
then leave sp_main; end if;
insert into restaurants values (ip_long_name, ip_rating, ip_spent, ip_location, null);
end //
delimiter ;

-- [8] add_service()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new delivery service.  A new service must have
a unique identifier, along with a valid home base and manager. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_service;
delimiter //
create procedure add_service (in ip_id varchar(40), in ip_long_name varchar(100),
	in ip_home_base varchar(40), in ip_manager varchar(40))
sp_main: begin
	-- ensure new delivery service doesn't already exist
if exists (select id from delivery_services where id = ip_id)
then leave sp_main; end if;
    -- ensure that the home base location is valid
if ip_home_base in (select home_base from delivery_services)
then leave sp_main; end if;
    -- ensure that the manager is valid
if ip_manager not in (select username from workers)
then leave sp_main; end if;
insert into delivery_services values (ip_id, ip_long_name, ip_home_base, ip_manager);

end //
delimiter ;

-- [9] add_location()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new location that becomes a new valid drone
destination.  A new location must have a unique combination of coordinates.  We
could allow for "aliased locations", but this might cause more confusion that
it's worth for our relatively simple system. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_location;
delimiter //
create procedure add_location (in ip_label varchar(40), in ip_x_coord integer,
	in ip_y_coord integer, in ip_space integer)
sp_main: begin
	-- ensure new location doesn't already exist
if exists (select x_coord and y_coord from locations where x_coord = ip_x_coord and y_coord = ip_y_coord )
then leave sp_main; end if;
    -- ensure that the coordinate combination is distinct
if ip_x_coord and ip_y_coord in (select x_coord and y_coord from locations)
then leave sp_main; end if;
insert into locations values (ip_label, ip_x_coord, ip_y_coord, ip_space);
end //
delimiter ;

-- [10] start_funding()
-- -----------------------------------------------------------------------------
/* This stored procedure opens a channel for a restaurant owner to provide funds
to a restaurant. If a different owner is already providing funds, then the current
owner is replaced with the new owner.  The owner and restaurant must be valid. */
-- -----------------------------------------------------------------------------
drop procedure if exists start_funding;
delimiter //
create procedure start_funding (in ip_owner varchar(40), in ip_long_name varchar(40))
sp_main: begin
	-- ensure the owner and restaurant are valid
if ip_owner not in (select username from restaurant_owners)
then leave sp_main; end if;

if ip_long_name not in (select long_name from restaurants)
then leave sp_main; end if;
-- if ip_owner not in (select username from restaurant_owners)
-- then 
-- 	insert into restaurant_owners values (ip_owner);
-- end if;

update restaurants set funded_by=ip_owner where long_name=ip_long_name;

end //
delimiter ;



-- [11] hire_employee()
-- -----------------------------------------------------------------------------
/* This stored procedure hires an employee to work for a delivery service.
Employees can be combinations of workers and pilots. If an employee is actively
controlling drones or serving as manager for a different service, then they are
not eligible to be hired.  Otherwise, the hiring is permitted. */
-- -----------------------------------------------------------------------------
drop procedure if exists hire_employee;
delimiter //
create procedure hire_employee (in ip_username varchar(40), in ip_id varchar(40))
sp_main: begin
	-- ensure that the employee hasn't already been hired
     if ip_username in (select username from work_for where username = ip_username and id = ip_id)
then leave sp_main; end if;

	-- ensure that the employee and delivery service are valid
    if not exists(select username from employees where username=ip_username)
then leave sp_main; end if;
	if not exists(select id from delivery_services where id = ip_id)
then leave sp_main; end if;

    -- ensure that the employee isn't a manager for another service
    if exists(select manager from delivery_services where manager = ip_username and id<>ip_id)
then leave sp_main; end if;

	-- ensure that the employee isn't actively controlling drones for another service
    if exists(select flown_by from drones where flown_by = ip_username and id<>ip_id)
then leave sp_main; end if;

	insert into work_for(username, id) values (ip_username, ip_id);

end //
delimiter ;

-- [12] fire_employee()
-- -----------------------------------------------------------------------------
/* This stored procedure fires an employee who is currently working for a delivery
service.  The only restrictions are that the employee must not be: [1] actively
controlling one or more drones; or, [2] serving as a manager for the service.
Otherwise, the firing is permitted. */
-- -----------------------------------------------------------------------------
drop procedure if exists fire_employee;
delimiter //
create procedure fire_employee (in ip_username varchar(40), in ip_id varchar(40))
sp_main: begin
	-- ensure that the employee is currently working for the service
    if not exists (select username from work_for where username = ip_username and id = ip_id)
    then leave sp_main; end if;

    -- ensure that the employee isn't an active manager
     if exists(select manager from delivery_services where id = ip_id and manager = ip_username)
    then leave sp_main; end if;

	-- ensure that the employee isn't controlling any drones
     if exists(select flown_by from drones where flown_by = ip_username and id = ip_id)
    then leave sp_main; end if;
    
	 delete from work_for where username = ip_username and id=ip_id;

end //
delimiter ;

-- [13] manage_service()
-- -----------------------------------------------------------------------------
/* This stored procedure appoints an employee who is currently hired by a delivery
service as the new manager for that service.  The only restrictions are that: [1]
the employee must not be working for any other delivery service; and, [2] the
employee can't be flying drones at the time.  Otherwise, the appointment to manager
is permitted.  The current manager is simply replaced.  And the employee must be
granted the worker role if they don't have it already. */
-- -----------------------------------------------------------------------------
drop procedure if exists manage_service;
delimiter //
create procedure manage_service (in ip_username varchar(40), in ip_id varchar(40))
sp_main: begin
	-- ensure that the employee is currently working for the service
    if not exists(select username from work_for where username=ip_username and id=ip_id)
    then leave sp_main; end if;

	-- ensure that the employee is not flying any drones
    if exists(select flown_by from drones where flown_by=ip_username)
    then leave sp_main; end if;

    -- ensure that the employee isn't working for any other services
    if exists(select username from work_for where username=ip_username and id<>ip_id)
    then leave sp_main; end if;

    -- add the worker role if necessary
    if not exists(select username from workers where username= ip_username)
    then 
		insert into workers(username) values (ip_username);
	end if;
	update delivery_services set manager = ip_username where id=ip_id;

end //
delimiter ;

-- [14] takeover_drone()
-- -----------------------------------------------------------------------------
/* This stored procedure allows a valid pilot to take control of a lead drone owned
by the same delivery service, whether it's a "lone drone" or the leader of a swarm.
The current controller of the drone is simply relieved of those duties. And this
should only be executed if a "leader drone" is selected. */
-- -----------------------------------------------------------------------------
drop procedure if exists takeover_drone;
delimiter //
create procedure takeover_drone (in ip_username varchar(40), in ip_id varchar(40),
	in ip_tag integer)
sp_main: begin
	-- ensure that the employee is currently working for the service
    if not exists(select username from work_for where username=ip_username and id=ip_id)
    then leave sp_main; end if;

	-- ensure that the selected drone is owned by the same service and is a leader and not follower
    if not exists(select tag from drones where tag = ip_tag and id = ip_id and flown_by is not null)
    then leave sp_main; end if;

	-- ensure that the employee isn't a manager
    if exists(select manager from delivery_services where id=ip_id and manager=ip_username)
    then leave sp_main; end if;

    -- ensure that the employee is a valid pilot
    if not exists (select username from pilots where username=ip_username)
    then leave sp_main; end if;
    
    update drones set flown_by = ip_username where id=ip_id and tag=ip_tag;

end //
delimiter ;

-- [15] join_swarm()
-- -----------------------------------------------------------------------------
/* This stored procedure takes a drone that is currently being directly controlled
by a pilot and has it join a swarm (i.e., group of drones) led by a different
directly controlled drone. A drone that is joining a swarm connot be leading a
different swarm at this time.  Also, the drones must be at the same location, but
they can be controlled by different pilots. */
-- -----------------------------------------------------------------------------
drop procedure if exists join_swarm;
delimiter //
create procedure join_swarm (in ip_id varchar(40), in ip_tag integer,
	in ip_swarm_leader_tag integer)
sp_main: begin
	-- ensure that the swarm leader is a different drone
	if ip_tag=ip_swarm_leader_tag
    then leave sp_main; end if;

	-- ensure that the drone joining the swarm is valid and owned by the service
	if ip_tag not in (select tag from drones where id=ip_id and flown_by is not null)
    then leave sp_main; end if;

    -- ensure that the drone joining the swarm is not already leading a swarm
    if ip_tag in (select swarm_tag from drones where id=ip_id)
    then leave sp_main; end if;

	-- ensure that the swarm leader drone is directly controlled
    if ip_swarm_leader_tag not in (select tag from drones where flown_by is not null)
    then leave sp_main; end if;

	-- ensure that the drones are at the same location
    -- if not exists (select hover from drones where tag=ip_tag and ip_id and hover=(select hover from drones where tag=ip_swarm_leader_tag and id=ip_id))
    if (select hover from drones where tag = ip_tag and id=ip_id) = (select hover from drones where tag=ip_swarm_leader_tag and id=ip_id)
    then 
		update drones set flown_by=null, swarm_tag=ip_swarm_leader_tag, swarm_id=ip_id where tag=ip_tag and id=ip_id;
    end if;
    
end //
delimiter ;


-- [16] leave_swarm()
-- -----------------------------------------------------------------------------
/* This stored procedure takes a drone that is currently in a swarm and returns
it to being directly controlled by the same pilot who's controlling the swarm. */
-- -----------------------------------------------------------------------------
drop procedure if exists leave_swarm;
delimiter //
create procedure leave_swarm (in ip_id varchar(40), in ip_swarm_tag integer)
sp_main: begin
	-- ensure that the selected drone is owned by the service and flying in a swarm
    if ip_swarm_tag not in(select tag from drones where id=ip_id and flown_by is null)
    then leave sp_main; end if;
	
    set @pilot = (select flown_by from drones where tag=(select swarm_tag from drones where tag=ip_swarm_tag and id=ip_id));
    update drones set 
		flown_by= @pilot,
        swarm_tag=NULL, 
        swarm_id=NULL
        where tag=ip_swarm_tag and id=ip_id;

end //
delimiter ;

-- [17] load_drone()
-- -----------------------------------------------------------------------------
/* This stored procedure allows us to add some quantity of fixed-size packages of
a specific ingredient to a drone's payload so that we can sell them for some
specific price to other restaurants.  The drone can only be loaded if it's located
at its delivery service's home base, and the drone must have enough capacity to
carry the increased number of items.

The change/delta quantity value must be positive, and must be added to the quantity
of the ingredient already loaded onto the drone as applicable.  And if the ingredient
already exists on the drone, then the existing price must not be changed. */
-- -----------------------------------------------------------------------------
drop procedure if exists load_drone;
delimiter //
create procedure load_drone (in ip_id varchar(40), in ip_tag integer, in ip_barcode varchar(40),
	in ip_more_packages integer, in ip_price integer)
sp_main: begin
	-- ensure that the drone being loaded is owned by the service
    if not exists (select tag from drones where tag=ip_tag and id=ip_id)
    then leave sp_main; end if;
    
	-- ensure that the ingredient is valid
    if not exists (select barcode from ingredients where barcode=ip_barcode) 
    then leave sp_main; end if;
    
    -- ensure that the drone is located at the service home base
    if (select home_base from delivery_services where id=ip_id)<>(select hover from drones where tag = ip_tag and id=ip_id)
    then leave sp_main; end if;
    
	-- ensure that the quantity of new packages is greater than zero
    if ip_more_packages<=0 then leave sp_main; end if;
    
	-- ensure that the drone has sufficient capacity to carry the new packages
    if not ((select capacity from drones where tag=ip_tag and id=ip_id)-(select quantity from payload where tag=ip_tag and id=ip_id))>=ip_more_packages
    then leave sp_main;
    end if;
    
    -- add more of the ingredient to the drone
    if exists (select * from payload where id=ip_id and tag=ip_tag and barcode=ip_barcode)
    then
    update payload set quantity = quantity+ip_more_packages where tag=ip_tag and barcode=ip_barcode and id=ip_id; 
    else
    insert into payload (id, tag, barcode, quantity, price) values (ip_id, ip_tag, ip_barcode, ip_more_packages, ip_price);
    end if;
    

end //
delimiter ;

-- [18] refuel_drone()
-- -----------------------------------------------------------------------------
/* This stored procedure allows us to add more fuel to a drone. The drone can only
be refueled if it's located at the delivery service's home base. */
-- -----------------------------------------------------------------------------
drop procedure if exists refuel_drone;
delimiter //
create procedure refuel_drone (in ip_id varchar(40), in ip_tag integer, in ip_more_fuel integer)
sp_main: begin
	-- ensure that the drone being switched is valid and owned by the service
    if not exists(select tag from drones where tag=ip_tag and id=ip_id)
    then leave sp_main; end if;

    -- ensure that the drone is located at the service home base
    if (select home_base from delivery_services where id=ip_id)<>(select hover from drones where tag = ip_tag and id=ip_id)
    then leave sp_main; end if;
    
    update drones set fuel=fuel + ip_more_fuel where tag=ip_tag and id=ip_id;

end //
delimiter ;

-- [19] fly_drone()
-- -----------------------------------------------------------------------------
/* This stored procedure allows us to move a single or swarm of drones to a new
location (i.e., destination). The main constraints on the drone(s) being able to
move to a new location are fuel and space.  A drone can only move to a destination
if it has enough fuel to reach the destination and still move from the destination
back to home base.  And a drone can only move to a destination if there's enough
space remaining at the destination.  For swarms, the flight directions will always
be given to the lead drone, but the swarm must always stay together. */
-- -----------------------------------------------------------------------------
drop function if exists fuel_required;
delimiter //
create function fuel_required (ip_departure varchar(40), ip_arrival varchar(40))
	returns integer reads sql data
begin
	if (ip_departure = ip_arrival) then return 0;
    else return (select 1 + truncate(sqrt(power(arrival.x_coord - departure.x_coord, 2) + power(arrival.y_coord - departure.y_coord, 2)), 0) as fuel
		from (select x_coord, y_coord from locations where label = ip_departure) as departure,
        (select x_coord, y_coord from locations where label = ip_arrival) as arrival);
	end if;
end //
delimiter ;

drop procedure if exists fly_drone;
delimiter //
create procedure fly_drone (in ip_id varchar(40), in ip_tag integer, in ip_destination varchar(40))
sp_main: begin
	declare ip_swarm_id varchar(40); declare ip_swarm_tag integer;

	-- ensure that the lead drone being flown is directly controlled and owned by the service 
	if (select swarm_id from drones where id = ip_id and tag = ip_tag) is not null then 
		if ((select swarm_id, swarm_tag from drones where id = ip_id and tag = ip_tag) not in (select id, tag from drones)) then 
		leave sp_main; end if;
    
	-- ensure that the lead drone being flown is owned by the service 
		if (select swarm_id from drones where id = ip_id) not in (select id from delivery_services) then 
		leave sp_main; end if; 
    end if;
    
    -- ensure that the destination is a valid location
    if ip_destination not in (select label from locations) then 
    leave sp_main; end if;
   
   if (select swarm_id from drones where id = ip_id and tag = ip_tag) is null then
    
    -- ensure that the drone isn't already at the location
    if ip_destination = (select hover from drones where id = ip_id and tag = ip_tag) then 
    leave sp_main; end if;
    
    -- ensure that the drone/swarm has enough fuel to reach the destination and (then) home base
    if fuel_required((select hover from drones where id = ip_id and tag = ip_tag), ip_destination) * 2 > 
    (select fuel from drones where id = ip_id and tag = ip_tag) then 
    leave sp_main; end if;
    
    -- ensure that the drone/swarm has enough space at the destination for the flight
    if (select count(hover) from drones group by hover having hover = (select hover from drones where id = ip_id and tag = ip_tag) + 1) > 
    (select space from locations where label = ip_destination) then leave sp_main; end if; 
    
    update drones 
    set fuel = fuel - fuel_required((select hover from (select * from drones) as t where id = ip_id and tag = ip_tag), ip_destination)
	where id = (select id from (select * from drones) as t where id = ip_id and tag = ip_tag) and 
	tag = (select tag from (select * from drones) as t where id = ip_id and tag = ip_tag);
    
    update drones set hover = ip_destination where id = ip_id and tag = ip_tag;
    end if;
    
	if (select swarm_id from drones where id = ip_id and tag = ip_tag) is not null then
    select swarm_id from drones 
    where id = ip_id and tag = ip_tag 
    into ip_swarm_id;
    select swarm_tag from drones 
    where id = ip_id and tag = ip_tag 
    into ip_swarm_tag;
    
    -- ensure that the drone isn't already at the location
    if ip_destination = (select hover from drones where id = ip_swarm_id and tag = ip_swarm_tag) then 
    leave sp_main; end if;
    
    -- ensure that the drone/swarm has enough fuel to reach the destination and (then) home base
    if fuel_required((select hover from drones where id = ip_swarm_id and tag = ip_swarm_tag), ip_destination) * 2 > 
    (select fuel from drones where id = ip_swarm_id and tag = ip_swarm_tag) 
    then leave sp_main; end if;
    
    -- ensure that the drone/swarm has enough space at the destination for the flight
    if (select count(hover) from drones 
    group by hover having hover = (select hover from drones where id = ip_swarm_id and tag = ip_swarm_tag) + 1) > 
    (select space from locations where label = ip_destination) then 
    leave sp_main; end if; end if;
	
	update drones 
    set fuel = fuel - fuel_required((select hover from (select * from drones) as t where swarm_id = ip_id and swarm_tag = ip_tag), ip_destination)
	where id = (select id from (select * from drones) as t where swarm_id = ip_id and swarm_tag = ip_tag)  and 
	tag = (select tag from (select * from drones) as t where swarm_id = ip_id and swarm_tag = ip_tag);
    
    update drones 
    set hover = ip_destination 
    where id = (select id from (select * from drones where swarm_id = ip_id and swarm_tag = ip_tag) as t) 
    and tag = (select tag from (select * from drones where swarm_id = ip_id and swarm_tag = ip_tag) as t);
    
	update drones 
    set fuel = fuel - fuel_required((select hover from (select * from drones) as t where id = ip_id and tag = ip_tag), ip_destination)
	where id = (select id from (select * from drones) as t where id = ip_id and tag = ip_tag)  and 
	tag = (select tag from (select * from drones) as t where id = ip_id and tag = ip_tag);
   
    update drones set hover = ip_destination 
    where id = ip_id and tag = ip_tag;
    
    if (select swarm_id from drones where id = ip_id and tag = ip_tag) is null then
    update pilots 
    set experience = experience + 1
	where username = (select flown_by from (select * from drones) as t
    where id = ip_id and tag = ip_tag); end if;
    
    if (select swarm_id from drones where id = ip_id and tag = ip_tag) is not null then
    update pilots 
    set experience = experience + 1
	where username = (select flown_by from (select * from drones) as t 
    where id = (select swarm_id from (select * from drones) as t 
    where swarm_id = ip_id and swarm_tag = ip_tag) and 
	tag = (select swarm_tag from (select * from drones) as t 
    where swarm_id = ip_id and swarm_tag = ip_tag)); end if;
    
end //
delimiter ;

-- [20] purchase_ingredient()
-- -----------------------------------------------------------------------------
/* This stored procedure allows a restaurant to purchase ingredients from a drone
at its current location.  The drone must have the desired quantity of the ingredient
being purchased.  And the restaurant must have enough money to purchase the
ingredients.  If the transaction is otherwise valid, then the drone and restaurant
information must be changed appropriately.  Finally, we need to ensure that all
quantities in the payload table (post transaction) are greater than zero. */
-- -----------------------------------------------------------------------------
drop procedure if exists purchase_ingredient;
delimiter //
create procedure purchase_ingredient (in ip_long_name varchar(40), in ip_id varchar(40),
	in ip_tag integer, in ip_barcode varchar(40), in ip_quantity integer)
sp_main: begin
	-- ensure that the restaurant is valid
    if ip_long_name not in (select long_name from restaurants)
    then leave sp_main; end if;
    
    -- ensure that the drone is valid and exists at the resturant's location
    if ip_tag not in (select tag from drones where id=ip_id and hover in (select location from restaurants where long_name=ip_long_name))
    then leave sp_main; end if;
    
	-- ensure that the drone has enough of the requested ingredient
    if (select quantity from payload where tag=ip_tag and barcode=ip_barcode and id=ip_id) < ip_quantity
    then leave sp_main; end if;
    
	-- update the drone's payload
    update payload set quantity = quantity-ip_quantity where tag=ip_tag and barcode=ip_barcode and id=ip_id;
    
    -- ensure all quantities in the payload table are greater than zero
    if (select quantity from payload where tag=ip_tag and id=ip_id and barcode=ip_barcode) < 0
    then leave sp_main; end if;
    
    -- update the monies spent and gained for the drone and restaurant
    set @money = (select price*ip_quantity from payload where tag=ip_tag and barcode=ip_barcode and id=ip_id);
    
    update restaurants set spent=spent+@money where long_name=ip_long_name;
    update drones set sales = sales+@money where tag=ip_tag and id=ip_id;
    
end //
delimiter ;

-- [21] remove_ingredient()
-- -----------------------------------------------------------------------------
/* This stored procedure removes an ingredient from the system.  The removal can
occur if, and only if, the ingredient is not being carried by any drones. */
-- -----------------------------------------------------------------------------
drop procedure if exists remove_ingredient;
delimiter //
create procedure remove_ingredient (in ip_barcode varchar(40))
sp_main: begin
	-- ensure that the ingredient exists
    if (ip_barcode NOT IN (select barcode from ingredients))
    then leave sp_main; end if;
    -- ensure that the ingredient is not being carried by any drones
    if (ip_barcode IN (select barcode from payload))
    then leave sp_main; end if;
    -- remove ingredient
    delete from ingredients where barcode = ip_barcode;
end //
delimiter ;


-- [22] remove_drone()
-- -----------------------------------------------------------------------------
/* This stored procedure removes a drone from the system.  The removal can
occur if, and only if, the drone is not carrying any ingredients, and if it is
not leading a swarm. */
-- -----------------------------------------------------------------------------
drop procedure if exists remove_drone;
delimiter //
create procedure remove_drone (in ip_id varchar(40), in ip_tag integer)
sp_main: begin
	-- ensure that the drone exists
    if (ip_tag NOT IN (select tag from drones where id = ip_id))
    then leave sp_main; end if;
    -- ensure that the drone is not carrying any ingredients
    if ((select count(barcode) from payload where tag = ip_tag and id = ip_id) > 0)
    then leave sp_main; end if;
	-- ensure that the drone is not leading a swarm
    if (ip_tag in (select swarm_tag from drones))
    then leave sp_main; end if;
    -- remove drone
    delete from drones where tag = ip_tag and id = ip_id;
end //
delimiter ;

-- [23] remove_pilot_role()
-- -----------------------------------------------------------------------------
/* This stored procedure removes a user who is a pilot (and employee) from the
system.  The removal must occur if, and only if, the pilot is not controlling
any drones.  If the pilot also has an owner role, then the owner information
must be maintained; otherwise, all of that user's information must be completely
removed from the system. */
-- -----------------------------------------------------------------------------
drop procedure if exists remove_pilot_role;
delimiter //
create procedure remove_pilot_role (in ip_username varchar(40))
sp_main: begin
	-- ensure that the pilot exists
    if (ip_username NOT IN (select username from pilots))
    then leave sp_main; end if;
    -- ensure that the pilot is not controlling any drones
	if (ip_username IN (select flown_by from drones))
    then leave sp_main; end if;
    -- remove all remaining information unless the pilot is also a worker
    if (ip_username IN (select username from workers))
    then leave sp_main; end if;
    -- if pilot is an owner, retain owner information
    if (ip_username in (select username from restaurant_owners))
    then delete from pilots where username = ip_username;
    else 
    -- remove pilot
    delete from pilots where username = ip_username;
    delete from employees where username = ip_username;
    delete from users where username = ip_username;
    
    end if;
end //
delimiter ;



-- [24] display_owner_view()
-- -----------------------------------------------------------------------------
/* This view displays information in the system from the perspective of an owner.
For each owner, it includes the owner's information, along with the number of
restaurants for which they provide funds and the number of different places where
those restaurants are located.  It also includes the highest and lowest ratings
for each of those restaurants, as well as the total amount of debt based on the
monies spent purchasing ingredients by all of those restaurants. And if an owner
doesn't fund any restaurants then display zeros for the highs, lows and debt. */
CREATE OR REPLACE VIEW display_owner_view AS
    SELECT 
        restaurant_owners.username,
        users.first_name,
        users.last_name,
        users.address,
        COUNT(restaurants.funded_by) AS num_restaurants,
        COUNT(DISTINCT (location)) AS num_places,
        MAX(COALESCE(restaurants.rating, 0)) AS highs,
        MIN(COALESCE(restaurants.rating, 0)) AS lows,
        SUM(COALESCE(restaurants.spent, 0)) AS debt
    FROM
        restaurant_owners
            LEFT JOIN
        users ON restaurant_owners.username = users.username
            LEFT JOIN
        restaurants ON restaurant_owners.username = restaurants.funded_by
    GROUP BY restaurant_owners.username;

-- [25] display_employee_view()
-- -----------------------------------------------------------------------------
/* This view displays information in the system from the perspective of an employee.
For each employee, it includes the username, tax identifier, hiring date and
experience level, along with the license identifer and piloting experience (if
applicable), and a 'yes' or 'no' depending on the manager status of the employee. */
CREATE OR REPLACE VIEW display_employee_view AS
    SELECT 
        employees.username,
        employees.taxID,
        employees.salary,
        employees.hired,
        employees.experience AS employee_experience,
        COALESCE(pilots.licenseID, 'n/a') AS licenseID,
        COALESCE(pilots.experience, 'n/a') AS piloting_experience,
        CASE
            WHEN ISNULL(delivery_services.manager) THEN 'no'
            ELSE 'yes'
        END AS manager_status
    FROM
        employees
            LEFT JOIN
        pilots ON employees.username = pilots.username
            LEFT JOIN
        delivery_services ON employees.username = delivery_services.manager
    GROUP BY employees.username;

-- [26] display_pilot_view()
-- -----------------------------------------------------------------------------
/* This view displays information in the system from the perspective of a pilot.
For each pilot, it includes the username, licenseID and piloting experience, along
with the number of drones that they are controlling. */
CREATE OR REPLACE VIEW display_pilot_view AS
    SELECT 
        pilots.username,
        pilots.licenseID,
        pilots.experience,
        COUNT(i5.flown_by) AS num_drones,
        COUNT(DISTINCT i5.hover) AS num_locations
    FROM
        (SELECT 
            id, tag, flown_by, hover
        FROM
            (SELECT 
            *
        FROM
            drones) AS i1 UNION ALL SELECT 
            *
        FROM
            (SELECT 
            i2.id, i2.tag, i2.flown_by, i2.hover
        FROM
            (SELECT 
            *
        FROM
            drones) AS i2
        JOIN (SELECT 
            *
        FROM
            drones) AS i3 ON i2.id = i3.swarm_id
            AND i2.tag = i3.swarm_tag) AS i4) AS i5
            RIGHT JOIN
        pilots ON pilots.username = i5.flown_by
    GROUP BY pilots.username;

-- [27] display_location_view()
-- -----------------------------------------------------------------------------
/* This view displays information in the system from the perspective of a location.
For each location, it includes the label, x- and y- coordinates, along with the
number of restaurants, delivery services and drones at that location. */
CREATE OR REPLACE VIEW display_location_view AS
    SELECT 
        locations.label,
        locations.x_coord,
        locations.y_coord,
        COUNT(DISTINCT (restaurants.long_name)) AS num_restaurants,
        COUNT(DISTINCT (delivery_services.id)) AS num_delivery_services,
        COUNT(DISTINCT CONCAT(drones.id, drones.tag)) AS num_drones
    FROM
        locations
            LEFT JOIN
        restaurants ON locations.label = restaurants.location
            LEFT JOIN
        delivery_services ON locations.label = delivery_services.home_base
            LEFT JOIN
        drones ON locations.label = drones.hover
    GROUP BY locations.label;

-- [28] display_ingredient_view()
-- -----------------------------------------------------------------------------
/* This view displays information in the system from the perspective of the ingredients.
For each ingredient that is being carried by at least one drone, it includes a list of
the various locations where it can be purchased, along with the total number of packages
that can be purchased and the lowest and highest prices at which the ingredient is being
sold at that location. */
CREATE OR REPLACE VIEW display_ingredient_view AS
    SELECT 
        ingredients.iname,
        drones.hover AS location,
        payload.quantity,
        payload.price AS low_price,
        payload.price AS high_price
    FROM
        payload
            LEFT JOIN
        drones ON drones.tag = payload.tag
            AND drones.id = payload.id
            LEFT JOIN
        ingredients ON ingredients.barcode = payload.barcode
    ORDER BY iname , location;


-- [29] display_service_view()
-- -----------------------------------------------------------------------------
/* This view displays information in the system from the perspective of a delivery
service.  It includes the identifier, name, home base location and manager for the
service, along with the total sales from the drones.  It must also include the number
of unique ingredients along with the total cost and weight of those ingredients being
carried by the drones. */
CREATE OR REPLACE VIEW display_service_view AS
    SELECT 
        delivery_services.id,
        delivery_services.long_name,
        delivery_services.home_base,
        delivery_services.manager,
        SUM(DISTINCT (drones.sales)) AS revenue,
        COUNT(DISTINCT (payload.barcode)) AS ingredients_carried,
        SUM(DISTINCT (payload.price * payload.quantity)) AS cost_carried,
        SUM(DISTINCT (payload.quantity * ingredients.weight)) AS weight_carried
    FROM
        delivery_services
            LEFT JOIN
        drones ON delivery_services.id = drones.id
            LEFT JOIN
        payload ON delivery_services.id = payload.id
            INNER JOIN
        ingredients ON ingredients.barcode = payload.barcode
    GROUP BY delivery_services.id;




