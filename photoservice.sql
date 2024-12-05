--CREATE DATABASE photoservice;

--USE photoservice;

--TWORZENIE TABEL
--Tabela u�ytkownik�w
CREATE TABLE users (
	id_user INT PRIMARY KEY IDENTITY,
	f_name VARCHAR(50) NOT NULL,
	l_name VARCHAR(50) NOT NULL,
	phone_number VARCHAR(20) NOT NULL UNIQUE,
	email VARCHAR(50) NOT NULL UNIQUE,
	password_hash VARCHAR(255) NOT NULL,
	registration_date DATETIME DEFAULT CURRENT_TIMESTAMP,
	is_deleted BIT DEFAULT 0	-- 0 oznacza aktywnego u�ytkownika, 1 usuni�tego
)

--Tabela obs�uguj�ca przesy�anie wiadomo�ci mi�dzy u�ytkownikami
CREATE TABLE messages (
	id_mess INT PRIMARY KEY IDENTITY,
	sender_id INT NOT NULL,
	recipient_id INT NOT NULL,
	mess_content VARCHAR(500),
	mess_date DATETIME DEFAULT CURRENT_TIMESTAMP,

	FOREIGN KEY (sender_id) REFERENCES users(id_user),
	FOREIGN KEY (recipient_id) REFERENCES users(id_user)
)

--Tabela zawieraj�ca list� r�l jakie mog� by� przypisane do u�ytkownik�w
CREATE TABLE roles (
	id_role	INT PRIMARY KEY IDENTITY,
	name VARCHAR(50) NOT NULL,
	description VARCHAR(255)
)

--Tabela przypisuj�ca danea role do konkretnych u�ytkownik�w (jeden u�ytkownik mo�e mie� kilka r�l)
CREATE TABLE user_role (
	id_ur INT PRIMARY KEY IDENTITY,
	user_id INT,
	role_id INT,

	FOREIGN KEY (user_id) REFERENCES users(id_user),
	FOREIGN KEY (role_id) REFERENCES roles(id_role)
)

--Tabela zawieraj�ca list� dost�pnych status�w zlecenia(tabela reservation)
CREATE TABLE status (
	id_status INT PRIMARY KEY IDENTITY,
	name VARCHAR(50) NOT NULL,
	description VARCHAR(255)
)

--Tabela zawiera list� typ�w zlece� (np: FOTO/VIDEO/FOTO-VIDEO)
CREATE TABLE service_type (
	id_service INT PRIMARY KEY IDENTITY,
	name VARCHAR(50) NOT NULL,
	description VARCHAR(255) 
)

--Tabela obs�uguj�ca rezerwacj� us�ug
CREATE TABLE reservation (
	id_res INT PRIMARY KEY IDENTITY,
	client_id INT NOT NULL,
	service_id INT NOT NULL,
	status_id INT NOT NULL DEFAULT 1, --domy�lnie status ustawiony na oczekuj�ce
	date DATETIME,
	deadline DATE,
	finished_date DATE,
	price MONEY,
	other_info VARCHAR(2000),
	reservation_date DATETIME DEFAULT CURRENT_TIMESTAMP,

	FOREIGN KEY (client_id) REFERENCES users(id_user),
	FOREIGN KEY (service_id) REFERENCES service_type(id_service),
	FOREIGN KEY (status_id) REFERENCES status(id_status)
)

--Tabela przypisuj�ca konkretnego pracownika do danego zlecenia (do jednego zlecenia mo�na doda� kilku pracownik�w)
CREATE TABLE reservation_employee (
	id_res_emp INT PRIMARY KEY IDENTITY,
	reservation_id INT NOT NULL,
	employee_id INT NOT NULL,

	FOREIGN KEY (reservation_id) REFERENCES reservation(id_res),
	FOREIGN KEY (employee_id) REFERENCES users(id_user)
)

--Tabela z list� kategorii sprz�tu
CREATE TABLE equipment_type (
	id_eq_type INT PRIMARY KEY IDENTITY,
	name VARCHAR(50) NOT NULL,
	description VARCHAR(255)
)

--Tabela z list� producent�w sprz�tu
CREATE TABLE equipment_manufacturer (
	id_eq_man INT PRIMARY KEY IDENTITY,
	name VARCHAR(50) NOT NULL,
	description VARCHAR(255)
)

