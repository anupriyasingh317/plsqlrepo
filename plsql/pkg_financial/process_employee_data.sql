-- Create a permanent table
CREATE TABLE employees (
    employee_id NUMBER PRIMARY KEY,
    first_name VARCHAR2(50),
    last_name VARCHAR2(50),
    salary NUMBER,
    department_id NUMBER
);

-- Insert sample data into the permanent table
INSERT INTO employees VALUES (1, 'John', 'Doe', 5000, 10);
INSERT INTO employees VALUES (2, 'Jane', 'Smith', 6000, 20);
INSERT INTO employees VALUES (3, 'Mike', 'Johnson', 7000, 10);
INSERT INTO employees VALUES (4, 'Emily', 'Davis', 8000, 30);

-- Commit the data
COMMIT;

-- Create a global temporary table for intermediate processing
CREATE GLOBAL TEMPORARY TABLE temp_employees (
    employee_id NUMBER,
    first_name VARCHAR2(50),
    last_name VARCHAR2(50),
    salary NUMBER,
    department_id NUMBER
) ON COMMIT DELETE ROWS;

-- Create a PL/SQL procedure
CREATE OR REPLACE PROCEDURE process_employee_data IS
BEGIN
    -- Step 1: Insert employees with salary greater than 6000 into the temporary table
    INSERT INTO temp_employees
    SELECT * 
    FROM employees
    WHERE salary > 6000;

    -- Step 2: Update the salary in the permanent table for employees in department 10
    UPDATE employees
    SET salary = salary * 1.1
    WHERE department_id = 10;

    -- Step 3: Display the contents of the temporary table
    FOR rec IN (SELECT * FROM temp_employees) LOOP
        DBMS_OUTPUT.PUT_LINE('Employee ID: ' || rec.employee_id 
                             ||', Name: ' || rec.first_name || ' ' || rec.last_name 
                            || ', Salary: ' || rec.salary ||
                             ', Department ID: ' || rec.department_id);
    END LOOP;
END;
/

-- Check the updated permanent table
SELECT * FROM employees;
