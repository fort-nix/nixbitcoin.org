import json
import lnurl as Lnurl
import os
import qrcode
import qrcode.image.svg
import sys
import re
from pathlib import Path
from string import Template

def create_donation_page(donate_other_methods_url,
                         title,
                         lnurl_plaintext,
                         lightning_address,
                         bg_color='#f5f5f7',
                         html_template=os.path.join(os.path.dirname(__file__), 'donate-template.html'),
                         # for debugging
                         url_prefix=''):
    lnurl = f"lightning:{Lnurl.encode(lnurl_plaintext).lower()}"
    lnurl_qrcode = make_qrcode(lnurl, bg_color)
    template = Template(Path(html_template).read_text())
    html = template.substitute(title=title,
                               lnurl_qrcode=lnurl_qrcode,
                               lnurl=lnurl,
                               lightning_address=lightning_address,
                               donate_other_methods_url=donate_other_methods_url,
                               url_prefix=url_prefix)
    return html


def make_qrcode(lnurl_encoded, bg_color):
    img = qrcode.make(lnurl_encoded, image_factory=qrcode.image.svg.SvgPathImage)
    svg = img.to_string().decode('utf-8')
    svg = re.sub(r'width=".*?" height=".*?"', 'shape-rendering="crispEdges"', svg, count=1)
    # Add background rect before first <path> element
    svg = re.sub(r'<path', f'<rect x="0" y="0" width="256" height="256" fill="{bg_color}"></rect><path', svg, count=1)
    return svg

args = json.loads(sys.argv[1])
html = create_donation_page(**args)
print(html)
