-- BUS 393-01 Final Project Script (Cristina Shaffer, Kyndall Banales, Klara Chang)
-- Drop table statements
DROP TABLE salesInvoice CASCADE CONSTRAINTS PURGE;
DROP TABLE purchaseOrder CASCADE CONSTRAINTS PURGE;
DROP TABLE seller CASCADE CONSTRAINTS PURGE;
DROP TABLE serviceIncluded CASCADE CONSTRAINTS PURGE;
DROP TABLE service CASCADE CONSTRAINTS PURGE;
DROP TABLE partInUse CASCADE CONSTRAINTS PURGE;
DROP TABLE part CASCADE CONSTRAINTS PURGE;
DROP TABLE serviceInvoice CASCADE CONSTRAINTS PURGE;
DROP TABLE preference CASCADE CONSTRAINTS PURGE;
DROP TABLE vehicle CASCADE CONSTRAINTS PURGE;
DROP TABLE employee CASCADE CONSTRAINTS PURGE;
DROP TABLE customer CASCADE CONSTRAINTS PURGE;
-- Create table statements
CREATE TABLE customer
(CustomerID    NUMBER(6)        CONSTRAINT cust_cid_pk PRIMARY KEY,
FirstName      VARCHAR2(30)     NOT NULL,
LastName       VARCHAR2(30)     NOT NULL,
StreetAddress  VARCHAR2(50)     NOT NULL,
City           VARCHAR2(30)     NOT NULL,
CState         CHAR(2)          DEFAULT 'CA' NOT NULL,
ZipCode        CHAR(5)          NOT NULL,
PhoneNumber    CHAR(12)         NOT NULL CONSTRAINT cust_pn_uk UNIQUE,
Email          VARCHAR2(30)     NOT NULL CONSTRAINT cust_em_uk UNIQUE,
CDate          DATE             NOT NULL
);
CREATE TABLE vehicle
(VIN           VARCHAR2(6)      CONSTRAINT veh_vid_pk PRIMARY KEY,
VYear          CHAR(4)          NOT NULL,
Make           VARCHAR2(30)     NOT NULL,
VModel         VARCHAR2(30)     NOT NULL,
ExteriorColor  VARCHAR2(20),
ListBasePrice  NUMBER(9,2)      CONSTRAINT veh_lp_ck CHECK(ListBasePrice >= 0),
VTrim          VARCHAR2(20),
Mileage        NUMBER(9)        NOT NULL,
VCondition     VARCHAR2(10),
Status         VARCHAR2(20),
VehicleType    CHAR(2)          NOT NULL,
CustomerID     NUMBER(6)        CONSTRAINT veh_cid_fk REFERENCES customer(CustomerID),
CONSTRAINT veh_vt_ck CHECK
 ((VehicleType = 'SV' AND ExteriorColor IS NULL AND ListBasePrice IS NULL
       AND VTrim IS NULL AND VCondition IS NULL AND Status IS NOT NULL)
 OR
 (VehicleType = 'FS' AND ExteriorColor IS NOT NULL AND ListBasePrice IS NOT NULL
      AND VTrim IS NOT NULL AND VCondition IS NOT NULL AND Status IS NOT NULL))
);
CREATE TABLE employee
(EmployeeID            NUMBER(4)        CONSTRAINT emp_eid_pk PRIMARY KEY,
FirstName              VARCHAR2(30)     NOT NULL,
LastName               VARCHAR2(30)     NOT NULL,
StreetAddress          VARCHAR2(50)     NOT NULL,
City                   VARCHAR2(30)     NOT NULL,
EState                 CHAR(2)          DEFAULT 'CA' NOT NULL,
ZipCode                CHAR(5)          NOT NULL,
PersonalPhoneNumber    CHAR(12)         NOT NULL CONSTRAINT emp_ppn_uk UNIQUE,
Email                  VARCHAR2(30)     NOT NULL CONSTRAINT emp_email_uk UNIQUE,
DateHired              DATE             DEFAULT SYSDATE NOT NULL,
Salary                 NUMBER(9,2)      NOT NULL CONSTRAINT emp_sal_ck CHECK (Salary >= 0),
EmployeeTitle          VARCHAR2(30)     NOT NULL,
EManager               CHAR(1),
SalesStaff             CHAR(1),
ServiceStaff           CHAR(1),
CommissionPct          NUMBER(2,2)      CONSTRAINT emp_compct_ck CHECK (CommissionPct BETWEEN .20 AND .30),
ManagerID              NUMBER(4)        CONSTRAINT emp_mgrid_fk REFERENCES employee(EmployeeID),
CONSTRAINT emp_eid_ck CHECK (EmployeeID BETWEEN 1000 AND 1999),
CONSTRAINT emp_type_ck CHECK
 ((EManager = 'Y' AND CommissionPct IS NOT NULL)
  OR
  (SalesStaff = 'Y' AND CommissionPct IS NOT NULL)
  OR
  (ServiceStaff = 'Y' AND CommissionPct IS NULL)
  OR
  (EManager = 'Y' AND SalesStaff = 'Y' AND CommissionPct IS NOT NULL)
  OR
  (EManager = 'Y' AND ServiceStaff = 'Y' AND CommissionPct IS NULL)
  OR
  (EManager IS NULL AND SalesStaff IS NULL AND ServiceStaff IS NULL AND CommissionPct IS NULL)
)
);
CREATE TABLE preference
( PreferenceID   NUMBER(6)      CONSTRAINT pref_pid_pk PRIMARY KEY,
Make            VARCHAR2(15)   NOT NULL,
Model           VARCHAR2(15)   NOT NULL,
Year            CHAR(4),
Description     VARCHAR2(30),
StartDate       DATE           DEFAULT SYSDATE NOT NULL,    
EndDate         DATE,
CustomerID      NUMBER(6)      NOT NULL CONSTRAINT pref_cid_fk
                               REFERENCES customer(CustomerID),
CONSTRAINT pref_start_end_ck CHECK (EndDate > StartDate)
);
CREATE TABLE serviceInvoice
(WorkOrderNumber   VARCHAR2(8)     CONSTRAINT si_won_pk PRIMARY KEY,
Description        VARCHAR2(100)   NOT NULL,
CustomerID         NUMBER(6)       NOT NULL CONSTRAINT si_cid_fk REFERENCES customer(CustomerID),
EmployeeID         NUMBER(4)       NOT NULL CONSTRAINT si_eid_fk REFERENCES employee(EmployeeID),
VIN                VARCHAR2(6)     NOT NULL CONSTRAINT si_vin_fk REFERENCES vehicle(VIN),
DateServiced       DATE,
Mileage            NUMBER(6)
);
CREATE TABLE part
(PartCode       VARCHAR2(20) CONSTRAINT part_pc_pk PRIMARY KEY,
Description     VARCHAR2(25) NOT NULL,
PCost           NUMBER(9,2)  NOT NULL CONSTRAINT part_cost_ck CHECK (PCost >= 0),
Price           NUMBER(9,2)  NOT NULL CONSTRAINT part_price_ck CHECK (Price >=0)
);
CREATE TABLE partInUse
(WorkOrderNumber   VARCHAR2(8)     CONSTRAINT piu_won_fk
                                  REFERENCES serviceInvoice(WorkOrderNumber),
PartCode           VARCHAR2(20)    CONSTRAINT piu_pc_fk REFERENCES part(PartCode),
CONSTRAINT piu_wonpc_pk PRIMARY KEY(WorkOrderNumber, PartCode)
);
CREATE TABLE service
(ServiceCode      VARCHAR2(20)    CONSTRAINT serv_sc_pk PRIMARY KEY,
Description       VARCHAR(150)    NOT NULL,
Price             NUMBER(9,2)     NOT NULL CONSTRAINT serv_p_ck CHECK (Price >= 0),
Cost              NUMBER(9,2)     NOT NULL CONSTRAINT serv_c_ck CHECK (Cost >= 0),
Months            NUMBER(2),
Mileage           NUMBER(9,2)
);
CREATE TABLE serviceIncluded
(WorkOrderNumber   VARCHAR2(8)     CONSTRAINT si_won_fk REFERENCES serviceInvoice(WorkOrderNumber),
ServiceCode        VARCHAR2(20)    CONSTRAINT si_sc_fk REFERENCES service(ServiceCode),
CONSTRAINT si_wonsc_pk PRIMARY KEY(WorkOrderNumber, ServiceCode)
);
CREATE TABLE seller
(SellerID      NUMBER(6)       CONSTRAINT seller_sid_pk PRIMARY KEY,
CompanyName    VARCHAR2(30),
ContactName    VARCHAR2(30)    NOT NULL,
StreetAddress  VARCHAR2(50)    NOT NULL,
City           VARCHAR2(30)    NOT NULL,
SState         CHAR(2)         NOT NULL,
ZipCode        CHAR(5)         NOT NULL,
PhoneNumber    CHAR(12)        NOT NULL,
FaxNumber      VARCHAR2(12)    CONSTRAINT seller_fax_uk UNIQUE
);
CREATE TABLE salesInvoice
(SalesInvoiceNumber    NUMBER(5)       CONSTRAINT salesinv_sin_pk PRIMARY KEY,
SellingPrice           NUMBER(9,2)     NOT NULL CONSTRAINT salesinv_si_ck CHECK(SellingPrice >=0),
PaymentTerms           VARCHAR2(10)    NOT NULL,
EmployeeID             NUMBER(4)       NOT NULL CONSTRAINT salesinv_eid_fk REFERENCES employee(EmployeeID),
VIN                    VARCHAR2(6)     CONSTRAINT salesinv_vin_uk_fk REFERENCES vehicle(VIN) UNIQUE,
CustomerID             NUMBER(6)       NOT NULL CONSTRAINT salesinv_cid_fk REFERENCES customer(CustomerID),
ManagerID              NUMBER(4)       CONSTRAINT salesinv_mid_fk REFERENCES employee(EmployeeID),
DateSold               DATE,
VINTI                  VARCHAR2(6)     CONSTRAINT salesinv_vinti_fk REFERENCES vehicle(VIN)
);
CREATE TABLE purchaseOrder
(PONumber              VARCHAR2(6)     CONSTRAINT po_pon_pk PRIMARY KEY,
OrderType              VARCHAR2(10)    NOT NULL,
PurchasePrice          NUMBER(9,2)     NOT NULL CONSTRAINT po_pp_ck CHECK(PurchasePrice >= 0),
SellerID               NUMBER(6)       NOT NULL CONSTRAINT po_sid_fk REFERENCES seller(SellerID),
VIN                    VARCHAR2(6)     NOT NULL CONSTRAINT po_vin_uk_fk REFERENCES vehicle(VIN) UNIQUE,
EmployeeID             NUMBER(4)       NOT NULL CONSTRAINT po_eid_fk REFERENCES employee(EmployeeID),
ManagerID              NUMBER(4)       CONSTRAINT po_mid_fk REFERENCES employee(EmployeeID)
);
-- Memo 1: insert statements for customer
INSERT INTO customer (CustomerID, FirstName, LastName, StreetAddress, City, ZipCode, PhoneNumber, Email, CDate)
VALUES (100001, 'John', 'Smith', '1 Santa Rosa', 'San Luis Obispo', '93405', '800-333-3333', 'jsmith@hotmail.com', '10/25/2020');
INSERT INTO customer (CustomerID, FirstName, LastName, StreetAddress, City, ZipCode, PhoneNumber, Email, CDate)
VALUES (100002, 'J', 'McNamara', '1 Grand Ave', 'San Luis Obispo', '93405', '818-555-5555', 'jmcnamarah@hotmail.com', '05/01/2020');
INSERT INTO customer (CustomerID, FirstName, LastName, StreetAddress, City, ZipCode, PhoneNumber, Email, CDate)
VALUES (100003, 'Bill', 'George', '100 Venice Boulevard', 'Los Angeles', '91323', '310-123-4567', 'bgeorge@hotmail.com', '11/22/2019');
INSERT INTO customer (CustomerID, FirstName, LastName, StreetAddress, City, ZipCode, PhoneNumber, Email, CDate)
VALUES (100004, 'Ian', 'Thomas', '56 Monterey Street', 'Monterey', '90522', '510-321-7654', 'ithomas@hotmail.com', '02/14/2020');
INSERT INTO customer (CustomerID, FirstName, LastName, StreetAddress, City, ZipCode, PhoneNumber, Email, CDate)
VALUES (100005, 'Hank', 'Franklin', '1 Foothill BLVD', 'San Luis Obispo', '93405', '818-989-9090', 'hfrank@it.com', '07/04/2020');
INSERT INTO customer (CustomerID, FirstName, LastName, StreetAddress, City, CState, ZipCode, PhoneNumber, Email, CDate)
VALUES (100006, 'Adam', 'Sandler', '1234 Hollywood', 'Los Angeles', 'SD', '56789', '253-699-4200', 'uncutgems@me.com', '11/11/2020');
INSERT INTO customer (CustomerID, FirstName, LastName, StreetAddress, City, CState, ZipCode, PhoneNumber, Email, CDate)
VALUES (100007, 'Jennifer', 'Marks', '919 Palm Street', 'Seattle', 'WA', '93401', '800-444-4444', 'jmarks@hotmail.com', '11/26/2020');
INSERT INTO customer (CustomerID, FirstName, LastName, StreetAddress, City, CState, ZipCode, PhoneNumber, Email, CDate)
VALUES (100008, 'Lori', 'Lanes', '7 Santa Rosa', 'New York City', 'NY', '78940', '800-222-2222', 'Llanes@hotmail.com', '5/30/2020');
INSERT INTO customer (CustomerID, FirstName, LastName, StreetAddress, City, CState, ZipCode, PhoneNumber, Email, CDate)
VALUES (100009, 'Lannie', 'Jones', '2 Lemon St', 'Detroit', 'MI', '93402', '800-999-9999', 'Ljones@hotmail.com', '8/23/2020');
INSERT INTO customer (CustomerID, FirstName, LastName, StreetAddress, City, CState, ZipCode, PhoneNumber, Email, CDate)
VALUES (100010, 'Robert', 'Kane', '5 Cambridge Lane', 'Orlando', 'FL', '93378', '800-222-3333', 'Rkane@hotmail.com', '5/12/2020');
-- Memo 1: insert statements for preference
INSERT INTO preference (PreferenceID, Make, Model, Year, Description, EndDate, CustomerID)
VALUES (200001, 'Fiat', 'X19', '1995', 'Green, with tinted sun roof', NULL, 100001);
INSERT INTO preference (PreferenceID, Make, Model, Year, Description, StartDate, EndDate, CustomerID)
VALUES (200002, 'Toyota', 'Tundra', '2000', 'Black, covered bed', '12/01/2000', '11/06/2001', 100001);
INSERT INTO preference (PreferenceID, Make, Model, Year, Description, StartDate, EndDate, CustomerID)
VALUES (200003, 'Porsche', 'Cayenne', '2000', 'Bright red, 4 wheel drive', '12/05/2001', '12/11/2026', 100001);
INSERT INTO preference (PreferenceID, Make, Model, Year, Description, EndDate, CustomerID)
VALUES (200004, 'Mazda', 'RX7', '1996', 'Green, with tinted sun roof', NULL, 100002);
INSERT INTO preference (PreferenceID, Make, Model, Year, Description, EndDate, CustomerID)
VALUES (200005, 'Fiat', 'X19', '2018','White, with ski rack', NULL, 100003);
INSERT INTO preference (PreferenceID, Make, Model, Year, Description, StartDate, EndDate, CustomerID)
VALUES (200006, 'Fiat', 'X19', '2018', 'White, with tinted sun roof', '08/03/2020', NULL, 100004);
INSERT INTO preference (PreferenceID, Make, Model, Year, Description, StartDate, EndDate, CustomerID)
VALUES (200007, 'Mazda', 'RX7', '2017', 'Red', '03/01/2018', '08/12/2020', 100004);
INSERT INTO preference (PreferenceID, Make, Model, Year, Description, StartDate, EndDate, CustomerID)
VALUES (200008, 'Fiat', '128', '2019','White, with black upholstery', '04/12/2019', '02/04/2020', 100005);
--Memo 1: queries for customer and preference
CREATE OR REPLACE VIEW ViewCust
AS SELECT FirstName, LastName, StreetAddress, City, CState, ZipCode, PhoneNumber, Email
FROM customer
ORDER BY LastName;
CREATE OR REPLACE VIEW CustPref
AS SELECT c.FirstName, c.LastName, c.PhoneNumber, p.Make, p.Model, p.StartDate, p.EndDate
FROM customer c JOIN preference p
ON (c.customerID = p.customerID);
CREATE OR REPLACE VIEW AllCustPref
AS SELECT c.FirstName, c.LastName, c.PhoneNumber, NVL(p.Make, 'No Preference') Make, p.Model, p.StartDate, p.EndDate
FROM customer c LEFT OUTER JOIN preference p
ON (c.customerID = p.customerID);
--MEMO 2 insert statements for employee
INSERT INTO employee (EmployeeID, FirstName, LastName, StreetAddress, City, ZipCode, PersonalPhoneNumber, Email, DateHired, Salary, EmployeeTitle, EManager, CommissionPct)
VALUES (1000, 'Larry', 'Margaria', '1234 Longview Lane', 'Avila Beach', '93455', '987-684-9835', 'lmargaria@josecuervo.com', '01/01/1975', 90000, 'Owner/Manager', 'Y', 0.30);
INSERT INTO employee (EmployeeID, FirstName, LastName, StreetAddress, City, ZipCode, PersonalPhoneNumber, Email, DateHired, Salary, EmployeeTitle, EManager, ManagerID)
VALUES (1001, 'Jim', 'Kaney', '23 Leff Street', 'Atascadero', '98566', '674-735-8626', 'jkaney@hotmail.com', '01/01/2000', 85000, 'Accounting Manager', 'Y', 1000);
INSERT INTO employee (EmployeeID, FirstName, LastName, StreetAddress, City, ZipCode, PersonalPhoneNumber, Email, DateHired, Salary, EmployeeTitle, EManager, ServiceStaff, ManagerID)
VALUES (1002, 'Norm', 'Allen', '24 Albert Street', 'Nipomo', '96482', '373-524-7353', 'norm@allen.me', '01/01/2012', 64500, 'Service Manager', 'Y', 'Y', 1000);
INSERT INTO employee (EmployeeID, FirstName, LastName, StreetAddress, City, ZipCode, PersonalPhoneNumber, Email, DateHired, Salary, EmployeeTitle, EManager, SalesStaff, CommissionPct, ManagerID)
VALUES (1003, 'Mary', 'Long', '24 Orange Lane', 'Morro Bay', '93465', '543-543-7521', 'mlong@hotmail.com', '04/20/2008' , 74678, 'Sales Manager', 'Y', 'Y', 0.25, 1000);
INSERT INTO employee (EmployeeID, FirstName, LastName, StreetAddress, City, ZipCode, PersonalPhoneNumber, Email, Salary, EmployeeTitle, ManagerID)
VALUES (1004, 'Steve', 'Euro', '123 Main Street', 'Sacramento', '91234', '825-337-2837', 'seuro@hotmail.com', 40000, 'Cashier', 1001);
INSERT INTO employee (EmployeeID, FirstName, LastName, StreetAddress, City, EState, ZipCode, PersonalPhoneNumber, Email, DateHired, Salary, EmployeeTitle, ManagerID)
VALUES (1005, 'Alice', 'Credit', '29 Islay Lane', 'Seattle', 'WA', '62990', '920-078-1122', 'acredit@hotmail.com', '02/11/2001', 40000, 'Bookkeeper', 1001);
INSERT INTO employee (EmployeeID, FirstName, LastName, StreetAddress, City, EState, ZipCode, PersonalPhoneNumber, Email, DateHired, Salary, EmployeeTitle, ServiceStaff, ManagerID)
VALUES (1006, 'Alan', 'Wrench', '7253 West Avenue', 'Portland', 'OR', '77723', '723-223-1010', 'awrench@hotmail.com', '10/10/2009', 50000, 'Service Worker', 'Y', 1002);
INSERT INTO employee (EmployeeID, FirstName, LastName, StreetAddress, City, EState, ZipCode, PersonalPhoneNumber, Email, DateHired, Salary, EmployeeTitle, ServiceStaff, ManagerID)
VALUES (1007, 'Woody', 'Apple', '1 Apple Road', 'Phoenix', 'AZ', '52431', '804-123-6879', 'wapple@hotmail.com', '09/24/2016', 50000, 'Service Worker', 'Y', 1002);
INSERT INTO employee (EmployeeID, FirstName, LastName, StreetAddress, City, EState, ZipCode, PersonalPhoneNumber, Email, DateHired, Salary, EmployeeTitle, ServiceStaff, ManagerID)
VALUES (1008, 'Sherry', 'Sophomore', '145 Bark Street', 'Elk Grove', 'CA', '95758', '916-683-2621','ssophmore@gmail.com', '02/08/2000', 5000, 'Cal Poly Intern', 'Y', 1007);
INSERT INTO employee (EmployeeID, FirstName, LastName, StreetAddress, City, EState, ZipCode, PersonalPhoneNumber, Email, Salary, EmployeeTitle, SalesStaff, CommissionPct, ManagerID)
VALUES (1009, 'Adam', 'Pecker', '546 Strawberry Lane', 'San Luis Obispo', 'CA', '93401', '805-934-2432', 'apecker@gmail.com', 55000, 'Salesperson', 'Y', 0.22, 1003);
INSERT INTO employee (EmployeeID, FirstName, LastName, StreetAddress, City, EState, ZipCode, PersonalPhoneNumber, Email, Salary, EmployeeTitle, SalesStaff, CommissionPct, ManagerID)
VALUES (1010, 'Larry', 'Jones', '856 Arena Blvd', 'Los Angeles', 'CA', '96748', '607-456-3847', 'ljones@yahoo.com', 55000, 'Salesperson', 'Y', 0.24, 1003);
--MEMO 2: queries for employee
CREATE OR REPLACE VIEW EmpContact
AS SELECT FirstName, LastName, PersonalPhoneNumber, Email
FROM employee
ORDER BY LastName;
CREATE OR REPLACE VIEW EmpReportList
AS SELECT mgr.FirstName || ' ' || mgr.LastName ManagerName, mgr.EmployeeTitle ManagerTitle, emp.FirstName || ' ' || emp.LastName EmployeeName, emp.EmployeeTitle EmployeeTitle
FROM employee emp JOIN employee mgr
ON (emp.managerID = mgr.employeeID)
WHERE emp.managerID IS NOT NULL
ORDER BY mgr.LastName ASC;
-- MEMO 3: insert statements for Service
INSERT INTO service (ServiceCode, Description, Cost, Price, Months, Mileage)
VALUES ('OILCHG', 'Oil Change', 9.95, 10.95, 6, 6000);
INSERT INTO service (ServiceCode, Description, Cost, Price, Months, Mileage)
VALUES ('TIREROTATE', 'Tire Rotation', 6.95, 9.95, 12, 12000);
INSERT INTO service (ServiceCode, Description, Cost, Price, Months, Mileage)
VALUES ('FLUIDS', 'Fluid Replacement', 29.95, 49.96, 30, 30000);
INSERT INTO service (ServiceCode, Description, Cost, Price, Months, Mileage)
VALUES ('TUNEUPBASIC', 'Basic engine tune up', 69.95, 149.95, 18, 18000);
INSERT INTO service (ServiceCode, Description, Cost, Price, Months, Mileage)
VALUES ('MULTIPOINTINSP', 'Multi-Point Inspection', 29.95, 59.95, 6, 6000);
INSERT INTO service (ServiceCode, Description, Cost, Price, Months, Mileage)
VALUES ('AIRFILTER', 'Air Filter Replacement', 4.95, 14.95, 6, 6000);
INSERT INTO service (ServiceCode, Description, Cost, Price, Months, Mileage)
VALUES ('BRAKEREPLACE', 'Brake Replacement', 299.95, 499.95, 20, 20000);
INSERT INTO service (ServiceCode, Description, Cost, Price, Months, Mileage)
VALUES ('WINDSHLDREP', 'Windshield Replacement', 14.95, 20.95, 36, 36000 );
-- MEMO 3: insert statements for Part
INSERT INTO part (PartCode, Description, PCost, Price)
VALUES ('OIL10W30', 'Oil 10W30', 2.79, 3.95);
INSERT INTO part (PartCode, Description, PCost, Price)
VALUES ('OILFILTER', 'Oil Filter', 6.95, 11.95);
INSERT INTO part (PartCode, Description, PCost, Price)
VALUES ('WINSHIELDFLUID', 'Windshield Fluid', 2.96, 4.95);
INSERT INTO part (PartCode, Description, PCost, Price)
VALUES ('SPARKPLUG4', 'Spark Plug Set (4)', 9.95, 19.95);
INSERT INTO part (PartCode, Description, PCost, Price)
VALUES ('AIRFILTER', 'Air Filter', 3.95, 8.95);
INSERT INTO part (PartCode, Description, PCost, Price)
VALUES ('BATTERY', 'Battery', 190.95, 220.95);
INSERT INTO part (PartCode, Description, PCost, Price)
VALUES ('WINDSHIELD', 'Windshield', 19.95, 29.95);
INSERT INTO part (PartCode, Description, PCost, Price)
VALUES ('MUFFLER', 'Muffler', 49.95, 59.95);
-- MEMO 3: queries for service and part
CREATE OR REPLACE VIEW ViewServ
AS SELECT ServiceCode, Description, Cost, Price, Months, Mileage
FROM service
ORDER BY ServiceCode ASC;
CREATE OR REPLACE VIEW ViewPart
AS SELECT PartCode, Description, PCost, Price
FROM part
ORDER BY PartCode ASC;
-- MEMO 4: insert statements for sales vehicle and service vehicle
INSERT INTO vehicle (VIN, VYear, Make, VModel, ExteriorColor, ListBasePrice, VTrim, Mileage, VCondition, Status, VehicleType, CustomerID)
VALUES ('V10001', '1995', 'Fiat', 'X19', 'Green', 25000, 'Beige', 10000, 'Good', 'TRADEIN', 'FS', 100001);
INSERT INTO vehicle (VIN, VYear, Make, VModel, ExteriorColor, ListBasePrice, VTrim, Mileage, VCondition, Status, VehicleType, CustomerID)
VALUES ('V10002', '2000', 'Toyota', 'Tundra', 'Black', 40000, 'Black', 10000, 'Good', 'TRADEIN', 'FS', 100005);
INSERT INTO vehicle (VIN, VYear, Make, VModel, Mileage, Status, VehicleType)
VALUES ('V10003', '2000', 'Porsche', 'Cayenne', 20000, 'SERVICE', 'SV');
INSERT INTO vehicle (VIN, VYear, Make, VModel, ExteriorColor, ListBasePrice, VTrim, Mileage, VCondition, Status, VehicleType, CustomerID)
VALUES ('V10004', '1996', 'Mazda', 'RX7', 'Green', 12000, 'Beige', 100000, 'Old', 'TRADEIN', 'FS', 100002);
INSERT INTO vehicle (VIN, VYear, Make, VModel, ExteriorColor, ListBasePrice, VTrim, Mileage, VCondition, Status, VehicleType)
VALUES ('V10005', '2018', 'Fiat', 'X19', 'White', 50000, 'White', 0, 'FORSALE', 'FORSALE', 'FS');
INSERT INTO vehicle (VIN, VYear, Make, VModel, Mileage, Status, VehicleType)
VALUES ('V10006', '2017', 'Mazda', 'RX7', 40000,'SERVICE', 'SV');
INSERT INTO vehicle (VIN, VYear, Make, VModel, ExteriorColor, ListBasePrice, VTrim, Mileage, VCondition, Status, VehicleType, CustomerID)
VALUES ('V10007', '2019', 'Fiat', '128', 'White', 30000, 'Black', 10000, 'Good', 'TRADEIN', 'FS', 100003);
INSERT INTO vehicle (VIN, VYear, Make, VModel, ExteriorColor, ListBasePrice, VTrim, Mileage, VCondition, Status, VehicleType, CustomerID)
VALUES ('L46524', '1981', 'Lancia', '2 door', 'Aurora White', 15000, 'Beige Vinyl', 37000, 'Excellent', 'TRADEIN', 'FS', 100004);
INSERT INTO vehicle (VIN, VYear, Make, VModel, ExteriorColor, ListBasePrice, VTrim, Mileage, VCondition, Status, VehicleType)
VALUES ('VX1113', '2016', 'Porsche', '911 Carrera', 'Metallic Blackf', 89400, 'Shadow Grey', 0, 'FORSALE', 'FORSALE', 'FS');
-- MEMO 5: insert statements for seller
INSERT INTO seller (SellerID, CompanyName, ContactName, StreetAddress, City, SState, ZipCode, PhoneNumber, FaxNumber)
VALUES (300001, 'Carmax', 'Carrie Smith', '35 Broad Street', 'San Luis Obispo', 'CA', '93401', '805-222-2345', '805-222-2346');
INSERT INTO seller (SellerID, CompanyName, ContactName, StreetAddress, City, SState, ZipCode, PhoneNumber, FaxNumber)
VALUES (300002, 'Enterprise', 'Jennifer Creek', '1450 Nipomo Street', 'Nipomo', 'CA', '93407', '818-243-9999', '818-243-9990');
INSERT INTO seller (SellerID, CompanyName, ContactName, StreetAddress, City, SState, ZipCode, PhoneNumber, FaxNumber)
VALUES (300003, 'Hertz', 'Harry Styles', '120 London Lane', 'San Francisco', 'CA', '92310', '920-098-6453', '920-098-6542');
INSERT INTO seller (SellerID, CompanyName, ContactName, StreetAddress, City, SState, ZipCode, PhoneNumber, FaxNumber)
VALUES (300004, 'Budget', 'Brad Jones', '884 Lindwood Drive', 'Seattle', 'WA', '98423', '775-094-1123', '775-094-1124');
INSERT INTO seller (SellerID, CompanyName, ContactName, StreetAddress, City, SState, ZipCode, PhoneNumber, FaxNumber)
VALUES (300005, 'Cars.com', 'Bradley Miller', '346 Main Street', 'Portland', 'OR', '55732', '310-112-2223', '301-112-2224');
INSERT INTO seller (SellerID, CompanyName, ContactName, StreetAddress, City, SState, ZipCode, PhoneNumber, FaxNumber)
VALUES (300006, 'LAX Porsche', 'Alan Jones', '112 Airport Drive', 'Los Angeles', 'CA', '93111', '800-555-1123', '800-555-4211');
INSERT INTO seller (SellerID, CompanyName, ContactName, StreetAddress, City, SState, ZipCode, PhoneNumber, FaxNumber)
VALUES (300007, 'Lancia Motors', 'Bill Smith', '1500 Lizzie Street', 'Los Angeles', 'CA', '93111', '800-333-3333', '800-333-3334');
INSERT INTO seller (SellerID, ContactName, StreetAddress, City, SState, ZipCode, PhoneNumber)
SELECT CustomerID, FirstName || ' ' || LastName, StreetAddress, City, CState, ZipCode, PhoneNumber
FROM customer;
-- MEMO 5: insert statements for purchase order
INSERT INTO purchaseOrder (PONumber, OrderType, PurchasePrice, SellerID, VIN, EmployeeID)
VALUES('LX1234', 'FORSALE', 89400, 300006, 'VX1113', 1000);
INSERT INTO purchaseOrder (PONumber, OrderType, PurchasePrice, SellerID, VIN, EmployeeID)
VALUES('CK3751', 'TRADEIN', 15000, 100004, 'L46524', 1000);
INSERT INTO purchaseOrder (PONumber, OrderType, PurchasePrice, SellerID, VIN, EmployeeID, ManagerID)
VALUES('DF2190', 'FORSALE', 50000, 300005, 'V10005', 1003, 1000);
INSERT INTO purchaseOrder (PONumber, OrderType, PurchasePrice, SellerID, VIN, EmployeeID, ManagerID)
VALUES('QW5784', 'TRADEIN', 30000, 100003, 'V10007', 1009, 1003);
INSERT INTO purchaseOrder (PONumber, OrderType, PurchasePrice, SellerID, VIN, EmployeeID, ManagerID)
VALUES('RT5555', 'TRADEIN', 25000, 100005, 'V10002', 1009, 1003);
INSERT INTO purchaseOrder (PONumber, OrderType, PurchasePrice, SellerID, VIN, EmployeeID, ManagerID)
VALUES('TY9867', 'TRADEIN', 25000, 100001, 'V10001', 1003, 1000);
INSERT INTO purchaseOrder (PONumber, OrderType, PurchasePrice, SellerID, VIN, EmployeeID, ManagerID)
VALUES('DS7777', 'TRADEIN', 12000, 100002, 'V10004', 1003, 1000);
-- MEMO 5: selling a car
INSERT INTO salesInvoice (SalesInvoiceNumber, SellingPrice, PaymentTerms, EmployeeID, VIN, CustomerID, ManagerID, DateSold, VINTI)
VALUES ('44444', 15000, 'Cash', 1009, 'L46524', 100001, 1003, '03/11/2020', 'V10001');
INSERT INTO salesInvoice (SalesInvoiceNumber, SellingPrice, PaymentTerms, EmployeeID, VIN, CustomerID, ManagerID, DateSold, VINTI)
VALUES ('22222', 25000, 'Credit', 1010, 'V10001', 100002, 1003, '03/24/2020', 'V10004');
INSERT INTO salesInvoice (SalesInvoiceNumber, SellingPrice, PaymentTerms, EmployeeID, VIN, CustomerID, ManagerID, DateSold)
VALUES ('22223', 40000, 'Debit', 1003, 'V10002', 100002, 1000, '02/14/2020');
INSERT INTO salesInvoice (SalesInvoiceNumber, SellingPrice, PaymentTerms, EmployeeID, VIN, CustomerID, ManagerID, DateSold, VINTI)
VALUES ('13245', 50000, 'Cash', 1003, 'V10005', 100003, 1000, '12/31/2020', 'V10007');
INSERT INTO salesInvoice (SalesInvoiceNumber, SellingPrice, PaymentTerms, EmployeeID, VIN, CustomerID, ManagerID, DateSold)
VALUES ('22224', 89400, 'Credit', 1003, 'VX1113', 100002, 1000, '06/17/2019');
UPDATE salesInvoice
SET ManagerID = 1000
WHERE ManagerID <> 1000;
UPDATE vehicle
SET Status = 'SOLD'
WHERE Status = 'FORSALE';
UPDATE vehicle
SET Status = 'FORSALE'
WHERE Status = 'TRADEIN';
-- MEMO 4: queries for vehicle
CREATE OR REPLACE VIEW VehicleList
AS SELECT VIN, VYear, Make, VModel, ExteriorColor, VTrim, Mileage, VCondition, Status, ListBasePrice
FROM vehicle
ORDER BY Make ASC, VModel ASC;
CREATE OR REPLACE VIEW ForSaleList
AS SELECT VIN, VYear, Make, VModel, ExteriorColor, VTrim, Mileage, VCondition, Status, ListBasePrice
FROM vehicle
WHERE VehicleType = 'FS'
ORDER BY Make ASC, VModel ASC;
CREATE OR REPLACE VIEW SoldList
AS SELECT VIN, VYear, Make, VModel, Mileage, VCondition, ListBasePrice
FROM vehicle
WHERE Status = 'SOLD';
CREATE OR REPLACE VIEW InvValue
AS SELECT SUM(ListBasePrice) "Sum of ListBasePrice"
FROM vehicle
WHERE VehicleType = 'FS';
CREATE OR REPLACE VIEW InvValueByMake
AS SELECT Make, SUM(ListBasePrice) "Sum of ListBasePrice"
FROM vehicle
WHERE VehicleType = 'FS'
GROUP BY Make
ORDER BY Make;
-- MEMO 5: servicing a car
INSERT INTO serviceInvoice (WorkOrderNumber, Description, CustomerID, EmployeeID, VIN, DateServiced, Mileage)
VALUES ('SV-55555', 'Oil Change with Oil and Oil Filter', 100002, 1002, 'V10004', '02/13/2019', 100000);
INSERT INTO serviceIncluded (WorkOrderNumber, ServiceCode)
VALUES ('SV-55555', 'OILCHG');
INSERT INTO partInUse (WorkOrderNumber, PartCode)
VALUES ('SV-55555', 'OIL10W30');
INSERT INTO partInUse (WorkOrderNumber, PartCode)
VALUES ('SV-55555', 'OILFILTER');
INSERT INTO serviceInvoice (WorkOrderNumber, Description, CustomerID, EmployeeID, VIN, DateServiced, Mileage)
VALUES ('SV-56789', 'Tire Rotation with Battery Replacement and Air Filter', 100002, 1002, 'V10001', '04/28/2020', 10000);
INSERT INTO serviceIncluded (WorkOrderNumber, ServiceCode)
VALUES ('SV-56789', 'TIREROTATE');
INSERT INTO partInUse (WorkOrderNumber, PartCode)
VALUES ('SV-56789', 'BATTERY');
INSERT INTO partInUse (WorkOrderNumber, PartCode)
VALUES ('SV-56789', 'AIRFILTER');
INSERT INTO serviceInvoice (WorkOrderNumber, Description, CustomerID, EmployeeID, VIN, DateServiced, Mileage)
VALUES ('SV-47474', 'Tune Up Basic and Multi-Point Inspection with a Muffler', 100003, 1006, 'V10007', '03/29/2020', 10000);
INSERT INTO serviceIncluded (WorkOrderNumber, ServiceCode)
VALUES ('SV-47474', 'TUNEUPBASIC');
INSERT INTO serviceIncluded (WorkOrderNumber, ServiceCode)
VALUES ('SV-47474', 'MULTIPOINTINSP');
INSERT INTO partInUse (WorkOrderNumber, PartCode)
VALUES ('SV-47474', 'MUFFLER');
INSERT INTO serviceInvoice (WorkOrderNumber, Description, CustomerID, EmployeeID, VIN, DateServiced)
VALUES ('SV-54321', 'Oil Change with Oil and Oil Filter', 100003, 1002, 'V10007', '11/13/2019');
INSERT INTO serviceIncluded (WorkOrderNumber, ServiceCode)
VALUES ('SV-54321', 'OILCHG');
INSERT INTO partInUse (WorkOrderNumber, PartCode)
VALUES ('SV-54321', 'OIL10W30');
INSERT INTO partInUse (WorkOrderNumber, PartCode)
VALUES ('SV-54321', 'OILFILTER');
INSERT INTO serviceInvoice (WorkOrderNumber, Description, CustomerID, EmployeeID, VIN, DateServiced)
VALUES ('SV-82736', 'Tune Up Basic and Multi-Point Inspection with a Muffler', 100002, 1006, 'V10004', '05/18/2020');
INSERT INTO serviceIncluded (WorkOrderNumber, ServiceCode)
VALUES ('SV-82736', 'TUNEUPBASIC');
INSERT INTO serviceIncluded (WorkOrderNumber, ServiceCode)
VALUES ('SV-82736', 'MULTIPOINTINSP');
INSERT INTO partInUse (WorkOrderNumber, PartCode)
VALUES ('SV-82736', 'MUFFLER');
INSERT INTO serviceInvoice (WorkOrderNumber, Description, CustomerID, EmployeeID, VIN, DateServiced)
VALUES ('SV-90876', 'Oil Change with Oil and Oil Filter', 100003, 1002, 'V10007', '09/17/2020');
INSERT INTO serviceIncluded (WorkOrderNumber, ServiceCode)
VALUES ('SV-90876', 'OILCHG');
INSERT INTO partInUse (WorkOrderNumber, PartCode)
VALUES ('SV-90876', 'OIL10W30');
INSERT INTO partInUse (WorkOrderNumber, PartCode)
VALUES ('SV-90876', 'OILFILTER');
INSERT INTO serviceInvoice (WorkOrderNumber, Description, CustomerID, EmployeeID, VIN, DateServiced)
VALUES ('SV-13243', 'Fluid Replacement with Windshield Fluid and Air Filter', 100005, 1006, 'V10002', '07/17/2019');
INSERT INTO serviceIncluded (WorkOrderNumber, ServiceCode)
VALUES ('SV-13243', 'FLUIDS');
INSERT INTO partInUse (WorkOrderNumber, PartCode)
VALUES ('SV-13243', 'WINSHIELDFLUID');
INSERT INTO partInUse (WorkOrderNumber, PartCode)
VALUES ('SV-13243', 'AIRFILTER');
INSERT INTO serviceInvoice (WorkOrderNumber, Description, CustomerID, EmployeeID, VIN, DateServiced)
VALUES ('SV-60001', 'Tire Rotation with Battery Replacement and Air Filter', 100002, 1002, 'V10005', '04/16/2020');
INSERT INTO serviceIncluded (WorkOrderNumber, ServiceCode)
VALUES ('SV-60001', 'TIREROTATE');
INSERT INTO partInUse (WorkOrderNumber, PartCode)
VALUES ('SV-60001', 'BATTERY');
INSERT INTO partInUse (WorkOrderNumber, PartCode)
VALUES ('SV-60001', 'AIRFILTER');
-- MEMO 5: queries
CREATE OR REPLACE VIEW SellerList
AS SELECT CompanyName, ContactName, StreetAddress, City, SState, ZipCode, PhoneNumber, FaxNumber
FROM seller
ORDER BY CompanyName ASC;
CREATE OR REPLACE VIEW VehSalesList
AS SELECT sa.SalesInvoiceNumber, c.FirstName || ' ' || c.LastName CustomerName, e.FirstName || ' ' || e.LastName SalespersonName, m.FirstName || ' ' || m.LastName ApprovedByName, 
    sa.VIN, v.Make, v.VModel, tiv.VIN TradeInVIN, tiv.Make TradeInMake, tiv.VModel TradeInModel,sa.SellingPrice, sa.SellingPrice*0.05 Shipping, sa.SellingPrice*0.01 Discount, 
    NVL(sa.SellingPrice*0.75, 0) TradeInAllowance, (sa.SellingPrice + sa.SellingPrice*0.05 - sa.SellingPrice*0.01 - NVL(sa.SellingPrice*0.75, 0)) Subtotal, 
    (sa.SellingPrice + sa.SellingPrice*0.05 - sa.SellingPrice*0.01 - NVL(sa.SellingPrice*0.75, 0))*0.09 Taxes, 
    (sa.SellingPrice + sa.SellingPrice*0.05 - sa.SellingPrice*0.01 - NVL(sa.SellingPrice*0.75, 0)) + (sa.SellingPrice + sa.SellingPrice*0.05 - sa.SellingPrice*0.01 - NVL(sa.SellingPrice*0.75, 0)*0.09) TotalSellingPrice
