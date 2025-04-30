;; ArtifactLedger - Decentralized Historical Artifact Authentication and Provenance Platform

;; Error Constants
(define-constant ERR_PERMISSION_DENIED (err u1000))
(define-constant ERR_OWNER_ONLY (err u1001))
(define-constant ERR_EXISTING_RECORD (err u1002))
(define-constant ERR_NO_RECORD_EXISTS (err u1003))
(define-constant ERR_INSUFFICIENT_BALANCE (err u1004))
(define-constant ERR_ITEM_NOT_FOUND (err u1005))
(define-constant ERR_AUTHENTICATION_EXPIRED (err u1006))
(define-constant ERR_NO_AUTHENTICATION (err u1007))
(define-constant ERR_TRANSACTION_INVALID (err u1008))
(define-constant ERR_ITEM_UNAVAILABLE (err u1009))
(define-constant ERR_INVALID_VALUE (err u1010))
(define-constant ERR_ALREADY_HANDLED (err u1011))
(define-constant ERR_INVALID_TIMESPAN (err u1012))
(define-constant ERR_QUOTA_EXCEEDED (err u1013))
(define-constant ERR_INVALID_FEE (err u1014))
(define-constant ERR_INVALID_ERA (err u1015))
(define-constant ERR_INVALID_DATA (err u1016))
(define-constant ERR_UNAUTHORIZED_AUTHENTICATOR (err u1017))
(define-constant ERR_INVALID_ORIGIN (err u1018))

;; Contract Owner
(define-constant SYSTEM_ADMIN tx-sender)

;; Data Variables
(define-data-var authentication-fund-balance uint u0)
(define-data-var total-registered-items uint u0)
(define-data-var authentication-counter uint u0)
(define-data-var system-suspended bool false)

;; Constants
(define-constant BLOCKS_PER_YEAR u52560)
(define-constant MIN_AUTHENTICATION_FEE u1000)
(define-constant MAX_ITEM_VALUE u1000000000)
(define-constant MAX_ITEMS_PER_MUSEUM u1000)
(define-constant SYSTEM_FEE_PERCENT u5)
(define-constant MIN_AUTHENTICATOR_TRUST u300)

;; Principal Maps
(define-map heritage-institutions principal
    {
        certified: bool,
        item-count: uint,
        trust-score: uint,
        operational-status: bool,
        enrollment-height: uint,
        recent-activity-height: uint,
        total-revenue: uint
    }
)

(define-map authenticators principal
    {
        has-active-authentication: bool,
        authenticated-item-id: uint,
        authentication-focus: (string-ascii 64),
        yearly-fee: uint,
        authentication-start-height: uint,
        authentication-end-height: uint,
        total-authenticated-items: uint,
        last-authentication-height: uint,
        expertise: (string-ascii 64),
        trust-score: uint
    }
)

(define-map historical-items uint
    {
        institution-owner: principal,
        time-period: (string-ascii 64),
        authentication-fee: uint,
        purchase-value: uint,
        available-for-authentication: bool,
        active-authentication-count: uint,
        registry-height: uint,
        min-authentication-period: uint,
        max-authentication-period: uint,
        item-details: (string-ascii 256),
        origin-location: (string-ascii 128),
        scientifically-dated: bool
    }
)

(define-map authentication-records uint
    {
        authenticator-address: principal,
        fee-amount: uint,
        current-status: (string-ascii 20),
        submission-height: uint,
        authentication-report: (string-ascii 256),
        testing-facility: (optional principal),
        authentication-duration: uint,
        authentication-techniques: (string-ascii 128)
    }
)

;; Private Functions
(define-private (check-admin-privileges)
    (is-eq tx-sender SYSTEM_ADMIN)
)

(define-private (validate-authentication-fee (fee-amount uint))
    (>= fee-amount MIN_AUTHENTICATION_FEE)
)

(define-private (validate-purchase-value (purchase-value uint))
    (and 
        (> purchase-value u0)
        (<= purchase-value MAX_ITEM_VALUE)
    )
)

(define-private (validate-era (time-period (string-ascii 64)))
    (let ((period-length (len time-period)))
        (and (> period-length u0) (<= period-length u64))
    )
)

(define-private (validate-details (item-details (string-ascii 256)))
    (let ((details-length (len item-details)))
        (and (> details-length u0) (<= details-length u256))
    )
)

(define-private (validate-origin (origin-location (string-ascii 128)))
    (let ((location-length (len origin-location)))
        (and (> location-length u0) (<= location-length u128))
    )
)

(define-private (calculate-system-fee (payment uint))
    (/ (* payment SYSTEM_FEE_PERCENT) u100)
)

;; Read-Only Functions
(define-read-only (get-institution-details (institution-address principal))
    (map-get? heritage-institutions institution-address)
)

(define-read-only (get-authenticator-details (authenticator-address principal))
    (map-get? authenticators authenticator-address)
)

(define-read-only (get-item-details (item-id uint))
    (map-get? historical-items item-id)
)

(define-read-only (get-authentication-details (record-id uint))
    (map-get? authentication-records record-id)
)

(define-read-only (get-authentication-fund)
    (var-get authentication-fund-balance)
)

(define-read-only (is-system-suspended)
    (var-get system-suspended)
)

;; Public Functions

;; Register as a heritage institution
(define-public (register-institution)
    (let (
        (existing-institution (map-get? heritage-institutions tx-sender))
        (current-height block-height)
    )
    (asserts! (not (var-get system-suspended)) ERR_PERMISSION_DENIED)
    (asserts! (is-none existing-institution) ERR_EXISTING_RECORD)
    (map-set heritage-institutions tx-sender
        {
            certified: true,
            item-count: u0,
            trust-score: u100,
            operational-status: true,
            enrollment-height: current-height,
            recent-activity-height: current-height,
            total-revenue: u0
        }
    )
    (ok true))
)

