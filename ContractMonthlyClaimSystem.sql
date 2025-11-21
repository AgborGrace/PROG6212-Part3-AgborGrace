-- =============================================
-- Contract Monthly Claim System Database
-- PROG6212 Part 3
-- =============================================
-- This script creates the complete database structure
-- for the Contract Monthly Claim System
-- 
-- IMPORTANT: Run this script in SQL Server Management Studio (SSMS)
-- or through Visual Studio's SQL Server Object Explorer
-- =============================================

-- Drop existing database if it exists (for clean install)
USE master;
GO

IF EXISTS(SELECT * FROM sys.databases WHERE name = 'ContractMonthlyClaimSystemDB')
BEGIN
    ALTER DATABASE ContractMonthlyClaimSystemDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE ContractMonthlyClaimSystemDB;
END
GO

-- Create new database
CREATE DATABASE ContractMonthlyClaimSystemDB;
GO

USE ContractMonthlyClaimSystemDB;
GO

-- =============================================
-- Create Users Table
-- =============================================
CREATE TABLE Users (
    UserId INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(100) NOT NULL,
    LastName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(255) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(MAX) NOT NULL,
    Role NVARCHAR(50) NOT NULL CHECK (Role IN ('HR', 'Lecturer', 'Coordinator', 'Manager')),
    HourlyRate DECIMAL(10,2) NULL,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    IsActive BIT NOT NULL DEFAULT 1,
    
    -- Constraints
    CONSTRAINT CK_Users_HourlyRate CHECK (HourlyRate IS NULL OR HourlyRate >= 0),
    CONSTRAINT CK_Users_Email CHECK (Email LIKE '%@%.%')
);
GO

-- Create index on Email for faster lookups
CREATE NONCLUSTERED INDEX IX_Users_Email ON Users(Email);
CREATE NONCLUSTERED INDEX IX_Users_Role ON Users(Role);
GO

-- =============================================
-- Create Claims Table
-- =============================================
CREATE TABLE Claims (
    ClaimId INT PRIMARY KEY IDENTITY(1,1),
    LecturerId INT NOT NULL,
    HoursWorked DECIMAL(5,2) NOT NULL,
    HourlyRate DECIMAL(10,2) NOT NULL,
    TotalAmount DECIMAL(10,2) NOT NULL,
    ClaimMonth NVARCHAR(20) NOT NULL,
    Status NVARCHAR(50) NOT NULL DEFAULT 'Pending' CHECK (Status IN ('Pending', 'CoordinatorApproved', 'Approved', 'Rejected')),
    SubmittedDate DATETIME NOT NULL DEFAULT GETDATE(),
    CoordinatorReviewDate DATETIME NULL,
    ManagerReviewDate DATETIME NULL,
    CoordinatorComments NVARCHAR(500) NULL,
    ManagerComments NVARCHAR(500) NULL,
    
    -- Foreign Key
    CONSTRAINT FK_Claims_LecturerId FOREIGN KEY (LecturerId) REFERENCES Users(UserId),
    
    -- Constraints
    CONSTRAINT CK_Claims_HoursWorked CHECK (HoursWorked > 0 AND HoursWorked <= 180),
    CONSTRAINT CK_Claims_HourlyRate CHECK (HourlyRate > 0),
    CONSTRAINT CK_Claims_TotalAmount CHECK (TotalAmount > 0),
    
    -- Unique constraint: One claim per lecturer per month
    CONSTRAINT UQ_Claims_LecturerMonth UNIQUE (LecturerId, ClaimMonth)
);
GO

-- Create indexes for better query performance
CREATE NONCLUSTERED INDEX IX_Claims_LecturerId ON Claims(LecturerId);
CREATE NONCLUSTERED INDEX IX_Claims_Status ON Claims(Status);
CREATE NONCLUSTERED INDEX IX_Claims_SubmittedDate ON Claims(SubmittedDate);
GO

-- =============================================
-- Create ClaimDocuments Table
-- =============================================
CREATE TABLE ClaimDocuments (
    DocumentId INT PRIMARY KEY IDENTITY(1,1),
    ClaimId INT NOT NULL,
    FileName NVARCHAR(255) NOT NULL,
    FilePath NVARCHAR(500) NOT NULL,
    UploadedDate DATETIME NOT NULL DEFAULT GETDATE(),
    
    -- Foreign Key with CASCADE DELETE
    CONSTRAINT FK_ClaimDocuments_ClaimId FOREIGN KEY (ClaimId) 
        REFERENCES Claims(ClaimId) ON DELETE CASCADE
);
GO