--Tabela z list� sprz�tu firmy
CREATE TABLE equipment (
	id_eq INT PRIMARY KEY IDENTITY,
	name VARCHAR(50) NOT NULL,
	eq_type_id INT NOT NULL,
	eq_manufacturer_id INT NOT NULL,
	description VARCHAR(255),
	condition VARCHAR(255),
	working BIT DEFAULT 1, --1: working, 0:not working

	FOREIGN KEY (eq_type_id) REFERENCES equipment_type(id_eq_type),
	FOREIGN KEY (eq_manufacturer_id) REFERENCES equipment_manufacturer(id_eq_man)
)

--Tabela przechowuj�ca informacj�, ze sprz�tem jakich firm jest kompatybilny dany przedmiot (np lampa b�yskowa firmy YANGNUO mo�e by� kompatybilna z aparatami Canon, Sony, itp, a obiektyw Tamron z aparatami Nikona)
CREATE TABLE equipment_compability (
	id_compability INT PRIMARY KEY IDENTITY,
	eq_id INT NOT NULL,
	compatible_with_id INT NOT NULL,

	FOREIGN KEY (eq_id) REFERENCES equipment(id_eq),
	FOREIGN KEY (compatible_with_id) REFERENCES equipment(id_eq)
)

--Tabela przypisuj�ca list� sprz�tu do rezerwacji. Jedna rezerwacja mo�e mie� tylko jedn� list� rezerwacji
CREATE TABLE reservation_equipment (
	id_res_eq INT PRIMARY KEY IDENTITY,
	res_id INT NOT NULL,
	eq_id INT NOT NULL,

	FOREIGN KEY (res_id) REFERENCES reservation(id_res),
	FOREIGN KEY (eq_id) REFERENCES equipment(id_eq)
)


--Tabela z list� typ�w rezerwacji(wedding, photoshoot,itp.)
CREATE TABLE reservation_type (
	id_res_type INT PRIMARY KEY IDENTITY,
	name VARCHAR(50) NOT NULL,
	description VARCHAR(255)
)

--Tabela zawieraj�ca datale zlecenia w przypadku wybrania typu wedding z reservation type
CREATE TABLE details_wedding (
    id_det_wed INT PRIMARY KEY IDENTITY,
    groom_address VARCHAR(255) NOT NULL,
    groom_prep_time TIME,
    bride_address VARCHAR(255) NOT NULL,
    bride_prep_time TIME,
    ceremony_address VARCHAR(255) NOT NULL,
    ceremony_time TIME NOT NULL,
    church_entry_info VARCHAR(255),
    documments_signing_info VARCHAR(255),
    church_exit_info VARCHAR(255),
    compliments_info VARCHAR(255),
    wedding_hall_address VARCHAR(255) NOT NULL,
    musical_band_info VARCHAR(255),
    additional_attractions VARCHAR(500)
);

--Tabela zawieraj�ca datale zlecenia w przypadku wybrania typu photoshoot z reservation type
CREATE TABLE details_photoshoot (
	id_det_ps INT PRIMARY KEY IDENTITY,
	localisation VARCHAR(255) NOT NULL,
	transport VARCHAR(255),
	num_of_participants INT NOT NULL
)

--Tabela zawieraj�ca datale zlecenia w przypadku wybrania typu baptism z reservation type
CREATE TABLE details_baptism (
	id_det_bap INT PRIMARY KEY IDENTITY,
	church_address VARCHAR(255) NOT NULL,
	home_address VARCHAR(255),
	ceremony_time TIME NOT NULL
)

--Tabela zawieraj�ca datale zlecenia w przypadku wybrania typu other z reservation type
CREATE TABLE details_other (
	id_det_oth INT PRIMARY KEY IDENTITY,
	localisation VARCHAR(255) NOT NULL,
	description VARCHAR(1000) NOT NULL
)

--Tabela zapisuj�ca wyb�r typu zlecenia (�lub, sesja zdj�ciowa,itp.) do konkretnej rezerwacji. 
CREATE TABLE reservation_details (
	id_res_det INT PRIMARY KEY IDENTITY,
	reservation_id INT NOT NULL,
	type_id INT NOT NULL,
	details_id INT, --Nie jest kluczem obcym, poniewa� rekord zostanie dopiero utworzony po wyborze typu. ID zostanie wpisane do kom�rki np za pomoca SCOPE_IDENTITY(), a kolizji mi�dzy u�ytkownikamiu mo�na zapobiec u�ywaj�c tranzakcji.

	FOREIGN KEY (reservation_id) REFERENCES reservation(id_res),
	FOREIGN KEY (type_id) REFERENCES reservation_type(id_res_type)
)

