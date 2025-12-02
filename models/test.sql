-- with all_values as (

--     select
--         status as value_field,
--         count(*) as n_records

--     from `dbt-fundamentals-course-479017`.`jaffle_shop`.`stg_jaffle_shop__orders`
--     group by status

-- )

-- select *
-- from all_values
-- where value_field not in (
--     'placed','shipped','completed','returned'
-- )
-- ;


select
    order_id,
    sum(amount) as total_amount
from {{ ref("stg_jaffle_shop__payments")}} 
-- using ref macro isntead of harcorded db.dataset.table
    -- bcs we want to reference the model
    -- plus when someone else will run, target and source schema might be different
group by 1
having total_amount < 0