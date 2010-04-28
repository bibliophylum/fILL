prefix=temp
suffix=$(date '+%Y%m%d%H%M')  # The "+%s" option to 'date' is GNU-specific.
filename=$prefix.$suffix
echo $filename

hmm=$(date '+%M');
if [ $hmm == "00" ]; then
    echo It is eleven minutes after the hour!
fi

