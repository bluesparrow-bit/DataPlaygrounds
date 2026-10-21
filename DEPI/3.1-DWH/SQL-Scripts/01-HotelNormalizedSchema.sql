/* =============================================================================
    HOTEL BOOKINGS | Normalized database - EGYPT  (Microsoft SQL Server 2016+)

    Tables : guests, hotels, room_types, rooms, bookings, booking_rooms
    Data   : 12 Egyptian hotels, 5 room types, 350 rooms, 61 guests and
            ~6,000 bookings (Jan 2024 - Dec 2026) with their booking rooms.

    The booking generator is seeded, so every run produces the same data.
    Running the whole script again drops and rebuilds everything.
    Amounts are in USD.
   ============================================================================= */

SET NOCOUNT ON;
GO

IF DB_ID(N'HotelNormalizedSchema') IS NULL
    CREATE DATABASE HotelNormalizedSchema;
GO

USE HotelNormalizedSchema;
GO

/* -----------------------------------------------------------------------------
    2. Tables
   ----------------------------------------------------------------------------- */
CREATE TABLE dbo.guests (
    guest_id       INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_guests PRIMARY KEY,
    guest_name     NVARCHAR(100)     NOT NULL,
    country        NVARCHAR(60)      NOT NULL,
    loyalty_level  NVARCHAR(20)      NOT NULL
        CONSTRAINT DF_guests_loyalty_level DEFAULT (N'None')
        CONSTRAINT CK_guests_loyalty_level CHECK (loyalty_level IN (N'None', N'Silver', N'Gold', N'Platinum'))
);

CREATE TABLE dbo.hotels (
    hotel_id    INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_hotels PRIMARY KEY,
    hotel_name  NVARCHAR(100)     NOT NULL CONSTRAINT UQ_hotels_hotel_name UNIQUE,
    city        NVARCHAR(60)      NOT NULL,
    region      NVARCHAR(60)      NOT NULL
);

CREATE TABLE dbo.room_types (
    room_type_id    INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_room_types PRIMARY KEY,
    room_type_name  NVARCHAR(40)      NOT NULL CONSTRAINT UQ_room_types_name UNIQUE,
    capacity        TINYINT           NOT NULL CONSTRAINT CK_room_types_capacity CHECK (capacity BETWEEN 1 AND 10)
);

CREATE TABLE dbo.rooms (
    room_id       INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_rooms PRIMARY KEY,
    hotel_id      INT               NOT NULL CONSTRAINT FK_rooms_hotels     REFERENCES dbo.hotels (hotel_id),
    room_type_id  INT               NOT NULL CONSTRAINT FK_rooms_room_types REFERENCES dbo.room_types (room_type_id),
    room_number   NVARCHAR(10)      NOT NULL,
    CONSTRAINT UQ_rooms_hotel_room_number UNIQUE (hotel_id, room_number)
);

CREATE TABLE dbo.bookings (
    booking_id      INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_bookings PRIMARY KEY,
    guest_id        INT               NOT NULL CONSTRAINT FK_bookings_guests REFERENCES dbo.guests (guest_id),
    booking_date    DATE              NOT NULL,
    check_in_date   DATE              NOT NULL,
    check_out_date  DATE              NOT NULL,
    booking_status  NVARCHAR(20)      NOT NULL
        CONSTRAINT CK_bookings_status CHECK (booking_status IN (N'Confirmed', N'Checked-In', N'Completed', N'Cancelled', N'No-Show')),
    CONSTRAINT CK_bookings_stay_dates    CHECK (check_out_date > check_in_date),
    CONSTRAINT CK_bookings_booking_date  CHECK (booking_date <= check_in_date)
);

