--CREATE DATABASE photoservice;

USE photoservice;

--Tabela u¿ytkowników
CREATE TABLE users (
	id_user INT PRIMARY KEY IDENTITY,
	f_name VARCHAR(50) NOT NULL,
	l_name VARCHAR(50) NOT NULL,
	phone_number VARCHAR(20) NOT NULL UNIQUE,
	email VARCHAR(50) NOT NULL UNIQUE,
	password_hash VARCHAR(255) NOT NULL,
	registration_date DATETIME DEFAULT CURRENT_TIMESTAMP,
	is_deleted BIT DEFAULT 0	-- 0 oznacza aktywnego u¿ytkownika, 1 usuniêtego
)

--Tabela obs³uguj¹ca przesy³anie wiadomoœci miêdzy u¿ytkownikami
CREATE TABLE messages (
	id_mess INT PRIMARY KEY IDENTITY,
	sender_id INT NOT NULL,
	recipient_id INT NOT NULL,
	mess_content VARCHAR(500),
	mess_date DATETIME DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (sender_id) REFERENCES users(id_user),
	FOREIGN KEY (recipient_id) REFERENCES users(id_user)
)

--Tabela zawieraj¹ca listê ról jakie mog¹ byœ przypisane do u¿ytkowników
CREATE TABLE roles (
	id_role	INT PRIMARY KEY IDENTITY,
	name VARCHAR(50) NOT NULL,
	description VARCHAR(255)
)

--Tabela przypisuj¹ca danea role do konkretnych u¿ytkowników (jeden u¿ytkownik mo¿e mieæ kilka ról)
CREATE TABLE user_role (
	id_ur INT PRIMARY KEY IDENTITY,
	user_id INT,
	role_id INT,
	FOREIGN KEY (user_id) REFERENCES users(id_user),
	FOREIGN KEY (role_id) REFERENCES roles(id_role)
)

--Tabela zawieraj¹ca listê dostêpnych statusów zlecenia(tabela reservation)
CREATE TABLE status (
	id_status INT PRIMARY KEY IDENTITY,
	name VARCHAR(50) NOT NULL,
	description VARCHAR(255)
)

--Tabela zawiera listê typów zleceñ (np: FOTO/VIDEO/FOTO-VIDEO)
CREATE TABLE service_type (
	id_service INT PRIMARY KEY IDENTITY,
	name VARCHAR(50) NOT NULL,
	description VARCHAR(255) 
)

--Tabela obs³uguj¹ca rezerwacjê us³ug
CREATE TABLE reservation (
	id_res INT PRIMARY KEY IDENTITY,
	client_id INT NOT NULL,
	service_id INT NOT NULL,
	status_id INT NOT NULL,
	date DATETIME NOT NULL,
	deadline DATE,
	finished_date DATE,
	price MONEY,
	other_info VARCHAR(2000),
	reservation_date DATETIME DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (client_id) REFERENCES users(id_user),
	FOREIGN KEY (service_id) REFERENCES service_type(id_service),
	FOREIGN KEY (status_id) REFERENCES status(id_status)
)

--Tabela przypisuj¹ca konkretnego pracownika do danego zlecenia (do jednego zlecenia mo¿na dodaæ kilku pracowników)
CREATE TABLE reservation_employee (
	id_res_emp INT PRIMARY KEY IDENTITY,
	reservation_id INT NOT NULL,
	employee_id INT NOT NULL,
	FOREIGN KEY (reservation_id) REFERENCES reservation(id_res),
	FOREIGN KEY (employee_id) REFERENCES users(id_user)
)

--Tabela z list¹ kategorii sprzêtu
CREATE TABLE equipment_type (
	id_eq_type INT PRIMARY KEY IDENTITY,
	name VARCHAR(50) NOT NULL,
	description VARCHAR(255)
)

--Tabela z list¹ producentów sprzêtu
CREATE TABLE equipment_manufacturer (
	id_eq_man INT PRIMARY KEY IDENTITY,
	name VARCHAR(50) NOT NULL,
	description VARCHAR(255)
)

