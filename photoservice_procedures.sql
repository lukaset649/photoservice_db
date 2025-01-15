--====================PROCEDURY====================

--====================Procedura pozwalaj¹ca na dodanie rezerwacji dla u¿ytkowników z odpowiednimi rolami====================
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



--====================Procedura do przypisania pracownika (u¿ytkownik z odpowiedni¹ rol¹) do rezerwacji.====================

CREATE PROCEDURE AssignEmployeeToReservation
    @reservation_id INT,
    @employee_id INT
AS
BEGIN
    -- Sprawdzanie, czy pracownik istnieje
    IF EXISTS (SELECT 1 FROM users WHERE id_user = @employee_id)
    BEGIN
        -- zapisanie typu zlecenia (service_id) przypisanego do rezerwacji
        DECLARE @service_id INT;

        SELECT @service_id = service_id
        FROM reservation
        WHERE id_res = @reservation_id;

        -- zapisanie roli wybranego u¿ytkownika
        DECLARE @role_id INT;

        SELECT @role_id = r.id_role
        FROM user_role ur
        JOIN roles r ON ur.role_id = r.id_role
        WHERE ur.user_id = @employee_id;

        -- Sprawdzanie, czy pracownik ma odpowiedni¹ rolê dla danego zlecenia
        IF (@service_id = 1 AND @role_id = 2)  -- id_service = 1 -> rola 2
        BEGIN
            -- Przypisanie pracownika do rezerwacji
            INSERT INTO reservation_employee (reservation_id, employee_id)
            VALUES (@reservation_id, @employee_id);

            PRINT 'Pracownik zosta³ przypisany do zlecenia';
        END
        ELSE IF (@service_id = 2 AND @role_id = 3)  -- id_service = 2 -> rola 3
        BEGIN
            -- Przypisanie pracownika do rezerwacji
            INSERT INTO reservation_employee (reservation_id, employee_id)
            VALUES (@reservation_id, @employee_id);
            PRINT 'Pracownik zosta³ przypisany do zlecenia';
        END
        ELSE IF (@service_id = 3 AND (@role_id = 2 OR @role_id = 3))  -- id_service = 3 -> rola 2 lub 3
        BEGIN
            -- Przypisanie pracownika do rezerwacji
            INSERT INTO reservation_employee (reservation_id, employee_id)
            VALUES (@reservation_id, @employee_id);
            PRINT 'Pracownik zosta³ przypisany do zlecenia';
        END
        ELSE
        BEGIN
            PRINT 'Wybrany u¿ytkownik nie ma wymaganych uprawnieñ';
        END
    END
    ELSE
    BEGIN
        PRINT 'Nie znaleziono wybranego pracownika';
    END;
END;

--Przyk³ad wywo³ania

--SELECT * FROM reservation
--SELECT * FROM user_role
--SELECT * FROM service_type
--SELECT * FROM roles

EXEC AssignEmployeeToReservation 
	@reservation_id = 1,
	@employee_id = 4;

SELECT * FROM reservation_employee



--====================Procedura do anulowania rezerwacji.====================

CREATE PROCEDURE CancelReservation
    @res_id INT,
    @cancelled_by INT,
    @cancell_reason VARCHAR(500)
AS
BEGIN
    DECLARE @creator_id INT;
    DECLARE @is_assigned_employee BIT;
	DECLARE @is_admin BIT;

    --Zapisanie u¿ytkownika, który stworzy³ rezerwacjê
    SELECT @creator_id = client_id
    FROM reservation
    WHERE id_res = @res_id;

    -- Sprawdzenie, czy u¿ytkownik który chce anulowaæ zlecenie jest przypisanym do niej pracownikiem
    SELECT @is_assigned_employee = 1
    FROM reservation_employee
    WHERE reservation_id = @res_id AND employee_id = @cancelled_by;

	-- Sprawdzenie, czy u¿ytkownik ma rolê administratora
    SELECT @is_admin = 1
    FROM user_role ur
    JOIN roles r ON ur.role_id = r.id_role
    WHERE ur.user_id = @cancelled_by AND r.id_role = 1;

	-- Aktualizacja statusu rezerwacji na anulowan¹
    IF (@cancelled_by = @creator_id OR @is_assigned_employee = 1 OR @is_admin = 1)
    BEGIN
        UPDATE reservation
        SET status_id = 3
        WHERE id_res = @res_id;

        -- Zapisanie informacji o anulowanej rezerwacji do tabeli reservation_cancellation
        INSERT INTO reservation_cancellation (res_id, cancelled_by, cancell_reason)
        VALUES (@res_id, @cancelled_by, @cancell_reason);

        PRINT 'Rezerwacja anulowana pomyœlnie';
    END
    ELSE
    BEGIN
        PRINT 'Nie masz uprawnieñ do anulowania tej rezerwacji';
    END;
