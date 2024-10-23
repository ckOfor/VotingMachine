;; proposal-execution.clar

;; Constants
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_PROPOSAL_NOT_ACTIVE (err u102))
(define-constant ERR_PROPOSAL_NOT_EXIST (err u103))
(define-constant ERR_EXECUTION_FAILED (err u105))

;; Data vars
(define-data-var contract-owner principal tx-sender)

;; Data maps (referenced from proposal-voting.clar)
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

;; Public function to execute a proposal
(define-public (execute-proposal (proposal-id uint))
  (let
    (
      (proposal (unwrap! (map-get? proposals { id: proposal-id }) ERR_PROPOSAL_NOT_EXIST))
    )
    (asserts! (>= block-height (get end-block proposal)) ERR_PROPOSAL_NOT_ACTIVE)
    (asserts! (not (get executed proposal)) ERR_PROPOSAL_NOT_ACTIVE)
    (asserts! (> (get for-votes proposal) (get against-votes proposal)) ERR_UNAUTHORIZED)

    ;; Mark the proposal as executed
    (map-set proposals { id: proposal-id } (merge proposal { executed: true }))

    ;; Here you would typically call other functions or implement the specific actions
    ;; associated with the proposal execution (e.g., fund transfers, rule changes, etc.)

    ;; For now, we'll just return an ok result indicating success
    (ok true)
  )
)

;; Read-only function to check if a proposal has been executed
(define-read-only (is-proposal-executed (proposal-id uint))
  (let ((proposal-data (map-get? proposals { id: proposal-id })))
    (match proposal-data
      proposal (ok (get executed proposal))
      (err ERR_PROPOSAL_NOT_EXIST)
    )
  )
)
