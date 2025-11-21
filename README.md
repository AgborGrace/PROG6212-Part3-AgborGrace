# Contract Monthly Claim System (CMCS)
## PROG6212 Part 3 - Final Portfolio of Evidence

### Student Information
**Student Name:** Grace Bissong Agbor 
**Student Number:** ST10066225  
**Module:** PROG6212  
**Submission Date:** 21 November 2025

---

## 📋 Project Overview

The Contract Monthly Claim System is a comprehensive ASP.NET Core MVC web application designed to streamline the process of submitting, reviewing, and approving monthly contract claims for lecturers. The system implements role-based access control with four distinct user roles: HR (Super User), Lecturer, Programme Coordinator, and Academic Manager.

---

## 🎯 Key Features

### HR (Super User) Features
- ✅ Create and manage all user accounts
- ✅ Update user information including hourly rates
- ✅ Generate comprehensive reports using LINQ queries
- ✅ Export reports to PDF format
- ✅ View system-wide statistics
- ✅ No registration system - HR creates all accounts

### Lecturer Features
- ✅ Secure login with HR-provided credentials
- ✅ Auto-calculation of claim amounts based on hours worked
- ✅ Submit claims with supporting documentation
- ✅ Track claim status through approval process
- ✅ View claim history
- ✅ Maximum 180 hours per month validation
- ✅ Auto-populated name, surname, and hourly rate

### Programme Coordinator Features
- ✅ Review pending claims (First-stage approval)
- ✅ Approve or reject claims with comments
- ✅ View supporting documents
- ✅ Dashboard with statistics

### Academic Manager Features
- ✅ Final approval authority (Second-stage approval)
- ✅ Review coordinator-approved claims
- ✅ Approve or reject with comments
- ✅ View complete claim history
- ✅ Access to all supporting documents

---

## 🛠️ Technology Stack

### Backend
- ASP.NET Core 6.0 MVC
- Entity Framework Core 6.0
- SQL Server (LocalDB/SQL Server Express)
- C# 10.0

### Frontend
- Razor Views
- Bootstrap 5.3.0
- Font Awesome 6.4.0
- jQuery 3.6.0

### Libraries & Dependencies
- Microsoft.EntityFrameworkCore.SqlServer (6.0.0)
- Microsoft.EntityFrameworkCore.Tools (6.0.0)
- iTextSharp (5.5.13.3) - For PDF generation

---

## 📦 Installation & Setup Instructions

### Prerequisites
1. Visual Studio 2022 (Community Edition or higher)
2. .NET 6.0 SDK
3. SQL Server 2019 or SQL Server Express
4. SQL Server Management Studio (SSMS) - Optional but recommended

### Step 1: Clone the Repository
```bash
git clone [your-github-repo-url]
cd ContractMonthlyClaimSystem
```

### Step 2: Database Setup

#### Option A: Using SQL Server Management Studio (SSMS)
1. Open SSMS and connect to your SQL Server instance
2. Open the `Database/CreateDatabase.sql` file
3. Execute the entire script to create:
   - Database: `ContractMonthlyClaimSystemDB`
   - Tables: Users, Claims, ClaimDocuments
   - Sample data with test users

#### Option B: Using Visual Studio
1. Open Server Explorer
2. Connect to your SQL Server instance
3. Right-click and select "New Query"
4. Copy and paste the content from `Database/CreateDatabase.sql`
5. Execute the script

