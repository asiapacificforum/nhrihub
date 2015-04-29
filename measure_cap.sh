#!/bin/bash
START=$(date +%s)
cap production deploy
END=$(date +%s)
DIFF=$(( $END - $START ))
echo "It took $DIFF seconds"

