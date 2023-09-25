# PostgreSQL

Some of our backend applications connect to a PostgreSQL server in order to store
persistent state in a database.

Currently, we run PostgreSQL v16 ourselves, on the same DigitalOcean droplet that runs
our APIs. This is because we are cheap, and managed database services are expensive. If
performance ever becomes a bottleneck, or if maintenance becomes a headache, we can
offload the postgres server to its own droplet, or pay for a managed DB instance.

Since our Postgres server is self-managed, there aren't many DB-related resources in
Terraform. But we _do_ use Terraform to centralize secrets and other configuration
details that our application needs for database access.

### Production database configuration

In production, we configure our Droplet's postgres installation as part of the
deployment process invoked via [`init-server.sh`](../init-server.sh).

[`postgres.tf`](../postgres.tf) defines a few different bits of data:

- A randomly-generated password to use for each database
- A set of environment variables defining connection details for each database
- A bash script (which hardcodes sensitive values like DB passwords) that creates the
  required databases and roles when by a postgres superuser

When we deploy our backend, the script:

- Uses `systemctl` to verify that postgres is running, and installs it if needed
- Runs the aforementioned script to ensure that all required databases/users exist
- Writes environment variables (`PGUSER`, `PGPASSWORD`, `PGDATABASE`, etc.) to the
  `.env` files for the services that need DB access

To view or administer the database manually, SSH into the droplet and run:

- `sudo -u postgres psql [-d <dbname>]`

### Local database for development

When running the backend locally, we use a throwaway PostgreSQL server that runs in a
Docker container. For convenience, all backend applications share the same database in
the local PostgreSQL server.

To run a local DB, first ensure that Docker is installed, and then use the
[`local-db.sh`](../local-db.sh) script:

- `./local-db.sh up` starts up a new DB, if not already running
- `./local-db.sh down` stops the container, destroying all data, if running
- `./local-db.sh logs` tails log output from the postgres server
- `./local-db.sh env` outputs `PG*` environment variables used to connect

Note that whenever you start up a new database, it will be entirely empty. You'll need
to run the migrations for all relevant applications (e.g. via `db-migrate.sh` scripts)
before you can exercise database-dependent application functionality.

You can connect to the local DB using `psql postgres://gvcr:password@localhost`.
