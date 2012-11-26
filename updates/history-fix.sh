while read r; do
  #echo $r
  REQ=`echo $r | cut -d \, -f 2`
  [ -z "$REQ" ] && continue
  echo $REQ
  `../bin/move-to-history.cgi reqid=$REQ`
done < history-fix.txt