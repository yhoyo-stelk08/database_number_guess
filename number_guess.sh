#!/bin/bash

# declare variable PSQL for execute sql command
PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"

# Generate a random number between 1 and 1000
RANDOM_NUMBER=$((RANDOM % 1000 + 1))
echo $RANDOM_NUMBER
echo -e "\n~~~~ Welcome to Number Guessing Game ~~~~\n"

# ask player to enter their username
echo "Enter your username:"
read USERNAME

# check if username lengh is less or equal 22 characters
if [ ${#USERNAME} -le 22 ]
then
  # check username
  GET_USERNAME_RESULT=$($PSQL "SELECT name FROM players WHERE name='$USERNAME'")

  # if not found
  if [[ -z $GET_USERNAME_RESULT ]]
  then
    echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."

    # insert new player into players table
    INSERT_NEW_PLAYER=$($PSQL "INSERT INTO players (name) VALUES ('$USERNAME')")
  else
    # get total played games
    TOTAL_PLAYED_GAMES=$($PSQL "SELECT COUNT(*) FROM players INNER JOIN games USING (player_id) WHERE name = '$USERNAME'")
    # echo "TOTAL PLAYED GAMES : $TOTAL_PLAYED_GAMES"

    # get best game
    BEST_GAME=$($PSQL "SELECT number_of_tries FROM (SELECT * FROM players INNER JOIN games USING (player_id)) t WHERE name = '$USERNAME' ORDER BY number_of_tries LIMIT 1")

    echo "Welcome back,$USERNAME! You have played $TOTAL_PLAYED_GAMES games, and your best game took $BEST_GAME guesses." | tr -s ' ' | sed 's/^ *//;s/ *$//'
  fi

  # get player id
  PLAYER_ID=$($PSQL "SELECT player_id FROM players WHERE name LIKE '$USERNAME'")

  # set number of try value
  NUMBER_OF_TRY=1

  # accept guessed number
  echo -e "\nGuess the secret number between 1 and 1000:"
  read GUESSED_NUMBER

  while true
  do
    # check if the answer is integer or not
    if [[ $GUESSED_NUMBER =~ ^[0-9]+$ ]]
    then
      if [[ $GUESSED_NUMBER -lt $RANDOM_NUMBER ]]
      then
        echo -e "\nIt's lower than that, guess again:"
        read GUESSED_NUMBER
        NUMBER_OF_TRY=$((NUMBER_OF_TRY+1))
      elif [[ $GUESSED_NUMBER -gt $RANDOM_NUMBER ]]
      then
        echo -e "\nIt's higher than that, guess again:"
        read GUESSED_NUMBER
        NUMBER_OF_TRY=$((NUMBER_OF_TRY+1))
      else
        echo -e "\nYou guessed it in $NUMBER_OF_TRY tries. The secret number was $RANDOM_NUMBER. Nice job!" | tr -s ' ' | sed 's/^ *//;s/ *$//'

        # add new record to game
        INSERT_NEW_GAME=$($PSQL "INSERT INTO games (player_id,number_of_tries) VALUES ($PLAYER_ID,$NUMBER_OF_TRY)")
        break
      fi
    else
      # if the guessed number not an integer
      echo -e "That is not an integer, guess again:"
      read GUESSED_NUMBER
    fi
  done
fi