CREATE TABLE dbo.booking_rooms (
    booking_room_id   INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_booking_rooms PRIMARY KEY,
    booking_id        INT               NOT NULL CONSTRAINT FK_booking_rooms_bookings REFERENCES dbo.bookings (booking_id) ON DELETE CASCADE,
    room_id           INT               NOT NULL CONSTRAINT FK_booking_rooms_rooms    REFERENCES dbo.rooms (room_id),
    nightly_rate      DECIMAL(10,2)     NOT NULL CONSTRAINT CK_booking_rooms_rate     CHECK (nightly_rate >= 0),
    number_of_nights  SMALLINT          NOT NULL CONSTRAINT CK_booking_rooms_nights   CHECK (number_of_nights > 0),
    discount_amount   DECIMAL(10,2)     NOT NULL
        CONSTRAINT DF_booking_rooms_discount DEFAULT (0)
        CONSTRAINT CK_booking_rooms_discount CHECK (discount_amount >= 0),
    CONSTRAINT UQ_booking_rooms_booking_room UNIQUE (booking_id, room_id)
);

-- Indexes on foreign keys / common filters
CREATE INDEX IX_rooms_room_type_id        ON dbo.rooms (room_type_id);
CREATE INDEX IX_bookings_guest_id         ON dbo.bookings (guest_id);
CREATE INDEX IX_bookings_stay_dates       ON dbo.bookings (check_in_date, check_out_date) INCLUDE (booking_status);
CREATE INDEX IX_booking_rooms_room_id     ON dbo.booking_rooms (room_id) INCLUDE (booking_id);
GO

/* -----------------------------------------------------------------------------
    3. Reference data  (region = governorate)
   ----------------------------------------------------------------------------- */
INSERT INTO dbo.hotels (hotel_name, city, region) VALUES
    (N'Marriott Mena House',                 N'Giza',            N'Giza'),         -- 1
    (N'Four Seasons Hotel Cairo at Nile Plaza', N'Cairo',        N'Cairo'),        -- 2
    (N'Kempinski Nile Hotel',                N'Cairo',           N'Cairo'),        -- 3
    (N'Steigenberger Hotel El Tahrir',       N'Cairo',           N'Cairo'),        -- 4
    (N'Steigenberger Cecil Hotel',           N'Alexandria',      N'Alexandria'),   -- 5
    (N'Sofitel Winter Palace Luxor',         N'Luxor',           N'Luxor'),        -- 6
    (N'Sofitel Legend Old Cataract',         N'Aswan',           N'Aswan'),        -- 7
    (N'Rixos Sharm El Sheikh',               N'Sharm El Sheikh', N'South Sinai'),  -- 8
    (N'Steigenberger Aldau Beach',           N'Hurghada',        N'Red Sea'),      -- 9
    (N'Hilton Marsa Alam Nubian Resort',     N'Marsa Alam',      N'Red Sea'),      -- 10
    (N'Adrere Amellal',                      N'Siwa',            N'Matrouh'),      -- 11
    (N'Le Meridien Dahab Resort',            N'Dahab',           N'South Sinai');  -- 12

INSERT INTO dbo.room_types (room_type_name, capacity) VALUES
    (N'Single',   1),   -- 1
    (N'Standard', 2),   -- 2
    (N'Deluxe',   2),   -- 3
    (N'Family',   4),   -- 4
    (N'Suite',    3);   -- 5

