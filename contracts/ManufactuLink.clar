;; ManufactuLink - Manufacturing Supply Chain Traceability
;; A smart contract for tracking products through manufacturing supply chains
;; Enhanced with multi-signature approvals for critical production stages
;; Now includes IoT sensor integration for automated data recording
;; FIXED VERSION - Addresses unchecked data warnings

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u100))
(define-constant ERR_PRODUCT_NOT_FOUND (err u101))
(define-constant ERR_STAGE_NOT_FOUND (err u102))
(define-constant ERR_INVALID_STAGE_TRANSITION (err u103))
(define-constant ERR_PRODUCT_ALREADY_EXISTS (err u104))
(define-constant ERR_EMPTY_STRING (err u105))
(define-constant ERR_INVALID_TIMESTAMP (err u106))
(define-constant ERR_APPROVAL_NOT_FOUND (err u107))
(define-constant ERR_ALREADY_APPROVED (err u108))
(define-constant ERR_INSUFFICIENT_APPROVALS (err u109))
(define-constant ERR_INVALID_QUALITY_SCORE (err u110))
(define-constant ERR_INVALID_APPROVAL_ID (err u111))
(define-constant ERR_APPROVAL_ALREADY_EXISTS (err u112))
(define-constant ERR_SENSOR_NOT_FOUND (err u113))
(define-constant ERR_SENSOR_ALREADY_EXISTS (err u114))
(define-constant ERR_INVALID_SENSOR_DATA (err u115))
(define-constant ERR_INVALID_TEMPERATURE (err u116))
(define-constant ERR_INVALID_HUMIDITY (err u117))
(define-constant ERR_SENSOR_NOT_AUTHORIZED (err u118))

;; Data Variables
(define-data-var contract-owner principal CONTRACT_OWNER)
(define-data-var product-counter uint u0)
(define-data-var stage-counter uint u0)
(define-data-var approval-counter uint u0)
(define-data-var sensor-counter uint u0)
(define-data-var sensor-data-counter uint u0)  ;; Added separate counter for sensor data
(define-data-var required-approvals uint u2)

;; Data Maps
(define-map products
  { product-id: uint }
  {
    name: (string-ascii 64),
    manufacturer: principal,
    created-at: uint,
    current-stage: uint,
    is-active: bool
  }
)

(define-map production-stages
  { stage-id: uint }
  {
    product-id: uint,
    stage-name: (string-ascii 32),
    operator: principal,
    timestamp: uint,
    location: (string-ascii 64),
    quality-score: uint,
    metadata: (string-ascii 256),
    is-critical: bool,
    approval-id: (optional uint),
    sensor-data-id: (optional uint)
  }
)

(define-map authorized-operators
  { operator: principal }
  { is-authorized: bool }
)

(define-map stage-approvals
  { approval-id: uint }
  {
    product-id: uint,
    stage-name: (string-ascii 32),
    location: (string-ascii 64),
    quality-score: uint,
    metadata: (string-ascii 256),
    requester: principal,
    created-at: uint,
    approval-count: uint,
    is-finalized: bool
  }
)

(define-map approval-signatures
  { approval-id: uint, operator: principal }
  { 
    approved: bool,
    approved-at: uint
  }
)

(define-map iot-sensors
  { sensor-id: uint }
  {
    sensor-name: (string-ascii 32),
    location: (string-ascii 64),
    sensor-type: (string-ascii 16),
    is-active: bool,
    registered-by: principal,
    registered-at: uint
  }
)

(define-map sensor-data
  { data-id: uint }
  {
    sensor-id: uint,
    temperature: (optional int),
    humidity: (optional uint),
    quality-reading: (optional uint),
    timestamp: uint,
    additional-data: (string-ascii 128)
  }
)

(define-map authorized-sensors
  { sensor-id: uint }
  { is-authorized: bool }
)

