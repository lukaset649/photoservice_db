--PROCEDURY
--Procedura pozwalaj�ca na dodanie rezerwacji dla u�ytkownik�w z odpowiednimi rolami
CREATE PROCEDURE AddReservation
	@client_id INT,
	@service_id INT,
	@date DATETIME,
	@other_info VARCHAR(2000),
	@type_id INT --typ zlecenia z tabeli reservation_details. Detale mog� by� uzupe�nione p�niej
AS
BEGIN
	--sprawdzenie czy u�ytkownik ma rol� klienta(id4) albo admina(id1)
	IF EXISTS (
		SELECT 1
		FROM user_role ur
		JOIN roles r ON ur.role_id = r.id_role
		WHERE ur.user_id = @client_id AND r.id_role IN (1, 4)
	)
	BEGIN
		DECLARE @reservation_id INT;

		--Dodanie rezerwacji
		INSERT INTO reservation(client_id, service_id, date, other_info)
		VALUES (@client_id, @service_id, @date, @other_info);

		--zapisuje id ostatnio dodanej rezerwacji
		SET @reservation_id = SCOPE_IDENTITY();

		--przypisuje typ zlecenia do rezerwacji (details_id zostanie uzupe�nione p�niej, w osobnej procedurze wprowadzaj�cej details)
		INSERT INTO reservation_details(reservation_id, type_id)
        VALUES (@reservation_id, @type_id);

		PRINT 'Rezerwacja zlecenia zosta�a dodana.';
	END
	ELSE
	BEGIN
		PRINT 'Brak uprawnie� do dodania rezerwacji.';
	END
END;

SELECT * FROM reservation_type


--WYWO�ANIE PROCEDUR
EXEC AddReservation 
    @client_id = 2,         -- ID u�ytkownika pr�buj�cego doda� rezerwacj� (brak uprawnie�)
    @service_id = 2,		
    @date = '2025-08-15', 
    @other_info = 'Sesja fotograficzna na pla�y.',
	@type_id = 1;

EXEC AddReservation 
    @client_id = 6,         -- ID u�ytkownika pr�buj�cego doda� rezerwacj� (posiada upranienia)
    @service_id = 1,		
    @date = '2024-08-15', 
    @other_info = 'Sesja fotograficzna na pla�y.',
	@type_id = 2;


--SELECT * FROM reservation
--select * from reservation_details
--select * from reservation_type
--SELECT * FROM user_role
--SELECT * FROM users