CREATE TABLE reservation_cancellation (
	id_cancell INT PRIMARY KEY IDENTITY,
	res_id INT NOT NULL,
	cancelled_by INT NOT NULL,
	cancell_reason VARCHAR(500) NOT NULL,
	cancell_date DATETIME DEFAULT CURRENT_TIMESTAMP,

	FOREIGN KEY (res_id) REFERENCES reservation(id_res),
    FOREIGN KEY (cancelled_by) REFERENCES users(id_user)
)





--WPROWADZENIE PRZYK�ADOWYCH DANYCH
-- Dodanie cztertech u�ytkownik�w do tabeli users
INSERT INTO users (f_name, l_name, phone_number, email, password_hash)
VALUES
('Jan', 'Kowalski', '123456789', 'jan.kowalski@example.com', 'hashed_password_1'),
('Anna', 'Nowak', '987654321', 'anna.nowak@example.com', 'hashed_password_2'),
('Piotr', 'Zielinski', '555666777', 'piotr.zielinski@example.com', 'hashed_password_3'),
('�ukasz', 'Setlak', '111222333', 'lukaset@example.com', 'hashed_password_3'),
('Marta', 'Wi�niewska', '444555666', 'marta.wisniewska@example.com', 'hashed_password_4'),
('Krzysztof', 'Nowicki', '777888999', 'krzysztof.nowicki@example.com', 'hashed_password_5'),
('Ewa', 'Kaczmarek', '333444555', 'ewa.kaczmarek@example.com', 'hashed_password_6');

--Lista r�l
INSERT INTO roles (name, description)
VALUES
('administrator','u�ytkownik z uprawnieniami do zarz�dzania u�ytkownikami i dost�pu do podgl�du wszystkich danych. Ma mo�liwo�� u�ywania czatu'),
('fotograf', 'u�ytkownik b�d�cy pracownikiem, mog�cym wykonywa� zlecenia typu: FOTO. Ma mo�liwo�� u�ywania czatu i sprawdzenia danych dotycz�cych zlece� do kt�rych zosta� przypisany przez administratora. Wybiera sprz�t potrzebny do wykonania zlecenia.'),
('kamerzysta', 'u�ytkownik b�d�cy pracownikiem, mog�cym wykonywa� zlecenia typu: VIDEO. Ma mo�liwo�� u�ywania czatu i sprawdzenia danych dotycz�cych zlece� do kt�rych zosta� przypisany przez administratora. Wybiera sprz�t potrzebny do wykonania zlecenia.'),
('klient', 'u�ytkownik maj�cy mo�liwo�� korzystania z czatu i dokonania rezeracji us�ug');

--Przypisanie r�l u�ytkownikom (Jan- administrator, Anna - kamerzysta i fotograf, Piotr - klient, �ukasz - fotograf)
INSERT INTO user_role (user_id, role_id)
VALUES
(1,1),
(2,3),
(2,2),
(3,4),
(4,2),
(5,4),
(6,4),
(7,4);

--Przyk�adowa konwersacja mi�dzy klientem i administratorem oraz klientem i fotografem
INSERT INTO messages (sender_id, recipient_id, mess_content, mess_date)
VALUES
(3, 1, 'Witam, chcia�bym zarezerwowa� termin na sesj� fotograficzn�.','2024-12-03 12:46:20'),
(1, 3, 'Oczywi�cie, prosz� utworzy� now� rezerwacj�, a nasz fotograf skontaktuje si� z Panem. Gdy tylko fotograf zostanie przypisany do Pana zlecenia, pojawi si� te� opcja "wy�lij wiadomo��" przy pomocy kt�rej b�dzie m�g� Pan skontaktowa� si� z nim jako pierwszy.', '2024-12-03 12:49:57'),
(3, 4, 'Cze�� �ukasz, mam pytanie odno�nie rezerwacji sesji zdj�ciowej.', '2024-12-04 09:15:00'),
(4, 3, 'Hej Piotr, ch�tnie Ci pomog�. O co dok�adnie chodzi?', '2024-12-04 09:20:00'),
(3, 4, 'Czy by�by dost�pny termin w przywsz�ym tygodniu?', '2024-12-04 09:45:13');

