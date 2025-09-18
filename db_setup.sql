CREATE DATABASE IF NOT EXISTS bytex_db;
USE bytex_db;

-- Main table for all users
CREATE TABLE Users (
    UserID INT AUTO_INCREMENT PRIMARY KEY,
    Username VARCHAR(50) NOT NULL UNIQUE,
    Password VARCHAR(255) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    FullName VARCHAR(100) NOT NULL,
    PhoneNumber VARCHAR(20),
    Role VARCHAR(20) NOT NULL CHECK (Role IN ('Customer', 'Staff', 'Technician', 'ProductManager', 'WarehouseManager', 'Admin')),
    CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    LastLogin DATETIME NULL
);

-- Table for customer support tickets
CREATE TABLE Tickets (
    TicketID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT NOT NULL,
    Subject VARCHAR(100) NOT NULL,
    Description TEXT NOT NULL,
    Status VARCHAR(20) NOT NULL DEFAULT 'Open' CHECK (Status IN ('Open', 'InProgress', 'Pending', 'Resolved', 'Closed')),
    Priority VARCHAR(10) NOT NULL DEFAULT 'Medium' CHECK (Priority IN ('Low', 'Medium', 'High', 'Critical')),
    AssignedToID INT NULL,
    CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    closedAt DATETIME NULL,
    archived BOOLEAN DEFAULT 0 NOT NULL,
    archivedAt DATETIME NULL,
    FOREIGN KEY (CustomerID) REFERENCES Users(UserID),
    FOREIGN KEY (AssignedToID) REFERENCES Users(UserID)
);

