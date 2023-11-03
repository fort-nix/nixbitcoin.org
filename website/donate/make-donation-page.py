import json
import lnurl as Lnurl
import os
import qrcode
import qrcode.image.svg
import re
import sys
from pathlib import Path
from string import Template

def create_lnurl_data(lnurl_plaintext, bg_color='#f5f5f7'):
    # TODO-EXTERNAL:
    # Switch to LUD-17 (plaintext URL instead of bech32 encoding) when it's widely supported
    # https://github.com/lnurl/luds
    lnurl = f"lightning:{Lnurl.encode(lnurl_plaintext).lower()}"
    return {
        'lnurl': lnurl,
        'lnurl_qrcode': make_qrcode(lnurl, bg_color)
    }

def make_qrcode(lnurl_encoded, bg_color):
    img = qrcode.make(lnurl_encoded, image_factory=qrcode.image.svg.SvgPathImage)
    svg = img.to_string().decode('utf-8')
    svg = re.sub(r'width=".*?" height=".*?"', 'shape-rendering="crispEdges"', svg, count=1)
    # Add background rect before first <path> element
    svg = re.sub(r'<path', f'<rect width="100%" height="100%" fill="{bg_color}"></rect><path', svg, count=1)
    return svg

def main(lnurl_plaintext,
         html_template,
         root_url=None,
         output_file=None,
         **values):
    values |= create_lnurl_data(lnurl_plaintext)

    template = Template(Path(html_template).read_text())
    html = template.substitute(**values)

    # For local debugging
    if root_url:
        html = re.sub(r'="/', f'="{root_url}/', html, count=0)
        print(html)

    if output_file:
        with open(output_file, 'w') as f:
            f.write(html)
            print(f"Wrote {output_file}", file=sys.stderr)

main(**json.loads(os.environ['ARGS']))
