# *****************************************************************************
# ***************************** TinyGearz Database ****************************
# *****************************************************************************

# Importing from other modules.
import sqlite3
from string import punctuation
from time import sleep

from tools import sections


# Defining various functions.
# *****************************************************************************
def file_names(type):
    special_char = set(punctuation.replace(".", "").replace("_", ""))
    if type == "db":
        while True:
            try:
                db_file = input(
                    "Press *Enter* to use or assign the default "
                    "database, or\nenter the name you want to "
                    "assign to your database file\n\nAnswer: "
                )

                if any(char in special_char for char in db_file):
                    raise ValueError
                elif db_file == "":
                    db_file = "tinygearz.db"

                sections(8)
                print("The selected database filename is: ", db_file)
                sections(7)
                # Writing the name of the newly created database to a text
                # file, to being able to skip this step
                # when using the database in the future.
                file = open("current db.txt", "w")
                file.write(db_file)
                file.close()
                sleep(0.5)
                return db_file
            except ValueError:
                print("\n" + "No special letters allowed! Try again!")
                sections(7)

    elif type == "sql":
        while True:
            try:
                sql_script_file = input(
                    "Press *Enter* to assign the default sql script name, "
                    "\nor enter the name of the file you want to use"
                    "\n\nAnswer: "
                )

                if any(char in special_char for char in sql_script_file):
                    raise ValueError
                elif sql_script_file == "":
                    sql_script_file = "tinygearz_script.sql"

                sections(8)
                print("The selected sql script filename is: ", sql_script_file)
                sections(7)
                sleep(0.5)
                return sql_script_file
            except ValueError:
                print("\n" + "No special letters allowed! Try again!")
                sections(7)


# *****************************************************************************
def db_setup(db_file_name):
    """Function for setting up a connection to a database using sqlite3,
    then creating a cursor object.

    Args:
        db_file_name: The name given to the database file.
        .db will be added if missing.
    """
    global conn, cur
    if ".db" not in db_file_name:
        db_file_name += ".db"
    conn = sqlite3.connect(db_file_name)
    cur = conn.cursor()


# *****************************************************************************
def sql_script_reader(sql_script_file_name):
    while True:
        try:
            if ".sql" not in sql_script_file_name:
                sql_script_file_name += ".sql"
            # Open file containing the sql script.
            sql_script_file = open(sql_script_file_name, "r")
            # Reading and executing the script.
            cur.executescript(sql_script_file.read())
            # Committing all changes to the database.
            conn.commit()
            # Closing the script file.
            sql_script_file.close()
            break
        except FileNotFoundError:
            print("File does not exist!")
            sections(7)
            sql_script_file_name = file_names("sql")
            continue


# *****************************************************************************
def query_formatter(query_input, spaces):
    while True:
        sections(7)
        menu_choice = input(
            "Do you want regular output, "
            "or special formatting?\n\n"
            "[1] Regular\n"
            "[2] Special\n"
            "[Q] Quit to previous menu\n\n"
            "Answer: "
        )

        if menu_choice == "1":
            sections(7)
            query = list(cur.execute(query_input))
            col_names = list(map(lambda x: x[0], cur.description))
            print(col_names)
            for row in cur.execute(query_input):
                print(row)
            continue
        elif menu_choice == "2":
            sections(7)
            query = list(cur.execute(query_input))
            col_names = list(map(lambda x: x[0], cur.description))
            col_space = spaces + 2
            print(*col_names, sep=(" " * col_space))
            line = list()
            for row in range(len(query)):
                for cols in range(len(col_names)):
                    col_name_len = (
                        spaces
                        + len(col_names[cols])
                        - (len(str(query[row][cols])))
                    )
                    space = " " * col_name_len
                    line.append(query[row][cols])
                    line.append(space)
                print(*line)
                line.clear()
            continue
        elif menu_choice.lower() == "q":
            # Exits the application
            break
        else:
            print("\nInvalid input! Please try again!")
            sections(7)
            continue
        continue


# ******************************** Main program *******************************
# Checking if a database has been setup earlier and selecting it as the current
try:
    file = open("current db.txt", "r")
    db_file = file.read()
    file.close()
    print(db_file)
except FileNotFoundError:
    pass