-- Table for responses/messages on tickets
CREATE TABLE Responses (
    ResponseID INT AUTO_INCREMENT PRIMARY KEY,
    TicketID INT NOT NULL,
    UserID INT NOT NULL,
    Message TEXT NOT NULL,
    CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (TicketID) REFERENCES Tickets(TicketID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- Table for technical repair jobs
CREATE TABLE Repairs (
    RepairID INT AUTO_INCREMENT PRIMARY KEY,
    TicketID INT NOT NULL,
    TechnicianID INT NOT NULL,
    Diagnosis TEXT NOT NULL,
    RepairDetails TEXT,
    Status VARCHAR(20) NOT NULL DEFAULT 'Pending' CHECK (Status IN ('Pending', 'InProgress', 'WaitingForParts', 'Completed', 'Failed')),
    StartDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    CompletionDate DATETIME NULL,
    FOREIGN KEY (TicketID) REFERENCES Tickets(TicketID),
    FOREIGN KEY (TechnicianID) REFERENCES Users(UserID)
);

-- Table for inventory of parts
CREATE TABLE Parts (
    PartID INT AUTO_INCREMENT PRIMARY KEY,
    PartNumber VARCHAR(50) NOT NULL UNIQUE,
    PartName VARCHAR(100) NOT NULL,
    Description TEXT,
    CurrentStock INT NOT NULL DEFAULT 0,
    MinimumStock INT NOT NULL DEFAULT 5,
    UnitPrice DECIMAL(10, 2) NOT NULL,
    Category VARCHAR(50) NOT NULL,
    Status VARCHAR(20) NOT NULL DEFAULT 'Active' CHECK (Status IN ('Active', 'LowStock', 'OutOfStock', 'Discontinued'))
);

-- Junction table for parts used in repairs
CREATE TABLE RepairParts (
    RepairID INT NOT NULL,
    PartID INT NOT NULL,
    Quantity INT NOT NULL DEFAULT 1,
    PRIMARY KEY (RepairID, PartID),
    FOREIGN KEY (RepairID) REFERENCES Repairs(RepairID),
    FOREIGN KEY (PartID) REFERENCES Parts(PartID)
);

-- Table for part requests from technicians/product managers
CREATE TABLE PartRequests (
    RequestID INT AUTO_INCREMENT PRIMARY KEY,
    PartID INT NOT NULL,
    RequestorID INT NOT NULL,
    Quantity INT NOT NULL DEFAULT 1,
    Reason TEXT,
    Status VARCHAR(20) NOT NULL DEFAULT 'Pending' CHECK (Status IN ('Pending', 'Approved', 'Fulfilled', 'Rejected')),
    RequestDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    FulfillmentDate DATETIME NULL,
    FOREIGN KEY (PartID) REFERENCES Parts(PartID),
    FOREIGN KEY (RequestorID) REFERENCES Users(UserID)
);

-- Table for purchase orders to vendors
CREATE TABLE PurchaseOrders (
    OrderID INT AUTO_INCREMENT PRIMARY KEY,
    CreatedByID INT NOT NULL,
    VendorName VARCHAR(100) NOT NULL,
    TotalAmount DECIMAL(10, 2) NOT NULL,
    Status VARCHAR(20) NOT NULL DEFAULT 'Pending' CHECK (Status IN ('Pending', 'Approved', 'Shipped', 'Delivered', 'Cancelled')),
    OrderDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    ExpectedDelivery DATETIME NULL,
    ActualDelivery DATETIME NULL,
    FOREIGN KEY (CreatedByID) REFERENCES Users(UserID)
);

-- Junction table for items in a purchase order
CREATE TABLE OrderItems (
    OrderID INT NOT NULL,
    PartID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (OrderID, PartID),
    FOREIGN KEY (OrderID) REFERENCES PurchaseOrders(OrderID),
    FOREIGN KEY (PartID) REFERENCES Parts(PartID)
);

-- Table for system activity logs
CREATE TABLE ActivityLogs (
    LogID INT AUTO_INCREMENT PRIMARY KEY,
    UserID INT,
    ActionType VARCHAR(50) NOT NULL,
    EntityType VARCHAR(50) NOT NULL,
    EntityID INT,
    Description TEXT,
    IPAddress VARCHAR(50),
    CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- Table for file attachments
CREATE TABLE Attachments (
    AttachmentID INT AUTO_INCREMENT PRIMARY KEY,
    TicketID INT,
    ResponseID INT,
    FileName VARCHAR(255) NOT NULL,
    FilePath VARCHAR(500) NOT NULL,
    FileSize INT NOT NULL,
    FileType VARCHAR(100) NOT NULL,
    UploadedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    UploadedBy INT NOT NULL,
    FOREIGN KEY (TicketID) REFERENCES Tickets(TicketID),
    FOREIGN KEY (ResponseID) REFERENCES Responses(ResponseID),
    FOREIGN KEY (UploadedBy) REFERENCES Users(UserID),
    CHECK ((TicketID IS NULL AND ResponseID IS NOT NULL) OR (TicketID IS NOT NULL AND ResponseID IS NULL))
);

-- Indexes for performance
CREATE INDEX IX_Tickets_CustomerID ON Tickets(CustomerID);
CREATE INDEX IX_Tickets_AssignedToID ON Tickets(AssignedToID);
CREATE INDEX IX_Parts_Status ON Parts(Status);
CREATE INDEX IX_Responses_TicketID ON Responses(TicketID);

-- Insert sample data

-- Admin user
INSERT INTO Users (Username, Password, Email, FullName, PhoneNumber, Role, CreatedAt, LastLogin) VALUES ('admin', 'admin123', 'admin@bytex.com', 'System Administrator', '+94711234567', 'Admin', '2025-07-01 08:30:00', '2025-08-25 14:00:00');

-- Staff members
INSERT INTO Users (Username, Password, Email, FullName, PhoneNumber, Role, CreatedAt, LastLogin) VALUES ('john.staff', 'staff123', 'john@bytex.com', 'John Smith', '+94712345678', 'Staff', '2025-07-05 09:15:00', '2025-08-24 16:45:00');
INSERT INTO Users (Username, Password, Email, FullName, PhoneNumber, Role, CreatedAt, LastLogin) VALUES ('sarah.staff', 'staff123', 'sarah@bytex.com', 'Sarah Johnson', '+94713456789', 'Staff', '2025-07-06 10:30:00', '2025-08-25 09:20:00');

-- Technicians
INSERT INTO Users (Username, Password, Email, FullName, PhoneNumber, Role, CreatedAt, LastLogin) VALUES ('mike.tech', 'tech123', 'mike@bytex.com', 'Mike Chen', '+94714567890', 'Technician', '2025-07-10 08:00:00', '2025-08-25 12:30:00');
INSERT INTO Users (Username, Password, Email, FullName, PhoneNumber, Role, CreatedAt, LastLogin) VALUES ('laura.tech', 'tech123', 'laura@bytex.com', 'Laura Silva', '+94715678901', 'Technician', '2025-07-11 08:30:00', '2025-08-24 17:15:00');

-- Product Manager
INSERT INTO Users (Username, Password, Email, FullName, PhoneNumber, Role, CreatedAt, LastLogin) VALUES ('david.pm', 'pm123', 'david@bytex.com', 'David Perera', '+94716789012', 'ProductManager', '2025-07-15 09:45:00', '2025-08-25 10:30:00');

-- Warehouse Manager
INSERT INTO Users (Username, Password, Email, FullName, PhoneNumber, Role, CreatedAt, LastLogin) VALUES ('priya.wm', 'wm123', 'priya@bytex.com', 'Priya Fernando', '+94717890123', 'WarehouseManager', '2025-07-20 08:15:00', '2025-08-24 15:45:00');

-- Customers
INSERT INTO Users (Username, Password, Email, FullName, PhoneNumber, Role, CreatedAt, LastLogin) VALUES ('raj.customer', 'pass123', 'raj@gmail.com', 'Raj Mendis', '+94718901234', 'Customer', '2025-07-25 14:20:00', '2025-08-23 18:30:00');
INSERT INTO Users (Username, Password, Email, FullName, PhoneNumber, Role, CreatedAt, LastLogin) VALUES ('anita.customer', 'pass123', 'anita@outlook.com', 'Anita De Silva', '+94719012345', 'Customer', '2025-07-26 15:45:00', '2025-08-22 19:15:00');
INSERT INTO Users (Username, Password, Email, FullName, PhoneNumber, Role, CreatedAt, LastLogin) VALUES ('kumar.customer', 'pass123', 'kumar@yahoo.com', 'Kumar Bandara', '+94720123456', 'Customer', '2025-07-27 16:30:00', '2025-08-24 09:45:00');
INSERT INTO Users (Username, Password, Email, FullName, PhoneNumber, Role, CreatedAt, LastLogin) VALUES ('michelle.customer', 'pass123', 'michelle@gmail.com', 'Michelle Gunasekera', '+94721234567', 'Customer', '2025-07-28 10:15:00', '2025-08-25 11:20:00');
INSERT INTO Users (Username, Password, Email, FullName, PhoneNumber, Role, CreatedAt, LastLogin) VALUES ('saman.customer', 'pass123', 'saman@outlook.com', 'Saman Jayawardena', '+94722345678', 'Customer', '2025-07-29 11:45:00', '2025-08-21 14:30:00');

-- Insert sample parts
INSERT INTO Parts (PartNumber, PartName, Description, CurrentStock, MinimumStock, UnitPrice, Category, Status) VALUES ('CPU001', 'Intel Core i7-12700K', 'High performance CPU', 15, 5, 399.99, 'CPU', 'Active');
INSERT INTO Parts (PartNumber, PartName, Description, CurrentStock, MinimumStock, UnitPrice, Category, Status) VALUES ('RAM001', 'Corsair Vengeance 16GB DDR4', 'High performance RAM', 30, 10, 79.99, 'RAM', 'Active');
INSERT INTO Parts (PartNumber, PartName, Description, CurrentStock, MinimumStock, UnitPrice, Category, Status) VALUES ('GPU001', 'NVIDIA RTX 3080', 'High-end graphics card', 5, 3, 699.99, 'GPU', 'LowStock');
INSERT INTO Parts (PartNumber, PartName, Description, CurrentStock, MinimumStock, UnitPrice, Category, Status) VALUES ('SSD001', 'Samsung 970 EVO 1TB', 'NVMe SSD', 0, 5, 149.99, 'Storage', 'OutOfStock');
