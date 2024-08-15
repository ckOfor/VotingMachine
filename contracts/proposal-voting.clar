;; proposal-voting.clar

;; Constants
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_ALREADY_VOTED (err u101))
(define-constant ERR_PROPOSAL_NOT_ACTIVE (err u102))
(define-constant ERR_PROPOSAL_NOT_EXIST (err u103))
(define-constant ERR_INSUFFICIENT_BALANCE (err u104))
(define-constant ERR_PROPOSAL_EXECUTED (err u105))

;; Data variables
(define-data-var proposal-count uint u0)
(define-data-var contract-owner principal tx-sender)

;; Data maps
(define-map proposals
  { id: uint }
  {
    proposer: principal,
    description: (string-utf8 256),
    for-votes: uint,
    against-votes: uint,
    start-block: uint,
    end-block: uint,
    executed: bool
  }
)

(define-map votes
  { proposal-id: uint, voter: principal }
  { voted: bool }
)

(define-map balances principal uint)

;; Public functions

(define-public (create-proposal (description (string-utf8 256)))
  (let
    (
      (new-proposal-id (+ (var-get proposal-count) u1))
      (sender tx-sender)
    )
    (map-set proposals
      { id: new-proposal-id }
      {
        proposer: sender,
        description: description,
        for-votes: u0,
        against-votes: u0,
        start-block: block-height,
        end-block: (+ block-height u1440), ;; ~10 days with 10 min block time
        executed: false
      }
    )
    (var-set proposal-count new-proposal-id)
    (ok new-proposal-id)
  )
)

(define-public (vote (proposal-id uint) (support bool))
  (let
    (
      (sender tx-sender)
      (proposal (unwrap! (map-get? proposals { id: proposal-id }) ERR_PROPOSAL_NOT_EXIST))
      (voter-balance (default-to u0 (map-get? balances sender)))
    )
    (asserts! (>= voter-balance u1) ERR_INSUFFICIENT_BALANCE)
    (asserts! (< block-height (get end-block proposal)) ERR_PROPOSAL_NOT_ACTIVE)
    (asserts! (is-none (map-get? votes { proposal-id: proposal-id, voter: sender })) ERR_ALREADY_VOTED)

    (map-set votes { proposal-id: proposal-id, voter: sender } { voted: true })

    (if support
      (map-set proposals { id: proposal-id }
        (merge proposal { for-votes: (+ (get for-votes proposal) voter-balance) }))
      (map-set proposals { id: proposal-id }
        (merge proposal { against-votes: (+ (get against-votes proposal) voter-balance) }))
    )
    (ok true)
  )
)

(define-public (execute-proposal (proposal-id uint))
  (let
    (
      (proposal (unwrap! (map-get? proposals { id: proposal-id }) ERR_PROPOSAL_NOT_EXIST))
    )
    (asserts! (>= block-height (get end-block proposal)) ERR_PROPOSAL_NOT_ACTIVE)
    (asserts! (not (get executed proposal)) ERR_PROPOSAL_EXECUTED)
    (asserts! (> (get for-votes proposal) (get against-votes proposal)) ERR_UNAUTHORIZED)

    (map-set proposals { id: proposal-id }
      (merge proposal { executed: true })
    )
    ;; Implement the proposal execution logic here
    (ok true)
  )
)

;; Read-only functions

(define-read-only (get-proposal (proposal-id uint))
  (map-get? proposals { id: proposal-id })
)

(define-read-only (get-balance (account principal))
  (default-to u0 (map-get? balances account))
)

;; Admin functions

(define-public (mint (amount uint) (recipient principal))
  (let
    (
      (sender tx-sender)
      (current-balance (default-to u0 (map-get? balances recipient)))
    )
    (asserts! (is-eq sender (var-get contract-owner)) ERR_UNAUTHORIZED)
    (map-set balances recipient (+ current-balance amount))
    (ok true)
  )
)

(define-public (set-contract-owner (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
    (var-set contract-owner new-owner)
    (ok true)
  )
)