while True:
    try:
        # Printing header.
        sections(0)
        menu_choice = input(
            "Please choose an action from the menu\n\n"
            "[1] Define new database\n"
            "[2] Queries\n"
            "[3] Book service\n"
            "[Q] Quit\n\n"
            "Answer: "
        )

        if menu_choice == "1":
            sections(1)
            # Having the user decide om which filenames to use.
            db_file = file_names("db")
            sql_script_file = file_names("sql")

            # Connect to a database and creating a cursor object.
            db_setup(db_file)

            # Reading and executing an sql script from a file.
            sql_script_reader(sql_script_file)

            # Committing all changes to the database.
            conn.commit()

            # Closing the connection to the database.
            conn.close()
            continue

        elif menu_choice == "2":
            while True:
                sections(2)
                # Connect to a database and creating a cursor object.
                db_setup(db_file)
                menu_choice = input(
                    "Please choose an action from the menu\n\n"
                    "[1] Table chooser\n"
                    "[2] All customers with watches\n"
                    "[3] All open service tickets and "
                    "mechanics'\n"
                    "[4] Employee and department\n"
                    "[5] Watch service this month\n"
                    "[Q] Quit to previous menu\n\n"
                    "Answer: "
                )
                if menu_choice == "1":
                    while True:
                        sections(21)
                        menu_choice = input(
                            "Please choose which table you "
                            "want to display from the menu\n\n"
                            "[1] Customers\n"
                            "[2] Employees\n"
                            "[3] Salespersons\n"
                            "[4] Mechanics\n"
                            "[5] Service tickets\n"
                            "[6] Service ticket mechanics\n"
                            "[7] Brand certifications\n"
                            "[8] Watches\n"
                            "[9] Models\n"
                            "[10] Inventory\n"
                            "[11] Used parts\n"
                            "[Q] Quit to previous menu\n\n"
                            "Answer: "
                        )
                        if menu_choice == "1":
                            query_formatter("SELECT * FROM customer", 4)
                            continue
                        elif menu_choice == "2":
                            query_formatter("SELECT * FROM employee", 10)
                            continue
                        elif menu_choice == "3":
                            query_formatter("SELECT * FROM salesperson", 2)
                            continue
                        elif menu_choice == "4":
                            query_formatter("SELECT * FROM mechanic", 2)
                            continue
                        elif menu_choice == "5":
                            query_formatter("SELECT * FROM service_ticket", 4)
                            continue
                        elif menu_choice == "6":
                            query_formatter(
                                "SELECT * " "FROM service_ticket_mechanic", 2
                            )
                            continue
                        elif menu_choice == "7":
                            query_formatter(
                                "SELECT * " "FROM brand_certification", 4
                            )
                            continue
                        elif menu_choice == "8":
                            query_formatter("SELECT * FROM watch", 6)
                            continue
                        elif menu_choice == "9":
                            query_formatter("SELECT * FROM model", 13)
                            continue
                        elif menu_choice == "10":
                            query_formatter("SELECT * FROM inventory", 13)
                            continue
                        elif menu_choice == "11":
                            query_formatter("SELECT * FROM used_part", 2)
                            continue
                        elif menu_choice.lower() == "q":
                            # Exits the application
                            break
                        else:
                            print("\nInvalid input! Please try again!")
                            sections(7)
                            continue
                        continue
                    continue

                elif menu_choice == "2":
                    # All customers with watches
                    query_formatter(
                        "SELECT c.first_name AS 'Name:', "
                        "c.last_name AS 'Surname:', "
                        "w.manufacturer AS 'Brand:', "
                        "m.model_name AS 'Model:', "
                        "w.serial_number AS 'Serial number:', "
                        "w.value_estimate AS 'Value' "
                        "FROM customer AS c, watch AS w, "
                        "model AS m "
                        "WHERE c.customer_id = w.customer_id AND "
                        "m.model_id = w.model_id "
                        "ORDER BY c.first_name",
                        16,
                    )
                    continue
                elif menu_choice == "3":
                    # All open service tickets and mechanics'
                    query_formatter(
                        "SELECT st.service_ticket_id "
                        "AS 'Service ticket ID:', "
                        "e.first_name AS 'Name:', "
                        "e.last_name AS 'Surname:' "
                        "FROM service_ticket AS st "
                        "INNER JOIN service_ticket_mechanic "
                        "AS stm "
                        "ON st.service_ticket_id "
                        "= stm.service_ticket_id "
                        "INNER JOIN mechanic "
                        "ON stm.mechanic_id "
                        "= mechanic.mechanic_id "
                        "INNER JOIN employee AS e "
                        "ON mechanic.employee_id = e.employee_id "
                        "WHERE st.returned IS NULL",
                        16,
                    )
                    continue
                elif menu_choice == "4":
                    # Employees and their departments
                    query_formatter(
                        "SELECT e.first_name AS 'Name:', "
                        "e.last_name AS 'Surname:', "
                        "e.employee_id AS 'Employee ID', "
                        "sp.salesperson_id AS 'Salesperson ID', "
                        "m.mechanic_id AS 'Mechanic ID' "
                        "FROM (SELECT e.employee_id, "
                        "e.first_name, "
                        "e.last_name "
                        "FROM employee AS e) AS e "
                        "LEFT OUTER JOIN salesperson AS sp "
                        "ON sp.employee_id = e.employee_id "
                        "LEFT OUTER JOIN mechanic AS m "
                        "ON m.employee_id = e.employee_id",
                        5,
                    )
                    continue
                elif menu_choice == "5":
                    # Employees and their departments
                    query_formatter(
                        "SELECT s.received, w.watch_id, "
                        "c.first_name, c.middle_name, "
                        "c.last_name "
                        "FROM watch AS w "
                        "INNER JOIN customer AS c "
                        "ON c.customer_id = w.customer_id "
                        "INNER JOIN service_ticket AS s "
                        "ON s.watch_id = w.watch_id "
                        "WHERE strftime('%Y-%m', s.received) "
                        "= strftime('%Y-%m', CURRENT_DATE)"
                        "ORDER BY s.received, w.watch_id",
                        5,
                    )
                    continue
                elif menu_choice.lower() == "q":
                    # Exits the application
                    break
                else:
                    print("\nInvalid input! Please try again!")
                    sections(7)
                    continue
                continue

        elif menu_choice == "3":
            sections(2)
            db_setup(db_file)
            # Questions to insert into service ticket.
            questions = [
                "Watch ID: ",
                "Salesperson ID: ",
                "Labour rate: ",
                "Customer comment: ",
                "Received: ",
            ]
            answers = list()
            for item in range(len(questions)):
                answers.append(input(questions[item]))
            answers_temp = tuple(answers)
            answers.clear()
            answers.append(answers_temp)
            cur.executemany(
                "INSERT INTO service_ticket (watch_id, "
                "salesperson_id, labour_rate, customer_comment, "
                "received) VALUES "
                "(?, ?, ?, ?, ?)",
                answers,
            )
            conn.commit()
            conn.close()

            continue
        elif menu_choice.lower() == "q":
            # Exits the application
            break
        else:
            print("\nInvalid input! Please try again!")
            # sections(7)
            continue
    except NameError:
        print("No database exists! Please use option 1 in the main menu.")

# Printing farewell message and exiting the application.
sections(9)
