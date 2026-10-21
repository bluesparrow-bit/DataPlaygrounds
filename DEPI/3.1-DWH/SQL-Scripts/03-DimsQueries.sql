/* =============================================================================
   HOTEL BOOKINGS | Star schema - source queries

   Run these against the normalized SOURCE database:
      HotelBookings        (Syria)   or
      HotelBookingsEgypt   (Egypt)

   Use each query as the input (e.g. tDBInput / tMSSqlInput in Talend) for
   the matching star-schema table in HotelBookingsDW.
   dim_date is not here: it is loaded from dim_date.csv.
   ============================================================================= */

-- USE HotelBookings;        -- Syria
-- USE HotelBookingsEgypt;   -- Egypt


/* -----------------------------------------------------------------------------
   1. dim_guest   (target: guest_id, guest_name, country, loyalty_level)
   ----------------------------------------------------------------------------- */
SELECT g.guest_id,
      g.guest_name,
      g.country,
      g.loyalty_level
FROM dbo.guests AS g
ORDER BY g.guest_id;


/* -----------------------------------------------------------------------------
   2. dim_hotel   (target: hotel_id, hotel_name, city, region)
   ----------------------------------------------------------------------------- */
SELECT h.hotel_id,
      h.hotel_name,
      h.city,
      h.region
FROM dbo.hotels AS h
ORDER BY h.hotel_id;


/* -----------------------------------------------------------------------------
   3. dim_room    (target: room_id, room_number, room_type_name, capacity)
      Room type is folded into the room dimension.
   ----------------------------------------------------------------------------- */
SELECT r.room_id,
      r.room_number,
      rt.room_type_name,
      rt.capacity
FROM dbo.rooms      AS r
JOIN dbo.room_types AS rt ON rt.room_type_id = r.room_type_id
ORDER BY r.room_id;


/* -----------------------------------------------------------------------------
   4. fact_booking   (one row per booking_rooms row)

      Returns the source ids (guest_id, hotel_id, room_id). In the ETL, look
      them up in dim_guest / dim_hotel / dim_room to get guest_key,
      hotel_key and room_key.

      The date keys are already in yyyymmdd form, so they join straight to
      dim_date.date_key.
   ----------------------------------------------------------------------------- */
SELECT b.booking_id,
      br.booking_room_id,

      b.guest_id,                     -- -> dim_guest.guest_key
      r.hotel_id,                     -- -> dim_hotel.hotel_key
      br.room_id,                     -- -> dim_room.room_key

       YEAR(b.booking_date)   * 10000 + MONTH(b.booking_date)   * 100 + DAY(b.booking_date)   AS booking_date_key,
       YEAR(b.check_in_date)  * 10000 + MONTH(b.check_in_date)  * 100 + DAY(b.check_in_date)  AS check_in_date_key,
       YEAR(b.check_out_date) * 10000 + MONTH(b.check_out_date) * 100 + DAY(b.check_out_date) AS check_out_date_key,

      br.number_of_nights,
      br.nightly_rate,
      CAST(br.number_of_nights * br.nightly_rate                      AS DECIMAL(12,2)) AS gross_amount,
      br.discount_amount,
       CAST(br.number_of_nights * br.nightly_rate - br.discount_amount AS DECIMAL(12,2)) AS net_amount
FROM dbo.booking_rooms AS br
JOIN dbo.bookings      AS b ON b.booking_id = br.booking_id
JOIN dbo.rooms         AS r ON r.room_id    = br.room_id
ORDER BY br.booking_room_id;
