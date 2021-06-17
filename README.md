# Hitobito Tenants

This hitobito wagon adds database multi-tenancy to hitobito. 
Each tenant gets an own subdomain and an own database with the same name.

This wagon does not contain any group or role definitions, so another wagon 
is required to actually run it.

## Development

It is preferable to develop directly with a MySQL database instead of the 
standard Sqlite3 DB.

After adjusting your `Wagonfile`, create a new development database:

    bin/with_mysql rake db:create db:setup:all

Start the Rails server to listen on all names:
 
    bin/with_mysql rails s -b0.0.0.0

Add entries for all your tenants in the `/etc/hosts` file:

    127.0.0.1      admin.hitobito.local tenant1.hitobito.local tenant2.hitobito.local

Then open the application in your browser at `admin.hitobito.local:3000`.

Tenants are created in delayed jobs, so do not forget to run them, too:

    bin/with_mysql rake jobs:work

## Deployment

Deploy the application as usual with a regular database configuration. 
This database will be the global/admin instance, managing the other tenants.

Set `RAILS_HOST_NAME` to the main domain part 
(e.g. `app.hitobito.ch` for tenant subdomains like `tenant1.app.hitobito.ch`).
All non-existing subdomains will be redirected to this main domain.

Set `RAILS_ADMIN_SUBDOMAIN` for the subdomain that accesses the global database. 
Default is 'admin'.

Set `RAILS_EXCLUDED_SUBDOMAINS` to a comma-separated list of subdomain names
that will not be allowed as tenant names, e.g. 'www, mail'. 
The admin subdomain is automatically in this list.

## Managing Tenants

Tenants are created and removed in the 'Settings' section in the frontend,
triggering a background job that sets up the database, subdomain and so on.
For each new tenant, a default admin user is created for the initial login.
This user will also receive the no-reply mailing list emails.

Hence, clients may directly login with `admin@hitobito.ch / ändere_mich`, 
change the name and email address to their own and then change the password
on the login screen.

In the rails console, you can switch the app to a specific tenant by
executing

	> Apartment::Tenant.switch!('tenant')

Switching back can be done with

	> Apartment::Tenant.switch!