### Step 3: Update Connection String
1. Open `appsettings.json`
2. Update the connection string to match your SQL Server instance:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=(localdb)\\mssqllocaldb;Database=ContractMonthlyClaimSystemDB;Trusted_Connection=True;MultipleActiveResultSets=true"
  }
}
```

**For SQL Server Express, use:**
```json
"DefaultConnection": "Server=.\\SQLEXPRESS;Database=ContractMonthlyClaimSystemDB;Trusted_Connection=True;MultipleActiveResultSets=true"
```

### Step 4: Restore NuGet Packages
1. In Visual Studio, right-click on the solution
2. Select "Restore NuGet Packages"
3. Wait for all packages to download

### Step 5: Build the Solution
1. Press `Ctrl + Shift + B` or
2. Click Build > Build Solution
3. Ensure there are no build errors

### Step 6: Run the Application
1. Press `F5` or click the "Run" button
2. The application will open in your default browser
3. Navigate to the login page

---

## 👤 Default User Accounts

### HR Account (Super User)
- **Email:** hr@cmcs.com
- **Password:** Admin@123
- **Capabilities:** Full system access, user management, report generation

### Lecturer Account
- **Email:** john.lecturer@cmcs.com
- **Password:** Lecturer@123
- **Hourly Rate:** R350.00
- **Capabilities:** Submit claims, track status

### Programme Coordinator Account
- **Email:** sarah.coord@cmcs.com
- **Password:** Coord@123
- **Capabilities:** Review and approve/reject claims (first stage)

### Academic Manager Account
- **Email:** michael.manager@cmcs.com
- **Password:** Manager@123
- **Capabilities:** Final approval authority (second stage)

---

## 🔄 Changes from Part 2 to Part 3

### Major Changes Based on Lecturer Feedback

1. **HR Role Implementation**
   - Added HR as super user with full system access
   - HR can create and manage all users
   - Removed registration functionality
   - HR sets hourly rates for lecturers

2. **Auto-Calculation Feature**
   - Lecturers no longer manually input hourly rate
   - Auto-calculation: Hours Worked × Hourly Rate = Total Amount
   - Real-time calculation display

3. **Validation Enhancements**
   - Maximum 180 hours per month validation
   - Duplicate claim per month prevention
   - Required field validation
   - Hourly rate validation for lecturers

4. **Entity Framework Integration**
   - Database-first approach with SQL Server
   - No migrations required
   - Direct SQL script execution
   - DbContext with proper relationships

5. **Session Management**
   - Implemented session-based authentication
   - Role-based page access restrictions
   - Secure session handling
   - Automatic session timeout (30 minutes)

6. **Two-Stage Approval Process**
   - Coordinator reviews first (stage 1)
   - Manager provides final approval (stage 2)
   - Status tracking: Pending → CoordinatorApproved → Approved
   - Rejection possible at both stages

7. **Report Generation**
   - LINQ queries for data filtering
   - PDF export functionality using iTextSharp
   - Customizable date ranges
   - Filter by status, lecturer, and date

---

## 🖥️ System Architecture

### Database Schema
```
Users
├── UserId (PK)
├── FirstName
├── LastName
├── Email (Unique)
├── PasswordHash
├── Role
├── HourlyRate (nullable)
├── CreatedDate
└── IsActive

Claims
├── ClaimId (PK)
├── LecturerId (FK → Users)
├── HoursWorked
├── HourlyRate
├── TotalAmount
├── ClaimMonth
├── Status
├── SubmittedDate
├── CoordinatorReviewDate
├── ManagerReviewDate
├── CoordinatorComments
└── ManagerComments

ClaimDocuments
├── DocumentId (PK)
├── ClaimId (FK → Claims)
├── FileName
├── FilePath
└── UploadedDate
```

### Application Flow
1. **HR** creates user accounts with credentials
2. **Lecturers** login and submit claims
3. **Coordinator** reviews pending claims (first approval)
4. **Manager** provides final approval (second approval)
5. **HR** generates reports for approved claims

---

## 🔐 Security Features

1. **Password Hashing**
   - PBKDF2 with HMAC-SHA256
   - 10,000 iterations
   - Unique salt per password

2. **Session Management**
   - HttpOnly cookies
   - Secure cookie policy
   - 30-minute idle timeout
   - Anti-forgery tokens on forms

3. **Role-Based Access Control**
   - Custom AuthorizeSession attribute
   - Page-level access restrictions
   - Automatic redirection for unauthorized access

4. **Input Validation**
   - Server-side validation
   - Client-side validation
   - SQL injection prevention
   - XSS protection

---

## 📊 Key Code Implementations

### 1. Auto-Calculation Feature
Located in: `Controllers/LecturerController.cs` - SubmitClaim method

```csharp
// Auto-calculate total amount
var totalAmount = model.HoursWorked * model.HourlyRate;

