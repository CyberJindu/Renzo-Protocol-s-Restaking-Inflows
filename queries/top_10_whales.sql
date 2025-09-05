WITH deposits AS (
    SELECT 
        depositor AS address,
        SUM(amount / 1e18) AS total_eth_deposited,
        COUNT(*) AS total_deposits
    FROM 
        renzo_ethereum.RestakeManager_evt_Deposit
    GROUP BY 
        1
),

latest_price AS (
    SELECT 
        price
    FROM 
        prices.usd_latest
    WHERE 
        blockchain = 'ethereum'
        AND symbol = 'WETH'
)

SELECT 
    -- Use Dune's function to create a clickable link to Etherscan
    get_href(
        get_chain_explorer_address('ethereum', address),
        CONCAT('0x', SUBSTRING(CAST(address AS VARCHAR), 3, 6), '...', "right"(CAST(address AS VARCHAR), 4))
    ) AS "Depositor's Address",
    total_eth_deposited AS "Total ETH Deposited",
    total_eth_deposited * p.price AS "Total USD Value",
    total_deposits AS "Number of Deposits"
FROM 
    deposits 
CROSS JOIN 
    latest_price p
ORDER BY 
    total_eth_deposited DESC
LIMIT 10;
