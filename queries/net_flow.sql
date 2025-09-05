WITH 
-- 1. Get deposits from Ethereum Mainnet
ethereum_deposits AS (
    SELECT 
        date_trunc('day', evt_block_time) AS day,
        SUM(amount / 1e18) AS flow_eth
    FROM renzo_ethereum.RestakeManager_evt_Deposit
    GROUP BY 1
),

-- 2. Get deposits from symbiotic chains
symbiotic_deposits AS (
    SELECT 
        day,
        deposits_eth AS flow_eth
    FROM query_3919869
    WHERE deposits_eth IS NOT NULL
),

-- 3. Get withdrawals from all sources
all_withdrawals AS (
    SELECT 
        day,
        -ezeth_amount AS flow_eth  -- Negative for outflows
    FROM query_3851298
    WHERE ezeth_amount IS NOT NULL
),

-- 4. Combine all flows
all_flows AS (
    SELECT day, flow_eth FROM ethereum_deposits
    UNION ALL
    SELECT day, flow_eth FROM symbiotic_deposits  
    UNION ALL
    SELECT day, flow_eth FROM all_withdrawals
)

-- 5. Calculate final net flow
SELECT 
    day,
    SUM(flow_eth) AS net_flow_eth
FROM all_flows
GROUP BY day
ORDER BY day DESC
