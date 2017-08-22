#!/bin/bash

echo
echo ">> doing a make clean..."
make clean

echo
echo ">> deleting '.DS_Store' files..."
find . -name '.DS_Store' -delete

echo
read -p "Delete Build folder? (y/N) " answer
while true
do
	case $answer in
		[yY]* ) echo ">> deleting Build folder..."
				find . -name 'Build' -print0 | xargs -0 rm -rf
				break;;
		* )		break;;
	esac
done

echo
read -p "Delete .theos foler? (y/N) " answer
while true
do
	case $answer in
		[yY]* ) echo ">> deleting .theos folder..."
				find . -name '.theos' -print0 | xargs -0 rm -rf
				break;;
		* )		break;;
	esac
done

echo
echo "Done."
echo
