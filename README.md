POIs enrichment app
===================

Configuration:

* rake db:migrate
* rake db:import_json (to load from dump) or rake db:fetch_coordinates (to fetch from the web)
* rake db:pois
* rake db:praias

Model structure:

* Local: POIs stored locally
* Bar: Bar POIs
* Cultura: Culture POIs
* Monumento: Monument POIs
* Praia: Beach POIs
* Restaurante: Restaurant POIs
* Servico: Services of a POI

Website structure:

* /: home, redirect to /pois if using desktop
* /pois: shows a list of pois based on category and district
