--To disable this model, set the using_bill and using_bill_payment variables within your dbt_project.yml file to False.
{{ config(enabled=var('using_bill', True)) and config(enabled=var('using_bill_payment', True))}}

with base as (

    select * 
    from {{ ref('stg_quickbooks__bill_linked_txn_tmp') }}

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
                source_columns=adapter.get_columns_in_relation(ref('stg_quickbooks__bill_linked_txn_tmp')),
                staging_columns=get_bill_linked_txn_columns()
            )
        }}
        
    from base
),

final as (
    
    select 
        bill_id,
        index,
        bill_payment_id
    from fields
)

select * 
from final