FROM salesInvoice sa LEFT OUTER JOIN vehicle tiv 
ON(sa.VINTI = tiv.VIN)
JOIN customer c
ON (sa.CustomerID = c.CustomerID)
JOIN employee e 
ON (sa.EmployeeID = e.EmployeeID)
JOIN employee m 
ON (sa.ManagerID = m.EmployeeID)
JOIN vehicle v 
ON (sa.VIN = v.VIN)
ORDER BY sa.SalesInvoiceNumber;
CREATE OR REPLACE VIEW VehPurchList
AS SELECT po.PONumber, s.CompanyName, s.ContactName, po.VIN, v.Make, v.VModel, po.PurchasePrice SalesAmount, po.PurchasePrice*0.05 Shipping, 
    po.PurchasePrice*0.09 Taxes, (po.PurchasePrice + po.PurchasePrice*0.05 + po.PurchasePrice*0.09) TotalPrice, m.FirstName || ' ' || m.LastName ManagerName
FROM purchaseOrder po JOIN seller s
ON (po.sellerID = s.sellerID)
JOIN vehicle v
ON (po.VIN = v.VIN)
JOIN employee m 
ON (po.ManagerID = m.EmployeeID);
CREATE OR REPLACE VIEW ServInvList
AS SELECT si.WorkOrderNumber, c.FirstName || ' ' || c.LastName CustomerName, si.VIN, v.Make, v.VModel, v.Mileage, 
    SUM(DISTINCT s.Price) TotalServiceCharge, SUM (DISTINCT p.Price) TotalPartCharge, (SUM(DISTINCT s.Price) + SUM(DISTINCT p.Price)) SubtotalCharges, 
    ROUND(((SUM(DISTINCT s.Price) + SUM(DISTINCT p.Price))*0.09), 2) Taxes, ROUND((((SUM(DISTINCT s.Price) + SUM(DISTINCT p.Price))*0.09) + (SUM(DISTINCT s.Price) + SUM(DISTINCT p.Price))), 2) TotalCharges
