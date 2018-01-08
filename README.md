# IS-05 Device Connection Management: GitHub Pages documentation

If you are reading this you are on the gh-pages branch, which is used to generate the documentation from the master and other branches, and from releases.

## Generating the GitHub Pages documentation

Make sure you have the correct version for raml2html installed.  For RAML 1.0 you need the latest version:

``sudo npm install -g raml2html``

_raml2html may hang on you... Simon can advise on a working configuration_

Clone this repo, checkout the gh-pages branch and make

``git checkout gh-pages``
``make``

Check it's ok and if so push

``make push``