--Lista typ�w wyposa�enia
INSERT INTO equipment_type (name, description)
VALUES
('Body', 'Podstawowy element aparatu, zawieraj�ca matryc� i mechanizm fotograficzny.'),
('Lens', 'Obiektyw, element aparatu odpowiedzialny za skupienie obrazu na matrycy.'),
('Tripod', 'Statyw fotograficzny, u�ywany do stabilizacji aparatu podczas robienia zdj��.'),
('Flash', 'Lampa b�yskowa, s�u��ca do do�wietlania sceny w przypadku s�abego o�wietlenia.');

--Lista producent�w wyposa�enia
INSERT INTO equipment_manufacturer (name, description)
VALUES
('Canon', 'Lustrzanki, bezlusterkowce i obiektywy u�ywane przez nas do fotografii'),
('Sony', 'Bezlusterkowce i obiektywy u�ywane przez nas do nagrywania video'),
('YANGNUO', 'Lampy b�yskowe i obiektywy'),
('Sigma', 'Obiektywy'),
('Tamron', 'Obiektywy');

--Lista sprz�tu dost�pnego w firmie
INSERT INTO equipment (name, eq_type_id, eq_manufacturer_id, description, condition)
VALUES
('Canon EOS R5', 1, 1, 'Bezlusterkowy aparat fotograficzny o wysokiej rozdzielczo�ci, idealny do profesjonalnej fotografii.', 'Nowy'),
('Sony Alpha 7 III', 1, 2, 'Profesjonalny bezlusterkowiec z matryc� pe�noklatkow�, doskona�y do nagrywania wideo.', 'U�ywany'),
('Sigma 35mm f/1.4 DG HSM', 2, 4, 'Obiektyw sta�oogniskowy o du�ej jasno�ci, idealny do portret�w i fotografii niskiego o�wietlenia.', 'Nowy'),
('Tamron 28-75mm f/2.8 Di III RXD', 2, 5, 'Zoom o sta�ej jasno�ci, idealny do fotografii krajobrazowej i portretowej.', 'U�ywany'),
('YANGNUO YN560 IV Flash', 4, 3, 'Lampa b�yskowa do aparat�w, z mo�liwo�ci� bezprzewodowego sterowania.', 'Nowy');

--Lista urz�dze�, kt�re s� ze sob� kompatybilne (np obiektyw Sigma jest kompatybilny z aparatem CANON R5)
INSERT INTO equipment_compability (eq_id, compatible_with_id)
VALUES
(3,1),
(4,2),
(5,1),
(5,2);

--Lista typ�w zlecenia
INSERT INTO service_type (name, description)
VALUES
('FOTO', 'Zlecenie do kt�rego wykonania potrzebny jest fotograf'),
('VIDEO', 'Zlecenie do kt�rego wykonania potrzebny jest kamerzysta'),
('FOTO-VIDEO', 'Zlecenie do kt�rego wykonania potrzebny jest zar�wno fotograf jak i kamerzysta');

--Lista status�w rezerwacji
INSERT INTO status (name, description)
VALUES
('Oczekuj�ce','Zlecenie oczekuje na przypisanie odpowiednich pracownik�w'),
('W trakcie ustale�','Przypisano odpowiednich pracownik�w, trwa ustalanie szczeg��w z klientem'),
('Anulowano','Zlecenie zosta�o anulowane przed rozpocz�ciem jego realizacji'),
('Potwierdzone', 'Data i lokalizacja zlecenia zosta�y ustalone z klientem i wprowadzone przez pracownik�w przypisanych do zlecenia'),
('W trakcie postprodukcji', 'materia� zdj�ciowy/filmowy zosta� wykonany i jest w trakcie postprodukcji'),
('Gotowy', 'Gotowy materia� jest gotowy do odbioru');

--Lista rezerwacji zlece�
INSERT INTO reservation (client_id, service_id, status_id, price, other_info)
VALUES
(3, 1, 1, 500.00, 'Sesja zdj�ciowa narzecze�ska w plenerze, zale�y nam na widoku na g�ry, ale tak �eby nie trzeba zbyt daleko i�� ani si� nigdzie wspina�');

