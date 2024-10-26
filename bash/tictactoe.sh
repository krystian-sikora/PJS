#!/usr/bin/bash

board=(1 2 3 4 5 6 7 8 9)
gamemode=0
player="X"
pc="O"
loaded=0

save_game() {
    echo "Saving game..."
    echo "${board[*]}" > tictactoe_save.txt
    echo "$gamemode" >> tictactoe_save.txt
    echo "$player" >> tictactoe_save.txt
    echo "$pc" >> tictactoe_save.txt
    exit
}

load_game() {
    if [[ -f tictactoe_save.txt ]]; then

        echo "Your last game was saved. Do you want to continue? (y/n)"
        read -r choice

        if [[ $choice != "y" ]]; then
            rm tictactoe_save.txt
            echo "Game discarded."
            return
        fi

        IFS=' ' read -r -a board < <(head -n 1 tictactoe_save.txt)
        gamemode=$(sed -n '2p' tictactoe_save.txt)
        player=$(sed -n '3p' tictactoe_save.txt)
        pc=$(sed -n '4p' tictactoe_save.txt)
        
        rm tictactoe_save.txt
        loaded=1
        echo "Game loaded."
    fi
}

draw_board() {
    echo " ${board[0]} | ${board[1]} | ${board[2]} "
    echo "---+---+---"
    echo " ${board[3]} | ${board[4]} | ${board[5]} "
    echo "---+---+---"
    echo " ${board[6]} | ${board[7]} | ${board[8]} "
}

display_menu() {
    echo "1. Local multiplayer"
    echo "2. Single vs. PC"
    echo "3. Exit"
    read -r choice
    case $choice in
        1) gamemode=0 ;;
        2) gamemode=1 ;;
        3) exit ;;
        *) echo "Invalid choice" ;;
    esac
}

check_win() {
    for i in 0 3 6; do
        if [[ ${board[$i]} == ${board[$i+1]} && ${board[$i+1]} == ${board[$i+2]} ]]; then
            echo "Player ${board[$i]} wins!"
            exit
        fi
    done

    for i in 0 1 2; do
        if [[ ${board[$i]} == ${board[$i+3]} && ${board[$i+3]} == ${board[$i+6]} ]]; then
            echo "Player ${board[$i]} wins!"
            exit
        fi
    done

    if [[ ${board[0]} == ${board[4]} && ${board[4]} == ${board[8]} ]]; then
        echo "Player ${board[0]} wins!"
        exit
    fi

    if [[ ${board[2]} == ${board[4]} && ${board[4]} == ${board[6]} ]]; then
        echo "Player ${board[2]} wins!"
        exit
    fi
}

check_draw() {
    for i in {0..8}; do
        if [[ ${board[$i]} != "X" && ${board[$i]} != "O" ]]; then
            return
        fi
    done
    echo "It's a draw!"
    exit
}

choose_player() {
    echo "Choose your player:"
    echo "1. X"
    echo "2. O"
    read -r choice
    case $choice in
        1) pc="O" ;;
        2) pc="X" ;;
        *) echo "Invalid choice" ;;
    esac
}

gameloop_multiplayer() {
    while true; do
    draw_board
        echo "Player $player, enter your move (1-9): "
        read -r move

        if [[ ${board[$move-1]} == "X" || ${board[$move-1]} == "O" ]]; then
            echo "Invalid move, try again."
            continue
        fi

        board[$move-1]=$player
        check_win
        check_draw

        if [[ $player == "X" ]]; then
            player="O"
        else
            player="X"
        fi
    done
}

gameloop_singleplayer() {
    if [[ $loaded -eq 0 ]]; then
        choose_player
    fi
    while true; do
        draw_board
        
        if [[ $pc == $player ]]; then
            move=$((RANDOM % 9 + 1))
            while [[ ${board[$move-1]} == "X" || ${board[$move-1]} == "O" ]]; do
                move=$((RANDOM % 9 + 1))
            done
            board[$move-1]=$pc
            echo "PC moved to $move"
            check_win
            check_draw

            if [[ $pc == "X" ]]; then
                player="O"
            else
                player="X"
            fi

            continue
        fi
        
        echo "Player $player, enter your move (1-9): "
        read -r move

        if [[ ${board[$move-1]} == "X" || ${board[$move-1]} == "O" ]]; then
            echo "Invalid move, try again."
            continue
        fi

        board[$move-1]=$player
        check_win
        check_draw

        if [[ $player == "X" ]]; then
            player="O"
        else
            player="X"
        fi
    done
}

trap save_game SIGINT SIGTERM EXIT
load_game

if [[ $loaded -eq 0 ]]; then
    display_menu
fi

# display_menu

if [[ $gamemode -eq 0 ]]; then
    echo "Local multiplayer"
    gameloop_multiplayer
elif [[ $gamemode -eq 1 ]]; then
    echo "Single vs. PC"
    gameloop_singleplayer
fi

while true; do
    draw_board
    echo "Player $player, enter your move (1-9): "
done