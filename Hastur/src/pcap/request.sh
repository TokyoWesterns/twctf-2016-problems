## on a Server
# tcpdump -w tcpdump-src.pcap port 31178 or port 31179

URL=http://hastur.chal.ctf.westerns.tokyo:31178/
RESOLVE="--resolve hastur.chal.ctf.westerns.tokyo:31178:127.0.0.1
         --resolve hastur.chal.ctf.westerns.tokyo:31179:127.0.0.1"
curl $RESOLVE $URL
sleep 2
curl $RESOLVE $URL -d "name=Hastur&text=hastur.chal.ctf.westerns.tokyo"
sleep 2
curl $RESOLVE --tlsv1.0 --ciphers AES256-SHA -k -L ${URL}flag3