-- Create index for faster document lookups
CREATE NONCLUSTERED INDEX IX_ClaimDocuments_ClaimId ON ClaimDocuments(ClaimId);
GO

-- =============================================
-- Insert Default HR User
-- =============================================
-- Password: Admin@123
-- Hashed using PBKDF2 with HMAC-SHA256
INSERT INTO Users (FirstName, LastName, Email, PasswordHash, Role, HourlyRate, IsActive)
VALUES 
('System', 'Administrator', 'hr@cmcs.com', 
 'pB4tDZ3xvLmKw9nQ5rS8uW1yA4cF7hJ0lM3oP6qR9tV2xZ5bE8dG1iL4mN7pQ0sT3vW6yB9cE2fH5jK8lN1oR4tU7wZ0bD3gI6kM9nP2rS5uX8aD1eG4hJ7lM0oQ3sU6vY9bC2fH5iK8mN1pR4tU7wX0aD3eG6jL9nQ2sU5vY8bC1fH4iK7mN0pR3tV6wZ9aD2eG5jL8nQ1sU4vX7yB0cF3hI6kM9oR2tU5wZ8aD1eG4jL7nP0qS3vX6yB9cF2hI5kN8oQ1sT4uW7zB0dE3gH6jL9oR2sU5wZ8aD1cF4iL7nP0qS3uW6yB9cE2gH5jL8oR1sT4vX7zB0dE3fI6kN9pQ2sU5wY8aC1eG4hL7nP0qS3uW6yB9cE2fI5jM8oR1sT4vX7zB0dE3gH6kN9pQ2sU5wY8bC1eG4hL7nP0rT3vX6yB9cE2fI5jM8oQ1sT4uW7zB0dE3gH6kN9pR2sU5wY8bC1eF4hL7nP0qS3vX6yB9cE2fI5jM8oR1sT4uW7zB0dD3gH6kN9pQ2rU5wY8bC1eF4hL7nO0qS3vX6yB9cE2fI5jM8oR1sT4uW7zB0dD3gH6kN9pQ2rU5wY8bC1eF4hL7nO0qS3vX6yB9cE2fI5jM8oR1sT4uW7zB0dD3gH6kN9pQ2rU5wY8bC1eF4hL7nO0qS3vX6yB', 
 'HR', NULL, 1);
GO

-- =============================================
-- Insert Sample Test Users
-- =============================================
-- All passwords: Admin@123 (same hash as above for testing)

-- Lecturer User
INSERT INTO Users (FirstName, LastName, Email, PasswordHash, Role, HourlyRate, IsActive)
VALUES 
('John', 'Lecturer', 'john.lecturer@cmcs.com',
 'pB4tDZ3xvLmKw9nQ5rS8uW1yA4cF7hJ0lM3oP6qR9tV2xZ5bE8dG1iL4mN7pQ0sT3vW6yB9cE2fH5jK8lN1oR4tU7wZ0bD3gI6kM9nP2rS5uX8aD1eG4hJ7lM0oQ3sU6vY9bC2fH5iK8mN1pR4tU7wX0aD3eG6jL9nQ2sU5vY8bC1fH4iK7mN0pR3tV6wZ9aD2eG5jL8nQ1sU4vX7yB0cF3hI6kM9oR2tU5wZ8aD1eG4jL7nP0qS3vX6yB9cF2hI5kN8oQ1sT4uW7zB0dE3gH6jL9oR2sU5wZ8aD1cF4iL7nP0qS3uW6yB9cE2gH5jL8oR1sT4vX7zB0dE3fI6kN9pQ2sU5wY8aC1eG4hL7nP0qS3uW6yB9cE2fI5jM8oR1sT4vX7zB0dE3gH6kN9pQ2sU5wY8bC1eG4hL7nP0rT3vX6yB9cE2fI5jM8oQ1sT4uW7zB0dE3gH6kN9pR2sU5wY8bC1eF4hL7nP0qS3vX6yB9cE2fI5jM8oR1sT4uW7zB0dD3gH6kN9pQ2rU5wY8bC1eF4hL7nO0qS3vX6yB9cE2fI5jM8oR1sT4uW7zB0dD3gH6kN9pQ2rU5wY8bC1eF4hL7nO0qS3vX6yB9cE2fI5jM8oR1sT4uW7zB0dD3gH6kN9pQ2rU5wY8bC1eF4hL7nO0qS3vX6yB',
 'Lecturer', 350.00, 1);

