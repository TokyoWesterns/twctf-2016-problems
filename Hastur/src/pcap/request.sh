## on a Server
# tcpdump -w tcpdump-src.pcap port 31178 or port 31179

URL=http://hastur.chal.ctf.westerns.tokyo:31178/
curl $URL
sleep 2
curl $URL -d "name=Hastur&text=hastur.chal.ctf.westerns.tokyo"
sleep 2
curl --tlsv1.0 --ciphers AES256-SHA -k -L ${URL}flag3

