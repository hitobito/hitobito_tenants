# Hitobito Tenants

This hitobito wagon adds database multi-tenancy to hitobito. 
Each tenant gets an own subdomain and an own database with the same name.

## Setup

Deploy the application as usual with a regular database configuration. 
This database will be the global instance, managing the other tenants.
The name of the global database should also correspond to its subdomain.

Set `RAILS_HOST_NAME` to the main domain part 
(e.g. `app.hitobito.ch` for tenant subdomains like `tenant1.app.hitobito.ch`).

Tenants are created and removed in the 'Settings' section in the frontend,
triggering a background job that sets up the database, subdomain and so on.
For each new tenant, a default admin user is created for the initial login.
This user will also receive the no-reply mailing list emails.

Hence, clients may directly login with `admin@hitobito.ch / ändere_mich`, 
change the name and email address to their own and then change the password
on the login screen.