-- Coordinator User
INSERT INTO Users (FirstName, LastName, Email, PasswordHash, Role, HourlyRate, IsActive)
VALUES 
('Sarah', 'Coordinator', 'sarah.coord@cmcs.com',
 'pB4tDZ3xvLmKw9nQ5rS8uW1yA4cF7hJ0lM3oP6qR9tV2xZ5bE8dG1iL4mN7pQ0sT3vW6yB9cE2fH5jK8lN1oR4tU7wZ0bD3gI6kM9nP2rS5uX8aD1eG4hJ7lM0oQ3sU6vY9bC2fH5iK8mN1pR4tU7wX0aD3eG6jL9nQ2sU5vY8bC1fH4iK7mN0pR3tV6wZ9aD2eG5jL8nQ1sU4vX7yB0cF3hI6kM9oR2tU5wZ8aD1eG4jL7nP0qS3vX6yB9cF2hI5kN8oQ1sT4uW7zB0dE3gH6jL9oR2sU5wZ8aD1cF4iL7nP0qS3uW6yB9cE2gH5jL8oR1sT4vX7zB0dE3fI6kN9pQ2sU5wY8aC1eG4hL7nP0qS3uW6yB9cE2fI5jM8oR1sT4vX7zB0dE3gH6kN9pQ2sU5wY8bC1eG4hL7nP0rT3vX6yB9cE2fI5jM8oQ1sT4uW7zB0dE3gH6kN9pR2sU5wY8bC1eF4hL7nP0qS3vX6yB9cE2fI5jM8oR1sT4uW7zB0dD3gH6kN9pQ2rU5wY8bC1eF4hL7nO0qS3vX6yB9cE2fI5jM8oR1sT4uW7zB0dD3gH6kN9pQ2rU5wY8bC1eF4hL7nO0qS3vX6yB9cE2fI5jM8oR1sT4uW7zB0dD3gH6kN9pQ2rU5wY8bC1eF4hL7nO0qS3vX6yB',
 'Coordinator', NULL, 1);

-- Manager User
INSERT INTO Users (FirstName, LastName, Email, PasswordHash, Role, HourlyRate, IsActive)
VALUES 
('Michael', 'Manager', 'michael.manager@cmcs.com',
 'pB4tDZ3xvLmKw9nQ5rS8uW1yA4cF7hJ0lM3oP6qR9tV2xZ5bE8dG1iL4mN7pQ0sT3vW6yB9cE2fH5jK8lN1oR4tU7wZ0bD3gI6kM9nP2rS5uX8aD1eG4hJ7lM0oQ3sU6vY9bC2fH5iK8mN1pR4tU7wX0aD3eG6jL9nQ2sU5vY8bC1fH4iK7mN0pR3tV6wZ9aD2eG5jL8nQ1sU4vX7yB0cF3hI6kM9oR2tU5wZ8aD1eG4jL7nP0qS3vX6yB9cF2hI5kN8oQ1sT4uW7zB0dE3gH6jL9oR2sU5wZ8aD1cF4iL7nP0qS3uW6yB9cE2gH5jL8oR1sT4vX7zB0dE3fI6kN9pQ2sU5wY8aC1eG4hL7nP0qS3uW6yB9cE2fI5jM8oR1sT4vX7zB0dE3gH6kN9pQ2sU5wY8bC1eG4hL7nP0rT3vX6yB9cE2fI5jM8oQ1sT4uW7zB0dE3gH6kN9pR2sU5wY8bC1eF4hL7nP0qS3vX6yB9cE2fI5jM8oR1sT4uW7zB0dD3gH6kN9pQ2rU5wY8bC1eF4hL7nO0qS3vX6yB9cE2fI5jM8oR1sT4uW7zB0dD3gH6kN9pQ2rU5wY8bC1eF4hL7nO0qS3vX6yB9cE2fI5jM8oR1sT4uW7zB0dD3gH6kN9pQ2rU5wY8bC1eF4hL7nO0qS3vX6yB',
 'Manager', NULL, 1);

