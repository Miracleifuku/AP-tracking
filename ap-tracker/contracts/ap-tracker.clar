;; Artisanal Provenance Tracking System
;; Tracks artisanal goods from creator to collector with verified authenticity and transactions.

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-artisan (err u101))
(define-constant err-invalid-item (err u102))
(define-constant err-invalid-status (err u103))
(define-constant err-unauthorized (err u104))
(define-constant err-already-exists (err u105))

;; Data Variable
(define-data-var last-item-id uint u0)

;; Data Structures
(define-map artisans 
    principal 
    { name: (string-ascii 50), verified: bool })

(define-map items 
    uint 
    { 
        artisan: principal,
        name: (string-ascii 50),
        status: (string-ascii 20),
        current-keeper: principal,
        timestamp: uint,
        authenticated: bool,
        value: uint
    })

(define-map provenance-records
    { item-id: uint, record-number: uint }
    {
        keeper: principal,
        venue: (string-ascii 50),
        timestamp: uint,
        authenticated: bool
    })

;; Read-Only Functions

(define-read-only (get-item-details (item-id uint))
    (map-get? items item-id))

(define-read-only (get-artisan (address principal))
    (map-get? artisans address))

(define-read-only (get-provenance-record (item-id uint) (record-number uint))
    (map-get? provenance-records { item-id: item-id, record-number: record-number }))

;; Artisan Management Functions

(define-public (register-artisan (name (string-ascii 50)))
    (begin
        (asserts! (is-none (get-artisan tx-sender)) err-already-exists)
        (map-set artisans 
            tx-sender 
            { name: name, verified: false })
        (ok true)))

(define-public (authenticate-artisan (artisan principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (map-set artisans 
            artisan 
            (merge (unwrap! (get-artisan artisan) err-invalid-item)
                  { verified: true }))
        (ok true)))

;; Item Management Functions

(define-public (craft-item 
    (name (string-ascii 50))
    (authenticated bool)
    (value uint))
    (let (
        (artisan-data (unwrap! (get-artisan tx-sender) err-not-artisan))
        (item-id (+ (var-get last-item-id) u1))
        )
        (asserts! (get-verified artisan-data) err-unauthorized)
        (map-set items item-id
            {
                artisan: tx-sender,
                name: name,
                status: "crafted",
                current-keeper: tx-sender,
                timestamp: block-height,
                authenticated: authenticated,
                value: value
            })
        (var-set last-item-id item-id)
        (ok item-id)))

;; Provenance Tracking Functions

(define-public (record-provenance 
    (item-id uint)
    (record-number uint)
    (venue (string-ascii 50)))
    (let ((item (unwrap! (get-item-details item-id) err-invalid-item)))
        (asserts! (is-eq (get-current-keeper item) tx-sender) err-unauthorized)
        (map-set provenance-records
            { item-id: item-id, record-number: record-number }
            {
                keeper: tx-sender,
                venue: venue,
                timestamp: block-height,
                authenticated: false
            })
        (ok true)))

;; Transfer and Payment Functions

(define-public (transfer-item 
    (item-id uint)
    (recipient principal))
    (let ((item (unwrap! (get-item-details item-id) err-invalid-item)))
        (asserts! (is-eq (get-current-keeper item) tx-sender) err-unauthorized)
        (map-set items item-id
            (merge item {
                current-keeper: recipient,
                status: "transferred",
                timestamp: block-height
            }))
        (ok true)))

(define-public (process-transaction 
    (item-id uint))
    (let ((item (unwrap! (get-item-details item-id) err-invalid-item)))
        (try! (stx-transfer? 
            (get-value item)
            tx-sender
            (get-artisan-from-item item)))
        (map-set items item-id
            (merge item {
                status: "purchased",
                timestamp: block-height
            }))
        (ok true)))

;; Authentication Verification Functions

(define-read-only (verify-authenticity (item-id uint))
    (match (get-item-details item-id)
        item (ok (get-authenticated item))
        err-invalid-item))

;; Helper Functions for Data Access

(define-private (get-current-keeper (item {
        artisan: principal,
        name: (string-ascii 50),
        status: (string-ascii 20),
        current-keeper: principal,
        timestamp: uint,
        authenticated: bool,
        value: uint
    }))
    (get current-keeper item))

(define-private (get-value (item {
        artisan: principal,
        name: (string-ascii 50),
        status: (string-ascii 20),
        current-keeper: principal,
        timestamp: uint,
        authenticated: bool,
        value: uint
    }))
    (get value item))

(define-private (get-artisan-from-item (item {
        artisan: principal,
        name: (string-ascii 50),
        status: (string-ascii 20),
        current-keeper: principal,
        timestamp: uint,
        authenticated: bool,
        value: uint
    }))
    (get artisan item))

(define-private (get-verified (artisan-data {
        name: (string-ascii 50),
        verified: bool
    }))
    (get verified artisan-data))

(define-private (get-authenticated (item {
        artisan: principal,
        name: (string-ascii 50),
        status: (string-ascii 20),
        current-keeper: principal,
        timestamp: uint,
        authenticated: bool,
        value: uint
    }))
    (get authenticated item))