INSERT INTO dbo.guests (guest_name, country, loyalty_level) VALUES
    (N'Mohamed Abdel Rahman', N'Egypt',                N'Gold'),
    (N'Sara Mostafa',         N'Egypt',                N'Silver'),
    (N'Ahmed Fathy',          N'Egypt',                N'None'),
    (N'Nourhan Adel',         N'Egypt',                N'Platinum'),
    (N'Mahmoud El-Sayed',     N'Egypt',                N'None'),
    (N'Yasmin Farid',         N'Egypt',                N'Silver'),
    (N'Karim Hosny',          N'Egypt',                N'None'),
    (N'Mariam Gamal',         N'Egypt',                N'Gold'),
    (N'Omar Shawky',          N'Egypt',                N'None'),
    (N'Hana Lotfy',           N'Egypt',                N'Silver'),
    (N'Tamer Ibrahim',        N'Egypt',                N'None'),
    (N'Dina Samir',           N'Egypt',                N'None'),
    (N'Amr Nabil',            N'Egypt',                N'Platinum'),
    (N'Rana Soliman',         N'Egypt',                N'None'),
    (N'Hossam Ragab',         N'Egypt',                N'Silver'),
    (N'Aya Mahmoud',          N'Egypt',                N'None'),
    (N'Mostafa Helmy',        N'Egypt',                N'Gold'),
    (N'Salma Anwar',          N'Egypt',                N'None'),
    (N'Youssef Ashraf',       N'Egypt',                N'Silver'),
    (N'Heba Tawfik',          N'Egypt',                N'None'),
    (N'Sherif Mansour',       N'Egypt',                N'None'),
    (N'Nada Emad',            N'Egypt',                N'Silver'),
    (N'Ali Shaker',           N'Egypt',                N'None'),
    (N'Menna Fawzy',          N'Egypt',                N'Gold'),
    (N'Hazem Refaat',         N'Egypt',                N'None'),
    (N'Laila Abdallah',       N'Egypt',                N'None'),
    (N'Tarek Abbas',          N'Egypt',                N'Platinum'),
    (N'Reem Osman',           N'Egypt',                N'None'),
    (N'Khaled Nour',          N'Egypt',                N'Silver'),
    (N'Mai Wagdy',            N'Egypt',                N'None'),
    (N'Abdullah Al-Harbi',    N'Saudi Arabia',         N'Gold'),
    (N'Reem Al-Shehri',       N'Saudi Arabia',         N'Silver'),
    (N'Fahad Al-Enezi',       N'Kuwait',               N'Platinum'),
    (N'Hamad Al-Nuaimi',      N'United Arab Emirates', N'Gold'),
    (N'Laith Obeidat',        N'Jordan',               N'None'),
    (N'Karim Fares',          N'Lebanon',              N'Silver'),
    (N'Rania Nasser',         N'Syria',                N'None'),
    (N'Hiba Abdelrahim',      N'Sudan',                N'None'),
    (N'Lukas Becker',         N'Germany',              N'Gold'),
    (N'Hannah Schmidt',       N'Germany',              N'Silver'),
    (N'Felix Wagner',         N'Germany',              N'None'),
    (N'James Carter',         N'United Kingdom',       N'Platinum'),
    (N'Sophie Walker',        N'United Kingdom',       N'None'),
    (N'Oliver Hughes',        N'United Kingdom',       N'Silver'),
    (N'Dmitry Volkov',        N'Russia',               N'Silver'),
    (N'Anna Smirnova',        N'Russia',               N'None'),
    (N'Sergey Ivanov',        N'Russia',               N'None'),
    (N'Olena Kovalenko',      N'Ukraine',              N'None'),
    (N'Piotr Nowak',          N'Poland',               N'None'),
    (N'Marco Rossi',          N'Italy',                N'Silver'),
    (N'Giulia Bianchi',       N'Italy',                N'None'),
    (N'Julien Moreau',        N'France',               N'None'),
    (N'Camille Laurent',      N'France',               N'Silver'),
    (N'Carlos Garcia',        N'Spain',                N'None'),
    (N'Daan de Vries',        N'Netherlands',          N'None'),
    (N'Tomas Novak',          N'Czech Republic',       N'None'),
    (N'Wei Zhang',            N'China',                N'None'),
    (N'Li Mei',               N'China',                N'None'),
    (N'Yuki Tanaka',          N'Japan',                N'Silver'),
    (N'Michael Brown',        N'United States',        N'Gold'),
    (N'Emily Johnson',        N'United States',        N'None');
GO

/* -----------------------------------------------------------------------------
    4. Rooms  (generated per hotel: floors x rooms per floor, numbered 101, 102...)
        Top floor : rooms 1-2 are Suites, the rest Deluxe
        Other     : n%5=0 Family, n%5=1 Deluxe, floor 1 n%5=2 Single, else Standard
   ----------------------------------------------------------------------------- */
