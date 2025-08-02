# ManufactuLink

A decentralized supply chain traceability solution built on Stacks blockchain for manufacturing industries with multi-signature approval system for critical production stages.

## Overview

ManufactuLink enables manufacturers to track products through their entire production lifecycle using blockchain technology. The smart contract provides immutable records of production stages, quality metrics, and operator actions, ensuring transparency and accountability in manufacturing processes. Enhanced with multi-signature approvals for critical production stages to ensure additional security and verification.

## Features

- **Product Registration**: Create and register products with unique identifiers
- **Production Stage Tracking**: Record each manufacturing stage with timestamps and metadata
- **Critical Stage Protection**: Multi-signature approval system for sensitive production stages
- **Quality Scoring**: Track quality metrics at each production stage (0-100 scale)
- **Operator Authorization**: Manage authorized operators who can interact with the system
- **Immutable Records**: All production data is stored on-chain for permanent traceability
- **Location Tracking**: Record geographical locations of production stages
- **Approval Workflow**: Transparent approval process with signature tracking

## Smart Contract Functions

### Public Functions

#### Operator Management
- `authorize-operator`: Grant authorization to new operators
- `revoke-operator`: Remove operator authorization
- `set-required-approvals`: Set the number of required approvals for critical stages (owner only)

#### Product Management
- `create-product`: Register a new product in the system
- `deactivate-product`: Mark a product as inactive

#### Production Stage Management
- `add-production-stage`: Record a new production stage for a product (with critical flag)
- `request-critical-stage-approval`: Request approval for a critical production stage
- `approve-critical-stage`: Approve a pending critical stage request

### Read-Only Functions

#### Product Information
- `get-product`: Retrieve product information by ID
- `get-production-stage`: Get production stage details by stage ID
- `get-product-counter`: Get total number of products registered
- `get-stage-counter`: Get total number of production stages recorded

#### Approval System
- `get-stage-approval`: Get approval request details by approval ID
- `get-approval-signature`: Check if an operator has approved a specific request
- `get-approval-counter`: Get total number of approval requests
- `get-required-approvals`: Get current required approval count

#### Authorization
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
- `is-critical`: Whether the stage requires multi-signature approval
- `approval-id`: Optional reference to approval request (for critical stages)

### Stage Approval
- `approval-id`: Unique approval identifier
- `product-id`: Associated product ID
- `stage-name`: Name of production stage being approved
- `location`: Physical location
- `quality-score`: Quality metric (0-100)
- `metadata`: Additional information
- `requester`: Principal who requested the approval
- `created-at`: Block height when approval was requested
- `approval-count`: Current number of approvals received
- `is-finalized`: Whether the approval has been completed and stage created

### Approval Signature
- `approval-id`: Associated approval request ID
- `operator`: Principal of the approving operator
- `approved`: Approval status (always true when record exists)
- `approved-at`: Block height when approval was given

## Multi-Signature Approval Workflow

### For Critical Production Stages:

1. **Request Approval**: An authorized operator calls `request-critical-stage-approval` with stage details
2. **Collect Approvals**: Other authorized operators call `approve-critical-stage` to approve the request
3. **Automatic Finalization**: Once the required number of approvals is reached, the stage is automatically created
4. **Immutable Record**: The approval process and all signatures are permanently recorded on-chain

### For Regular Production Stages:

1. **Direct Creation**: Call `add-production-stage` with `is-critical` set to `false`
2. **Immediate Processing**: Stage is created immediately without requiring approvals

## Error Codes

- `u100`: Not authorized
- `u101`: Product not found
- `u102`: Stage not found
- `u103`: Invalid stage transition
- `u104`: Product already exists
- `u105`: Empty string provided
- `u106`: Invalid timestamp
- `u107`: Approval not found
- `u108`: Already approved
- `u109`: Insufficient approvals
- `u110`: Invalid quality score (must be 0-100)
- `u111`: Invalid approval ID
- `u112`: Approval already exists

## Getting Started

### Initial Setup

1. Deploy the contract to Stacks blockchain
2. The deployer becomes the contract owner
3. Set the required number of approvals using `set-required-approvals` (default is 2)
4. Authorize operators using `authorize-operator`

### Basic Workflow

```clarity
;; 1. Create a product
(contract-call? .manufacturlink create-product "Widget Model X" 'SP1ABCD...)

;; 2. Add a regular production stage
(contract-call? .manufacturlink add-production-stage u1 "Assembly" "Factory Floor A" u95 "Initial assembly completed" false)

;; 3. Request approval for critical stage
(contract-call? .manufacturlink request-critical-stage-approval u1 "Quality Control" "QC Lab" u98 "Final quality inspection")

;; 4. Approve the critical stage (requires multiple operators)
(contract-call? .manufacturlink approve-critical-stage u1)
```

### Multi-Signature Requirements

- Critical stages require multiple operator approvals before being finalized
- The number of required approvals is configurable by the contract owner
- Each operator can only approve a request once
- Once sufficient approvals are collected, the stage is automatically created
- All approval signatures are permanently recorded for audit purposes

## Security Features

- **Multi-Signature Protection**: Critical stages require multiple approvals
- **Operator Authorization**: Only authorized operators can interact with the system
- **Immutable Audit Trail**: All approvals and signatures are permanently recorded
- **Parameter Validation**: All inputs are validated to prevent invalid data
- **Access Control**: Contract owner has exclusive rights to manage operators and approval requirements

## Testing

Run the test suite using Clarinet:

```bash
clarinet test
```

## Use Cases

- **High-Value Manufacturing**: Electronics, pharmaceuticals, aerospace components
- **Regulated Industries**: Medical devices, automotive parts, food processing
- **Quality Assurance**: Multi-stage verification for critical production steps
- **Supply Chain Auditing**: Complete traceability with approval verification
- **Compliance Reporting**: Immutable records for regulatory requirements

## Benefits of Multi-Signature Approvals

1. **Enhanced Security**: Multiple operators must agree on critical stages
2. **Reduced Fraud**: Prevents single-point manipulation of critical data
3. **Audit Compliance**: Complete signature trail for regulatory requirements
4. **Quality Assurance**: Multiple verification points for critical processes
5. **Transparent Governance**: All approval decisions are recorded on-chain