# instalacja
Pobranie całej aplikacji:
git clone --recursive https://github.com/aplikacje-internetowe-l2/aplikacja-glowna.git

# Wejście do folderu:
cd instalacja

# instalacja aplikacji
./install.sh

# aktualizacja
./update.sh true true - glowna i testowa
./update.sh true false - glowna
./update.sh false true - testowa

# usuniecie
./remove.sh
