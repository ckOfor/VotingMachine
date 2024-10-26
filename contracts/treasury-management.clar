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
