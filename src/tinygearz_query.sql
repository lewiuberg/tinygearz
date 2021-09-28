/* ************************************************************************* */
/* **************************** TinyGearz Query **************************** */
/* ************************************************************************* */

/* To not repeat the comments, only the first encounter will be commented on.*/

/* Setting up how the database is displayed when querying.                   */
.mode columns
.width auto /* auto is based on the attribute length of the first row. */
.headers on
.nullvalue NULL

/*************************** Querying the Database ***************************/
.print ''
/* All customers with details                                                */
.print 'All customers with details'
/* Aliasing the columbs */
SELECT customer_id AS 'Customer ID:',
        first_name AS 'Name:',
        middle_name AS 'Middle name:',
        last_name AS 'Surname:',
        streetname AS "Streetname:",
        building_number AS "Building number:",
        postal_code AS 'Postal code:',
        city AS 'City',
        phone_number AS 'Phone number:',
        e_mail AS 'E-mail:'
FROM customer;
.print ''

/* All customers with watches                                                */
.print 'All customers with watches'
SELECT c.first_name AS 'Name:',
        c.last_name AS 'Surname:',
        w.manufacturer AS 'Brand:',
        m.model_name AS 'Model:',
        w.serial_number AS 'Serial number:',
        w.value_estimate AS 'Value'
/* Implicit inner join                                                       */
FROM customer AS c, watch AS w, model AS m
WHERE c.customer_id = w.customer_id AND m.model_id = w.model_id
ORDER BY c.first_name;
.print ''

/* All open service tickets and mechanics                                    */
.print 'All open service tickets and mechanics'
SELECT st.service_ticket_id AS 'Service ticket ID:',
        e.first_name AS 'Name:',
        e.last_name AS 'Surname:'
/* Explicit inner join                                                       */
/* Joining all tables one by one requered to display wanted information      */
FROM service_ticket AS st
INNER JOIN service_ticket_mechanic AS stm
ON st.service_ticket_id = stm.service_ticket_id
INNER JOIN mechanic
ON stm.mechanic_id = mechanic.mechanic_id
INNER JOIN employee AS e
ON mechanic.employee_id = e.employee_id
WHERE st.returned IS NULL;
.print ''

/* Parts used in services                                                    */
.print 'Parts used in services'
SELECT i.part_id AS 'Part number:',
i.manufacturer AS 'Manufacturer:',
u.quantity_used AS 'Parts used:'
FROM used_part AS u
INNER JOIN inventory AS i
ON u.part_id = i.part_id
/* It is assumed that this is meant to be a summary of part type usage for   */
/* future purchasing, so grouping on part id has been added.                 */
GROUP BY u.part_id
ORDER BY u.quantity_used DESC;
.print ''
 
/* Report of services in May 2019.                                           */
.print 'Report of services in May 2019'
SELECT  s.service_ticket_id AS 'Service ticket ID:',
        s.returned AS 'Data returned:',
        c.first_name AS 'Name:',
        c.last_name AS 'Surname:',
        w.manufacturer AS 'Brand:',
        m.model_name AS 'Model:',
        i.description AS 'Part description:',
        u.quantity_used AS 'QTY:', 
        i.selling_price AS 'Part price:', 
        ROUND((i.selling_price * u.quantity_used), 2) AS 'Part cost:',
        s.labour_rate AS 'Labour rate:',
        s.labour_time AS 'Time used:',
/* Calculating the labour cost, and then the total sum.                      */
        (s.labour_time * (s.labour_rate / 60)) AS 'Labour cost:',
        ((s.labour_time * (s.labour_rate / 60))
        + (i.selling_price * u.quantity_used)) AS 'Sum:'
FROM service_ticket AS s
INNER JOIN watch AS w
ON w.watch_id = s.watch_id
INNER JOIN customer AS c
ON c.customer_id = w.customer_id
INNER JOIN used_part AS u
ON s.service_ticket_id = u.service_ticket_id
INNER JOIN inventory AS i
ON u.part_id = i.part_id
INNER JOIN model AS m
ON m.model_id = w.model_id
/* Spesifying year and month */
WHERE strftime('%Y-%m', s.returned) ='2019-05';
.print ''

