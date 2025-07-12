# ManufactuLink

A decentralized supply chain traceability solution built on Stacks blockchain for manufacturing industries.

## Overview

ManufactuLink enables manufacturers to track products through their entire production lifecycle using blockchain technology. The smart contract provides immutable records of production stages, quality metrics, and operator actions, ensuring transparency and accountability in manufacturing processes.

## Features

- **Product Registration**: Create and register products with unique identifiers
- **Production Stage Tracking**: Record each manufacturing stage with timestamps and metadata
- **Quality Scoring**: Track quality metrics at each production stage
- **Operator Authorization**: Manage authorized operators who can interact with the system
- **Immutable Records**: All production data is stored on-chain for permanent traceability
- **Location Tracking**: Record geographical locations of production stages

## Smart Contract Functions

### Public Functions

- `authorize-operator`: Grant authorization to new operators
- `revoke-operator`: Remove operator authorization
- `create-product`: Register a new product in the system
- `add-production-stage`: Record a new production stage for a product
- `deactivate-product`: Mark a product as inactive

### Read-Only Functions

- `get-product`: Retrieve product information by ID
- `get-production-stage`: Get production stage details by stage ID
- `get-product-counter`: Get total number of products registered
- `get-stage-counter`: Get total number of production stages recorded
- `is-operator-authorized`: Check if an operator is authorized
- `get-contract-owner`: Get the contract owner address

## Data Structures

### Product
- `product-id`: Unique identifier
- `name`: Product name (up to 64 characters)
- `manufacturer`: Principal address of manufacturer
- `created-at`: Block height when product was created
- `current-stage`: Current production stage ID
- `is-active`: Product status

### Production Stage
- `stage-id`: Unique stage identifier
- `product-id`: Associated product ID
- `stage-name`: Name of production stage (up to 32 characters)
- `operator`: Principal who recorded the stage
- `timestamp`: Block height when stage was recorded
- `location`: Physical location (up to 64 characters)
- `quality-score`: Quality metric (0-100)
- `metadata`: Additional information (up to 256 characters)

## Error Codes

- `u100`: Not authorized
- `u101`: Product not found
- `u102`: Stage not found
- `u103`: Invalid stage transition
- `u104`: Product already exists
- `u105`: Empty string provided
- `u106`: Invalid timestamp

## Getting Started

1. Deploy the contract to Stacks blockchain
2. The deployer becomes the contract owner
3. Authorize operators using `authorize-operator`
4. Start creating products and tracking production stages

## Testing

Run the test suite using Clarinet:

```bash
clarinet test
```