;; Authorization Functions
(define-private (is-contract-owner)
  (is-eq tx-sender (var-get contract-owner))
)

(define-private (is-authorized-operator)
  (default-to false (get is-authorized (map-get? authorized-operators { operator: tx-sender })))
)

(define-private (is-valid-string (input (string-ascii 64)))
  (> (len input) u0)
)

(define-private (is-valid-stage-name (input (string-ascii 32)))
  (> (len input) u0)
)

(define-private (is-valid-sensor-name (input (string-ascii 32)))
  (> (len input) u0)
)

(define-private (is-valid-sensor-type (input (string-ascii 16)))
  (> (len input) u0)
)

(define-private (is-valid-additional-data (input (string-ascii 128)))
  (> (len input) u0)
)

(define-private (is-valid-location (input (string-ascii 64)))
  (> (len input) u0)
)

(define-private (is-valid-metadata (input (string-ascii 256)))
  (> (len input) u0)
)

(define-private (is-valid-principal (input principal))
  (not (is-eq input 'SP000000000000000000002Q6VF78))
)

(define-private (is-valid-product-id (input uint))
  (and (> input u0) (<= input (var-get product-counter)))
)

(define-private (is-valid-sensor-id (input uint))
  (and (> input u0) (<= input (var-get sensor-counter)))
)

(define-private (is-valid-sensor-data-id (input uint))
  (and (> input u0) (<= input (var-get sensor-data-counter)))
)

(define-private (is-valid-quality-score (score uint))
  (<= score u100)
)

(define-private (is-valid-approval-id (approval-id uint))
  (and (> approval-id u0) (<= approval-id (var-get approval-counter)))
)

(define-private (is-valid-temperature (temp int))
  (and (>= temp -273) (<= temp 1000))
)

(define-private (is-valid-humidity (humidity uint))
  (<= humidity u100)
)

(define-private (is-sensor-authorized (sensor-id uint))
  (default-to false (get is-authorized (map-get? authorized-sensors { sensor-id: sensor-id })))
)

;; Public Functions
(define-public (authorize-operator (operator principal))
  (begin
    (asserts! (is-contract-owner) ERR_NOT_AUTHORIZED)
    (asserts! (is-valid-principal operator) ERR_NOT_AUTHORIZED)
    (ok (map-set authorized-operators
      { operator: operator }
      { is-authorized: true }
    ))
  )
)

(define-public (revoke-operator (operator principal))
  (begin
    (asserts! (is-contract-owner) ERR_NOT_AUTHORIZED)
    (asserts! (is-valid-principal operator) ERR_NOT_AUTHORIZED)
    (ok (map-set authorized-operators
      { operator: operator }
      { is-authorized: false }
    ))
  )
)

(define-public (set-required-approvals (new-requirement uint))
  (begin
    (asserts! (is-contract-owner) ERR_NOT_AUTHORIZED)
    (asserts! (> new-requirement u0) ERR_INVALID_TIMESTAMP)
    (ok (var-set required-approvals new-requirement))
  )
)

(define-public (register-iot-sensor 
  (sensor-name (string-ascii 32))
  (location (string-ascii 64))
  (sensor-type (string-ascii 16))
)
  (let
    (
      (sensor-id (+ (var-get sensor-counter) u1))
      (current-block stacks-block-height)
    )
    (asserts! (is-authorized-operator) ERR_NOT_AUTHORIZED)
    (asserts! (is-valid-sensor-name sensor-name) ERR_EMPTY_STRING)
    (asserts! (is-valid-location location) ERR_EMPTY_STRING)
    (asserts! (is-valid-sensor-type sensor-type) ERR_EMPTY_STRING)
    (asserts! (is-none (map-get? iot-sensors { sensor-id: sensor-id })) ERR_SENSOR_ALREADY_EXISTS)
    
    (map-set iot-sensors
      { sensor-id: sensor-id }
      {
        sensor-name: sensor-name,
        location: location,
        sensor-type: sensor-type,
        is-active: true,
        registered-by: tx-sender,
        registered-at: current-block
      }
    )
    (var-set sensor-counter sensor-id)
    (ok sensor-id)
  )
)

(define-public (authorize-sensor (sensor-id uint))
  (begin
    (asserts! (is-contract-owner) ERR_NOT_AUTHORIZED)
    (asserts! (is-valid-sensor-id sensor-id) ERR_SENSOR_NOT_FOUND)
    (asserts! (is-some (map-get? iot-sensors { sensor-id: sensor-id })) ERR_SENSOR_NOT_FOUND)
    (ok (map-set authorized-sensors
      { sensor-id: sensor-id }
      { is-authorized: true }
    ))
  )
)

(define-public (revoke-sensor (sensor-id uint))
  (begin
    (asserts! (is-contract-owner) ERR_NOT_AUTHORIZED)
    (asserts! (is-valid-sensor-id sensor-id) ERR_SENSOR_NOT_FOUND)
    (ok (map-set authorized-sensors
      { sensor-id: sensor-id }
      { is-authorized: false }
    ))
  )
)

(define-public (record-sensor-data
  (sensor-id uint)
  (temperature (optional int))
  (humidity (optional uint))
  (quality-reading (optional uint))
  (additional-data (string-ascii 128))
)
  (let
    (
      (data-id (+ (var-get sensor-data-counter) u1))
      (current-block stacks-block-height)
      (sensor-info (map-get? iot-sensors { sensor-id: sensor-id }))
    )
    (asserts! (is-authorized-operator) ERR_NOT_AUTHORIZED)
    (asserts! (is-valid-sensor-id sensor-id) ERR_SENSOR_NOT_FOUND)
    (asserts! (is-some sensor-info) ERR_SENSOR_NOT_FOUND)
    (asserts! (is-sensor-authorized sensor-id) ERR_SENSOR_NOT_AUTHORIZED)
    ;; FIXED: Properly validate sensor exists and is active
    (let ((sensor-details (unwrap! sensor-info ERR_SENSOR_NOT_FOUND)))
      (asserts! (get is-active sensor-details) ERR_SENSOR_NOT_AUTHORIZED)
      (asserts! (is-valid-additional-data additional-data) ERR_EMPTY_STRING)
      
      ;; Validate and process all optional values and additional-data
      (let (
        (validated-additional-data additional-data) ;; Explicit validation binding
        (validated-temperature 
          (match temperature
            temp-val (begin
              (asserts! (is-valid-temperature temp-val) ERR_INVALID_TEMPERATURE)
              (some temp-val)
            )
            none
          ))
        (validated-humidity
          (match humidity
            humidity-val (begin
              (asserts! (is-valid-humidity humidity-val) ERR_INVALID_HUMIDITY)
              (some humidity-val)
            )
            none
          ))
        (validated-quality-reading
          (match quality-reading
            quality-val (begin
              (asserts! (is-valid-quality-score quality-val) ERR_INVALID_QUALITY_SCORE)
              (some quality-val)
            )
            none
          ))
        )
        
        (map-set sensor-data
          { data-id: data-id }
          {
            sensor-id: sensor-id,
            temperature: validated-temperature,
            humidity: validated-humidity,
            quality-reading: validated-quality-reading,
            timestamp: current-block,
            additional-data: validated-additional-data
          }
        )
        (var-set sensor-data-counter data-id)
        (ok data-id)
      )
    )
  )
)

(define-public (create-product (name (string-ascii 64)) (manufacturer principal))
  (let
    (
      (product-id (+ (var-get product-counter) u1))
      (current-block stacks-block-height)
    )
    (asserts! (is-authorized-operator) ERR_NOT_AUTHORIZED)
    (asserts! (is-valid-string name) ERR_EMPTY_STRING)
    (asserts! (is-valid-principal manufacturer) ERR_NOT_AUTHORIZED)
    (asserts! (is-none (map-get? products { product-id: product-id })) ERR_PRODUCT_ALREADY_EXISTS)
    
    (map-set products
      { product-id: product-id }
      {
        name: name,
        manufacturer: manufacturer,
        created-at: current-block,
        current-stage: u0,
        is-active: true
      }
    )
    (var-set product-counter product-id)
    (ok product-id)
  )
)

(define-public (add-production-stage 
  (product-id uint)
  (stage-name (string-ascii 32))
  (location (string-ascii 64))
  (quality-score uint)
  (metadata (string-ascii 256))
  (is-critical bool)
  (sensor-data-id (optional uint))
)
  (let
    (
      (stage-id (+ (var-get stage-counter) u1))
      (current-block stacks-block-height)
      (product-info (map-get? products { product-id: product-id }))
    )
    (asserts! (is-authorized-operator) ERR_NOT_AUTHORIZED)
    (asserts! (is-valid-product-id product-id) ERR_PRODUCT_NOT_FOUND)
    (asserts! (is-some product-info) ERR_PRODUCT_NOT_FOUND)
    (asserts! (is-valid-stage-name stage-name) ERR_EMPTY_STRING)
    (asserts! (is-valid-location location) ERR_EMPTY_STRING)
    (asserts! (is-valid-metadata metadata) ERR_EMPTY_STRING)
    (asserts! (is-valid-quality-score quality-score) ERR_INVALID_QUALITY_SCORE)
    
    ;; FIXED: Properly validate product exists and is active
    (let ((product-details (unwrap! product-info ERR_PRODUCT_NOT_FOUND)))
      (asserts! (get is-active product-details) ERR_PRODUCT_NOT_FOUND)
      
      ;; Validate optional sensor data ID
      (match sensor-data-id
        data-id (begin
          (asserts! (is-valid-sensor-data-id data-id) ERR_INVALID_SENSOR_DATA)
          (asserts! (is-some (map-get? sensor-data { data-id: data-id })) ERR_INVALID_SENSOR_DATA)
        )
        true
      )
      
      (if is-critical
        ;; For critical stages, return stage ID but don't finalize
        (begin
          (map-set production-stages
            { stage-id: stage-id }
            {
              product-id: product-id,
              stage-name: stage-name,
              operator: tx-sender,
              timestamp: current-block,
              location: location,
              quality-score: quality-score,
              metadata: metadata,
              is-critical: true,
              approval-id: none,
              sensor-data-id: sensor-data-id
            }
          )
          (var-set stage-counter stage-id)
          (ok stage-id)
        )
        ;; For non-critical stages, proceed normally
        (begin
          (map-set production-stages
            { stage-id: stage-id }
            {
              product-id: product-id,
              stage-name: stage-name,
              operator: tx-sender,
              timestamp: current-block,
              location: location,
              quality-score: quality-score,
              metadata: metadata,
              is-critical: false,
              approval-id: none,
              sensor-data-id: sensor-data-id
            }
          )
          
          (map-set products
            { product-id: product-id }
            (merge product-details { current-stage: stage-id })
          )
          
          (var-set stage-counter stage-id)
          (ok stage-id)
        )
      )
    )
  )
)

(define-public (request-critical-stage-approval
  (product-id uint)
  (stage-name (string-ascii 32))
  (location (string-ascii 64))
  (quality-score uint)
  (metadata (string-ascii 256))
)
  (let
    (
      (approval-id (+ (var-get approval-counter) u1))
      (current-block stacks-block-height)
      (product-info (map-get? products { product-id: product-id }))
    )
    (asserts! (is-authorized-operator) ERR_NOT_AUTHORIZED)
    (asserts! (is-valid-product-id product-id) ERR_PRODUCT_NOT_FOUND)
    (asserts! (is-some product-info) ERR_PRODUCT_NOT_FOUND)
    (asserts! (is-valid-stage-name stage-name) ERR_EMPTY_STRING)
    (asserts! (is-valid-location location) ERR_EMPTY_STRING)
    (asserts! (is-valid-metadata metadata) ERR_EMPTY_STRING)
    (asserts! (is-valid-quality-score quality-score) ERR_INVALID_QUALITY_SCORE)
    (asserts! (is-none (map-get? stage-approvals { approval-id: approval-id })) ERR_APPROVAL_ALREADY_EXISTS)
    
    ;; FIXED: Validate product exists and is active before creating approval
    (let ((product-details (unwrap! product-info ERR_PRODUCT_NOT_FOUND)))
      (asserts! (get is-active product-details) ERR_PRODUCT_NOT_FOUND)
      
      (map-set stage-approvals
        { approval-id: approval-id }
        {
          product-id: product-id,
          stage-name: stage-name,
          location: location,
          quality-score: quality-score,
          metadata: metadata,
          requester: tx-sender,
          created-at: current-block,
          approval-count: u0,
          is-finalized: false
        }
      )
      
      (var-set approval-counter approval-id)
      (ok approval-id)
    )
  )
)

(define-public (approve-critical-stage (approval-id uint))
  (let
    (
      (approval-info (map-get? stage-approvals { approval-id: approval-id }))
      (existing-signature (map-get? approval-signatures { approval-id: approval-id, operator: tx-sender }))
      (current-block stacks-block-height)
    )
    (asserts! (is-authorized-operator) ERR_NOT_AUTHORIZED)
    (asserts! (is-valid-approval-id approval-id) ERR_INVALID_APPROVAL_ID)
    (asserts! (is-some approval-info) ERR_APPROVAL_NOT_FOUND)
    (asserts! (is-none existing-signature) ERR_ALREADY_APPROVED)
    
    (let
      (
        (approval-data (unwrap! approval-info ERR_APPROVAL_NOT_FOUND))
        (new-approval-count (+ (get approval-count approval-data) u1))
      )
      (asserts! (not (get is-finalized approval-data)) ERR_APPROVAL_NOT_FOUND)
      
      ;; Record the approval signature
      (map-set approval-signatures
        { approval-id: approval-id, operator: tx-sender }
        {
          approved: true,
          approved-at: current-block
        }
      )
      
      ;; Update approval count
      (map-set stage-approvals
        { approval-id: approval-id }
        (merge approval-data { approval-count: new-approval-count })
      )
      
      ;; Check if we have enough approvals to finalize
      (if (>= new-approval-count (var-get required-approvals))
        (begin
          (try! (finalize-critical-stage approval-id))
          (ok true)
        )
        (ok true)
      )
    )
  )
)

(define-private (finalize-critical-stage (approval-id uint))
  (let
    (
      (approval-info (map-get? stage-approvals { approval-id: approval-id }))
      (stage-id (+ (var-get stage-counter) u1))
      (current-block stacks-block-height)
    )
    (match approval-info
      approval-data
      (let
        (
          (product-info (map-get? products { product-id: (get product-id approval-data) }))
        )
        ;; FIXED: Validate product exists before finalizing stage
        (let ((product-details (unwrap! product-info ERR_PRODUCT_NOT_FOUND)))
          (asserts! (get is-active product-details) ERR_PRODUCT_NOT_FOUND)
          
          ;; Create the production stage
          (map-set production-stages
            { stage-id: stage-id }
            {
              product-id: (get product-id approval-data),
              stage-name: (get stage-name approval-data),
              operator: (get requester approval-data),
              timestamp: current-block,
              location: (get location approval-data),
              quality-score: (get quality-score approval-data),
              metadata: (get metadata approval-data),
              is-critical: true,
              approval-id: (some approval-id),
              sensor-data-id: none
            }
          )
          
          ;; Update product current stage
          (map-set products
            { product-id: (get product-id approval-data) }
            (merge product-details { current-stage: stage-id })
          )
          
          ;; Mark approval as finalized
          (map-set stage-approvals
            { approval-id: approval-id }
            (merge approval-data { is-finalized: true })
          )
          
          (var-set stage-counter stage-id)
          (ok stage-id)
        )
      )
      ERR_APPROVAL_NOT_FOUND
    )
  )
)

(define-public (deactivate-product (product-id uint))
  (let
    (
      (product-info (map-get? products { product-id: product-id }))
    )
    (asserts! (is-authorized-operator) ERR_NOT_AUTHORIZED)
    (asserts! (is-valid-product-id product-id) ERR_PRODUCT_NOT_FOUND)
    (asserts! (is-some product-info) ERR_PRODUCT_NOT_FOUND)
    
    (map-set products
      { product-id: product-id }
      (merge (unwrap! product-info ERR_PRODUCT_NOT_FOUND) { is-active: false })
    )
    (ok true)
  )
)

(define-public (deactivate-sensor (sensor-id uint))
  (let
    (
      (sensor-info (map-get? iot-sensors { sensor-id: sensor-id }))
    )
    (asserts! (is-authorized-operator) ERR_NOT_AUTHORIZED)
    (asserts! (is-valid-sensor-id sensor-id) ERR_SENSOR_NOT_FOUND)
    (asserts! (is-some sensor-info) ERR_SENSOR_NOT_FOUND)
    
    (map-set iot-sensors
      { sensor-id: sensor-id }
      (merge (unwrap! sensor-info ERR_SENSOR_NOT_FOUND) { is-active: false })
    )
    (ok true)
  )
)

;; Read-only Functions
(define-read-only (get-product (product-id uint))
  (if (is-valid-product-id product-id)
    (map-get? products { product-id: product-id })
    none
  )
)

(define-read-only (get-production-stage (stage-id uint))
  (if (and (> stage-id u0) (<= stage-id (var-get stage-counter)))
    (map-get? production-stages { stage-id: stage-id })
    none
  )
)

(define-read-only (get-stage-approval (approval-id uint))
  (if (is-valid-approval-id approval-id)
    (map-get? stage-approvals { approval-id: approval-id })
    none
  )
)

(define-read-only (get-approval-signature (approval-id uint) (operator principal))
  (if (and (is-valid-approval-id approval-id) (is-valid-principal operator))
    (map-get? approval-signatures { approval-id: approval-id, operator: operator })
    none
  )
)

(define-read-only (get-iot-sensor (sensor-id uint))
  (if (is-valid-sensor-id sensor-id)
    (map-get? iot-sensors { sensor-id: sensor-id })
    none
  )
)

(define-read-only (get-sensor-data (data-id uint))
  (if (is-valid-sensor-data-id data-id)
    (map-get? sensor-data { data-id: data-id })
    none
  )
)

(define-read-only (get-product-counter)
  (var-get product-counter)
)

(define-read-only (get-stage-counter)
  (var-get stage-counter)
)

(define-read-only (get-approval-counter)
  (var-get approval-counter)
)

(define-read-only (get-sensor-counter)
  (var-get sensor-counter)
)

(define-read-only (get-sensor-data-counter)
  (var-get sensor-data-counter)
)

(define-read-only (get-required-approvals)
  (var-get required-approvals)
)

(define-read-only (is-operator-authorized (operator principal))
  (if (is-valid-principal operator)
    (default-to false (get is-authorized (map-get? authorized-operators { operator: operator })))
    false
  )
)

(define-read-only (is-sensor-authorized-check (sensor-id uint))
  (if (is-valid-sensor-id sensor-id)
    (default-to false (get is-authorized (map-get? authorized-sensors { sensor-id: sensor-id })))
    false
  )
)

(define-read-only (get-contract-owner)
  (var-get contract-owner)
)