    select
        id as customer_id,
        first_name,
        last_name

    -- from `dbt-fundamentals-course-479017.jaffle_shop.customers_source`
    from {{source("jaffle_shop", "customers_source")}}
    -- 2 args: name of the source + name of the table
    --> if I go to target --> compiled --> models --> stagging --> there is sql that was compiled containg the source again

    -- thanks to I can: 1) change db or schema just in one file + 2) see the source in lineage