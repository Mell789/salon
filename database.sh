#!/bin/bash

# ALTER SEQUENCE <tablename>_<id>_seq RESTART WITH 1

PSQL_P="psql --username=freecodecamp --dbname=postgres -c"

$PSQL_P "DROP DATABASE salon"
$PSQL_P "CREATE DATABASE salon"

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

# create tables
$PSQL "CREATE TABLE IF NOT EXISTS customers (
  customer_id SERIAL PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  phone VARCHAR(50) UNIQUE NOT NULL
)"

$PSQL "CREATE TABLE IF NOT EXISTS services (
  service_id SERIAL PRIMARY KEY,
  name VARCHAR(50) NOT NULL
)"

$PSQL "CREATE TABLE IF NOT EXISTS appointments (
  appointment_id SERIAL PRIMARY KEY,
  customer_id INT NOT NULL,
  service_id INT NOT NULL,
  time VARCHAR(50) NOT NULL
)"

# add foreıgn keys
$PSQL "ALTER TABLE appointments ADD FOREIGN KEY(customer_id) REFERENCES customers(customer_id)"
$PSQL "ALTER TABLE appointments ADD FOREIGN KEY(service_id) REFERENCES services(service_id)"

# restart all sequences with 1
$PSQL "ALTER SEQUENCE services_service_id_seq RESTART WITH 1"
$PSQL "ALTER SEQUENCE customers_customer_id_seq RESTART WITH 1"
$PSQL "ALTER SEQUENCE appointments_appointment_id_seq RESTART WITH 1"

# truncate all tables
$PSQL "TRUNCATE TABLE customers, services, appointments CASCADE"

# insert into services
$PSQL "INSERT INTO services(name) VALUES('cut'),('color'),('perm'),('style'),('trim')"