--Tabela z list¹ sprzêtu firmy
CREATE TABLE equipment (
	id_eq INT PRIMARY KEY IDENTITY,
	name VARCHAR(50) NOT NULL,
	eq_type_id INT NOT NULL,
	eq_manufacturer_id INT NOT NULL,
	description VARCHAR(255),
	condition VARCHAR(255),
	working BIT DEFAULT 1,

	FOREIGN KEY (eq_type_id) REFERENCES equipment_type(id_eq_type),
	FOREIGN KEY (eq_manufacturer_id) REFERENCES equipment_manufacturer(id_eq_man)
)

--Tabela przechowuj¹ca informacjê, ze sprzêtem jakich firm jest kompatybilny dany przedmiot (np lampa b³yskowa firmy YANGNUO mo¿e byæ kompatybilna z aparatami Canon, Sony, itp, a obiektyw Tamron z aparatami Nikona)
CREATE TABLE equipment_compability (
	id_compability INT PRIMARY KEY IDENTITY,
	eq_id INT NOT NULL,
	man_id INT NOT NULL,

	FOREIGN KEY (eq_id) REFERENCES equipment(id_eq),
	FOREIGN KEY (man_id) REFERENCES equipment_manufacturer(id_eq_man)
)

--Tabela przypisuj¹ca listê sprzêtu do rezerwacji. Jedna rezerwacja mo¿e mieæ tylko jedn¹ listê rezerwacji
CREATE TABLE reservation_equipment (
	id_res_eq INT PRIMARY KEY IDENTITY,
	res_id INT NOT NULL,
	eq_id INT NOT NULL,

	FOREIGN KEY (res_id) REFERENCES reservation(id_res),
	FOREIGN KEY (eq_id) REFERENCES equipment(id_eq)
)


--Tabela z list¹ typów rezerwacji(wedding, photoshoot,itp.)
CREATE TABLE reservation_type (
	id_res_type INT PRIMARY KEY IDENTITY,
	name VARCHAR(50) NOT NULL,
	description VARCHAR(255)
)

--Tabela zawieraj¹ca datale zlecenia w przypadku wybrania typu wedding z reservation type
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

--Tabela zawieraj¹ca datale zlecenia w przypadku wybrania typu photoshoot z reservation type
CREATE TABLE details_photoshoot (
	id_det_ps INT PRIMARY KEY IDENTITY,
	localisation VARCHAR(255) NOT NULL,
	transport VARCHAR(255),
	num_of_participants INT NOT NULL
)

--Tabela zawieraj¹ca datale zlecenia w przypadku wybrania typu baptism z reservation type
CREATE TABLE details_baptism (
	id_det_bap INT PRIMARY KEY IDENTITY,
	church_address VARCHAR(255) NOT NULL,
	home_address VARCHAR(255),
	ceremony_time TIME NOT NULL
)

--Tabela zawieraj¹ca datale zlecenia w przypadku wybrania typu other z reservation type
CREATE TABLE details_other (
	id_det_oth INT PRIMARY KEY IDENTITY,
	localisation VARCHAR(255) NOT NULL,
	description VARCHAR(1000) NOT NULL
)

--Tabela zapisuj¹ca wybór typu zlecenia (œlub, sesja zdjêciowa,itp.) do konkretnej rezerwacji. 
CREATE TABLE reservation_details (
	id_res_det INT PRIMARY KEY IDENTITY,
	reservation_id INT NOT NULL,
	type_id INT NOT NULL,
	details_id INT, --Nie jest kluczem obcym, poniewa¿ rekord zostanie dopiero utworzony po wyborze typu. ID zostanie wpisane do komórki np za pomoca SCOPE_IDENTITY(), a kolizji miêdzy u¿ytkownikamiu mo¿na zapobiec u¿ywaj¹c tranzakcji.

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
