cat real-execute-modified-part-res.txt | grep "modified part" > real-execute-modified-part-res-1.txt
cat real-execute-res-old.txt | grep "Average number of seconds to run all queries" > real-execute-res-old-1.txt
cat real-execute-res.txt | grep "Average number of seconds to run all queries" > real-execute-res-1.txt

cat real-execute-res-pure.txt | grep "Average number of seconds to run all queries" > real-execute-res-pure-1.txt


python3 run-getres.py > final-res1.txt
python3 run-getres-modify.py > final-res2.txt
python3 run-getres-icount.py > final-res3.txt

echo "end-to-end diff:" > final-res.txt

cat final-res1.txt >> final-res.txt

echo " " >> final-res.txt
echo " " >> final-res.txt
echo "modified part:" >> final-res.txt

cat final-res2.txt >> final-res.txt

echo " " >> final-res.txt
echo " " >> final-res.txt
echo "icount diff" >> final-res.txt

cat final-res3.txt >> final-res.txt


