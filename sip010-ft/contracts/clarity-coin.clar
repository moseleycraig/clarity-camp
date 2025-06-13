;; contracts/clarity-coin.clar

;; Trait Conformance
;; Asserting explicit conformity with the trait is the first step as usual.

(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; Constants and Error Codes
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))

;; Define Fungible Token (unlimited supply)
;; No maximum supply
(define-fungible-token clarity-coin)

;; Trait Functions
;; The transfer function should assert that the sender is equal to the tx-sender
;; this prevents principals from transferring tokens they do not own
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
    (begin
        (asserts! (is-eq tx-sender sender) err-not-token-owner)
        (try! (ft-transfer? clarity-coin amount sender recipient))
        (match memo to-print (print to-print) 0x)
        (ok true)
    )
)

(match (some "inner string")
    inner-str (print inner-str)
    (print "got nothing")
)

;; the read only functions are standard output for these fungible tokens
(define-read-only (get-name) (ok "Clarity Coin"))

(define-read-only (get-symbol) (ok "CC"))

(define-read-only (get-decimals) (ok u6))

(define-read-only (get-balance (who principal))
    (ok (ft-get-balance clarity-coin who))
)

(define-read-only (get-total-supply)
    (ok (ft-get-supply clarity-coin))
)

(define-read-only (get-token-uri)
    (ok none)
)

;; by default, the first wallet address in clarity console is the recipient

(define-public (mint (amount uint) (recipient principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (ft-mint? clarity-coin amount recipient)
    )
)