with payments as (
    select
        *
    from {{ ref("stg_jaffle_shop__payments")}}
),
orders as (
    select
        *
    from {{ ref("stg_jaffle_shop__orders")}}
),
payments_orders as (
    select
        orders.order_id,
        orders.customer_id,
        orders.order_date,
        orders.status,
        payments.payment_method,
        payments.amount
    from orders
    inner join payments on
        orders.order_id = payments.order_id
        -- and orders.customer_id = payments.customer_id
)
select * from payments_orders