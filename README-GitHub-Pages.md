# Generating the GitHub Pages documentation

Eventually this will be automated, but in the meantime, those with write access to the repo must update the GitHub Pages following any change to the specification or supporting documents.

Make sure you have the correct version for raml2html installed.  For RAML 1.0 you need the latest version:

``sudo npm install -g raml2html``

_raml2html may hang on you... Simon can advise on a working configuration_

Clone this repo, checkout the gh-pages branch and make

``git clone https://github.com/AMWA-TV/nmos-device-connection-management``

``cd nmos-device-connection-management``

``git checkout gh-pages``

``make``

Check it's ok and if so push

``make push``