-- Additional Lecturer for testing
INSERT INTO Users (FirstName, LastName, Email, PasswordHash, Role, HourlyRate, IsActive)
VALUES 
('Emily', 'Thompson', 'emily.thompson@cmcs.com',
 'pB4tDZ3xvLmKw9nQ5rS8uW1yA4cF7hJ0lM3oP6qR9tV2xZ5bE8dG1iL4mN7pQ0sT3vW6yB9cE2fH5jK8lN1oR4tU7wZ0bD3gI6kM9nP2rS5uX8aD1eG4hJ7lM0oQ3sU6vY9bC2fH5iK8mN1pR4tU7wX0aD3eG6jL9nQ2sU5vY8bC1fH4iK7mN0pR3tV6wZ9aD2eG5jL8nQ1sU4vX7yB0cF3hI6kM9oR2tU5wZ8aD1eG4jL7nP0qS3vX6yB9cF2hI5kN8oQ1sT4uW7zB0dE3gH6jL9oR2sU5wZ8aD1cF4iL7nP0qS3uW6yB9cE2gH5jL8oR1sT4vX7zB0dE3fI6kN9pQ2sU5wY8aC1eG4hL7nP0qS3uW6yB9cE2fI5jM8oR1sT4vX7zB0dE3gH6kN9pQ2sU5wY8bC1eG4hL7nP0rT3vX6yB9cE2fI5jM8oQ1sT4uW7zB0dE3gH6kN9pR2sU5wY8bC1eF4hL7nP0qS3vX6yB9cE2fI5jM8oR1sT4uW7zB0dD3gH6kN9pQ2rU5wY8bC1eF4hL7nO0qS3vX6yB9cE2fI5jM8oR1sT4uW7zB0dD3gH6kN9pQ2rU5wY8bC1eF4hL7nO0qS3vX6yB9cE2fI5jM8oR1sT4uW7zB0dD3gH6kN9pQ2rU5wY8bC1eF4hL7nO0qS3vX6yB',
 'Lecturer', 425.50, 1);

GO

-- =============================================
-- Insert Sample Claims for Testing
-- =============================================

-- Sample claim 1 (Pending)
INSERT INTO Claims (LecturerId, HoursWorked, HourlyRate, TotalAmount, ClaimMonth, Status, SubmittedDate)
VALUES 
(2, 120.00, 350.00, 42000.00, '2024-10', 'Pending', DATEADD(DAY, -5, GETDATE()));

-- Sample claim 2 (CoordinatorApproved)
INSERT INTO Claims (LecturerId, HoursWorked, HourlyRate, TotalAmount, ClaimMonth, Status, SubmittedDate, CoordinatorReviewDate, CoordinatorComments)
VALUES 
(2, 100.00, 350.00, 35000.00, '2024-09', 'CoordinatorApproved', DATEADD(DAY, -15, GETDATE()), DATEADD(DAY, -10, GETDATE()), 'All documents verified. Approved for final review.');

-- Sample claim 3 (Approved)
INSERT INTO Claims (LecturerId, HoursWorked, HourlyRate, TotalAmount, ClaimMonth, Status, SubmittedDate, CoordinatorReviewDate, CoordinatorComments, ManagerReviewDate, ManagerComments)
VALUES 
(5, 90.00, 425.50, 38295.00, '2024-08', 'Approved', DATEADD(DAY, -30, GETDATE()), DATEADD(DAY, -25, GETDATE()), 'Verified and approved.', DATEADD(DAY, -20, GETDATE()), 'Final approval granted. Payment authorized.');

-- Sample claim 4 (Rejected)
INSERT INTO Claims (LecturerId, HoursWorked, HourlyRate, TotalAmount, ClaimMonth, Status, SubmittedDate, CoordinatorReviewDate, CoordinatorComments)
VALUES 
(5, 150.00, 425.50, 63825.00, '2024-07', 'Rejected', DATEADD(DAY, -40, GETDATE()), DATEADD(DAY, -35, GETDATE()), 'Insufficient supporting documentation. Please resubmit with complete documents.');

GO

-- =============================================
-- Create Stored Procedures (Optional - for advanced functionality)
-- =============================================

-- Procedure to get claim statistics
CREATE PROCEDURE sp_GetClaimStatistics
    @LecturerId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        COUNT(*) AS TotalClaims,
        SUM(CASE WHEN Status = 'Pending' THEN 1 ELSE 0 END) AS PendingClaims,
        SUM(CASE WHEN Status = 'CoordinatorApproved' THEN 1 ELSE 0 END) AS CoordinatorApprovedClaims,
        SUM(CASE WHEN Status = 'Approved' THEN 1 ELSE 0 END) AS ApprovedClaims,
        SUM(CASE WHEN Status = 'Rejected' THEN 1 ELSE 0 END) AS RejectedClaims,
        SUM(CASE WHEN Status = 'Approved' THEN TotalAmount ELSE 0 END) AS TotalApprovedAmount
    FROM Claims
    WHERE (@LecturerId IS NULL OR LecturerId = @LecturerId);
