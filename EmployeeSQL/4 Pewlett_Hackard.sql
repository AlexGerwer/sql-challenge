CREATE TABLE departments (
    dept_no VARCHAR(4) NOT NULL PRIMARY KEY,
    dept_name VARCHAR(40) NOT NULL  -- Added NOT NULL as dept_name is important
);

CREATE TABLE titles (
    title_id VARCHAR(5) NOT NULL PRIMARY KEY,
    title VARCHAR(50) NOT NULL -- Added NOT NULL
);

CREATE TABLE employees (
    emp_no INT NOT NULL PRIMARY KEY,
    emp_title_id VARCHAR(5) NOT NULL,  -- Added NOT NULL constraint
    birth_date DATE NOT NULL,         -- Added NOT NULL constraint
    first_name VARCHAR(20) NOT NULL,    -- Added NOT NULL constraint
    last_name VARCHAR(20) NOT NULL,     -- Added NOT NULL constraint
    sex VARCHAR(1) NOT NULL,          -- Added NOT NULL constraint
    hire_date DATE NOT NULL,          -- Added NOT NULL constraint
    FOREIGN KEY (emp_title_id) REFERENCES titles (title_id)
);

CREATE TABLE dept_emp (
    emp_no INT NOT NULL,
    dept_no VARCHAR(4) NOT NULL,
    PRIMARY KEY (emp_no, dept_no),  -- Composite PK
    FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
    FOREIGN KEY (dept_no) REFERENCES departments (dept_no)
);

CREATE TABLE dept_manager (
    dept_no VARCHAR(4) NOT NULL,
    emp_no INT NOT NULL,
    PRIMARY KEY (dept_no, emp_no),  -- Composite PK
    FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
    FOREIGN KEY (emp_no) REFERENCES employees (emp_no)
);

CREATE TABLE salaries (
    emp_no INT NOT NULL PRIMARY KEY,
    salary INT NOT NULL,  -- Added NOT NULL constraint
    FOREIGN KEY (emp_no) REFERENCES employees (emp_no)
);

-- Import data from CSV files (note order of insertion)
COPY departments FROM 'C:\Program Files\PostgreSQL\17\data\departments.csv' WITH (FORMAT CSV, HEADER); 
COPY titles FROM 'C:\Program Files\PostgreSQL\17\data\titles.csv' WITH (FORMAT CSV, HEADER);
COPY employees FROM 'C:\Program Files\PostgreSQL\17\data\employees.csv' WITH (FORMAT CSV, HEADER);
COPY salaries FROM 'C:\Program Files\PostgreSQL\17\data\salaries.csv' WITH (FORMAT CSV, HEADER);
COPY dept_emp FROM 'C:\Program Files\PostgreSQL\17\data\dept_emp.csv' WITH (FORMAT CSV, HEADER); 
COPY dept_manager FROM 'C:\Program Files\PostgreSQL\17\data\dept_manager.csv' WITH (FORMAT CSV, HEADER);

-- Check that each table is populated correctly
SELECT * FROM departments LIMIT 10;
SELECT * FROM titles LIMIT 10;
SELECT * FROM employees LIMIT 10;
SELECT * FROM salaries LIMIT 10;
SELECT * FROM dept_emp LIMIT 10;
SELECT * FROM dept_manager LIMIT 10;

-- Data Analysis inquiries 
-- 1. List the employee number, last name, first name, sex, and salary of each employee.
SELECT e.emp_no, e.last_name, e.first_name, e.sex, s.salary
FROM employees AS e
JOIN salaries AS s ON e.emp_no = s.emp_no;

-- 2. List the first name, last name, and hire date for the employees who were hired in 1986.
SELECT first_name, last_name, hire_date
FROM employees
WHERE EXTRACT(YEAR FROM hire_date) = 1986;

-- 3. List the manager of each department along with their department number, department name, employee number, last name, and first name.
SELECT dm.dept_no, d.dept_name, dm.emp_no, e.last_name, e.first_name
FROM dept_manager AS dm
JOIN departments AS d ON dm.dept_no = d.dept_no
JOIN employees AS e ON dm.emp_no = e.emp_no;

-- 4. List the department number for each employee along with that employee’s employee number, last name, first name, and department name.
-- Note this does not select only the latest department to which an employee was assigned as department assignment dates are not in the data.
SELECT de.dept_no, e.emp_no, e.last_name, e.first_name, d.dept_name
FROM dept_emp AS de
JOIN employees AS e ON de.emp_no = e.emp_no
JOIN departments AS d ON de.dept_no = d.dept_no;

-- 5. List first name, last name, and sex of each employee whose first name is Hercules and whose last name begins with the letter B.
SELECT first_name, last_name, sex
FROM employees
WHERE first_name = 'Hercules' AND last_name LIKE 'B%';

-- 6. List each employee in the Sales department, including their employee number, last name, and first name.
SELECT e.emp_no, e.last_name, e.first_name
FROM employees AS e
JOIN dept_emp AS de ON e.emp_no = de.emp_no
JOIN departments AS d ON de.dept_no = d.dept_no
WHERE d.dept_name = 'Sales';


-- 7. List each employee in the Sales and Development departments, including their employee number, last name, first name, and department name.
SELECT e.emp_no, e.last_name, e.first_name, d.dept_name
FROM employees AS e
JOIN dept_emp AS de ON e.emp_no = de.emp_no
JOIN departments AS d ON de.dept_no = d.dept_no
WHERE d.dept_name IN ('Sales', 'Development');


-- 8. List the frequency counts, in descending order, of all the employee last names (that is, how many employees share each last name).
SELECT last_name, COUNT(*) AS frequency
FROM employees
GROUP BY last_name
ORDER BY frequency DESC;