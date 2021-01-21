with base as (

    select * 
    from {{ ref('stg_quickbooks__item_tmp') }}

),

fields as (

    select
        /*
        The below macro is used to generate the correct SQL for package staging models. It takes a list of columns 
        that are expected/needed (staging_columns from dbt_salesforce_source/models/tmp/) and compares it with columns 
        in the source (source_columns from dbt_salesforce_source/macros/).
        For more information refer to our dbt_fivetran_utils documentation (https://github.com/fivetran/dbt_fivetran_utils.git).
        */

        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_quickbooks__item_tmp')),
                staging_columns=get_item_columns()
            )
        }}
        
    from base
),

final as (
    
    select 
        id as item_id,
        active as is_active,
        created_at,
        income_account_id,
        asset_account_id,
        expense_account_id,
        name,
        purchase_cost,
        taxable,
        type,
        unit_price  
    from fields
)

select * 
from final