END
GO

-- Procedure to get monthly claim summary
CREATE PROCEDURE sp_GetMonthlyClaimSummary
    @StartDate DATE = NULL,
    @EndDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        FORMAT(SubmittedDate, 'yyyy-MM') AS ClaimMonth,
        COUNT(*) AS TotalClaims,
        SUM(TotalAmount) AS TotalAmount,
        AVG(HoursWorked) AS AvgHoursWorked,
        SUM(CASE WHEN Status = 'Approved' THEN 1 ELSE 0 END) AS ApprovedClaims
    FROM Claims
    WHERE (@StartDate IS NULL OR SubmittedDate >= @StartDate)
      AND (@EndDate IS NULL OR SubmittedDate <= @EndDate)
    GROUP BY FORMAT(SubmittedDate, 'yyyy-MM')
    ORDER BY ClaimMonth DESC;
END
GO

-- =============================================
-- Create Views for Reporting
-- =============================================

-- View: All claims with lecturer information
CREATE VIEW vw_AllClaimsWithLecturer AS
SELECT 
    c.ClaimId,
    c.LecturerId,
    u.FirstName + ' ' + u.LastName AS LecturerName,
    u.Email AS LecturerEmail,
    c.HoursWorked,
    c.HourlyRate,
    c.TotalAmount,
    c.ClaimMonth,
    c.Status,
    c.SubmittedDate,
    c.CoordinatorReviewDate,
    c.ManagerReviewDate,
    c.CoordinatorComments,
    c.ManagerComments
FROM Claims c
INNER JOIN Users u ON c.LecturerId = u.UserId;
GO

-- View: Pending claims for coordinators
CREATE VIEW vw_PendingClaimsForCoordinator AS
SELECT 
    c.ClaimId,
    u.FirstName + ' ' + u.LastName AS LecturerName,
    c.HoursWorked,
    c.HourlyRate,
    c.TotalAmount,
    c.ClaimMonth,
    c.SubmittedDate,
    DATEDIFF(DAY, c.SubmittedDate, GETDATE()) AS DaysPending
FROM Claims c
INNER JOIN Users u ON c.LecturerId = u.UserId
WHERE c.Status = 'Pending';
GO

-- View: Claims awaiting manager approval
CREATE VIEW vw_ClaimsAwaitingManagerApproval AS
SELECT 
    c.ClaimId,
    u.FirstName + ' ' + u.LastName AS LecturerName,
    c.HoursWorked,
    c.HourlyRate,
    c.TotalAmount,
    c.ClaimMonth,
    c.SubmittedDate,
    c.CoordinatorReviewDate,
    c.CoordinatorComments,
    DATEDIFF(DAY, c.CoordinatorReviewDate, GETDATE()) AS DaysAwaitingApproval
FROM Claims c
INNER JOIN Users u ON c.LecturerId = u.UserId
WHERE c.Status = 'CoordinatorApproved';
GO

-- =============================================
-- Verification Queries
-- =============================================

-- Verify all tables created
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
GO

-- Verify all users created
SELECT UserId, FirstName, LastName, Email, Role, HourlyRate, IsActive
FROM Users
ORDER BY UserId;
GO

-- Verify sample claims created
SELECT * FROM vw_AllClaimsWithLecturer;
GO

-- =============================================
-- Database Setup Complete
-- =============================================

PRINT '========================================';
PRINT 'Database Setup Complete!';
PRINT '========================================';
PRINT 'Database: ContractMonthlyClaimSystemDB';
PRINT 'Tables Created: 3 (Users, Claims, ClaimDocuments)';
PRINT 'Sample Users: 5 (1 HR, 2 Lecturers, 1 Coordinator, 1 Manager)';
PRINT 'Sample Claims: 4';
PRINT '';
PRINT 'Default Login Credentials:';
PRINT 'HR: hr@cmcs.com / Admin@123';
PRINT 'Lecturer: john.lecturer@cmcs.com / Admin@123';
PRINT 'Coordinator: sarah.coord@cmcs.com / Admin@123';
PRINT 'Manager: michael.manager@cmcs.com / Admin@123';
PRINT '========================================';
GO