DROP TABLE IF EXISTS #hotel_profile;

CREATE TABLE #hotel_profile (
    hotel_id         INT          NOT NULL PRIMARY KEY,
    floors           TINYINT      NOT NULL,
    rooms_per_floor  TINYINT      NOT NULL,
    rate_factor      DECIMAL(4,2) NOT NULL,   -- price level vs. base rate
    popularity       INT          NOT NULL    -- relative share of bookings
);
GO

INSERT INTO #hotel_profile (hotel_id, floors, rooms_per_floor, rate_factor, popularity) VALUES
    ( 1, 5,  8, 1.60, 12),   -- Marriott Mena House              40 rooms
    ( 2, 5,  8, 1.75, 11),   -- Four Seasons Nile Plaza          40 rooms
    ( 3, 4,  6, 1.50,  7),   -- Kempinski Nile Hotel             24 rooms
    ( 4, 4,  8, 1.15, 10),   -- Steigenberger El Tahrir          32 rooms
    ( 5, 4,  6, 1.05,  8),   -- Steigenberger Cecil Hotel        24 rooms
    ( 6, 3,  8, 1.45,  8),   -- Sofitel Winter Palace Luxor      24 rooms
    ( 7, 3,  6, 1.85,  6),   -- Sofitel Legend Old Cataract      18 rooms
    ( 8, 5, 10, 1.40, 14),   -- Rixos Sharm El Sheikh            50 rooms
    ( 9, 5,  8, 1.30, 12),   -- Steigenberger Aldau Beach        40 rooms
    (10, 4,  6, 1.00,  6),   -- Hilton Marsa Alam Nubian Resort  24 rooms
    (11, 2,  5, 1.90,  2),   -- Adrere Amellal                   10 rooms
    (12, 3,  8, 1.10,  6);   -- Le Meridien Dahab Resort         24 rooms

INSERT INTO dbo.rooms (hotel_id, room_type_id, room_number)
SELECT hp.hotel_id,
        CASE
            WHEN f.n = hp.floors AND r.n <= 2 THEN 5   -- Suite
            WHEN f.n = hp.floors              THEN 3   -- Deluxe
            WHEN r.n % 5 = 0                  THEN 4   -- Family
            WHEN r.n % 5 = 1                  THEN 3   -- Deluxe
            WHEN f.n = 1 AND r.n % 5 = 2      THEN 1   -- Single
            ELSE 2                                     -- Standard
        END,
        CONCAT(f.n, RIGHT(CONCAT('0', r.n), 2))
FROM #hotel_profile AS hp
JOIN (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10)) AS f(n) ON f.n <= hp.floors
JOIN (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10)) AS r(n) ON r.n <= hp.rooms_per_floor
ORDER BY hp.hotel_id, f.n, r.n;
GO


/* -----------------------------------------------------------------------------
    5. Bookings + booking rooms
        - check-in dates 2024-01-01 .. 2026-12-31, Egyptian season:
        busiest Dec-Jan, high Oct-Apr, quieter in summer
        - 1-3 rooms per booking, all in the same hotel, never double-booked
        - status depends on @AsOfDate (past = Completed/Cancelled/No-Show,
        in-house = Checked-In, future = Confirmed/Cancelled)
        - discount: loyalty (Silver 5%, Gold 10%, Platinum 15%)
                    + 10% for 7+ nights or an occasional 5% promo
        Change @Target for more or fewer bookings.
   ----------------------------------------------------------------------------- */
DROP TABLE IF EXISTS #hotel_pick, #guest_pick;

SELECT hotel_id,
        rate_factor,
        CAST(SUM(popularity) OVER (ORDER BY hotel_id ROWS UNBOUNDED PRECEDING) AS FLOAT) AS cum_weight
INTO #hotel_pick
FROM #hotel_profile;

