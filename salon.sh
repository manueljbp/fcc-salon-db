#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

SERVICES_MENU() {
  # get offered services
  OFFERED_SERVICES=$($PSQL "SELECT * FROM services")
  # print offered services
  echo "$OFFERED_SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
}

APPOINTMENT_MENU() {
  # display offered services
  SERVICES_MENU
  # ask for service to book
  read SERVICE_ID_SELECTED
  # match service_to_book service with services table
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  # if chosen service doesn't exist
  if [[ -z $SERVICE_NAME ]]
  then
    # display services menu
    echo -e "\nI could not find that service. What would you like today?\n"
    SERVICES_MENU
  else
    # ask for customer phone number
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    # get customer id for phone number
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    # if customer phone is not in the database
    if [[ -z $CUSTOMER_NAME ]]
    then
      # ask for customer name
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      # insert new customer into table
      INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
    fi

    # ask for service time
    echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME

    # get customer id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    # insert appointment
    INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
    # print appointment info 
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

APPOINTMENT_MENU