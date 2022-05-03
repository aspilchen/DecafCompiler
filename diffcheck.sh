# !/bin/bash

#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	
#
# Quickly thrown together bash script thingy to 
# provide side by side comparison for incorrect output.
#	
#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	


TESTCASES=$1
N_CASES=$2

for ((i = 1 ; i < $N_CASES ; i++)); do
	DIFF=$(diff output/dev/$TESTCASES$i.out references/dev/$TESTCASES$i.out)
	if [ "$DIFF" != "" ]; then
		echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
		echo "Test $i has failed..."
		diff output/dev/$TESTCASES$i.out references/dev/$TESTCASES$i.out -y
		echo ""
	fi
done