FROM serviceInvoice si JOIN customer c
ON (si.CustomerID = c.CustomerID)
JOIN vehicle v 
ON (si.VIN = v.VIN)
JOIN serviceIncluded sinc 
ON (si.WorkOrderNumber = sinc.WorkOrderNumber)
JOIN service s 
ON (sinc.ServiceCode = s.ServiceCode)
JOIN partInUse piu 
ON (si.WorkOrderNumber = piu.WorkOrderNumber)
JOIN part p 
ON(piu.PartCode = p.PartCode)
GROUP BY si.WorkOrderNumber, c.FirstName || ' ' || c.LastName, si.VIN, v.Make, v.VModel, v.Mileage;
-- MEMO 6: Analysis Queries
CREATE OR REPLACE VIEW CustPurch
AS SELECT c.FirstName || ' ' || c.LastName CustomerName, c.PhoneNumber
FROM customer c JOIN salesInvoice sa
ON (c.CustomerID = sa.CustomerID);
CREATE OR REPLACE VIEW CustPurchNoServ
AS SELECT c.FirstName || ' ' || c.LastName CustomerName, c.PhoneNumber
FROM salesInvoice sa FULL OUTER JOIN serviceInvoice si 
ON (sa.CustomerID = si.CustomerID)
JOIN customer c
ON (c.CustomerID = sa.CustomerID)
WHERE c.CustomerID IN (SELECT CustomerID
                        FROM salesInvoice)
