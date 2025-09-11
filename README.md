# ManufactuLink

A decentralized supply chain traceability solution built on Stacks blockchain for manufacturing industries with multi-signature approval system for critical production stages and IoT sensor integration for automated data collection.

## Overview

ManufactuLink enables manufacturers to track products through their entire production lifecycle using blockchain technology. The smart contract provides immutable records of production stages, quality metrics, and operator actions, ensuring transparency and accountability in manufacturing processes. Enhanced with multi-signature approvals for critical production stages and IoT sensor integration for automated temperature, humidity, and quality data recording.

## Features

- **Product Registration**: Create and register products with unique identifiers
- **Production Stage Tracking**: Record each manufacturing stage with timestamps and metadata
- **Critical Stage Protection**: Multi-signature approval system for sensitive production stages
- **IoT Sensor Integration**: Connect with IoT devices for automated temperature, humidity, and quality data recording
- **Automated Data Collection**: Real-time environmental and quality monitoring through sensors
- **Quality Scoring**: Track quality metrics at each production stage (0-100 scale)
- **Operator Authorization**: Manage authorized operators who can interact with the system
- **Sensor Management**: Register, authorize, and manage IoT sensors in the manufacturing environment
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
- `add-production-stage`: Record a new production stage for a product (with critical flag and optional sensor data)
- `request-critical-stage-approval`: Request approval for a critical production stage
- `approve-critical-stage`: Approve a pending critical stage request

#### IoT Sensor Management
- `register-iot-sensor`: Register a new IoT sensor in the system
- `authorize-sensor`: Grant authorization to a sensor for data recording (owner only)
- `revoke-sensor`: Remove sensor authorization (owner only)
- `deactivate-sensor`: Mark a sensor as inactive
- `record-sensor-data`: Record sensor data (temperature, humidity, quality readings)

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

#### IoT Sensor Information
- `get-iot-sensor`: Retrieve IoT sensor information by ID
- `get-sensor-data`: Get sensor data by data ID
- `get-sensor-counter`: Get total number of registered sensors
- `is-sensor-authorized-check`: Check if a sensor is authorized

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
- `sensor-data-id`: Optional reference to associated IoT sensor data

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

### IoT Sensor
- `sensor-id`: Unique sensor identifier
- `sensor-name`: Name of the sensor (up to 32 characters)
- `location`: Physical location of the sensor (up to 64 characters)
- `sensor-type`: Type of sensor (up to 16 characters, e.g., "temperature", "humidity", "quality")
- `is-active`: Sensor status
- `registered-by`: Principal who registered the sensor
- `registered-at`: Block height when sensor was registered

### Sensor Data
- `data-id`: Unique data record identifier
- `sensor-id`: Associated sensor ID
- `temperature`: Optional temperature reading in Celsius (range: -273 to 1000)
- `humidity`: Optional humidity percentage (0-100)
- `quality-reading`: Optional quality metric (0-100)
- `timestamp`: Block height when data was recorded
- `additional-data`: Additional sensor information (up to 128 characters)

## IoT Sensor Integration Workflow

### Sensor Registration and Authorization

1. **Register Sensor**: Authorized operators call `register-iot-sensor` with sensor details
2. **Authorize Sensor**: Contract owner calls `authorize-sensor` to enable data recording
3. **Record Data**: Authorized operators record sensor readings using `record-sensor-data`

### Automated Data Collection

1. **Environmental Monitoring**: Sensors automatically record temperature and humidity
2. **Quality Assessment**: Quality sensors provide real-time quality metrics
3. **Data Validation**: All sensor data is validated before blockchain storage
4. **Stage Integration**: Sensor data can be linked to production stages for complete traceability

## Multi-Signature Approval Workflow

### For Critical Production Stages:

1. **Request Approval**: An authorized operator calls `request-critical-stage-approval` with stage details
2. **Collect Approvals**: Other authorized operators call `approve-critical-stage` to approve the request
3. **Automatic Finalization**: Once the required number of approvals is reached, the stage is automatically created
4. **Immutable Record**: The approval process and all signatures are permanently recorded on-chain

### For Regular Production Stages:

1. **Direct Creation**: Call `add-production-stage` with `is-critical` set to `false`
2. **Immediate Processing**: Stage is created immediately without requiring approvals
3. **Optional Sensor Data**: Link sensor data to the stage using `sensor-data-id` parameter

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
- `u113`: Sensor not found
- `u114`: Sensor already exists
- `u115`: Invalid sensor data
- `u116`: Invalid temperature (must be between -273°C and 1000°C)
- `u117`: Invalid humidity (must be between 0% and 100%)
- `u118`: Sensor not authorized

## Getting Started

### Initial Setup

1. Deploy the contract to Stacks blockchain
2. The deployer becomes the contract owner
3. Set the required number of approvals using `set-required-approvals` (default is 2)
4. Authorize operators using `authorize-operator`
5. Register IoT sensors using `register-iot-sensor`
6. Authorize sensors for data recording using `authorize-sensor`

### Basic Workflow

