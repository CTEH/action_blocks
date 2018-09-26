```grant :customer do
    and(
        or(
          eq(:customer_company, _user(:company)),
          eq(:customer_otherfield,  _user(:something))
        ),
        eq(:customer_thirdfield, _user(:blah)),
        gt(:published, -> Date.today-3.days )
    )
end```


```ruby

    ActionBlock.authorize Order do
        grant :admin, do |user| [] end
        grant :customer do
            _and(
                _or(
                _eq(:customer_company, _user(:company)),
                _eq(:customer_otherfield,  _user(:something))
                ),
                _eq(:customer_thirdfield, _user(:blah)),
                _gt(:published, -> Date.today-3.days )
            )
        end

        read do
            read :employee,          [a    ]
            read :customer,          [a,  c]
            read :social_security    [a,  c]
            read :order_date,        [a,  c]
            read :shipped_date,      [a,  c]
            read :ship_name,         [a,  c]
            read :ship_address1,     [a,  c]
            read :ship_address2,     [a,  c]
            read :ship_city,         [a,  c]
            read :ship_state,        [a,  c]
            read :ship_postal_code,  [a,  c]
            read :ship_country,      [a,  c]
            read :shipping_fee,      [a,  c]
            read :payment_type,      [a,  c]
            read :paid_date,         [a,  c]
            read :created_at,        [a,  c]
            read :updated_at,        [a,  c]
            read :region,            [a,  c]
            read :referred_by,       [a,  c]
        end

        mask do
            mask :social_security    [a,   ]
        end

        export do
            export :employee,          [a    ]
            export :customer,          [    c]
            export :social_security    [     ]
            export :order_date,        [a,  c]
            export :shipped_date,      [a,  c]
            export :ship_name,         [    c]
            export :ship_address1,     [    c]
            export :ship_address2,     [    c]
            export :ship_city,         [a,  c]
            export :ship_state,        [a,  c]
            export :ship_postal_code,  [a,  c]
            export :ship_country,      [a,  c]
            export :shipping_fee,      [a,  c]
            export :payment_type,      [a,  c]
            export :paid_date,         [a,  c]
            export :created_at,        [a,  c]
            export :updated_at,        [a,  c]
            export :region,            [a,  c]
            export :referred_by,       [a,  c]
        end
    end
end

```

    t.bigint "employee_id"
    t.bigint "customer_id"
    t.datetime "order_date"
    t.datetime "shipped_date"
    :ship_name"
    t.text "ship_address1"
    t.text "ship_address2"
    :ship_city"
    :ship_state"
    :ship_postal_code"
    :ship_country"
    t.decimal "shipping_fee", precision: 17, scale: 2
    :payment_type"
    t.datetime "paid_date"
    :status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    :num"
    t.bigint "region_id"
    t.bigint "referred_by_id"