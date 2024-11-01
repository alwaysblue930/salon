#!/bin/bash

MAIN_MENU(){
  PSQL="psql -X --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

  if [[ -z $1 ]] 
  then
    echo -e "\n~~~~~ MY SALON ~~~~~\n"
    echo -e "Welcome to My Salon, how can I help you?\n"
  else
    echo -e "\n$1"
  fi
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")

  if [[ -z $SERVICES ]]
  then
    MAIN_MENU "There is no service available currently."
  else
    echo -e "$SERVICES" | sed 's/|/) /' | while read SERVICE_ID NAME
    do
      echo "$SERVICE_ID $NAME"
    done
    read SERVICE_ID_SELECTED 

    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      VALID_SERVICE=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
      if [[ -z $VALID_SERVICE ]]
      then
        MAIN_MENU "I could not find that service. What would you like today?"
      else
        echo -e "\nWhat's your phone number?"
        read CUSTOMER_PHONE
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
        CUSTOMER_NAME=""
        if [[ -z $CUSTOMER_ID ]]
        then
          echo -e "\nI don't have a record for that phone number, what's your name?"
          read CUSTOMER_NAME
          CUSTOMER_CREATED=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
          CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
        fi
        
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id='$CUSTOMER_ID';")
        echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
        read SERVICE_TIME
        APPOINTMENT_CREATED=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")
        if [[ $APPOINTMENT_CREATED != 'INSERT 0 1' ]]
        then
          MAIN_MENU "Please check your appointment details."
        else
            SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
            echo -e "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."

        fi #Appointment detail not correct
      fi #if service not valid
    fi #if service not int
  fi #if service not available

}

MAIN_MENU