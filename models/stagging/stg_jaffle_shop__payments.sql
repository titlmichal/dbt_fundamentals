select
    id as payment_id,
    order_id,
    payment_method,
    status,
    amount,
    created
-- from `dbt-fundamentals-course-479017.jaffle_shop.payments_source`
from {{source("jaffle_shop", "payments_source")}}