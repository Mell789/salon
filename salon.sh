#!/bin/bash


PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"


echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "\nWelcome to My Salon, how can I help you?\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  MAIN_MENU_INTRO="1) Cut\n2) Color\n3) Perm\n4) Style\n5) Trim\n6) Exit"
  echo -e $MAIN_MENU_INTRO
  read SERVICE_ID_SELECTED
  if [[ $SERVICE_ID_SELECTED = 6 ]]
  then
    EXIT_MENU
  else
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      MAIN_MENU "That is not a valid number."
    else
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
      if [[ -z $SERVICE_NAME ]]
      then
        MAIN_MENU "I could not find that service. What would you like today?"
      else
        echo -e "\nWhat's your phone number?"
        read CUSTOMER_PHONE
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
        if [[ -z $CUSTOMER_NAME ]]
        then
          echo -e "\nI don't have a record for that phone number, what's your name?"
          read CUSTOMER_NAME
          echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed 's/^ //g'), $(echo $CUSTOMER_NAME | sed 's/^ //g')?"
          read SERVICE_TIME
          INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
          if [[ $INSERT_CUSTOMER_RESULT ]]
          then
            CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name='$CUSTOMER_NAME'")
            SERVICE_ID=$SERVICE_ID_SELECTED
            INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID,'$SERVICE_TIME')")
            if [[ -z $INSERT_APPOINTMENT_RESULT ]]
            then
              MAIN_MENU "\nAppointment error"
            else
              echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed 's/ //g') at $SERVICE_TIME, $CUSTOMER_NAME."
            fi
          else
            MAIN_MENU "INSERT CUSTOMER FAILED"
          fi  
        else
          SERVICE_ID=$SERVICE_ID_SELECTED
          CUSTOMER_NAME_NOSPACE=$(echo $CUSTOMER_NAME | sed 's/^ //g')
          echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed 's/^ //g'), $CUSTOMER_NAME_NOSPACE?"
          read SERVICE_TIME
          CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name='$CUSTOMER_NAME_NOSPACE'")
          if [[ -z $CUSTOMER_ID ]]
          then
            echo "customer id null"
            echo "CUSTOMER NAME:$CUSTOMER_NAME_NOSPACE"
          else
            INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID,'$SERVICE_TIME')")
            if [[ ! -z $INSERT_APPOINTMENT_RESULT ]]
            then
              echo "I have put you down for a $(echo $SERVICE_NAME | sed 's/ //g') at $SERVICE_TIME, $CUSTOMER_NAME_NOSPACE."
            fi
          fi
        fi
      fi
    fi
  fi
}

EXIT_MENU() {
  echo -e "\nYou have successfully exited from the menu."
}

MAIN_MENU
