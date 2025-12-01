-- in case i want to materialize everything else as default but this as a view --> config block on model-level
--> double {} = macro = function in dbt (usually single line but configs longer)
{{
    config(
        materialized = "table" 
    )
}}
-- switching to table bcs Bigquery offers 10 GB free quering but 1 TB of free storage (table = storing) + dbt best practice to have mart as a table
-- btw comments within jinja block have to follow jinja commenting, not sql
--> this will be used primarly for materializing this DM



with customers as (

    /*
    select
        id as customer_id,
        first_name,
        last_name

    -- from raw.jaffle_shop.customers
    -- replacing bcs this cloned repo works with snowflake data, not bigquerry
    -- from dbt-tutorial.jaffle_shop.customers
    -- replacing this too bcs AI says the erorr is due to the fact the dbt-tutorial is not min
    -- from `dbt-fundamentals-course-479017.jaffle_shop.customers`
    -- again, i dont have any data in my dataset, AI proposes using this dbt approach with sources.yml file in models dir
    -- (had to remove this one bcs the syntax cause some issues when compiling even when commented out)
    -- coming back to one of the previous version bcs AI didnt help --> copied and inserted the contents in my own tables
    -- from `dbt-fundamentals-course-479017.jaffle_shop.customers`
    -- was getting location issues (dataset is multregion EU, project is west4 --> switched in profiles to EU)
    -- was getting issue that customer mat. view was trying to be created by the macro but it already as a table
    -- --> switched to different name (in gcp)
    from `dbt-fundamentals-course-479017.jaffle_shop.customers_source`
    */
    

    -- for sake of modulartiy --> moving this into stagging model so hypothetical others could use it
    -- stagging model is called stg_ ... to indicate its a stagging model 
    -- + jaffle_shop as a schema
    -- + customers as table name
    -- --> modularizing and hitting dbtf run to check its ok syntax
    -- how to query now? --> using a ref macro (btw the double {} are Jinja - templating lang)

    select * from {{ ref("stg_jaffle_shop__customers")}} -- the name has to reference the name of the sql file (also = the name in bigquery now)
    -- those 2 stagging models have to be built before building the final one, otherwise dbt --> can use +Run model (run model and parents)
    -- the +Run will run this model plus everything that is within the ref (= upstream)
    -- --> in SQL (see the log) the ref macro will be replaced by the SQL valid language bcs the Jinja is rendered to pure SQL 
    -- the ref referenced a stagging model within this environemt/project/DB and target schema/dataset
    -- --> so if someone else would use this code --> it would have their own project/DB and target schema (btw that has to be unique for each dev)

),

orders as (

    /*
    select
        id as order_id,
        user_id as customer_id,
        order_date,
        status

    -- from raw.jaffle_shop.orders
    -- replacing bcs this cloned repo works with snowflake data, not bigquerry
    -- from dbt-tutorial.jaffle_shop.orders
    -- replacing this too bcs AI says the erorr is due to the fact the dbt-tutorial is not min
    -- from `dbt-fundamentals-course-479017.jaffle_shop.orders`
    -- again, i dont have any data in my dataset, AI proposes using this dbt approach with sources.yml file in models dir
    -- (had to remove this one bcs the syntax cause some issues when compiling even when commented out)
    -- coming back to one of the previous version bcs AI didnt help --> copied and inserted the contents in my own tables
    -- from `dbt-fundamentals-course-479017.jaffle_shop.orders`
    -- was getting location issues (dataset is multregion EU, project is west4 --> switched in profiles to EU)
    -- was getting issue that customer mat. view was trying to be created by the macro but it already as a table
    -- --> switched to different name (in gcp)
    from `dbt-fundamentals-course-479017.jaffle_shop.orders_source`
    */

    -- same as for customers --> modularizing

    select * from {{ ref("stg_jaffle_shop__orders")}}

),

payments as (
    select
        *
    from {{ ref("stg_jaffle_shop__payments")}}
),

customer_orders as (

    select
        customer_id, -- if i was to remove this comma and save, the extension would highlight the issue (no need to compike/run)
                    -- same if I change the name or the column name is changed in source (even in some other upstream data model/sql)
                    -- same for changing the references/upstream data models names
                    -- ... thats thanks to the dbt fusion engine ... they say

        min(order_date) as first_order_date,
        max(order_date) as most_recent_order_date,
        count(order_id) as number_of_orders

    from orders

    group by 1

),

lifetime_orders as (
    select
        orders.customer_id,
        sum(payments.amount) as lifetime_value 
    from orders
    left join payments using (order_id)
    where payments.status = 'success'
    group by 1
),

final as (

    select
        customers.customer_id,
        customers.first_name,
        customers.last_name,
        customer_orders.first_order_date,
        customer_orders.most_recent_order_date,
        coalesce(customer_orders.number_of_orders, 0) as number_of_orders,
        coalesce(lifetime_orders.lifetime_value, 0) as lifetime_value


    from customers

    left join customer_orders using (customer_id)
    left join lifetime_orders using (customer_id)

)

select * from final

/*
this doesnt yet build anything --> i have to "run the model" (e.g. via dbtf run or via the x in top right)
--> MATERIALIZATION: it created a view in the platform --> it materialized (view is default)
dbt basically creates DDR and DDL wrapper --> see query_log.sql in logs dir (it took the customers name and built in bigquery)

do I want to change to build tables instead of views as data objects? --> dbt_project.yml file --> models ... materialized --> table
(btw got an error about missing table when commenting out view and setting it to be table --> removed comment --> worked --> added back --> still works
... and log changed accordingly)

modularity? --> breaking big system into simple parts to be assembled --> possible to apply to data modelling --> use semantic pieces 
with distinct models to create one big final one (--> modularity and reuse)

dbt has some best practices --> one of them is clean project organization --> directories in models directory
stagging = stagging models
marts = data marts = final tables (--> good to also rename e.g. dim_customers to shot its dimension table)
- one of best practices: have stagging models as views
*/