infile="2022-all.csv"
out0="2022-"
prefix="103300-Rochester Section"
for month in 01 02 03 04 05 06 07 08 09 10 11 12
do
( head -1 ${infile} 
  grep "^${prefix},${month}/" ${infile}
) >${out0}${month}.csv
done
