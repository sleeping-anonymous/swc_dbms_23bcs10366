-- https://datalemur.com/questions/repeated-payments
WITH payments as(
  select merchant_id,
    EXTRACT(
      EPOCH
      from transaction_timestamp - LAG(transaction_timestamp) OVER(
          PARTITION BY merchant_id,
          credit_card_id,
          amount
          ORDER BY transaction_timestamp
        )
    ) / 60 AS minute_diff
  from transactions
)
select count(merchant_id) as payment_count
from payments
where minute_diff <= 10;