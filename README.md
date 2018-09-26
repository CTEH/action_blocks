# ActionBlocks

ActionBlocks is a Ruby On Rails engine for building administrative database-driven applications.

* Automates Backend and Frontend Development

* Supports Granular Authorization

* Leverages PostgreSQL for Performance

* Encourages Task Oriented UI


Automates Backend and Frontend Development
-------------------

A single low-code DSL is used to define both the backend and frontend.

![ActionBlocks Diagram](https://raw.githubusercontent.com/CTEH/action_blocks/master/docs/single_dsl_diagram.png)

```ruby
ActionBlocks.app do
  title "My App"
  workspace :main do
    subspace :orders  do
      dashboard :all_orders do
        table :list_all do
          model :order
          columns [:number, :employee, :customer, :status]
        end
      end

...
```

Supports Granular Authorization
----------

Row Level Security (RLS) is defined for each role.

```ruby
ActionBlock.authorize Post do
    grant :reviewer do
        _or(
            _eq(:author_id, _user(:id)),
            _eq(:status, 'Published')
        ),
    end
end
```

Field Level Security (FLS) is defined for each role.

```ruby
read do
    read :employee,          [:admin           ]
    read :customer,          [:admin, :customer]
    read :social_security    [:admin, :customer]
    read :order_date,        [:admin, :customer]
    read :shipped_date,      [:admin, :customer]
    read :ship_name,         [:admin, :customer]
    read :ship_address1,     [:admin, :customer]
    read :ship_address2,     [:admin, :customer]
    read :ship_city,         [:admin, :customer]
    read :ship_state,        [:admin, :customer]
    read :ship_postal_code,  [:admin, :customer]
    read :ship_country,      [:admin, :customer]
    read :shipping_fee,      [:admin, :customer]
    read :payment_type,      [:admin, :customer]
    read :paid_date,         [:admin, :customer]
    read :created_at,        [:admin, :customer]
    read :updated_at,        [:admin, :customer]
    read :region,            [:admin, :customer]
    read :referred_by,       [:admin, :customer]
end

```



Leverages PostgreSQL for Performance
------------

ActionBlocks is similar to [Hasura](https://blog.hasura.io/architecture-of-a-high-performance-graphql-to-sql-server-58d9944b8a87) since it avoids N+1 queries and pushes JSON generation into PostgreSQL

* Uses an intelligent DSL managed data engine that avoids the N+1 problem associated with retrieving data in related tables and running authorization checks.

* Bypasses the performance tax of marshalling results to Objects and ultimately to JSON by pushing the transformation into PostgreSQL.

Encourages Task Oriented UI
------------

Following the pholisophy of make the right thing the easy thing, ActionBlocks doesn't support CRUD.  Instead it provides a rich DSL for Task Oriented UIs as explained https://cqrs.wordpress.com/documents/task-based-ui/



## License
MIT License

Copyright (c) 2018 CTEH LLC

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.