AND c.CustomerID NOT IN (SELECT CustomerID
                        FROM serviceInvoice);
CREATE OR REPLACE VIEW CustPorsche
AS SELECT c.FirstName || ' ' || c.LastName CustomerName, c.PhoneNumber
FROM customer c JOIN preference p 
ON (c.CustomerID = p.CustomerID)
WHERE p.Make = 'Porsche' AND p.EndDate > SYSDATE;
CREATE OR REPLACE VIEW CustNoTrade
AS SELECT c.FirstName || ' ' || c.LastName CustomerName
FROM customer c JOIN vehicle v 
ON (c.CustomerID = v.CustomerID)
JOIN salesInvoice sa 
ON (c.CustomerID = sa.CustomerID)
WHERE sa.VINTI IS NULL;
CREATE OR REPLACE VIEW VehSold30
AS SELECT v.VIN, v.Make, v.VModel, v.VYear
FROM vehicle v JOIN salesinvoice sa 
ON (v.VIN = sa.VIN)
WHERE sa.DateSold < (SYSDATE - 30);
CREATE OR REPLACE VIEW ServProfit
AS SELECT si.ServiceCode, SUM(s.Price) TotalServiceProfit
FROM service s JOIN serviceIncluded si
ON (s.ServiceCode = si.ServiceCode)
GROUP BY si.ServiceCode;
CREATE OR REPLACE VIEW ServProfitWCost
AS SELECT si.ServiceCode, (SUM(s.Price) - SUM(s.Cost)) ProfitsMinusCost
FROM service s JOIN serviceIncluded si
ON (s.ServiceCode = si.ServiceCode)
GROUP BY si.ServiceCode;
CREATE OR REPLACE VIEW BestSalesPersonComm
AS SELECT FirstName || ' ' || LastName SalesPersonName, CommissionPct
FROM employee
WHERE CommissionPct = (SELECT MAX(CommissionPct)
                        FROM employee);
