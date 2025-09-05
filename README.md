# Renzo Protocol: On-Chain Analytics

A comprehensive Dune Analytics dashboard dissecting the growth and economics of Renzo Protocol.

**Live Dashboard:** (https://dune.com/jindu_onchain/renzo-protocol-restaking-inflows-and-holder-growth)

## Overview

This project tracks key metrics for Renzo Protocol, including:
- Total Value Locked (TVL) across all chains (Ethereum, Arbitrum, BNB, etc.)
- Daily net capital flows (Inflows vs. Outflows)
- Unique depositor growth
- Whale and top depositor activity

## Queries

This repository contains the SQL queries powering the dashboard:
- `queries/daily_tvl.sql`: Calculates daily TVL in ETH and USD.
- `queries/net_flow.sql`: Calculates daily net capital flows.
- `queries/top_whales.sql`: Identifies and ranks the top depositors.

## Build Process

This dashboard was built through a iterative process of hypothesis, testing, and feedback from the Renzo community. Key improvements include integrating cross-chain data to fix incomplete metrics.

## Notes

- Some data relies on internal Dune queries (`query_3919869`, `query_3851298`) for symbiotic chain data.
