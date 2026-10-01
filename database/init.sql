DROP DATABASE IF EXISTS GCM_DB;
CREATE DATABASE GCM_DB;
USE GCM_DB;



CREATE TABLE Users (
    UserID INT AUTO_INCREMENT PRIMARY KEY,
    UserName VARCHAR(255) NOT NULL UNIQUE,
    Password VARCHAR(255) NOT NULL,
    Role ENUM(
        'Customer',
        'Worker',
        'CustomerSupport',
        'ContentEmployee',
        'ContentManager',
        'CompanyManager'
    ) NOT NULL,
    lastLogin DATETIME NULL,
    failedAttempts INT DEFAULT 0,
    isLocked BOOLEAN DEFAULT FALSE,
    lockedUntil DATETIME NULL,
    name VARCHAR(255) NULL,
    surname VARCHAR(255) NULL,
    phoneNum INT NULL,
    email VARCHAR(255) NULL
);






CREATE TABLE Cities (
    CityID INT AUTO_INCREMENT PRIMARY KEY,
    CityName VARCHAR(255) NOT NULL UNIQUE,
    baseMap VARCHAR(255) NOT NULL ,
    CityPrice DOUBLE NOT NULL,
    SubPrice DOUBLE NOT NULL,
    description TEXT
);

CREATE TABLE pois (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100),
    x DOUBLE NOT NULL,
    y DOUBLE NOT NULL,
    is_accessible BOOLEAN NOT NULL DEFAULT FALSE,
    cityID INT NOT NULL,
    is_approved BOOLEAN NOT NULL DEFAULT FALSE,
    recommended_minutes INT,
    FOREIGN KEY (cityID) REFERENCES Cities(cityID)
        ON DELETE CASCADE
);





CREATE TABLE pending_maps (
    version INT NOT NULL,
    cityID INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    path VARCHAR(512),
    poi_array JSON,
    is_edit BOOLEAN NOT NULL DEFAULT FALSE,
    source_map_id INT NULL,
    FOREIGN KEY (cityID) REFERENCES Cities(cityID)
        ON DELETE CASCADE
);

CREATE TABLE Maps (
    mapID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    cityID INT NOT NULL,
    mapName VARCHAR(255) NOT NULL,
	map JSON NOT NULL,
    version INT NOT NULL,
    FOREIGN KEY (cityID) REFERENCES Cities(cityID)
        ON DELETE CASCADE
);

CREATE TABLE pending_routes (
    routeID INT AUTO_INCREMENT PRIMARY KEY,
    cityID INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
	is_edit BOOLEAN NOT NULL DEFAULT FALSE,
    sourceRouteID INT NULL,
    FOREIGN KEY (cityID) REFERENCES Cities(cityID)
);


CREATE TABLE routes (
    routeID INT AUTO_INCREMENT PRIMARY KEY,
    cityID INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,

    FOREIGN KEY (cityID) REFERENCES Cities(cityID)
);



CREATE TABLE route_stops (
    routeID INT NOT NULL,
    poiID INT NOT NULL,
    stop_order INT NOT NULL,

    PRIMARY KEY (routeID, stop_order),

    FOREIGN KEY (routeID) REFERENCES routes(routeID)
        ON DELETE CASCADE,
    FOREIGN KEY (poiID) REFERENCES pois(id)
        ON DELETE CASCADE
);


CREATE TABLE pending_route_stops (
    routeID INT NOT NULL,
    poiID INT NOT NULL,
    stop_order INT NOT NULL,

    PRIMARY KEY (routeID, stop_order),

    FOREIGN KEY (routeID) REFERENCES pending_routes(routeID)
        ON DELETE CASCADE,
    FOREIGN KEY (poiID) REFERENCES pois(id)
        ON DELETE CASCADE
);


CREATE TABLE pending_city_prices (
    cityID INT PRIMARY KEY,
    newCityPrice DOUBLE NOT NULL,
    newSubPrice DOUBLE NOT NULL,
    FOREIGN KEY (cityID) REFERENCES Cities(cityID)
        ON DELETE CASCADE
);



-- one time purchase
CREATE TABLE Purchases (
    PurchaseID INT AUTO_INCREMENT PRIMARY KEY,
    UserID INT NOT NULL,
    PurchaseDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    DownloadUsed BOOLEAN DEFAULT FALSE,
    CityName VARCHAR(255) NOT NULL,
    mapVersion INT NOT NULL,
    PaymentLast4 CHAR(4) NOT NULL,
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);


-- subscription purchase 
CREATE TABLE Subscriptions (
    SubscriptionID INT AUTO_INCREMENT PRIMARY KEY,
    UserID INT NOT NULL,
    CityID INT NOT NULL,
    StartDate DATETIME NOT NULL,
    EndDate DATETIME NOT NULL,
    DownloadsRemaining INT DEFAULT 10,
    PaymentLast4 CHAR(4) NOT NULL,
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (CityID) REFERENCES Cities(CityID)
);


CREATE TABLE Messages (
    UserID INT NOT NULL,
    Message TEXT NOT NULL,
    CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);


CREATE TABLE SupportTickets (
    ticketID INT AUTO_INCREMENT PRIMARY KEY,
    userID INT NOT NULL,
    message TEXT NOT NULL,
    response TEXT NULL,
    ticketStatus ENUM('Open', 'WaitingForBot','WaitingForHuman', 'InProgress', 'Closed') DEFAULT 'Open',
    createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (userID) REFERENCES Users(UserID),
	responseBy ENUM('Bot', 'Human') NULL
);


CREATE TABLE ViewLogs (
    viewID INT AUTO_INCREMENT PRIMARY KEY,
    userID INT NOT NULL,
    viewDate DATETIME DEFAULT CURRENT_TIMESTAMP,
	cityID INT NOT NULL,
    FOREIGN KEY (cityID) REFERENCES Cities(cityID)
);


CREATE TABLE DownloadLogs (
    downloadID INT AUTO_INCREMENT PRIMARY KEY,
    userID INT NOT NULL,
    downloadDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (userID) REFERENCES Users(UserID)
);


INSERT INTO Users (UserName,email, Password, Role) VALUES
('Adminn','Admin', 'Admin', 'CompanyManager'),
('Adam','adam', 'adam', 'Customer'),
('worker','Worker', 'Worker', 'Worker'),
('customersupport','CustomerSupport', 'CustomerSupport', 'CustomerSupport'),
('contentEmployee','ContentEmployee', 'ContentEmployee', 'ContentEmployee'),
('contentManager','ContentManager', 'ContentManager', 'ContentManager');
-- client\src\main\resources\gcm\client\map\Haifa
-- change this to match ur pc please 
INSERT INTO Cities (CityID, CityName, baseMap, CityPrice,SubPrice,description) VALUES
(1, 'Haifa', 'client\\src\\main\\resources\\gcm\\client\\map\\Haifa',0,0,'Coastal city in northern Israel, known for its port and diverse population.'),
(2, 'Akko',  'client\\src\\main\\resources\\gcm\\client\\map\\Akko',0,0,'Ancient port city famous for its preserved Old City.'),
(3, 'Tel-Aviv','client\\src\\main\\resources\\gcm\\client\\map\\Tel-Aviv',0,0,'Israel’s main economic and cultural center with beaches and nightlife.'),
(4, 'Jerusalem','client\\src\\main\\resources\\gcm\\client\\map\\Jerusalem',0,0,'Historic city of major religious and cultural significance.'),
(5, 'Beer-Sheva','client\\src\\main\\resources\\gcm\\client\\map\\Beer-Sheva',0,0,'Regional hub and largest city in the Negev Desert.');