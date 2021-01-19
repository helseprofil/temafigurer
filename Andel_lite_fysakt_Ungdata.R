#  Temafigur FHP-2021: UNGDATA, ANDEL LITE FYSISK AKTIVE.

# Inndata: Ferdig flatfil Indikator.txt. Der er den (ganske hårete) databehandlingen
# av Ungdatatall gjort ferdig.
# Scripting gjøres med Git versjonskontroll, med remote repository på Github helseprofil/temafigurer.

# I utviklingen: Bruker fjorårets Indikator.txt.
# Bruker riktig indikator "Lite fysisk aktive".
# Den er nummer 24 i Kommune og 19 i Bydel i denne testfilen.

# Spec kommune/bydel: 
# Søyler for hver kommune i fylket.
# Markere aktuell kommune med avvikende farge.
# ? Rød/grønn linje for lands- eller fylkes (by-) tall?
  ## OBS: For Bydel går dette an, men for Kommune vil det som regel være mer 
  ## enn ett av både fylkes- og Landstall i treårsperioden.
# Symbol i grafen og forklaring i Note nedenfor hvis kommunen mangler tall.
# 
# FYLKER: Antakelig IKKE AKTUELT, vi bruker ikke Ungdata i fylkesprofiler.
# 
# Inndata: Indikator.txt for KOMMUNER/Bydel, der alle tallene er ferdig preppet fram.
# 
# Data til label "kommunenavn": Merge på en masterfil med de navnene vi bruker hele veien.
# Styres av "profilaar".
# 
# Inndata-filnavnet (som har datotag) ligger som grå minitekst
# nederst i hjørnet på figurene.

#-------------------------------------------------------------------------------
# Nødvendige packages
## Jeg er i The tidyverse - install.packages("tidyverse") tar inn alt.
library(tidyverse)
# library(readr)
# library(ggplot2)

#-------------------------------------------------------------------------------
# Paths, inndata, utdata, predefinerte verdier
## Husk / i paths i R ...

geonivaa <- "bydel" # Tillatt: "bydel", "kommune"
profilaar <- 2021
pos <- 4            # Figurposisjon øverst s.3 - VERIFISÉR

result_root <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_"
inndata_root <- "N:/Helseprofiler_Rapportgenerator/Folkehelseprofiler/Importfiler/PROD"

geomaster <- paste(result_root, "Masterfiler", profilaar, "Stedsnavn_SSB_TIL_GRAFER_Unicode.csv", sep = "/")
## I denne ligger: «Sted_kode», string stedskode ned til bydel dvs 6-sifret
## (dvs. geo-numre med ledende null). 
## «Sted», kortversjon av stedsnavn. 
## «geo» og «GEO», numerisk stedskode, (hadde kortversjon av navn som value label i Stata). 

## SKARP:
# inndatafil <- paste(inndata_root, geonivaa, "Flatfiler/Indikator.txt", sep = "/") 
# utdata <- paste(result_root, "PRODUKSJON/PRODUKTER/SSRS_filer", profilaar, geonivaa, "Temafigurer/Fysakt_Ungdata", sep = "/")
# indik_nr <- 

## UTVIKLING:
inndatafil <- "N:/Helseprofiler_Rapportgenerator/Folkehelseprofiler/Importfiler/PROD/Bydel/Flatfiler/FHP_2020/Indikator.txt"
utdata <- paste(result_root, "PRODUKSJON/PRODUKTER/SSRS_filer", profilaar, geonivaa, "Temafigurer/TEST", sep = "/")

if(geonivaa == "bydel") {
  indik_nr <- 19
} else if(geonivaa == "kommune") {
  indik_nr <- 24
}


#-------------------------------------------------------------------------------
# Preppe data
## TAB-separert, desimaltegn er komma. 
## Det ligger "-" for manglende tall, så "Verdi_..."-kolonnene kan bli lest som character. Fikses med "na =".
## Datotag_... leses som stort tall. Fikses med "col_types...".
datasett <- readr::read_tsv(inndatafil, 
                            col_names = TRUE, 
                            col_types = cols("Datotag_side4_innfilutfil" = col_character()), 
                            locale = locale(decimal_mark = ","), 
                            na = "-")

# Subset, gamlemåten: Krymper datasettet trinnvis
datauttrekk <- datasett[datasett$LPnr == indik_nr, ]
datauttrekk <- datauttrekk[datauttrekk$SpraakId == "BOKMAAL", ]

# Sjekk at det er riktig indikator
assertthat::assert_that(stringr::str_starts(datauttrekk$Indikator[1], "Lite fysisk aktive"))

hjemmeby <- str_sub(datauttrekk$Sted_kode, start = 1, end = 2)

#-------------------------------------------------------------------------------
# Prøver å gjøre det samme med tidyverse-triksene:

# Sjekke indikatorteksten: bare les ut en celle, styrt av indik_nr, uten å droppe noe.
  ## Er det da [[]] brukes, for å aksessere ett element?

plotdata <- datasett %>%
  filter(LPnr == indik_nr, SpraakId == "BOKMAAL") %>%
  mutate(hjemmeby = str_sub(datauttrekk$Sted_kode, start = 1, end = 2)) %>%
  split(.$hjemmeby) %>%
  map(~ggplot(., mapping = aes(x = Sted_kode, y = Verdi_lavesteGeonivaa)) +
        geom_col() +
        labs(x = "Bydeler", y = "Andel lite aktive (prosent)" ) + 
        annotate(geom = "text", x = 10, y = 25, label = "Indikator.txt batchnr=")
  )



#-------------------------------------------------------------------------------
# Grafkommando

# Gamlemåten: Så ser jeg hva delene gjør
ggplot(datauttrekk, mapping = aes(x = Sted_kode, y = Verdi_lavesteGeonivaa)) +
  geom_col() +
  labs(x = "Bydeler", y = "Andel lite aktive (prosent)" ) + 
  annotate(geom = "text", x = 10, y = 25, label = "datafil Indikator.txt")