END;


--przyk³ad u¿ycia: admin odwo³uje rezerwacjê
EXEC CancelReservation
	@res_id = 1, 
	@cancelled_by = 1, 
	@cancell_reason = 'Admin action';

--SELECT * FROM reservation
--SELECT * FROM reservation_cancellation


--====================WIDOKI====================
--widok ³¹cz¹cy u¿ytkowników z ich rolami
CREATE VIEW ActiveUsersWithRoles AS
SELECT u.id_user, u.f_name, u.l_name, u.email, r.name AS role_name
FROM users u
JOIN user_role ur ON u.id_user = ur.user_id
JOIN roles r ON ur.role_id = r.id_role
WHERE u.is_deleted = 0;	--sprawdza czy konto u¿ytkownika jest aktywne (nie zosta³o usuniête)

--SELECT * FROM ActiveUsersWithRoles

--widok wyœwietlaj¹cy informacje o rezerwacji
CREATE VIEW ReservationView AS
SELECT r.id_res, u.f_name + ' ' + u.l_name AS client_name, st.name AS service_type, r.date, s.name AS status, r.price, r.other_info, r.reservation_date AS reservation_timestamp
FROM reservation r
JOIN users u ON r.client_id = u.id_user
JOIN service_type st ON r.service_id = st.id_service
JOIN status s ON r.status_id = s.id_status;

--widok wyœwietlaj¹cy informacje o rezerwacji przeznaczone dla klienta
CREATE VIEW ClientReservationView AS
SELECT 
    r.id_res, 
    st.name AS service_type, 
	rt.name AS reservation_type,
    r.date, 
    s.name AS status, 
    r.price, 
    r.other_info, 
    r.reservation_date AS reservation_timestamp
FROM reservation r
JOIN users u ON r.client_id = u.id_user
JOIN service_type st ON r.service_id = st.id_service
JOIN status s ON r.status_id = s.id_status
JOIN reservation_details rd ON r.id_res = rd.reservation_id
JOIN reservation_type rt ON rd.type_id = rt.id_res_type;

--SELECT * FROM ReservationView

--widok wyœwietlaj¹cy wszystkie zlecenia do których zostali przypisani pracownicy
CREATE VIEW EmployeeReservationsView AS
SELECT 
    r.id_res AS reservation_id,
    u.f_name + ' ' + u.l_name AS client_name,
    st.name AS service_type,
	r.date,
    s.name AS status,
    r.price,
    r.other_info,
    r.reservation_date AS reservation_timestamp,
    e.f_name + ' ' + e.l_name AS employee_name
FROM 
    reservation r
JOIN 
    reservation_employee re ON r.id_res = re.reservation_id
JOIN 
    users u ON r.client_id = u.id_user	
JOIN 
    service_type st ON r.service_id = st.id_service	--typ zlecenia
JOIN 
    status s ON r.status_id = s.id_status	--status rezerwacji
JOIN 
    users e ON re.employee_id = e.id_user  --dane pracownika
JOIN 
    user_role ur ON e.id_user = ur.user_id  --role pracownika
WHERE 
    ur.role_id IN (2, 3);  -- sprawdza czy u¿ytkownik ma rolê fotografa lub kamerzysty

SELECT * FROM EmployeeReservationsView



--====================TRIGGER====================
--Trigger zapobiegaj¹cy usuniêciu konta przez u¿ytkownika z aktywnym zleceniem
CREATE TRIGGER PreventUserDeletion
ON users
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM reservation 
        WHERE client_id IN (SELECT id_user FROM deleted) AND status_id NOT IN (3, 6)  -- 3:Anulowano, 6:Gotowy
    )
    BEGIN
        PRINT 'Nie mo¿na usun¹æ konta z aktywn¹ rezerwacj¹.';
    END
    ELSE
    BEGIN
        UPDATE users 
        SET is_deleted = 1
        WHERE id_user IN (SELECT id_user FROM deleted);
        
        PRINT 'U¿ytkownik oznaczony jako usuniêty.';
    END;
END;

--Przyk³ad u¿ycia:
--DELETE FROM users WHERE id_user= 2;
--SELECT * FROM USERS

--Trigger zbieraj¹cy logi zmiany pola dotycz¹cego stanu sprzêtu (condition w tabel equipment)
CREATE TRIGGER LogEquipmentConditionChange
ON equipment
AFTER UPDATE
AS
BEGIN
    IF UPDATE(condition)
    BEGIN
        INSERT INTO equipment_condition_log (equipment_id, old_condition, new_condition, change_date)
        SELECT d.id_eq, d.condition, i.condition, GETDATE()
        FROM deleted d
        JOIN inserted i ON d.id_eq = i.id_eq;
        
        PRINT 'Zmieni³ siê stan sprzêtu.';
    END;
END
