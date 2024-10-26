;; treasury-management.clar

;; Constants
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_INSUFFICIENT_FUNDS (err u101))
(define-constant ERR_INVALID_AMOUNT (err u102))
(define-constant ERR_SPENDING_LIMIT_EXCEEDED (err u103))
(define-constant ERR_PROPOSAL_NOT_EXECUTED (err u104))

;; Data vars
(define-data-var contract-owner principal tx-sender)
(define-data-var spending-limit uint u1000000) ;; Set a default spending limit
(define-data-var transaction-count uint u0)

;; Data maps
(define-map treasury-balance
  { token: principal }  ;; Use principal to support multiple token types
  { amount: uint }
)

(define-map spending-proposals
  { proposal-id: uint }
  {
    amount: uint,
    recipient: principal,
    token: principal,
    executed: bool,
    execution-block: (optional uint)
  }
)

(define-map transaction-history
  { tx-id: uint }
  {
    proposal-id: uint,
    amount: uint,
    recipient: principal,
    token: principal,
    block: uint
  }
)

;; Public functions

;; Function to deposit funds into treasury
(define-public (deposit (token principal) (amount uint))
  (let
    (
      (current-balance (default-to { amount: u0 } (map-get? treasury-balance { token: token })))
    )
    ;; Implement token transfer from sender to treasury
    ;; This would need to interact with the specific token contract
    (map-set treasury-balance
      { token: token }
      { amount: (+ (get amount current-balance) amount) }
    )
    (ok true)
  )
)

;; Function to execute a spending proposal
(define-public (execute-spending (proposal-id uint))
  (let
    (
      (proposal (unwrap! (map-get? spending-proposals { proposal-id: proposal-id }) ERR_UNAUTHORIZED))
      (current-balance (default-to { amount: u0 }
        (map-get? treasury-balance { token: (get token proposal) })))
    )
    ;; Check if proposal is approved via governance
    (asserts! (is-proposal-executed proposal-id) ERR_PROPOSAL_NOT_EXECUTED)
    ;; Check if we have enough funds
    (asserts! (>= (get amount current-balance) (get amount proposal)) ERR_INSUFFICIENT_FUNDS)
    ;; Check if amount is within spending limit
    (asserts! (<= (get amount proposal) (var-get spending-limit)) ERR_SPENDING_LIMIT_EXCEEDED)

    ;; Update treasury balance
    (map-set treasury-balance
      { token: (get token proposal) }
      { amount: (- (get amount current-balance) (get amount proposal)) }
    )

    ;; Record transaction in history
    (let
      ((new-tx-id (+ (var-get transaction-count) u1)))
      (map-set transaction-history
        { tx-id: new-tx-id }
        {
          proposal-id: proposal-id,
          amount: (get amount proposal),
          recipient: (get recipient proposal),
          token: (get token proposal),
          block: block-height
        }
      )
      (var-set transaction-count new-tx-id)
    )

    ;; Mark proposal as executed
    (map-set spending-proposals
      { proposal-id: proposal-id }
      (merge proposal
        {
          executed: true,
          execution-block: (some block-height)
        }
      )
    )

    (ok true)
  )
)

;; Admin functions

;; Set new spending limit (requires governance approval)
(define-public (set-spending-limit (new-limit uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
    (var-set spending-limit new-limit)
    (ok true)
  )
)

;; Read-only functions

(define-read-only (get-treasury-balance (token principal))
  (default-to { amount: u0 } (map-get? treasury-balance { token: token }))
)

(define-read-only (get-spending-proposal (proposal-id uint))
  (map-get? spending-proposals { proposal-id: proposal-id })
)

(define-read-only (get-transaction (tx-id uint))
  (map-get? transaction-history { tx-id: tx-id })
)

(define-read-only (get-current-spending-limit)
  (ok (var-get spending-limit))
)

;; Helper functions

;; Check if a proposal has been executed through governance
(define-read-only (is-proposal-executed (proposal-id uint))
  (contract-call? .proposal-execution is-proposal-executed proposal-id)
)

;; Contract initialization
(define-public (initialize (governance-token principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
    (ok true)
  )
)