;; Register as an item authenticator
(define-public (register-authenticator (expertise (string-ascii 64)))
    (let (
        (existing-authenticator (map-get? authenticators tx-sender))
        (current-height block-height)
    )
    (asserts! (not (var-get system-suspended)) ERR_PERMISSION_DENIED)
    (asserts! (is-none existing-authenticator) ERR_EXISTING_RECORD)
    (map-set authenticators tx-sender
        {
            has-active-authentication: false,
            authenticated-item-id: u0,
            authentication-focus: "",
            yearly-fee: u0,
            authentication-start-height: u0,
            authentication-end-height: u0,
            total-authenticated-items: u0,
            last-authentication-height: u0,
            expertise: expertise,
            trust-score: u300
        }
    )
    (ok true))
)

;; Register a historical item
(define-public (register-historical-item 
    (time-period (string-ascii 64)) 
    (authentication-fee uint) 
    (purchase-value uint)
    (min-period uint)
    (max-period uint)
    (item-details (string-ascii 256))
    (origin-location (string-ascii 128))
    (scientifically-dated bool)
)
    (let (
        (institution-details (unwrap! (map-get? heritage-institutions tx-sender) ERR_NO_RECORD_EXISTS))
        (new-item-id (var-get total-registered-items))
        (current-height block-height)
    )
    (asserts! (not (var-get system-suspended)) ERR_PERMISSION_DENIED)
    (asserts! (get certified institution-details) ERR_PERMISSION_DENIED)
    (asserts! (get operational-status institution-details) ERR_PERMISSION_DENIED)
    (asserts! (< (get item-count institution-details) MAX_ITEMS_PER_MUSEUM) ERR_QUOTA_EXCEEDED)
    (asserts! (validate-authentication-fee authentication-fee) ERR_INVALID_FEE)
    (asserts! (validate-purchase-value purchase-value) ERR_TRANSACTION_INVALID)
    (asserts! (>= max-period min-period) ERR_INVALID_TIMESPAN)
    (asserts! (validate-era time-period) ERR_INVALID_ERA)
    (asserts! (validate-details item-details) ERR_INVALID_DATA)
    (asserts! (validate-origin origin-location) ERR_INVALID_ORIGIN)
    
    (map-set historical-items new-item-id
        {
            institution-owner: tx-sender,
            time-period: time-period,
            authentication-fee: authentication-fee,
            purchase-value: purchase-value,
            available-for-authentication: true,
            active-authentication-count: u0,
            registry-height: current-height,
            min-authentication-period: min-period,
            max-authentication-period: max-period,
            item-details: item-details,
            origin-location: origin-location,
            scientifically-dated: scientifically-dated
        }
    )
    
    ;; Update institution's item count
    (map-set heritage-institutions tx-sender
        (merge institution-details { 
            item-count: (+ (get item-count institution-details) u1),
            recent-activity-height: current-height
        })
    )
    
    (var-set total-registered-items (+ new-item-id u1))
    (ok new-item-id))
)

;; Request item authentication
(define-public (request-item-authentication (item-id uint) (authentication-period uint) (authentication-focus (string-ascii 64)))
    (let (
        (item-details (unwrap! (map-get? historical-items item-id) ERR_ITEM_NOT_FOUND))
        (institution-details (unwrap! (map-get? heritage-institutions (get institution-owner item-details)) ERR_NO_RECORD_EXISTS))
        (authenticator-details (unwrap! (map-get? authenticators tx-sender) ERR_UNAUTHORIZED_AUTHENTICATOR))
        (current-height block-height)
        (yearly-fee (get authentication-fee item-details))
        (period-fee (* yearly-fee authentication-period))
        (system-fee (calculate-system-fee period-fee))
        (institution-payment (- period-fee system-fee))
    )
    (asserts! (not (var-get system-suspended)) ERR_PERMISSION_DENIED)
    (asserts! (get available-for-authentication item-details) ERR_ITEM_UNAVAILABLE)
    (asserts! (>= (get trust-score authenticator-details) MIN_AUTHENTICATOR_TRUST) ERR_UNAUTHORIZED_AUTHENTICATOR)
    (asserts! (and 
        (>= authentication-period (get min-authentication-period item-details))
        (<= authentication-period (get max-authentication-period item-details))
    ) ERR_INVALID_TIMESPAN)
    
    ;; Process payment
    (try! (stx-transfer? period-fee tx-sender (get institution-owner item-details)))
    
    ;; Update authentication fund
    (var-set authentication-fund-balance (+ (var-get authentication-fund-balance) system-fee))
    
    ;; Update authenticator record
    (map-set authenticators tx-sender
        (merge authenticator-details {
            has-active-authentication: true,
            authenticated-item-id: item-id,
            authentication-focus: authentication-focus,
            yearly-fee: yearly-fee,
            authentication-start-height: current-height,
            authentication-end-height: (+ current-height (* authentication-period BLOCKS_PER_YEAR)),
            total-authenticated-items: (+ (get total-authenticated-items authenticator-details) u1),
            last-authentication-height: current-height
        })
    )
    
    ;; Update item authentication count
    (map-set historical-items item-id
        (merge item-details { active-authentication-count: (+ (get active-authentication-count item-details) u1) })
    )
    
    ;; Update institution earnings
    (map-set heritage-institutions (get institution-owner item-details)
        (merge institution-details { 
            total-revenue: (+ (get total-revenue institution-details) institution-payment),
            recent-activity-height: current-height
        })
    )
    
    (ok true))
)