var claim = new Claim
{
    LecturerId = userId.Value,
    HoursWorked = model.HoursWorked,
    HourlyRate = model.HourlyRate,
    TotalAmount = totalAmount, // Auto-calculated
    ClaimMonth = model.ClaimMonth,
    Status = "Pending"
};
```

### 2. Session Management
Located in: `Helpers/SessionHelper.cs`

```csharp
public static void SetUserSession(ISession session, int userId, 
    string email, string role, string name)
{
    session.SetInt32("UserId", userId);
    session.SetString("UserEmail", email);
    session.SetString("UserRole", role);
    session.SetString("UserName", name);
}
```

### 3. PDF Report Generation
Located in: `Helpers/PdfGenerator.cs`

```csharp
public static byte[] GenerateClaimReport(List<Claim> claims, string reportTitle)
{
    // Uses iTextSharp to generate PDF
    // Includes statistics and claim details
    // Returns byte array for download
}
```

### 4. LINQ Report Queries
Located in: `Controllers/HRController.cs` - GenerateReport method

```csharp
var query = _context.Claims
    .Include(c => c.Lecturer)
    .Where(c => c.SubmittedDate >= startDate && c.SubmittedDate <= endDate)
    .OrderByDescending(c => c.SubmittedDate);
```

---

## 📹 Video Demonstration

**YouTube Video Link:** [Insert your unlisted YouTube link here]

**Video Contents:**
1. Login demonstration for all roles (0:00 - 2:00)
2. HR user management features (2:00 - 4:00)
3. Lecturer claim submission (4:00 - 6:00)
4. Coordinator review process (6:00 - 8:00)
5. Manager approval process (8:00 - 10:00)
6. Report generation and PDF export (10:00 - 12:00)
7. Session management and security features (12:00 - 14:00)

**Video Settings:** Unlisted (NOT private, NOT public)  
**Duration:** 10-15 minutes

---

## 📚 Testing Guide

### Test Scenario 1: Complete Claim Workflow
1. Login as HR → Create new lecturer
2. Login as lecturer → Submit claim
3. Login as coordinator → Review and approve
4. Login as manager → Final approval
5. Login as HR → Generate report

### Test Scenario 2: Validation Testing
1. Try submitting claim with > 180 hours
2. Try submitting duplicate claim for same month
3. Try accessing unauthorized pages
4. Test session timeout (wait 30 minutes)

### Test Scenario 3: Rejection Workflow
1. Submit claim as lecturer
2. Reject as coordinator with comments
3. Verify lecturer can see rejection

---

## 🐛 Known Issues & Limitations

1. **File Upload Size:** Maximum file size is 10MB per document
2. **Browser Compatibility:** Optimized for Chrome, Edge, Firefox
3. **Session Storage:** Uses in-memory storage (not distributed)
4. **PDF Generation:** Basic styling, can be enhanced

---

## 🚀 Future Enhancements

1. Email notifications for claim status changes
2. Bulk claim approval
3. Advanced analytics dashboard
4. Mobile application
5. Integration with payroll systems
6. Document preview before download
7. Claim amendment functionality
8. Audit trail logging

---

## 📝 Commit History

This project has been developed with regular commits to GitHub:

1. Initial project setup and structure
2. Created database models and DbContext
3. Implemented authentication and session management
4. Added HR user management functionality
5. Implemented lecturer claim submission
6. Added coordinator review features
7. Implemented manager approval system
8. Added PDF report generation
9. Enhanced UI/UX with Bootstrap
10. Final testing and bug fixes
11. Documentation and README updates
12. [Additional commits as needed]

---

## 📄 License

This project is submitted as part of PROG6212 coursework at [Your Institution Name].

---

## 🤝 Acknowledgments

- **Lecturer:** [Lecturer Name] - For guidance and feedback
- **Marking Center** - For clarification on Entity Framework requirements
- **Classmates** - For collaborative discussions

---

## 📞 Contact

**Student Name:** [Your Name]  
**Email:** [Your Email]  
**Student Number:** [Your Number]

---

## 🔗 Links

- **GitHub Repository:** [Your GitHub Link]
- **Video Demonstration:** [Your YouTube Link]
- **PowerPoint Presentation:** Available in repository

---

## ✅ Submission Checklist

- [x] Source code committed to GitHub
- [x] SQL script included
- [x] README.md with setup instructions
- [x] PowerPoint presentation prepared
- [x] YouTube video recorded (unlisted)
- [x] Minimum 10 GitHub commits
- [x] All features implemented
- [x] Session management working
- [x] PDF generation functional
- [x] Two-stage approval process
- [x] 180-hour validation
- [x] Auto-calculation working
- [x] No registration functionality
- [x] HR creates all users

---

**Last Updated:** [Current Date]  
**Version:** 1.0.0
