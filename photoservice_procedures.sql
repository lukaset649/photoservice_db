--PROCEDURY
--Procedura pozwalaj¹ca na dodanie rezerwacji dla u¿ytkowników z odpowiednimi rolami

CREATE PROCEDURE AddReservation
    @client_id INT,
    @service_id INT,
    @date DATETIME,
    @other_info VARCHAR(2000),
    @type_id INT,  -- typ zlecenia z tabeli reservation_details
    @reservation_details_id INT OUTPUT -- Dodajemy parametr OUTPUT
AS
BEGIN
    -- Sprawdzenie czy u¿ytkownik ma rolê klienta(id4) albo admina(id1)
    IF EXISTS (
        SELECT 1
        FROM user_role ur
        JOIN roles r ON ur.role_id = r.id_role
        WHERE ur.user_id = @client_id AND r.id_role IN (1, 4)
    )
    BEGIN
		DECLARE @reservation_id INT;

        -- Dodanie rezerwacji
        INSERT INTO reservation(client_id, service_id, date, other_info)
        VALUES (@client_id, @service_id, @date, @other_info);

		SET @reservation_id = SCOPE_IDENTITY();

        -- Przypisanie typu zlecenia do rezerwacji (details_id zostanie uzupe³nione póŸniej)
        INSERT INTO reservation_details(reservation_id, type_id)
        VALUES (@reservation_id, @type_id);

		-- Zapisanie ID ostatnio dodanego rekordu
        SET @reservation_details_id = SCOPE_IDENTITY();

        PRINT 'Rezerwacja zlecenia zosta³a dodana.';
    END
    ELSE
    BEGIN
        PRINT 'Brak uprawnieñ do dodania rezerwacji.';
    END
END;



--Procedura dodania rekordu do tabeli details_wedding i uzupe³nienia details_id w tabeli reservation_details
CREATE PROCEDURE AddDetailsWedding
	@id_reservation_details INT,
    @groom_address VARCHAR(255),
    @groom_prep_time TIME,
    @bride_address VARCHAR(255),
    @bride_prep_time TIME,
    @ceremony_address VARCHAR(255),
    @ceremony_time TIME,
    @church_entry_info VARCHAR(255),
    @documments_signing_info VARCHAR(255),
    @church_exit_info VARCHAR(255),
    @compliments_info VARCHAR(255),
    @wedding_hall_address VARCHAR(255),
    @musical_band_info VARCHAR(255),
    @additional_attractions VARCHAR(500)
AS
BEGIN
    INSERT INTO details_wedding
        (groom_address, groom_prep_time, bride_address, bride_prep_time, 
         ceremony_address, ceremony_time, church_entry_info, documments_signing_info, 
         church_exit_info, compliments_info, wedding_hall_address, musical_band_info, 
         additional_attractions)
    VALUES
        (@groom_address, @groom_prep_time, @bride_address, @bride_prep_time, 
         @ceremony_address, @ceremony_time, @church_entry_info, @documments_signing_info, 
         @church_exit_info, @compliments_info, @wedding_hall_address, @musical_band_info, 
         @additional_attractions);

	--Zapisujê id dodanego rekordu
	DECLARE @details_wedding_id INT;
    SET @details_wedding_id = SCOPE_IDENTITY();
    
	--Aktualizacja tabeli reservation_details z nowym ID z details_wedding
	UPDATE reservation_details
    SET details_id = @details_wedding_id
    WHERE id_res_det = @id_reservation_details;
END;


--Procedura dodania rekordu do tabeli details_photoshoot i uzupe³nienia details_id w tabeli reservation_details
CREATE PROCEDURE AddDetailsPhotoshoot
    @id_reservation_details INT,
    @localisation VARCHAR(255),
    @transport VARCHAR(255),
    @num_of_participants INT
AS
BEGIN
    -- Dodanie rekordu do tabeli details_photoshoot
    INSERT INTO details_photoshoot
        (localisation, transport, num_of_participants)
    VALUES
        (@localisation, @transport, @num_of_participants);

    -- Zapisanie ID dodanego rekordu
    DECLARE @details_photoshoot_id INT;
    SET @details_photoshoot_id = SCOPE_IDENTITY();
    
    -- Aktualizacja tabeli reservation_details z nowym ID z details_photoshoot
    UPDATE reservation_details
    SET details_id = @details_photoshoot_id
    WHERE id_res_det = @id_reservation_details;
END;



--Procedura dodania rekordu do tabeli details_baptism i uzupe³nienia details_id w tabeli reservation_details
CREATE PROCEDURE AddDetailsBaptism
    @id_reservation_details INT,
    @home_address VARCHAR(255),
    @church_address VARCHAR(255),
    @ceremony_time TIME
AS
BEGIN
    -- Dodanie rekordu do tabeli details_baptism
    INSERT INTO details_baptism
        (home_address, church_address, ceremony_time)
    VALUES
        (@home_address, @church_address, @ceremony_time);

    -- Zapisanie ID dodanego rekordu
    DECLARE @details_baptism_id INT;
    SET @details_baptism_id = SCOPE_IDENTITY();
    
    -- Aktualizacja tabeli reservation_details z nowym ID z details_baptism
    UPDATE reservation_details
    SET details_id = @details_baptism_id
    WHERE id_res_det = @id_reservation_details;
END;


--Procedura dodania rekordu do tabeli details_other i uzupe³nienia details_id w tabeli reservation_details
CREATE PROCEDURE AddDetailsOther
    @id_reservation_details INT,
    @localisation VARCHAR(255),
    @description VARCHAR(500)
AS
BEGIN
    -- Dodanie rekordu do tabeli details_other
    INSERT INTO details_other
        (localisation, description)
    VALUES
        (@localisation, @description);

    -- Zapisanie ID dodanego rekordu
    DECLARE @details_other_id INT;
    SET @details_other_id = SCOPE_IDENTITY();
    
    -- Aktualizacja tabeli reservation_details z nowym ID z details_other
    UPDATE reservation_details
    SET details_id = @details_other_id
    WHERE id_res_det = @id_reservation_details;
END;


--PRZYK£AD WYWO£ANIA
--aplikacja sprawdza jaki typ zosta³ wybrany i na tej podstawie wywo³uje odpowiedni¹ procedurê (np: case 4: EXEC AddDetailsOther)
DECLARE @reservation_details_id INT;

-- Wywo³anie procedury AddReservation z przekazaniem parametrów i odbiorem @reservation_id
EXEC AddReservation
    @client_id = 6,
    @service_id = 1,
    @date = '2024-12-05',
    @other_info = 'Informacje dodatkowe...',
    @type_id = 4,
    @reservation_details_id = @reservation_details_id OUTPUT; --zapisanie id do @reservation_id na wyjœciu

-- Wywo³anie procedury AddDetailsOther z przekazaniem @reservation_id
EXEC AddDetailsOther
    @id_reservation_details = @reservation_details_id,
    @localisation = 'ul. Nowa 5, Wroc³aw',  -- Lokalizacja
    @description = 'Event w plenerze z widokiem na jezioro';  -- Opis