-- Loyal guests book more often
SELECT guest_id,
        loyalty_level,
        CAST(SUM(CASE loyalty_level WHEN N'Platinum' THEN 5 WHEN N'Gold' THEN 3 WHEN N'Silver' THEN 2 ELSE 1 END)
            OVER (ORDER BY guest_id ROWS UNBOUNDED PRECEDING) AS FLOAT) AS cum_weight
INTO #guest_pick
FROM dbo.guests;

DECLARE @StartDate DATE = '2024-01-01',
        @EndDate   DATE = '2026-12-31',
        @AsOfDate  DATE = '2026-09-29',     -- "today" for the sample data
        @Target    INT  = 6000;             -- number of bookings to create

DECLARE @Days        INT   = DATEDIFF(DAY, @StartDate, @EndDate) + 1,
        @HotelTotal  FLOAT = (SELECT MAX(cum_weight) FROM #hotel_pick),
        @GuestTotal  FLOAT = (SELECT MAX(cum_weight) FROM #guest_pick),
        @Made        INT   = 0,
        @Attempts    INT   = 0,
        @r           FLOAT,
        @guest_id    INT,
        @loyalty     NVARCHAR(20),
        @hotel_id    INT,
        @rate_factor DECIMAL(4,2),
        @season      DECIMAL(4,2),
        @check_in    DATE,
        @check_out   DATE,
        @booking_dt  DATE,
        @nights      INT,
        @room_count  INT,
        @status      NVARCHAR(20),
        @discount    DECIMAL(4,2),
        @booking_id  INT;

DECLARE @picked TABLE (room_id INT PRIMARY KEY, room_type_id INT NOT NULL);

SET @r = RAND(20240101);   -- fixed seed => same data on every run

BEGIN TRANSACTION;

WHILE @Made < @Target AND @Attempts < @Target * 5
BEGIN
    SET @Attempts += 1;

    -- Check-in date, thinned out in quiet months (Egypt peaks in winter)
    SET @check_in = DATEADD(DAY, CAST(FLOOR(RAND() * @Days) AS INT), @StartDate);
    SET @season = CASE MONTH(@check_in)
                        WHEN 12 THEN 1.25 WHEN 1  THEN 1.25
                        WHEN 11 THEN 1.15 WHEN 2  THEN 1.15
                        WHEN 3  THEN 1.15 WHEN 4  THEN 1.15
                        WHEN 10 THEN 1.10
                        WHEN 5  THEN 1.00 WHEN 7  THEN 1.00 WHEN 8 THEN 1.00
                        ELSE 0.90                                  -- Jun, Sep
                    END;
    IF RAND() > @season / 1.25 CONTINUE;

    -- Length of stay (resort stays run a little longer)
    SET @r = RAND();
    SET @nights = CASE WHEN @r < 0.15 THEN 1 WHEN @r < 0.35 THEN 2 WHEN @r < 0.55 THEN 3
                        WHEN @r < 0.70 THEN 4 WHEN @r < 0.80 THEN 5 WHEN @r < 0.93 THEN 7
                        ELSE 10 END;
    SET @check_out = DATEADD(DAY, @nights, @check_in);

    -- Lead time 0-120 days, mostly short
    SET @booking_dt = DATEADD(DAY, -CAST(FLOOR(RAND() * RAND() * 120) AS INT), @check_in);
    IF @booking_dt > @AsOfDate CONTINUE;   -- cannot be booked yet

    -- Guest and hotel (weighted)
    SET @r = RAND() * @GuestTotal;
    SELECT TOP (1) @guest_id = guest_id, @loyalty = loyalty_level
    FROM #guest_pick WHERE cum_weight > @r ORDER BY cum_weight;

    SET @r = RAND() * @HotelTotal;
    SELECT TOP (1) @hotel_id = hotel_id, @rate_factor = rate_factor
    FROM #hotel_pick WHERE cum_weight > @r ORDER BY cum_weight;

    -- Status relative to @AsOfDate
    SET @r = RAND();
    SET @status = CASE
                        WHEN @check_out <= @AsOfDate THEN CASE WHEN @r < 0.82 THEN N'Completed'
                                                                WHEN @r < 0.95 THEN N'Cancelled'
                                                                ELSE N'No-Show' END
                        WHEN @check_in  <= @AsOfDate THEN CASE WHEN @r < 0.93 THEN N'Checked-In'
                                                                ELSE N'Cancelled' END
                        ELSE                                  CASE WHEN @r < 0.88 THEN N'Confirmed'
                                                                ELSE N'Cancelled' END
                    END;

    -- Number of rooms
    SET @r = RAND();
    SET @room_count = CASE WHEN @r < 0.72 THEN 1 WHEN @r < 0.92 THEN 2 ELSE 3 END;

    -- Free rooms in that hotel for those nights
    DELETE FROM @picked;
    INSERT INTO @picked (room_id, room_type_id)
    SELECT TOP (@room_count) rm.room_id, rm.room_type_id
    FROM dbo.rooms AS rm
    WHERE rm.hotel_id = @hotel_id
        AND NOT EXISTS (SELECT 1
                        FROM dbo.booking_rooms AS br
                        JOIN dbo.bookings      AS b ON b.booking_id = br.booking_id
                        WHERE br.room_id = rm.room_id
                        AND b.booking_status <> N'Cancelled'
                        AND b.check_in_date  < @check_out
                        AND b.check_out_date > @check_in)
    ORDER BY ABS(CHECKSUM(@Attempts, rm.room_id));

    IF (SELECT COUNT(*) FROM @picked) < @room_count CONTINUE;   -- hotel full

    INSERT INTO dbo.bookings (guest_id, booking_date, check_in_date, check_out_date, booking_status)
    VALUES (@guest_id, @booking_dt, @check_in, @check_out, @status);

    SET @booking_id = SCOPE_IDENTITY();

    SET @discount = CASE @loyalty WHEN N'Platinum' THEN 0.15 WHEN N'Gold' THEN 0.10
                                    WHEN N'Silver'   THEN 0.05 ELSE 0 END
                    + CASE WHEN @nights >= 7 THEN 0.10
                            WHEN RAND() < 0.08 THEN 0.05
                            ELSE 0 END;

    -- Nightly rate = base rate x hotel level x season x yearly increase (6%)
    INSERT INTO dbo.booking_rooms (booking_id, room_id, nightly_rate, number_of_nights, discount_amount)
    SELECT @booking_id,
            p.room_id,
            x.rate,
            @nights,
           ROUND(x.rate * @nights * @discount, 2)
    FROM @picked AS p
    JOIN (VALUES (1, 55.0), (2, 85.0), (3, 125.0), (4, 160.0), (5, 260.0)) AS base(room_type_id, base_rate)
            ON base.room_type_id = p.room_type_id
    CROSS APPLY (SELECT CAST(ROUND(base.base_rate * @rate_factor * @season
                                   * (1 + 0.06 * (YEAR(@check_in) - 2024)), 0) AS DECIMAL(10,2)) AS rate) AS x;

    SET @Made += 1;
END;

COMMIT TRANSACTION;
IF DB_ID(N'HotelBookingsDWH') IS NULL
DROP TABLE IF EXISTS #hotel_pick, #guest_pick, #hotel_profile;
GO

/* -----------------------------------------------------------------------------
    7. Quick checks
   ----------------------------------------------------------------------------- */
SELECT 'guests' AS table_name, COUNT(*) AS row_count FROM dbo.guests
UNION ALL SELECT 'hotels',        COUNT(*) FROM dbo.hotels
UNION ALL SELECT 'room_types',    COUNT(*) FROM dbo.room_types
UNION ALL SELECT 'rooms',         COUNT(*) FROM dbo.rooms
UNION ALL SELECT 'bookings',      COUNT(*) FROM dbo.bookings
UNION ALL SELECT 'booking_rooms', COUNT(*) FROM dbo.booking_rooms;

SELECT booking_status, COUNT(*) AS bookings
FROM dbo.bookings
GROUP BY booking_status
ORDER BY bookings DESC;
