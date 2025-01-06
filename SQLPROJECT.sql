CREATE TABLE Students (
    StudentID NUMBER PRIMARY KEY,
    FirstName VARCHAR2(50),
    LastName VARCHAR2(50),
    Email VARCHAR2(100),
    PhoneNumber VARCHAR2(15)
);

INSERT INTO Students (StudentID, FirstName, LastName, Email, PhoneNumber) VALUES
(1, 'Aryan', 'Sabale', 'aryansabale@gmail.com', '123-456-7890');
INSERT INTO Students (StudentID, FirstName, LastName, Email, PhoneNumber) VALUES
(2, 'Amit', 'Patil', 'amitpatil@gmail.com', '987-654-3210');
INSERT INTO Students (StudentID, FirstName, LastName, Email, PhoneNumber) VALUES
(3, 'Krushna', 'Sase', 'krushnasase@gmail.com', '456-789-0123');
INSERT INTO Students (StudentID, FirstName, LastName, Email, PhoneNumber) VALUES
(4, 'Tejandrasing', 'Patil', 'tejandrasing@gmail.com', '562-568-0223');
INSERT INTO Students (StudentID, FirstName, LastName, Email, PhoneNumber) VALUES
(5, 'Avdhoot', 'Wakale', 'avdhootwakale@gmail.com', '789-455-2365');
INSERT INTO Students (StudentID, FirstName, LastName, Email, PhoneNumber) VALUES
(6, 'Sujal', 'Sahane', 'sujalsahane@gmail.com', '784-598-6247');
INSERT INTO Students (StudentID, FirstName, LastName, Email, PhoneNumber) VALUES
(7, 'Harshal', 'Mhetre', 'harshalmhetre@gmail.com', '457-896-8855');
INSERT INTO Students (StudentID, FirstName, LastName, Email, PhoneNumber) VALUES
(8, 'Manish', 'Naik', 'manishnaik@gmail.com', '789-231-5644');
INSERT INTO Students (StudentID, FirstName, LastName, Email, PhoneNumber) VALUES
(9, 'Yash', 'Patil', 'krushnasase@gmail.com', '123-987-4560');

select * from Students;

CREATE TABLE Courses (
    CourseID NUMBER PRIMARY KEY,
    CourseName VARCHAR2(100),
    Instructor VARCHAR2(100)
);

INSERT INTO Courses (CourseID, CourseName, Instructor) VALUES
(101, 'Mathematics', 'Dr. Alan Turing');
INSERT INTO Courses (CourseID, CourseName, Instructor) VALUES
(102, 'Physics', 'Dr. Marie Curie');
INSERT INTO Courses (CourseID, CourseName, Instructor) VALUES
(103, 'Computer Science', 'Dr. Ada Lovelace');

select * from courses;

CREATE TABLE Attendance (
    AttendanceID NUMBER PRIMARY KEY,
    StudentID NUMBER,
    CourseID NUMBER,
    AttendanceDate DATE,
    Status VARCHAR2(10) CHECK (Status IN ('Present', 'Absent')),
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID)
);

INSERT INTO Attendance (AttendanceID, StudentID, CourseID, AttendanceDate, Status) VALUES
(1, 1, 101, DATE '2025-01-02', 'Present');
INSERT INTO Attendance (AttendanceID, StudentID, CourseID, AttendanceDate, Status) VALUES
(2, 1, 102, DATE '2025-01-02', 'Absent');
INSERT INTO Attendance (AttendanceID, StudentID, CourseID, AttendanceDate, Status) VALUES
(3, 2, 101, DATE '2025-01-02', 'Present');
INSERT INTO Attendance (AttendanceID, StudentID, CourseID, AttendanceDate, Status) VALUES
(4, 2, 103, DATE '2025-01-02', 'Present');
INSERT INTO Attendance (AttendanceID, StudentID, CourseID, AttendanceDate, Status) VALUES
(5, 3, 102, DATE '2025-01-02', 'Absent');
INSERT INTO Attendance (AttendanceID, StudentID, CourseID, AttendanceDate, Status) VALUES
(6, 3, 103, DATE '2025-01-02', 'Present');

select * from Attendance;

CREATE OR REPLACE PROCEDURE CalculateAttendancePercentage (
    p_StudentID INT,
    p_CourseID INT,
    p_Percentage OUT FLOAT
) AS
BEGIN
    SELECT (SUM(CASE WHEN Status = 'Present' THEN 1 ELSE 0 END) * 100.0 / COUNT(*))
    INTO p_Percentage
    FROM Attendance
    WHERE StudentID = p_StudentID AND CourseID = p_CourseID;
END;
/


CREATE OR REPLACE TRIGGER NotifyLowAttendance
FOR INSERT OR UPDATE ON Attendance
COMPOUND TRIGGER
    TYPE AttendanceInfo IS RECORD (
        StudentID INT,
        CourseID INT
    );
    TYPE AttendanceInfoList IS TABLE OF AttendanceInfo;
    attendance_data AttendanceInfoList := AttendanceInfoList();
    v_Percentage FLOAT;
    v_Threshold FLOAT := 75; 

    BEFORE STATEMENT IS
    BEGIN
        attendance_data := AttendanceInfoList(); 
    END BEFORE STATEMENT;

    AFTER EACH ROW IS
    BEGIN
        attendance_data.EXTEND;
        attendance_data(attendance_data.COUNT) := AttendanceInfo(:NEW.StudentID, :NEW.CourseID);
    END AFTER EACH ROW;
    AFTER STATEMENT IS
    BEGIN
        FOR i IN attendance_data.FIRST .. attendance_data.LAST LOOP
            BEGIN
                SELECT (SUM(CASE WHEN Status = 'Present' THEN 1 ELSE 0 END) * 100.0 / COUNT(*))
                INTO v_Percentage
                FROM Attendance
                WHERE StudentID = attendance_data(i).StudentID
                  AND CourseID = attendance_data(i).CourseID;
                IF v_Percentage < v_Threshold THEN
                    DBMS_OUTPUT.PUT_LINE('Alert: Student ' || attendance_data(i).StudentID || 
                                         ' has low attendance (' || v_Percentage || '%).');
                END IF;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    NULL; 
            END;
        END LOOP;
    END AFTER STATEMENT;
END NotifyLowAttendance;
/


SELECT 
    s.StudentID,
    s.FirstName,
    s.LastName,
    c.CourseName,
    (SUM(CASE WHEN a.Status = 'Present' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS AttendancePercentage
FROM 
    Students s
    JOIN Attendance a ON s.StudentID = a.StudentID
    JOIN Courses c ON a.CourseID = c.CourseID
GROUP BY 
    s.StudentID, s.FirstName, s.LastName, c.CourseName
ORDER BY 
    s.StudentID, c.CourseName;






