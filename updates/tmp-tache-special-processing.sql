-- Special processing
update library_z3950 set special_processing=E'  <!-- don\'t include records that don\'t have 852$b="CLC" -->\n  <set name="pz:recordfilter" value="holding-destiny-location=CLC"/>' where oid=(select oid from org where symbol='MTPL');
