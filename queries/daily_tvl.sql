WITH 
-- CTE 1: Get the latest TVL calculation for each day from Ethereum Mainnet
latest_daily_tvl AS (
    SELECT 
        date_trunc('day', call_block_time) as day, 
        ROW_NUMBER() OVER (
            PARTITION BY date_trunc('day', call_block_time) 
            ORDER BY call_block_time DESC
        ) as recency_rank,
        output_2 / 1e18 as tvl_eth 
    FROM 
        renzo_ethereum.RestakeManager_call_calculateTVLs
    WHERE 
        call_success = true 
),

-- CTE 2: Filter to only keep the most recent TVL value per day
cleaned_daily_tvl AS (
    SELECT 
        day,
        tvl_eth 
    FROM 
        latest_daily_tvl 
    WHERE 
        recency_rank = 1 
),

-- CTE 3: Get USD price of ETH for joining
eth_prices AS (
    SELECT
        minute as price_time,
        price
    FROM
        prices.usd
    WHERE
        blockchain = 'ethereum'
        AND symbol = 'WETH'
)

-- MAIN QUERY: Combine Ethereum TVL with symbiotic TVL and calculate metrics
SELECT 
    t.day,
    -- Ethereum Mainnet Metrics
    t.tvl_eth as eigenlayer_tvl_eth,
    t.tvl_eth * p.price as eigenlayer_tvl_usd,
    
    -- Cross-Chain Total Metrics (Ethereum + Symbiotic)
    t.tvl_eth + COALESCE(sy.tvl_eth, 0) as total_tvl_eth, 
    (t.tvl_eth * p.price) + COALESCE(sy.tvl_usd, 0) as total_tvl_usd,
    
    -- Symbiotic (Multi-Chain) Metrics
    sy.tvl_usd as symbiotic_tvl_usd,
    sy.tvl_eth as symbiotic_tvl_eth,
    
    -- NEW: The "Leading Indicator" - Daily Percentage Change
    (( (t.tvl_eth * p.price) + COALESCE(sy.tvl_usd, 0) ) / 
    LAG( (t.tvl_eth * p.price) + COALESCE(sy.tvl_usd, 0) ) 
      OVER (ORDER BY t.day) - 1) * 100 AS daily_pct_change

FROM 
    cleaned_daily_tvl t
LEFT JOIN 
    eth_prices p ON p.price_time = t.day
LEFT JOIN 
    query_3919869 sy ON t.day = sy.day  -- Symbiotic TVL data
ORDER BY 
    t.day DESC;

Add daily TVL query
