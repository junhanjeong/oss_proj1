#! /bin/bash
main() {
        echo "--------------------------"
        echo "User Name: JeongJunHan"
	echo "Student Number: 12200529"
        echo "[ MENU ]"
        echo "1. Get the data of the movie identified by a specific 'movie id' from 'u.item'"
        echo "2. Get the data of action genre movies from 'u.item'"
        echo "3. Get the average 'rating' of the movie identified by specific 'movie id' from 'u.data'"
	echo "4. Delete the 'IMDb URL' from 'u.item'"
	echo "5. Get the data about users from 'u.user'"
	echo "6. Modify the format of 'release date' in 'u.item'"
	echo "7. Get the data of movies rated by a specific 'user id' from 'u.data'"
	echo "8. Get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'"
        echo "9. Exit"
	echo "--------------------------"

    while :
    do
        read -p "Enter your choice [ 1-9 ] " choice
        case $choice in
            1)
		echo
                read -p "Please enter 'movie id'(1~1682):" movie_id
		echo
		awk -F\| -v movie_id=$movie_id '$1 == movie_id {print}' $1
		echo
                ;;
            2)
		echo
		read -p "Do you want to get the data of 'action' genre movies from 'u.item'?(y/n):" confirm
		echo
        	if [ $confirm = "y" ]
	       	then awk -F\| '$7 == 1 { print $1, $2 }' $1| sort -n | head -10
		    echo
        	fi
                ;;
            3)
		echo
                read -p "Please enter the 'movie id'(1~1682):" movie_id
		echo
		avg_rating=$(awk -F'\t' -v id=$movie_id '$2 == id { sum += $3; count++ } END { if (count > 0) printf "%.6f", sum/count }' $2)
		rounded_avg_rating=$(echo "$avg_rating" | awk -v avg_rating="$avg_rating" 'BEGIN { if((avg_rating * 1e6) != int(avg_rating * 1e6)) { avg_rating += 5e-6; tmp_avg_rating = sprintf("%.5f", avg_rating); avg_rating = tmp_avg_rating + 0; } } { printf "%g\n", avg_rating }')
                echo "average rating of $movie_id: $rounded_avg_rating"
		echo
                ;;
	    4)
		echo
		read -p "Do you want to delete the 'IMDb URL' from 'u.item'?(y/n):" confirm
		echo
		if [ "$confirm" = "y" ]
		then
		    sed 's/^\(\([^|]*|\)\{4\}\)[^|]*|/\1|/' $1 | head -10
		    echo
		fi
	        ;;
	    5)
		echo
	        read -p "Do you want to get the data about users from 'u.user'?(y/n):" confirm
		echo
	        if [ "$confirm" = "y" ]
	        then
		    sed -n 's/^\([0-9]*\)|\([0-9]*\)|\([MF]\)|\([^|]*\)|.*/user \1 is \2 years old \3 \4/p' $3 | sed 's/ M/ male/' | sed 's/ F/ female/' | head -10
		    echo
	        fi
	        ;;
	    6)
		echo
	        read -p "Do you want to Modify the format of 'release data' in 'u.item'?(y/n):" confirm
		echo
	        if [ "$confirm" = "y" ]
	        then
		    sed -n 's|\([0-9][0-9]\)-\(...\)-\([0-9][0-9][0-9][0-9]\)|\3\2\1|; 1673,1682p' $1 | sed 's/Jan/01/;s/Feb/02/;s/Mar/03/;s/Apr/04/;s/May/05/;s/Jun/06/;s/Jul/07/;s/Aug/08/;s/Sep/09/;s/Oct/10/;s/Nov/11/;s/Dec/12/'
		    echo
	        fi
	        ;;
	    7)
		echo
	        read -p "Please enter the ‘user id’(1~943):" user_id
		echo
		movie_ids=$(awk -v user="$user_id" '$1 == user {print $2}' $2 | sort -n)
		echo "$movie_ids" | tr '\n' '|' | sed 's/|$/\n/'
		echo
		top_10_ids=$(echo "$movie_ids" | head -10)	    
		awk -F\| -v top10="$top_10_ids" 'BEGIN { split(top10, arr, "\n"); for(i in arr) lookup[arr[i]] } $1 in lookup { print $1"|"$2 }' $1
		echo
		;;
	    8)
		echo
		read -p "Do you want to get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'?(y/n):" confirm
		echo
		if [ "$confirm" = "y" ]; then
		    user_ids=$(awk -F\| '$2 >= 20 && $2 <= 29 && $4 == "programmer" {print $1}' $3)
		    awk -F'\t' -v users="$user_ids" 'BEGIN { split(users, arr, "\n"); for (i in arr) userLookup[arr[i]] } $1 in userLookup { sum[$2] += $3; count[$2]++ }
		    END {
			for (movie in sum) {
			    avg = sum[movie]/count[movie];
			    if ((avg * 1e6) != int(avg * 1e6)) {
				avg += 5e-6
				rounded_avg = sprintf("%.5f", avg)
				avg = rounded_avg + 0
			    }
			    printf "%d %g\n", movie, avg
			}
		    }' $2 | sort -k1,1n
		    echo
	        fi
	        ;;
            9)
		echo "Bye!"
                exit 0
                ;;
            *)  # Invalid choice
                echo "Invalid choice"
                ;;
        esac
    done
}

main $1 $2 $3