--Lista typ�w zlece�
INSERT INTO reservation_type (name, description)
VALUES
('wedding', 'Rezerwacja zlecenia �lubnego, przygotowania, ceremoni� i wesele do godziny 01:00.'),
('photoshoot', 'Rezerwacja sesji plenerowej, obejmuj�ca r�norodne sesje fotograficzne i filmowe.'),
('baptism', 'Rezerwacja zlecenia z ceremonii chrztu dziecka.'),
('other', 'Inny typ rezerwacji, kt�ry nie pasuje do wcze�niej wymienionych kategorii.');

--Lista detali wprowadzonych do r�nych zlece� z wybranym typem photoshoot
INSERT INTO details_photoshoot (localisation, transport, num_of_participants)
VALUES
('G�ra Zbor�w', 'Dojazd osobno, samochodem prywatnym', 2);

--Lista przypisuj�ca odpowiedni typ i detale zlecenia do danej rezerwacji
INSERT INTO reservation_details (reservation_id, type_id, details_id)
VALUES
(1, 2, 1);	--rezerwacja o id 1 ma przypisany typ o id 2: photoshoot i detale zlecenia o id 1 (z kt�ej tabeli b�dzie to id zale�y od type_id)

-- Przyk�adowa rezerwacja typu wedding i us�uga FOTO-VIDEO
INSERT INTO reservation (client_id, service_id, status_id, date, price, other_info)
VALUES
(3, 3, 1, '2025-06-15', 8000.00, 'Reporta� FOTO-VIDEO na weselu');

-- Dodanie szczeg��w do rezerwacji wedding
INSERT INTO reservation_details (reservation_id, type_id, details_id)
VALUES
(2, 1, 1);

-- Szczeg�y rezerwacji wedding
INSERT INTO details_wedding (groom_address, groom_prep_time, bride_address, bride_prep_time, ceremony_address, ceremony_time, church_entry_info, documments_signing_info, church_exit_info, compliments_info, wedding_hall_address, musical_band_info, additional_attractions)
VALUES
('ul. Kwiatowa 10, Warszawa', '09:00', 'ul. Weso�a 5, Warszawa', '10:30', 'Ko�ci� �w. Jana, Warszawa', '14:00', 'Wej�cie osobno. Pan m�ody czeka przy o�tarzu, a Pani m�oda wchodzi z tat�', 'Podpisanie dokument�w po ceremonii', 'Przy wyj�ciu pary m�odej z ko�cio�a b�dzie confetti', '�yczenia odb�d� si� na sali po obiedzie', 'Hotel Grand, ul. Pi�ciomorgowa 7, Warszawa', 'Zesp� muzyczny "Weselna Harmonia"', 'Pokaz sztucznych ogni po torcie oko�o godziny 22:00');

-- Rezerwacja chrztu dla klienta Marty
INSERT INTO reservation (client_id, service_id, status_id, date, price, other_info)
VALUES
(5, 1, 2, '2024-09-20', 1000.00, 'Ceremonia chrztu, fotografia w ko�ciele i w domu.');

-- Rezerwacja innego wydarzenia dla Krzysztofa
INSERT INTO reservation (client_id, service_id, status_id, date, price, other_info)
VALUES
(6, 1, 2, '2024-11-10', 1500.00, 'Uroczysto�� rodzinna, wymagane zdj�cia grupowe i portretowe.');

-- Rezerwacja, kt�ra zostanie anulowana dla Ewy
INSERT INTO reservation (client_id, service_id, status_id, date, price, other_info)
VALUES
(7, 2, 3, '2024-10-05', 1200.00, 'Sesja fotograficzna w parku miejskim, odwo�ana przez klienta.');

INSERT INTO details_baptism (church_address, home_address, ceremony_time)
VALUES
('Ko�ci� �w. Anny, Krak�w', 'ul. Lipowa 15, Krak�w', '12:00');

INSERT INTO reservation_details (reservation_id, type_id, details_id)
VALUES
(3, 3, 1);  -- Rezerwacja chrztu

INSERT INTO details_other (localisation, description)
VALUES
('Restauracja "Z�oty Smak", Pozna�', 'Rodzinne przyj�cie urodzinowe, zdj�cia przy stole i podczas przem�wie�.');

INSERT INTO reservation_details (reservation_id, type_id, details_id)
VALUES
(4, 4, 1);  -- Rezerwacja innego wydarzenia

INSERT INTO reservation_cancellation (res_id, cancelled_by, cancell_reason)
VALUES
(5, 7, 'Odwo�ujemy sesj� ze wzgl�du na zmian� plan�w.');