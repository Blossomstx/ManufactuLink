;; ManufactuLink - Manufacturing Supply Chain Traceability
;; A smart contract for tracking products through manufacturing supply chains

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u100))
(define-constant ERR_PRODUCT_NOT_FOUND (err u101))
(define-constant ERR_STAGE_NOT_FOUND (err u102))
(define-constant ERR_INVALID_STAGE_TRANSITION (err u103))
(define-constant ERR_PRODUCT_ALREADY_EXISTS (err u104))
(define-constant ERR_EMPTY_STRING (err u105))
(define-constant ERR_INVALID_TIMESTAMP (err u106))

;; Data Variables
(define-data-var contract-owner principal CONTRACT_OWNER)
(define-data-var product-counter uint u0)
(define-data-var stage-counter uint u0)

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
    metadata: (string-ascii 256)
  }
)

(define-map authorized-operators
  { operator: principal }
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

(define-public (create-product (name (string-ascii 64)) (manufacturer principal))
  (let
    (
      (product-id (+ (var-get product-counter) u1))
      (current-block burn-block-height)
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
)
  (let
    (
      (stage-id (+ (var-get stage-counter) u1))
      (current-block burn-block-height)
      (product-info (map-get? products { product-id: product-id }))
    )
    (asserts! (is-authorized-operator) ERR_NOT_AUTHORIZED)
    (asserts! (> product-id u0) ERR_PRODUCT_NOT_FOUND)
    (asserts! (is-some product-info) ERR_PRODUCT_NOT_FOUND)
    (asserts! (is-valid-stage-name stage-name) ERR_EMPTY_STRING)
    (asserts! (is-valid-location location) ERR_EMPTY_STRING)
    (asserts! (is-valid-metadata metadata) ERR_EMPTY_STRING)
    (asserts! (<= quality-score u100) ERR_INVALID_TIMESTAMP)
    
    (map-set production-stages
      { stage-id: stage-id }
      {
        product-id: product-id,
        stage-name: stage-name,
        operator: tx-sender,
        timestamp: current-block,
        location: location,
        quality-score: quality-score,
        metadata: metadata
      }
    )
    
    (map-set products
      { product-id: product-id }
      (merge (unwrap-panic product-info) { current-stage: stage-id })
    )
    
    (var-set stage-counter stage-id)
    (ok stage-id)
  )
)

(define-public (deactivate-product (product-id uint))
  (let
    (
      (product-info (map-get? products { product-id: product-id }))
    )
    (asserts! (is-authorized-operator) ERR_NOT_AUTHORIZED)
    (asserts! (> product-id u0) ERR_PRODUCT_NOT_FOUND)
    (asserts! (is-some product-info) ERR_PRODUCT_NOT_FOUND)
    
    (map-set products
      { product-id: product-id }
      (merge (unwrap-panic product-info) { is-active: false })
    )
    (ok true)
  )
)

;; Read-only Functions
(define-read-only (get-product (product-id uint))
  (if (> product-id u0)
    (map-get? products { product-id: product-id })
    none
  )
)

(define-read-only (get-production-stage (stage-id uint))
  (if (> stage-id u0)
    (map-get? production-stages { stage-id: stage-id })
    none
  )
)

(define-read-only (get-product-counter)
  (var-get product-counter)
)

(define-read-only (get-stage-counter)
  (var-get stage-counter)
)

(define-read-only (is-operator-authorized (operator principal))
  (if (is-valid-principal operator)
    (default-to false (get is-authorized (map-get? authorized-operators { operator: operator })))
    false
  )
)

(define-read-only (get-contract-owner)
  (var-get contract-owner)
)