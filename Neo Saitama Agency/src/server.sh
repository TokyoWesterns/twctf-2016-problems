socat tcp-listen:41534,fork,reuseaddr system:"python alice.py" &
socat tcp-listen:41535,fork,reuseaddr system:"python bob.py" &
socat tcp-listen:41536,fork,reuseaddr system:"python carol.py" &

wait