/***************************** Additional Queries ****************************/

/* Employees and their departments                                           */
/* Displays all employees with their employee, salesperson and mechanic IDs. */
/* Quick way to get an overview in a expanding business.                     */
.print 'Employees and their departments'
.nullvalue ' '
SELECT e.first_name AS 'Name:',
        e.last_name AS 'Surname:',
        e.employee_id AS 'Employee ID',
        sp.salesperson_id AS 'Salesperson ID',
        m.mechanic_id AS 'Mechanic ID'
/* Specifying which parts to bring along into the join using a sub-selection */
FROM (SELECT e.employee_id,
             e.first_name,
             e.last_name
        FROM employee AS e) AS e
LEFT OUTER JOIN salesperson AS sp
ON sp.employee_id = e.employee_id
LEFT OUTER JOIN mechanic AS m
ON m.employee_id = e.employee_id;
.print ''
.nullvalue NULL

/* Certification controle.                                                   */
/* Displaying all mechanics, their certifications and the days until they    */
/* expire. This is useful to make sure all certifications are up to date.    */
.print 'Employees and their departments'
SELECT m.mechanic_id AS 'Mechanic ID',
        e.first_name AS 'Name:',
        e.last_name AS 'Surname:',
        b.brand_name AS 'Brand:',
        b.valid_from AS 'Valid from:',
        b.valid_to AS 'Valid to:',
        CAST((julianday(b.valid_to) - julianday('now', 'localtime')) 
        AS INTEGER) AS 'Day to expiration:'
/* Specifying which parts to bring along into the join using a sub-selection */
FROM (SELECT e.employee_id,
             e.first_name,
             e.last_name
        FROM employee AS e) AS e
LEFT OUTER JOIN mechanic AS m
ON m.employee_id = e.employee_id
INNER JOIN brand_certification AS b
ON b.mechanic_id = m.mechanic_id
WHERE m.employee_id = e.employee_id;
.print ''

/* Condition and eventual easy fix.                                          */
/* Selecting watches that a nice cosmetic condition, but have errors that may*/
/* be fixes cheaply with just lubrication.                                   */
/* It is assumend that Tiny Gearz will not provide a value estimation unless */
/* it is explisitly asked for.                                               */
.print 'Condition and eventual easy fix'
SELECT w.watch_id AS 'Watch ID:',
        w.manufacturer AS 'Brand:',
        m.model_name AS 'Model:',
        w.cosmetic_condition_rating AS 'Condition rating:',
        w.cosmetic_description AS 'Condition description:',
/* Changing out 1 for Yes and 0 for No.                                      */
        (CASE WHEN w.functioning = 1 THEN
            'Yes'
        ELSE
            'No'
        END) AS 'Functioning:',
        w.amplitude AS 'Amplitude:',
        s.service_comment AS 'Service comment:'
FROM watch AS w
INNER JOIN model AS m
ON m.model_id = w.model_id
INNER JOIN service_ticket AS s
ON s.watch_id = w.watch_id
WHERE w.cosmetic_condition_rating >= 4 AND 
      w.amplitude <= 250 AND
/* Not including service comments that has the combination "lub" in it       */
      s.service_comment NOT LIKE '%lub%';
.print ''

/* Broken gasket.                                                            */
/* Selecting watches in good condition that have had the glass replaced,     */
/* but maybe haing a leaky gasket.                                           */
.print 'Broken gasket'
SELECT w.watch_id AS 'Watch ID:',
       w.manufacturer AS 'Brand:',
       m.model_name AS 'Model:',
       w.cosmetic_condition_rating AS 'Condition rating:',
       w.cosmetic_description AS 'Condition description:',
/* Changing out 1 for Yes and 0 for No.                                      */
        (CASE WHEN w.functioning = 1 THEN
            'Yes'
        ELSE
            'No'
        END) AS 'Functioning:',
        w.water_resistance_current AS 'Water resistance:',
        s.service_comment AS 'Service comment:'
FROM watch AS w
INNER JOIN model AS m
ON m.model_id = w.model_id
INNER JOIN service_ticket AS s
ON s.watch_id = w.watch_id
WHERE w.cosmetic_condition_rating >= 4 AND
      s.service_comment LIKE '%glass%';