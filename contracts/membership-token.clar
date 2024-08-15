;; membership-token.clar

;; Constants
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_INSUFFICIENT_BALANCE (err u101))
(define-constant ERR_ALREADY_MEMBER (err u102))

;; Data vars
(define-data-var contract-owner principal tx-sender)

;; Data maps
(define-map balances principal uint)
(define-map members principal bool)

;; Public functions

(define-public (register-member (recipient principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
    (asserts! (is-none (map-get? members recipient)) ERR_ALREADY_MEMBER)
    (map-set members recipient true)
    (map-set balances recipient u100) ;; Example initial balance
    (ok true)
  )
)

(define-public (transfer (amount uint) (recipient principal))
  (let
    (
      (sender tx-sender)
      (sender-balance (default-to u0 (map-get? balances sender)))
    )
    (asserts! (>= sender-balance amount) ERR_INSUFFICIENT_BALANCE)
    (map-set balances sender (- sender-balance amount))
    (map-set balances recipient (+ (default-to u0 (map-get? balances recipient)) amount))
    (ok true)
  )
)

;; Read-only functions

(define-read-only (get-balance (account principal))
  (default-to u0 (map-get? balances account))
)

(define-read-only (is-member (account principal))
  (default-to false (map-get? members account))
)

;; Admin functions

(define-public (set-contract-owner (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
    (var-set contract-owner new-owner)
    (ok true)
  )
)
