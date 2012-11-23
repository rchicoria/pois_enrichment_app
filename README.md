POIs enrichment app
===================

Configuration:

* rake db:migrate
* rake db:praias

Model structure:

* Local: POIs stored locally
* Praia: Beach POIs
* Servico: Services of a POI

Website structure:

* /: home, redirect to /pois if using desktop
* /pois: shows a list of pois based on category and district
