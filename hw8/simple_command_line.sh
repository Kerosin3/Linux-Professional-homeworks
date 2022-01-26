#/bin/bash
if [ -n "$1" ]
then  
    case "$1" in
    -dev) echo "couting "
        export test1=development;;
    -prod) echo "Running in Production mode";;
    *) echo "$1 is not an option, use either dev or prod"
      export test1=production
      exit 1;;
esac
fi
