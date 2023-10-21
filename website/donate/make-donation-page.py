import json
import lnurl as Lnurl
import os
import qrcode
import qrcode.image.svg
import re
import socket
import sys
import time
import urllib.request
from urllib.error import HTTPError, URLError
from pathlib import Path
from string import Template

def get_original_donation_page(url):
    while True:
        try:
            response = urllib.request.urlopen(url, timeout=10)
            return response.read().decode('utf-8')
        except HTTPError as e:
            wait_sec = 1
            print(f"URL {url} returned status {e.status}. Waiting {wait_sec} s.", file=sys.stderr, flush=True)
            time.sleep(wait_sec)
        except URLError as e:
            if isinstance(e.reason, socket.timeout):
                wait_sec = 5
                print(f"URL {url} timed out. Waiting {wait_sec} s.", file=sys.stderr, flush=True)
                time.sleep(wait_sec)
            else:
                raise e


def create_lnurl_section(lnurl_plaintext,
                         lightning_address,
                         bg_color='#f5f5f7',
                         html_template=os.path.join(os.path.dirname(__file__), 'donate-lnurl-template.html')):
    # TODO-EXTERNAL:
    # Switch to LUD-17 (plaintext URL instead of bech32 encoding) when it's widely supported
    # https://github.com/lnurl/luds
    lnurl = f"lightning:{Lnurl.encode(lnurl_plaintext).lower()}"
    lnurl_qrcode = make_qrcode(lnurl, bg_color)
    template = Template(Path(html_template).read_text())
    html = template.substitute(lnurl_qrcode=lnurl_qrcode,
                               lnurl=lnurl,
                               lightning_address=lightning_address)
    return html


def make_qrcode(lnurl_encoded, bg_color):
    img = qrcode.make(lnurl_encoded, image_factory=qrcode.image.svg.SvgPathImage)
    svg = img.to_string().decode('utf-8')
    svg = re.sub(r'width=".*?" height=".*?"', 'shape-rendering="crispEdges"', svg, count=1)
    # Add background rect before first <path> element
    svg = re.sub(r'<path', f'<rect width="100%" height="100%" fill="{bg_color}"></rect><path', svg, count=1)
    return svg

def main(invoice_donation_page_url,
         title,
         root_url=None,
         output_file=None,
         **args):
    orig_html = get_original_donation_page(invoice_donation_page_url)
    lnurl_section = create_lnurl_section(**args)
    logo = ('<a href="/">'
            '<img id="logo" style="width: 20rem; margin-bottom: -0.5rem;" src="/files/nix-bitcoin-logo-text.png" alt="nix-bitcoin">'
            '</a>')

    html = orig_html
    html = re.sub(r'<title>(.*?)</title>', f"<title>{title}</title>", html, count=1)
    html = re.sub(r'<h1.*?>Donate</h1>', logo, html, count=1)
    # Insert as last child of <div class="card ...">
    html = re.sub(r'\n(.*?</div>\s*</div>\s*</div>\s*</main>)', f"\n\n{lnurl_section}\n\\1", html, count=1)
    html = re.sub(r'Custom Amount',  "Donate", html, count=1)
    html = re.sub(r'Create invoice to pay custom amount', "Supports On-Chain, Lightning, Liquid", html, count=1)

    # For local debugging
    if root_url:
        html = re.sub(r'="/', f'="{root_url}/', html, count=0)
        print(html)

    if output_file:
        with open(output_file, 'w') as f:
            f.write(html)
            print(f"Wrote {output_file}", file=sys.stderr)

main(**json.loads(os.environ['ARGS']))
