;; Vehicle Registration Contract
;; Records details of self-driving vehicles

;; Define data maps
(define-map vehicles
  { vehicle-id: (buff 20) }
  {
    owner: principal,
    model: (string-utf8 50),
    manufacturer: (string-utf8 50),
    year: uint,
    registration-date: uint,
    status: (string-ascii 10)  ;; Changed from string-utf8 to string-ascii
  }
)

;; Define data variables
(define-data-var vehicle-count uint u0)

;; Public functions
(define-public (register-vehicle
                (vehicle-id (buff 20))
                (model (string-utf8 50))
                (manufacturer (string-utf8 50))
                (year uint))
  (let ((current-time (get-block-info? time (- block-height u1))))
    (if (is-some (map-get? vehicles { vehicle-id: vehicle-id }))
      (err u1) ;; Vehicle already registered
      (begin
        (map-set vehicles
          { vehicle-id: vehicle-id }
          {
            owner: tx-sender,
            model: model,
            manufacturer: manufacturer,
            year: year,
            registration-date: (default-to u0 current-time),
            status: "active"
          }
        )
        (var-set vehicle-count (+ (var-get vehicle-count) u1))
        (ok true)
      )
    )
  )
)

(define-public (update-vehicle-status (vehicle-id (buff 20)) (new-status (string-ascii 10)))
  (let ((vehicle-data (map-get? vehicles { vehicle-id: vehicle-id })))
    (if (is-none vehicle-data)
      (err u2) ;; Vehicle not found
      (if (is-eq tx-sender (get owner (unwrap-panic vehicle-data)))
        (begin
          (map-set vehicles
            { vehicle-id: vehicle-id }
            (merge (unwrap-panic vehicle-data) { status: new-status })
          )
          (ok true)
        )
        (err u3) ;; Not the owner
      )
    )
  )
)

(define-read-only (get-vehicle-details (vehicle-id (buff 20)))
  (map-get? vehicles { vehicle-id: vehicle-id })
)

(define-read-only (get-total-vehicles)
  (var-get vehicle-count)
)