```clarity
;; 1. Create a product
(contract-call? .manufacturlink create-product "Widget Model X" 'SP1ABCD...)

;; 2. Register an IoT sensor
(contract-call? .manufacturlink register-iot-sensor "Temp-Sensor-001" "Factory Floor A" "temperature")

;; 3. Authorize the sensor
(contract-call? .manufacturlink authorize-sensor u1)

;; 4. Record sensor data
(contract-call? .manufacturlink record-sensor-data u1 (some 23) (some u65) (some u95) "Normal operating conditions")

;; 5. Add a regular production stage with sensor data
(contract-call? .manufacturlink add-production-stage u1 "Assembly" "Factory Floor A" u95 "Initial assembly completed" false (some u1))

;; 6. Request approval for critical stage
(contract-call? .manufacturlink request-critical-stage-approval u1 "Quality Control" "QC Lab" u98 "Final quality inspection")

;; 7. Approve the critical stage (requires multiple operators)
(contract-call? .manufacturlink approve-critical-stage u1)
```

### IoT Integration Examples

```clarity
;; Temperature monitoring sensor
(contract-call? .manufacturlink register-iot-sensor "TempSensor-A1" "Production Line 1" "temperature")

;; Humidity monitoring sensor
(contract-call? .manufacturlink register-iot-sensor "HumiditySensor-B2" "Drying Room" "humidity")

;; Quality assessment sensor
(contract-call? .manufacturlink register-iot-sensor "QualitySensor-C3" "Inspection Station" "quality")

;; Record comprehensive sensor data
(contract-call? .manufacturlink record-sensor-data u1 (some 25) (some u45) (some u98) "Optimal conditions maintained")
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
- **Sensor Authorization**: Only authorized sensors can record data
- **Data Validation**: All sensor readings are validated before storage
- **Immutable Audit Trail**: All approvals and signatures are permanently recorded
- **Parameter Validation**: All inputs are validated to prevent invalid data
- **Access Control**: Contract owner has exclusive rights to manage operators, sensors, and approval requirements

## IoT Sensor Types and Use Cases

### Temperature Sensors
- **Manufacturing Processes**: Monitor heat-sensitive production stages
- **Storage Conditions**: Ensure proper temperature control for materials
- **Quality Assurance**: Validate temperature-dependent quality metrics

### Humidity Sensors
- **Environmental Control**: Monitor moisture levels in production areas
- **Material Protection**: Ensure optimal humidity for sensitive materials
- **Process Optimization**: Maintain ideal humidity for manufacturing processes

### Quality Sensors
- **Real-time Assessment**: Automated quality scoring during production
- **Defect Detection**: Early identification of quality issues
- **Process Validation**: Continuous monitoring of production quality

### Multi-Parameter Sensors
- **Comprehensive Monitoring**: Record multiple environmental factors simultaneously
- **Correlated Analysis**: Link environmental conditions to quality outcomes
- **Predictive Maintenance**: Use sensor data for predictive analytics

## Testing

Run the test suite using Clarinet:

```bash
clarinet test
```

## Use Cases

### Traditional Manufacturing
- **High-Value Manufacturing**: Electronics, pharmaceuticals, aerospace components
- **Regulated Industries**: Medical devices, automotive parts, food processing
- **Quality Assurance**: Multi-stage verification for critical production steps

### IoT-Enhanced Manufacturing
- **Smart Factory Integration**: Connect existing IoT infrastructure to blockchain
- **Environmental Compliance**: Automated recording of environmental conditions
- **Predictive Quality Control**: Use sensor data for quality prediction and optimization
- **Automated Reporting**: Generate compliance reports with real-time sensor data

### Supply Chain Applications
- **Cold Chain Management**: Temperature monitoring for pharmaceutical and food products
- **Humidity-Sensitive Goods**: Monitor moisture levels for electronics and textiles
- **Real-time Traceability**: Combine manual and automated data collection
- **Regulatory Compliance**: Meet industry standards with comprehensive data recording

## Benefits of IoT Integration

### Automated Data Collection
1. **Reduced Manual Errors**: Eliminate human error in data recording
2. **Real-time Monitoring**: Continuous tracking of environmental conditions
3. **Comprehensive Coverage**: Monitor multiple parameters simultaneously
4. **Cost Efficiency**: Reduce labor costs for data collection

### Enhanced Traceability
1. **Complete Data Chain**: Link environmental conditions to product quality
2. **Automated Compliance**: Meet regulatory requirements with automated reporting
3. **Quality Correlation**: Analyze relationships between conditions and outcomes
4. **Predictive Analytics**: Use historical sensor data for process optimization

### Improved Quality Control
1. **Early Detection**: Identify quality issues in real-time
2. **Process Optimization**: Use sensor data to improve manufacturing processes
3. **Preventive Measures**: Take corrective action before quality issues occur
4. **Data-Driven Decisions**: Make informed decisions based on real sensor data

## Benefits of Multi-Signature Approvals

1. **Enhanced Security**: Multiple operators must agree on critical stages
2. **Reduced Fraud**: Prevents single-point manipulation of critical data
3. **Audit Compliance**: Complete signature trail for regulatory requirements
4. **Quality Assurance**: Multiple verification points for critical processes
5. **Transparent Governance**: All approval decisions are recorded on-chain