CREATE OR REPLACE VIEW BestSalesPersonSold
AS SELECT e.FirstName || ' ' || e.LastName SalesPersonName, COUNT(sa.salesInvoiceNumber) NumberOfVehiclesSold
FROM employee e JOIN salesInvoice sa 
ON (e.EmployeeID = sa.EmployeeID)
HAVING COUNT(sa.salesInvoiceNumber) = (SELECT MAX(COUNT(salesInvoiceNumber))
                                        FROM salesInvoice
                                        GROUP BY EmployeeID)
GROUP BY e.FirstName || ' ' || e.LastName;
CREATE OR REPLACE VIEW LarrySales
AS SELECT SUM(TotalSellingPrice) TotalSales
FROM VehSalesList;
-- Extra Credit
CREATE OR REPLACE VIEW OilChgMileage
AS SELECT sil.CustomerName, c.PhoneNumber, sil.VIN, sil.Make
FROM ServInvList sil
JOIN serviceInvoice si 
ON (sil.WorkOrderNumber = si.WorkOrderNumber)
JOIN customer c 
ON (si.CustomerID = c.CustomerID)
JOIN serviceIncluded sin 
ON (si.WorkOrderNumber = sin.WorkOrderNumber)
JOIN service s 
ON (sin.ServiceCode = s.ServiceCode)
WHERE sin.ServiceCode = 'OILCHG'
AND si.Mileage NOT IN (SELECT Mileage+6000
                        FROM serviceInvoice);
CREATE OR REPLACE VIEW OilChgDate
AS SELECT sil.CustomerName, c.PhoneNumber, sil.VIN, sil.Make
FROM ServInvList sil
JOIN serviceInvoice si 
ON (sil.WorkOrderNumber = si.WorkOrderNumber)
JOIN customer c 
ON (si.CustomerID = c.CustomerID)
WHERE si.DateServiced > (SELECT ADD_MONTHS(si.DateServiced, 6)
                        FROM serviceInvoice);