{% docs order_status %}
<!-- This is jinja as well, this time its a setter = setting the doc block name -->

One of the following values: 

| status         | definition                                       |
|----------------|--------------------------------------------------|
| placed         | Order placed, not yet shipped                    |
| shipped        | Order has been shipped, not yet been delivered   |
| completed      | Order has been received by customers             |
| return pending | Customer indicated they want to return this item |
| returned       | Item has been returned                           |

{% enddocs %}
<!-- Jinja too = here closing the doc block -->
<!-- btw allows us to have multiple doc blocks in one file -->

{% docs payments %}

This is a doc block for staged DM of payments.
The table is later used in both final DM/DM tables: dimensional customers
and factual orders.

{% enddocs %}