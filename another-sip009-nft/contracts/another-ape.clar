
;; title: another-ape
;; sample NFT contract
;; 1. Assert SIP009 trait conformity
(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token another-ape uint)

(define-constant mint_price u5000000) ;; 5 STX
(define-constant contract-owner tx-sender) ;; principal that deploys the contract
;;(define-constant err-owner-only (err u100)) ;; error code for owner only
(define-constant err-not-token-owner (err u101)) ;; error code for not token owner

(define-data-var last-token-id uint u0) ;; counter for token IDs
(define-data-var base-uri (string-ascii 100) "") ;; base URI for metadata

;; clarity does not support IPFS URIs well
;; pass base URI to the frontend to display images
;; you must concatenate different strings and pass it to the frontend
;; plug in the correct data and retrieve it off-chain

(define-read-only (get-last-token-id)
  (ok (var-get last-token-id))
) ;; comply with SIP-009 trait signature

(define-read-only (get-token-uri (id uint))
  (ok (some (var-get base-uri)))
  )

(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? another-ape id))
)  

(define-public (transfer (id uint) (sender principal) (receiver principal))
  (begin
    (asserts! (is-eq tx-sender sender) err-not-token-owner)
    (nft-transfer? another-ape id sender receiver)
  )
)

(define-public (mint)
  (let
    (
      (id (+ (var-get last-token-id) u1))
    )
    ;; pay mint fee / transfer stx
    (try! (stx-transfer? mint_price tx-sender contract-owner))
    ;; create/mint a new nft
    (try! (nft-mint? another-ape id tx-sender))
    ;; set our new "last token id"
    (var-set last-token-id id)
    (ok id)
  )
)