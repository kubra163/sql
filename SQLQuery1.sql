
USE master;
GO


IF EXISTS (SELECT * FROM sys.databases WHERE name = 'AYKOS')
BEGIN
    ALTER DATABASE AYKOS SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE AYKOS;
END
GO


CREATE DATABASE AYKOS;
GO

USE AYKOS;
GO


CREATE TABLE Roles (
    role_id INT PRIMARY KEY IDENTITY(1,1),
    role_name VARCHAR(50) NOT NULL
);

CREATE TABLE Users (
    user_id INT PRIMARY KEY IDENTITY(1,1),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100),
    role_id INT FOREIGN KEY REFERENCES Roles(role_id)
);

CREATE TABLE Aid_Categories (
    category_id INT PRIMARY KEY IDENTITY(1,1),
    category_name VARCHAR(100) NOT NULL,
    priority_level INT DEFAULT 1
);

CREATE TABLE Inventory_Items (
    item_id INT PRIMARY KEY IDENTITY(1,1),
    item_name VARCHAR(150) NOT NULL,
    category_id INT FOREIGN KEY REFERENCES Aid_Categories(category_id),
    unit_type VARCHAR(20)
);

CREATE TABLE Warehouses (
    warehouse_id INT PRIMARY KEY IDENTITY(1,1),
    warehouse_name VARCHAR(100),
    city VARCHAR(50),
    manager_id INT FOREIGN KEY REFERENCES Users(user_id)
);

CREATE TABLE Warehouse_Stock (
    stock_id INT PRIMARY KEY IDENTITY(1,1),
    warehouse_id INT FOREIGN KEY REFERENCES Warehouses(warehouse_id),
    item_id INT FOREIGN KEY REFERENCES Inventory_Items(item_id),
    quantity DECIMAL(10,2) DEFAULT 0,
    last_updated DATETIME DEFAULT GETDATE()
);

CREATE TABLE Victims (
    victim_id INT PRIMARY KEY IDENTITY(1,1),
    full_name VARCHAR(100),
    national_id VARCHAR(11),
    contact_number VARCHAR(20)
);

CREATE TABLE Requests (
    request_id INT PRIMARY KEY IDENTITY(1,1),
    victim_id INT FOREIGN KEY REFERENCES Victims(victim_id),
    request_date DATETIME DEFAULT GETDATE(),
    urgency_status VARCHAR(20),
    fulfillment_status VARCHAR(20) DEFAULT 'Bekliyor'
);

CREATE TABLE Request_Items (
    detail_id INT PRIMARY KEY IDENTITY(1,1),
    request_id INT FOREIGN KEY REFERENCES Requests(request_id),
    item_id INT FOREIGN KEY REFERENCES Inventory_Items(item_id),
    quantity_needed DECIMAL(10,2)
);

CREATE TABLE Vehicles (
    vehicle_id INT PRIMARY KEY IDENTITY(1,1),
    plate_number VARCHAR(20) UNIQUE,
    driver_name VARCHAR(100),
    is_active BIT DEFAULT 1
);

CREATE TABLE Shipments (
    shipment_id INT PRIMARY KEY IDENTITY(1,1),
    warehouse_id INT FOREIGN KEY REFERENCES Warehouses(warehouse_id),
    request_id INT FOREIGN KEY REFERENCES Requests(request_id),
    vehicle_id INT FOREIGN KEY REFERENCES Vehicles(vehicle_id),
    status VARCHAR(50) DEFAULT 'Hazýrlanýyor'
);

CREATE TABLE Volunteers (
    volunteer_id INT PRIMARY KEY IDENTITY(1,1),
    full_name VARCHAR(100),
    phone VARCHAR(20),
    city VARCHAR(50)
);

CREATE TABLE Skills (
    skill_id INT PRIMARY KEY IDENTITY(1,1),
    skill_name VARCHAR(50)
);

CREATE TABLE Volunteer_Assignments (
    assignment_id INT PRIMARY KEY IDENTITY(1,1),
    volunteer_id INT FOREIGN KEY REFERENCES Volunteers(volunteer_id),
    shipment_id INT FOREIGN KEY REFERENCES Shipments(shipment_id),
    skill_used_id INT FOREIGN KEY REFERENCES Skills(skill_id),
    assigned_date DATETIME DEFAULT GETDATE()
);
GO


INSERT INTO Roles (role_name) VALUES ('Yönetici'), ('Saha Personeli');

INSERT INTO Users (username, email, role_id) VALUES ('kubra_ybs', 'kubra@medipol.edu.tr', 1);

INSERT INTO Aid_Categories (category_name, priority_level) VALUES ('Gýda', 5), ('Barýnma', 5), ('Týbbi', 4);

INSERT INTO Inventory_Items (item_name, category_id, unit_type) 
VALUES ('Su 0.5L', 1, 'Adet'), ('Çadýr 4 Kiþilik', 2, 'Adet'), ('Aðrý Kesici', 3, 'Kutu');

INSERT INTO Warehouses (warehouse_name, city, manager_id) 
VALUES ('Ýstanbul Ana Lojistik', 'Ýstanbul', 1), ('Hatay Sahra Deposu', 'Hatay', 1);

INSERT INTO Warehouse_Stock (warehouse_id, item_id, quantity) 
VALUES (1, 1, 10000), (1, 2, 500), (2, 1, 2000);

INSERT INTO Victims (full_name, national_id, contact_number) 
VALUES ('Ahmet Afetzede', '11122233344', '05001112233');

INSERT INTO Requests (victim_id, urgency_status) VALUES (1, 'ACÝL');

INSERT INTO Request_Items (request_id, item_id, quantity_needed) VALUES (1, 2, 2); -- 2 çadýr talebi

INSERT INTO Vehicles (plate_number, driver_name) VALUES ('34 MED 34', 'Mehmet Kaptan');

INSERT INTO Shipments (warehouse_id, request_id, vehicle_id, status) VALUES (1, 1, 1, 'Yolda');
GO


SELECT 
    W.warehouse_name AS [Depo], 
    I.item_name AS [Ürün], 
    S.quantity AS [Mevcut Stok]
FROM Warehouse_Stock S
JOIN Warehouses W ON S.warehouse_id = W.warehouse_id
JOIN Inventory_Items I ON S.item_id = I.item_id;
GO