#!/usr/bin/env python3

import sys
import time
import urllib.parse
import socket
import requests

def check_url(url, dns_separately=False):
  if dns_separately:
    bits = urllib.parse.urlparse(url)
    ip = socket.gethostbyname(bits.netloc)
    url = bits._replace(netloc=ip).geturl()

  print("Checking %s" % url)
  start = time.perf_counter()
  resp = requests.get(url, allow_redirects=False)
  resp.raise_for_status()
  size = len(resp.text) # just to make sure we drained the response body
  end = time.perf_counter()
  duration = end - start
  print("Fetched %s in %.1f seconds" % (size, duration))

def main():
  seahorse_host = sys.argv[1]
  for url_template in ["http://%s", "http://%s/Seahorse/JavaScript/UiText?ck=1234", "http://%s/Seahorse/JavaScript/UiTextCached?ck=1234&languageCode=en-US"]:
    check_url(url_template % seahorse_host)
    check_url(url_template % seahorse_host, True)

if __name__ == '__main__':
  main()
