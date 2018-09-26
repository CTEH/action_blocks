NorthWinds Application

https://github.com/mrin9/northwind

```
rails g model employee last_name:string first_name:string email:string avatar:string job_title:string department:string phone:string address1:text address2:text city:string state:string postal_code:string country:string

rails g migration add_manager_to_employee

rails g model customer last_name:string first_name:string email:string company:string phone:string address1:text address2:text city:string state:string postal_code:string country:string

rails g model order employee:references customer:references order_date:datetime shipped_date:datetime ship_name:string ship_address1:text ship_address2:text ship_city:string ship_state:string ship_postal_code:string ship_country:string shipping_fee:decimal{17-2} payment_type:string paid_date:datetime order_status:string

rails g model product product_code:string product_name:string description:string list_price:decimal{17-2} target_level:integer reorder_level:integer minimum_reorder_quantity:integer quantity_per_unit:string discounted:bool category:string

rails g model order_detail order:references product:references quantity:decimal{17-2} unit_price:decimal{17-2} discount:decimal{17-2} order_detail_status:string date_allocated:datetime
```