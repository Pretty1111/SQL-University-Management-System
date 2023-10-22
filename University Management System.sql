-- Creating the University Management System database
CREATE DATABASE UniversityManagementSystem;
USE UniversityManagementSystem;

-- Creating the departments table
CREATE TABLE departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(255) NOT NULL
);

-- Creating the students table
CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    date_of_birth DATE NOT NULL,
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- Creating the professors table
CREATE TABLE professors (
    professor_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE
);

-- Creating the courses table
CREATE TABLE courses (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    course_name VARCHAR(255) NOT NULL,
    department_id INT,
    professor_id INT,
    FOREIGN KEY (department_id) REFERENCES departments(department_id),
    FOREIGN KEY (professor_id) REFERENCES professors(professor_id)
);

-- Creating the enrollments table
CREATE TABLE enrollments (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT,
    course_id INT,
    grade VARCHAR(2),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

-- Creating Join and View
CREATE VIEW v_student_courses AS
SELECT s.first_name, s.last_name, c.course_name, d.department_name
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
JOIN courses c ON e.course_id = c.course_id
JOIN departments d ON c.department_id = d.department_id;

-- Creating a function that counts the number of students in a given department
DELIMITER //

CREATE FUNCTION count_students_in_department(dept_name VARCHAR(255))
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE student_count INT DEFAULT 0;
    SELECT COUNT(*) INTO student_count
    FROM students s
    JOIN departments d ON s.department_id = d.department_id
    WHERE d.department_name = dept_name;
    RETURN student_count;
END //

DELIMITER ;


-- Populating the departments table
INSERT INTO departments(department_name) VALUES 
('Computer Science'),
('Mathematics'),
('Biology'),
('Chemistry'),
('Physics'),
('English Literature'),
('History'),
('Social Policy'),
('Sociology'),
('Economics');

-- Populating the professors table
INSERT INTO professors(first_name, last_name, email) VALUES 
('John', 'Doe', 'john.doe@university.com'),
('Jane', 'Smith', 'jane.smith@university.com'),
('Robert', 'Brown', 'robert.brown@university.com'),
('Emily', 'Johnson', 'emily.johnson@university.com'),
('Michael', 'Taylor', 'michael.taylor@university.com'),
('Sarah', 'Miller', 'sarah.miller@university.com'),
('James', 'Davis', 'james.davis@university.com'),
('Linda', 'Jones', 'linda.jones@university.com'),
('William', 'Rodriguez', 'william.rodriguez@university.com'),
('Jessica', 'Martinez', 'jessica.martinez@university.com');

-- Populating the students table
INSERT INTO students(first_name, last_name, email, date_of_birth, department_id) VALUES 
('Alice', 'Adams', 'alice.adams@student.university.com', '1995-04-20', 1),
('Bob', 'Baker', 'bob.baker@student.university.com', '1996-03-15', 2),
('Charlie', 'Clark', 'charlie.clark@student.university.com', '1997-02-10', 3),
('David', 'Dunn', 'david.dunn@student.university.com', '1994-01-05', 4),
('Eve', 'Evans', 'eve.evans@student.university.com', '1995-12-25', 8),
('Frank', 'Franklin', 'frank.franklin@student.university.com', '1996-11-20', 9),
('Grace', 'Green', 'grace.green@student.university.com', '1997-10-15', 6),
('Henry', 'Hall', 'henry.hall@student.university.com', '1994-09-10', 7),
('Ivy', 'Iverson', 'ivy.iverson@student.university.com', '1995-08-05', 5),
('Jack', 'Jackson', 'jack.jackson@student.university.com', '1996-07-30', 10);

-- Populating the courses table
INSERT INTO courses(course_name, department_id, professor_id) VALUES 
('Introduction to Programming', 1, 1),
('Advanced Mathematics', 2, 2),
('Biology 101', 3, 3),
('Chemistry Basics', 4, 4),
('Physics for Beginners', 5, 5),
('English Classics', 6, 6),
('World History', 7, 7),
('Social Policy Fundamentals', 8, 8),
('Sociology 101', 9, 9),
('Economic Theories', 10, 10);

-- Populating the enrollments table
INSERT INTO enrollments(student_id, course_id, grade) VALUES 
(1, 1, 'A'),
(2, 2, 'B'),
(3, 3, 'C'),
(4, 4, 'B'),
(5, 5, 'A'),
(6, 6, 'B'),
(7, 7, 'C'),
(8, 8, 'A'),
(9, 9, 'B'),
(10, 10, 'A');


-- Query to view the contents of the v_student_courses view created earlier
SELECT * FROM v_student_courses;


-- Creating a Column Subquery to list all students who are enrolled in any course from the 'Social Policy' department
SELECT first_name, last_name 
FROM students 
WHERE student_id IN (
    SELECT student_id 
    FROM enrollments 
    WHERE course_id IN (
        SELECT course_id 
        FROM courses 
        WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Social Policy')
    )
);

-- Creating a subquery to show a list of all departments along with their student counts
SELECT 
    d.department_name, 
    (SELECT COUNT(*) FROM students s WHERE s.department_id = d.department_id) AS student_count
FROM 
    departments d;

-- Similarly, the function already created can just be called to list all departments along with the number of students in each department
SELECT department_name, count_students_in_department(department_name) AS student_count
FROM departments;

-- Listing all courses along with their respective departments
SELECT 
    c.course_name,
    d.department_name
FROM 
    courses c
JOIN 
    departments d ON c.department_id = d.department_id;
    
    
    
-- ADVANCED OPTIONS ---

-- Creating a procedure that enrolls a student into a course:
DELIMITER //
CREATE PROCEDURE EnrollStudentToCourse(IN stud_id INT, IN cour_id INT)
BEGIN
    INSERT INTO enrollments(student_id, course_id) VALUES(stud_id, cour_id);
END //
DELIMITER ;

-- Calling the Procedure
CALL EnrollStudentToCourse(1, 5);

-- Fetch and display the added enrolment record
SELECT * FROM enrollments WHERE student_id = 1 AND course_id = 5;
-- display all rows including the newly added one
SELECT * FROM enrollments;


-- Creating a View and Query that lists professors, their department, and the number of courses they teach
CREATE VIEW v_professor_data AS
SELECT p.first_name, p.last_name, d.department_name, COUNT(c.course_id) as course_count
FROM professors p
JOIN courses c ON p.professor_id = c.professor_id
JOIN departments d ON c.department_id = d.department_id
GROUP BY p.professor_id, d.department_id;

-- To see the reults of this view
SELECT * FROM v_professor_data WHERE course_count >= 1;


-- Querying with GROUP BY and HAVING to list departments with one or more courses
SELECT d.department_name, COUNT(c.course_id) as course_count
FROM departments d
JOIN courses c ON d.department_id = c.department_id
GROUP BY d.department_id
HAVING course_count >= 1;


-- Creating a comprehensive view for student enrollments, courses, professors, and departments
CREATE VIEW v_student_enrollment_details AS
SELECT 
    s.first_name AS student_first_name,
    s.last_name AS student_last_name,
    s.email AS student_email,
    c.course_name,
    p.first_name AS professor_first_name,
    p.last_name AS professor_last_name,
    d.department_name
FROM 
    students s
JOIN 
    enrollments e ON s.student_id = e.student_id
JOIN 
    courses c ON e.course_id = c.course_id
JOIN 
    professors p ON c.professor_id = p.professor_id
JOIN 
    departments d ON c.department_id = d.department_id;

-- Query to analyze the enrollments, courses, and professors for all departments
SELECT 
    student_first_name,
    student_last_name,
    student_email,
    course_name,
    professor_first_name,
    professor_last_name
FROM 
    v_student_enrollment_details

ORDER BY 
    course_name, student_last_name, student_first_name;




