    select
        id as order_id,
        user_id as customer_id,
        order_date,
        status,
        _etl_loaded_at

    -- from `dbt-fundamentals-course-479017.jaffle_shop.orders_source`
    from {{source("jaffle_shop", "orders_source")}}