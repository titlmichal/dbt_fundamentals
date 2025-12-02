-- this is a singular test for payments stg table in jaffle_shop dataset testing for total amount being positive
-- generic tests are in the end sql queires --> singular tests are too

select
    order_id,
    sum(amount) as total_amount
from {{ ref("stg_jaffle_shop__payments")}} 
-- using ref macro isntead of harcorded db.dataset.table
    -- bcs we want to reference the model
    -- plus when someone else will run, target and source schema might be different
group by 1
having total_amount < 0
    -- BTW bigquery doesnt like seeing ; at the end (--> will throw an error)

-- HOW TEST FAILS? --> WHEN ANY RESULT IS RETURNED
--> hence we want to see those failures (= those below 0)

-- HOW TO TEST JUST ONE MODEL?
--> use dbtf test --select model_name

-- ONLY GENERIC or SINGULAR tests?
--> use dbtf test --select test_type:generic