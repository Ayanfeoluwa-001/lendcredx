(define-data-var total-supply uint u0)
(define-data-var total-borrowed uint u0)

(define-map credit-scores {user: principal} uint)
(define-map loan-balances {user: principal} uint)
(define-map repayments {user: principal} uint)
(define-map penalties {user: principal} uint)

(define-constant base-interest-rate u5) ;; 5% base rate
(define-constant max-credit-score u1000)
(define-constant min-credit-score u100)

;; Utility: Calculate interest based on credit score
(define-read-only (calc-interest (credit uint))
  (- base-interest-rate (/ credit u200)) ;; better credit = lower rate
)

;; Admin function: Set credit score
(define-public (set-credit (user principal) (score uint))
  (begin
    (asserts! (<= score max-credit-score) (err u100))
    (map-set credit-scores {user: user} score)
    (ok true)
  )
)

;; User deposits funds into protocol
(define-public (deposit-funds (amount uint))
  (begin
    (asserts! (> amount u0) (err u101))
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (var-set total-supply (+ (var-get total-supply) amount))
    (ok true)
  )
)

;; User borrows based on their credit score
(define-public (borrow (amount uint))
  (let ((credit (default-to u0 (map-get? credit-scores {user: tx-sender}))))
    (begin
      (asserts! (>= credit min-credit-score) (err u102))
      (asserts! (<= amount (/ (* credit u10) max-credit-score)) (err u103)) ;; cap by credit
      (asserts! (<= amount (var-get total-supply)) (err u104))
      (try! (stx-transfer? amount (as-contract tx-sender) tx-sender))
      (map-set loan-balances {user: tx-sender} amount)
      (var-set total-supply (- (var-get total-supply) amount))
      (var-set total-borrowed (+ (var-get total-borrowed) amount))
      (ok true)
    )
  )
)

;; User repays loan with interest
(define-public (repay-loan (repayment uint))
  (let ((loan (default-to u0 (map-get? loan-balances {user: tx-sender})))
        (credit (default-to u0 (map-get? credit-scores {user: tx-sender}))))
    (let ((interest-rate (calc-interest credit))
          (due (+ loan (/ (* loan interest-rate) u100))))
      (asserts! (> loan u0) (err u105))
      (asserts! (>= repayment due) (err u106))
      (try! (stx-transfer? repayment tx-sender (as-contract tx-sender)))
      (map-delete loan-balances {user: tx-sender})
      (map-set repayments {user: tx-sender} repayment)
      (var-set total-supply (+ (var-get total-supply) repayment))
      (var-set total-borrowed (- (var-get total-borrowed) loan))
      (ok repayment)
    )
  )
)

;; Penalize late repayment or default
(define-public (penalize (user principal) (penalty uint))
  (let ((loan (default-to u0 (map-get? loan-balances {user: user}))))
    (begin
      (asserts! (> loan u0) (err u107))
      (map-set penalties {user: user} penalty)
      (ok true)
    )
  )
)

;; Read-only: Check user status
(define-read-only (get-user-status (user principal))
  {
    credit: (default-to u0 (map-get? credit-scores {user: user})),
    loan: (default-to u0 (map-get? loan-balances {user: user})),
    repaid: (default-to u0 (map-get? repayments {user: user})),
    penalty: (default-to u0 (map-get? penalties {user: user}))
  }
)

;; Read-only: Get pool stats
(define-read-only (get-pool-stats)
  {
    supply: (var-get total-supply),
    borrowed: (var-get total-borrowed)
  }
)
