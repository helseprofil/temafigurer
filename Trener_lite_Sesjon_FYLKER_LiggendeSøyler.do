* TEMAFIGUR 2021: TRENER LITE, SESJONSDATA  - ALLE FYLKER OG LANDET
*
* VELG SORTERING i linje 160
*
* Utg.pkt. i Fornøyd med lokalmiljøet, Lokalmil_FYLKER_v2 fra 2019.
*
/* 	Spec: 
	LIGGENDE Søyler for hvert fylke, pluss landet. Versjon med egen søyle for landet.
	Markere aktuelt fylke med avvikende farge.
	Symbol i grafen og forklaring i Note nedenfor hvis kommunen mangler tall. Annen 
	mekanisme enn i Alko/hasj-figuren.
	Navn på alle søyler.
	
	V2: 07.03.19 - Legge inn forklarende tekst i grafen: grønn linje er hele landet.
	
Inndata: Indikator.txt for KOMMUNER, der alle tallene er ferdig preppet fram.

Figur nr 4

MYE LETTERE å bruke Graph Twoway Bar enn Graph Bar! Et twoway-plott er mye lettere 
å manipulere, og det tillater overlays.

Data til label "kommunenavn": Merge på en masterfil med de navnene vi bruker hele veien.
Styres av "profilaar".

Inndata-filnavnet (som har datotag) ligger som grå minitekst 
nederst i hjørnet på figurene.

Endringer/utvikling: 
	- Jan-17: Flyttet script til
	  F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON\BIN\Z_Profiler\2017\Temafigurscript.
	- Okt-17: Klargjort for nye 50-koder Trøndelag (endret geo-filtreringsmetode fra geonumre 
	  til lengden av geokoden, og lagt inn at k-nr. for Trondheim leses fra masterfilen).
	- 22.01.18 (V5): 
	  Utsatt ekspansjon av makroer i fylkesnavn viste seg å ikke fungere pålitelig, endret mekanismen.
	- 18.02.2019 (Lokalmiljø Ungdata)
	- 23.02.2021 (Trener lite sesjon FYLKER)
	- Egne versjoner for landet som hori. linje, landet som søyle, og denne med hori. søyler.
	  Liggende søyler krever nybygging av grafen, for det er ikke automatikk i å flytte på aksene.
*/
*===============================================================================
set more off
set graphics on
pause on
macro drop _all

* REDIGER/SJEKK
*-----------------------------------------------------------------
local modus = "TEST" 	//Tillatt: TEST, SKARP  - styrer både utdata og løkke for én eller alle grafer.
local profilaar ="2021"		//Henter Geomaster fra dette året.
local geonivaa ="fylke"  //Tillatte verdier: "fylke" ("kommune", "bydel" ikke aktuelle her). 
						  //OBS fylker bør styres separat, se toppen av grafløkka.
						
local fig_nr =4			//Bestemmer hvor på sidene figuren skal stå.
						//s.2 -> fig.1-2-3, s.3 -> fig.4-5-6.
						//OBS: ER UAVHENGIG AV figurens nummer i profilteksten!
						
*Indikatorenes nummer i tabellen 
if "`geonivaa'" == "kommune" {
	di as err _n "Dette er script for FYLKER, bruk det andre for K/B."
	exit
} // fra Ungdata - for KOMMUNER
else if "`geonivaa'" == "bydel" {
	di as err _n "Dette er script for FYLKER, bruk det andre for K/B."
	exit
} // fra Ungdata - for BYDEL
else if "`geonivaa'" == "fylke" { //Bruker samme datafil som for kommunene.
	local indik1=23
} 

local Indik1tekst "Trener sjeldnere enn ukentlig"

*INNDATA:
* For UTVIKLING
*local datakatalog "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON\PRODUKTER\SSRS_filer/`profilaar'/`geonivaa'\FigurOgTabell"
*local datafil "Indikator_ny.txt"

* SKARP - Tar den som faktisk er lastet opp FOR KOMMUNENE
local datakatalog "N:\Helseprofiler_Rapportgenerator\Folkehelseprofiler\Importfiler\PROD/Kommune\Flatfiler"
local datafil "Indikator.txt"

global geomaster "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/Masterfiler/`profilaar'\Stedsnavn_SSB_TIL_GRAFER_Unicode.dta"
	/* I denne ligger: «Sted_kode», string stedskode ned til bydel dvs 6-sifret
	   (dvs. geo-numre med ledende null). 
	   «Sted», stedsnavn (inkl. fylkesangivelse for doble kommunenavn).
	   «geo», numerisk stedskode, med kortversjon av navn som value label. 
    */

*UTDATA:
if "`modus'" == "TEST" {
	local targetkatalog "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON\PRODUKTER\SSRS_filer\FHP/`profilaar'/`geonivaa'\Temafigurer\TEST"
}
*else local targetkatalog "F:\Forskningsprosjekter\PDB 2455 - Helseprofiler og til_\PRODUKSJON\PRODUKTER\SSRS_filer\FHP\2021\Fylke\Temafigurer\Trening_sesjon"
else local targetkatalog "C:\Users\stbj\Documents\1-FHI\Mellomlager" //Hjemme går det mye fortere å skrive til C:.

*===============================================================================

* KJØRING:
*-----------------------------------------------------------------
cd "`targetkatalog'"
import delimited using "`datakatalog'/`datafil'", varnames(1) encoding("utf-8") clear

* Droppe unødvendige variabler og rader
keep if lpnr==`indik1'
keep if spraakid=="BOKMAAL"
* Sjekker indik.tittel
assert regexm(indikator, "`Indik1tekst'") 

* Ta vare på landstallet: Må legge det inn sammen med resten.
*local landstall = verdi_referansenivaa
* Ta vare på fylkestallene
keep sted_kode indikator verdi_mellomgeonivaa verdi_referansenivaa datotag_side4_innfilutfil

****Merge på geo-navn fra masterfil: BRUKES OGSÅ i filtrering av geonivåer.
rename sted_kode geo
merge 1:1 geo using "$geomaster"	//Innfører rader for fylker, bydeler og HReg.
	*pause Etter merge geomaster
drop if geo>30000					//Bydeler
drop if geo>80 & geo<100			//Helsereg
drop _merge

*------------------------------------------------------------------------
**** SPLITT: Bydeler krever litt andre detaljer, men parallelt opplegg.
**** FYLKER skal ha samme data som kommuner, men grafen er litt annerledes.
*if "`geonivaa'" == "kommune" | "`geonivaa'" == "fylke" {

	**** Drop lavere geonivåer
*	drop if strlen(Sted_kode)>4
*	if "`geonivaa'" == "fylke"   drop if strlen(Sted_kode)>2 //Dropper ikke evt. HReg!
*	if "`geonivaa'" == "kommune" drop if strlen(Sted_kode)>4

	****Flytte fylkestallet inn på raden for fylket
	gen hjemmefylke =int(geo/100) //nærmeste integer ved trunkering
	replace hjemmefylke =geo if strlen(Sted_kode)==2 //Fylkene selv
	sort hjemmefylke geo //sikrer at selve fylket kommer først
	generate fylkestall = real(verdi_mellom[_n+1])
	replace fylkestall  = real(verdi_refera[_n+8]) if geo == 0		//Landstallet også
	
	****Batchnummer, til tekst i hjørnet av figuren
	local batchnr = datotag_side4_innfilutfil[10]	//Noen tomme rader øverst

	****Så kan vi droppe alt annet
	keep if strlen(Sted_kode)==2

	/****Lage variabel med fylkesnavn, til label i grafen - HAR "GEO"
	gen fylkesnavn =Sted if strlen(Sted_kode)==2
	replace fylkesnavn = fylkesnavn[_n-1] if fylkesnavn==""
	*/	
*} //FERDIG IF KOMMUNE/FYLKE
*--------------------------------------------------------------------------

*sort hjemmefylke geo

****Tell rader - skal være lik antall kommuner/fylker
quietly describe
global antall=r(N)

* JUSTERE HOVED-UTSEENDE: SORTERING 
*=====================
* Testet Søyleretning stående eller liggende: 
* Det er ikke bare å flippe, for x-options virker fremdeles
* på horisontal akse, og y-options på vertikal! Dette er derfor egen versjon av scriptet.
* "Hbar" er ikke noen twoway-graf.

* Liggende søyler krever motsatt sortering for å få Landet øverst.
* Mekke til rekkefølgen av fylkene - VELG METODE:

/* A) I GEOGRAFISK REKKEFØLGE (IKKE tilpasset liggende søyler)
gen radnr = .	//løkkestyring
replace radnr = 1 if GEO == 0
replace radnr = 2 if GEO == 30
replace radnr = 3 if GEO == 3
replace radnr = 4 if GEO == 34
replace radnr = 5 if GEO == 38
replace radnr = 6 if GEO == 42
replace radnr = 7 if GEO == 11
replace radnr = 8 if GEO == 46
replace radnr = 9 if GEO == 15
replace radnr = 10 if GEO == 50
replace radnr = 11 if GEO == 18
replace radnr = 12 if GEO == 54
*/

/* B) SORTERT ETTER VERDI, STIGENDE
sort fylkestall geo			//Måtte ha med geo også for å få samme rekkefølge hver gang! Like verdier sorteres tilfeldig.
gen radnr = _n
*/

* C) SORTERT ETTER VERDI, MEN LANDET ALLTID FØRST 
*	 -Landet øverst i liggende søyler
sort fylkestall geo	in 2/l		//hopper over landsraden, sorterer resten
gen radnr = _n
gsort -radnr
replace radnr = _n

/* TRENGS IKKE når det er selve fylkene som plottes:
Finne første og siste rad i hvert fylke (til x-aksen)
gen forsterad = radnr if hjemmefylke>hjemmefylke[_n-1]
replace forsterad=1 in 1 //Der virker ikke testen ovenfor
replace forsterad=forsterad[_n-1] if forsterad==.
gen sisterad = radnr if hjemmefylke<hjemmefylke[_n+1]
gsort -hjemmefylke -geo
replace sisterad =sisterad[_n-1] if sisterad==.
sort hjemmefylke geo
*/

*Lage en label til x-aksen i fylkesgrafene: Må koble navnene til radnr. ist.f. geokode.
*forvalues i = 1/4 {
sort radnr 
forvalues i = 1/$antall {
	local navn=Sted[`i']
	label define radnr `i' "`navn'", add
} //end -forvalues-
*/
label values radnr radnr

/* Lage en y-verdivariabel - GJORT ovenfor, fylkestall.
replace verdi_ = subinstr(verdi_, "-", ".",.)
destring verdi_, gen(andel)
*/

****For skalering av y-aksen: 
	/* VURDER: Dersom dette avsnittet plasseres foran der jeg renser vekk uvedkommende geo-nivå,
	   vil alle profiltyper (fylke, kommune og bydel) få samme y-akse i samme år.
	   Står avsnittet etter nivå-rensing, vil geonivåene få hver sin lengde på y-aksen.*/

/*Ymin: Ikke her, bruker null
summarize andel
local minverdi =r(min)
global ymin =`minverdi'-1 			//Legger litt buffer under, for at søylen alltid 
									//skal ha en viss lengde
*if $ymin>4 global ymin=4			//Setter max  "23:30"som laveste y, gir bra plass under normaltid-linja.
di "ymin: " $ymin
*/

*Ymax:
summarize fylkestall
local maxverdi =r(max)
local ymax =round(`maxverdi', 5) //Runder av til nærmeste 5-tall. SEES I SMNHENG med gridlines i grafen.
if `ymax' < `maxverdi' local ymax = `ymax' + 5 //Da ble den rundet nedover, så vi må ta neste gridline-trinn.
local ymax = round(ceil(`ymax'), 10) 		//Runder oppover til nærmeste heltall, og deretter til nærmeste 10-er.
if `ymax' > 40 & `ymax' < 50 local ymax = 50 	//Setter runde tall
if `ymax' > 80 & `ymax' < 100 local ymax = 100

* OVERSTYRING: Vanlig at folk ønsker bestemt oppsett.
local ymax = 75

	di "ymax: " `ymax'
	di "maxverdi: " `maxverdi'
		
****Dummyvariabel for å markere manglende data
gen datamangler= 2  if missing(fylkestall) //y-verdi like over x-aksen

cd "`targetkatalog'"

*-----------------------------------------------------------------------
* SELVE FIGUREN
*-----------------------------------------------------------------------
* Søylefarge i hht. FHIs webpalett 2021
local kommunefarge "57 60 97"	//mørk blå
local fylkesfarge "9 117 181"	//mellomblå
*local landsfarge "152 179 39"
	local landsfarge "112 163 0"	//dus grønn

* Unicode-tegn for landslinja, til forklaringstekst
local strek = ustrunescape("\u25AC")

**** Løkke gjennom alle rader
	*Fylkesgrafer: må styres separat (gidder ikke kjøre 356 ...)
	
if "`modus'" == "TEST" {
	local start = 5	//Lager én graf
}
else {
	gen startflagg =_n if geo<100
	levelsof startflagg, local(start)	//Kjører alt
}
foreach i of local start {
*local i=6 //for testing av graf
	//bygg filnavn fra kommunenummeret i rad x (subscripting)
	local nummer =Sted_kode[`i']
	local fil1   ="`nummer'" + "_`fig_nr'_tema.png"
	noisily di "`fil1'"
	
	//Finn kommune/fylkesnavn, til label i grafen. 
	global geonavn =Sted[`i']
	local fylkenavn =Sted[`i']
	global hjemfylke = hjemmefylke[`i']
di "local Fylkenavn rett etter fylling, i løkka: `fylkenavn' "	

****Aksetekster
	local yaksetekst "Andel (prosent)"
	*local yaksetekst "{bf:Andel (prosent)}"  //Bold
*	if "`geonivaa'" == "kommune" | "`geonivaa'" == "fylke" local xaksetekst "Kommunene i `fylkenavn'" 	
*	if "`geonivaa'" == "bydel" local xaksetekst "`fylkenavn'" 	//For bydel er "fylkenavn" hardkodet tekst.
*	if "`nummer'"  == "03"  local xaksetekst "" 				//Oslo har ingen underliggende kommuner
*di "Xaksetekst, som inneholder fylkenavn: `xaksetekst' "

	//Dimensjonere plassering av tekster og andre ting
*	local minste_x = forsterad[`i'] +1	//Hopper over selve fylket, som ligger først
	local xmin= 0.5			//Starten på x-aksen - legger litt luft før første søyle.
*	local storste_x = sisterad[`i']
	local xmax= $antall + 0.5			//Slutten på x-aksen, legger litt luft.

*	local batchnr_yplass = -55 	//Kildefilnavnet i hjørnet, avstand fra x-aksen: Styrer annerledes.
*	local batchnr_Xplass = `xmax'-(length("`inndata'")/4) //Kildefilnavnet i hjørnet, plass på x-aksen: Bruker xmax.
	local geolabel_yplass = $ymin+0.5
	local geolabel_xplass = radnr[`i']
*	local normal_linje	  = `landstall'
*	local normal_tekst_yplass	= `normal_linje'+0.2
*	local normal_tekst_xplass	= 11.4
*	local normal_tekst_xplass	= `xmax'
	
	//Skalere søyleteksten. Fant at en passende faktor (y) varierer slik: y=-0,021x+1,689 der x er antall søyler.
	local antallsoyler = $antall
*	local antallsoyler = sisterad[`i']-forsterad[`i']+1
*	local tekstskalering = -0.021*`antallsoyler'+1.689
	local tekstskalering = -0.02*`antallsoyler'+1.7	
	if "`geonivaa'" == "fylke" & `tekstskalering'>1 local tekstskalering=1
*noisily di "tekstskalering `tekstskalering'"	
	//Markere missing søyler: Symbol i grafen, forklarende Note nedenfor. Note vises bare 
	//hvis det fins kommuner med missing i fylket.
	quietly count if datamangler!=. & hjemmefylke==$hjemfylke & length(Sted_kode)>2		//Må ikke telle med selve fylkesraden
	if `r(N)'!=0 local missingtekst= ustrunescape("\u25CF")+" Kommunen mangler data."
		else local missingtekst= " "
	

* NY GRAFKOMMANDO
* Med Graph Editor-linjer nederst! Se notater i Stata_Figurtips.doc.
/*	if "`geonivaa'"=="kommune" | "`geonivaa'"=="bydel" {
	graph twoway ///
		(bar andel radnr if hjemmefylke==$hjemfylke ,		/// 
		color("150 200 230") barwidth(0.8) 						///
		ylabel($ymin(1)$ymax, angle(horizontal) valuelabel glcolor(gs12))	///		
		ytitle("`yaksetekst'", size(medium) orientation(vertical)) ///
		///yline(`normal_linje') 									///
		xlabel(none) xscale(titlegap(3) range(`xmin' `xmax'))	///
		xtitle("`xaksetekst'", size(medium))			///
		graphregion(fcolor(white) lcolor(white) ilcolor(white)) ///
		plotregion(fcolor(gs15) margin(zero)) 					///
		legend(off) 											///
		text(`batchnr_yplass' `xmax' "`inndata'", 	///
			placement(w) color(gs9) justification(left) size(vsmall)) ///
		note(" " "`missingtekst' ", size(small) )							///
		text(`normal_tekst_yplass' `normal_tekst_xplass' "Normaltid for skjenketidsslutt", color(red) size(small) placement(east)) ///
		) ///
		(bar andel radnr if Sted_kode=="`nummer'",  /// Plotter bare aktuell kommune, i avvikende farge
		color("60 90 170") barwidth(0.8) 				/// og med kommunenavnet oppå søyla.
		text(`geolabel_yplass' `geolabel_xplass' "$geonavn", orientation(vertical) placement(12) color(black) size(*`tekstskalering')) ///
		) ///
		(scatter datamangler radnr if hjemmefylke==$hjemfylke , /// Setter på symbol der søyle mangler
		msymbol(circle) mcolor(gs4) ///
		)
	gr_edit plotregion1.AddLine added_lines editor `xmin' `normal_linje' `xmax' `normal_linje'
	gr_edit plotregion1.added_lines[1].style.editstyle  ///
		linestyle( width(medthick) color(red) pattern(solid)) 
	} //end -kommune bydel-
*/	
	*Fylker	: Liggende søyler dvs. option 'horizontal', men da blir det ikke konsekvent hva som er x og y i kommandoene!
	*'xlabel' etc. virker på vannrett akse, men verdiene på aksen er y-verdiene.
*	else if "`geonivaa'"=="fylke" {
	graph twoway ///
		(bar fylkestall radnr ,	horizontal	/// 
		color("`kommunefarge'") barwidth(0.8) 						///
		xlabel(0(10)`ymax', angle(horizontal) valuelabel glcolor(white)) ///		
		xtitle("`yaksetekst'", size(medium) /*orientation(vertical) */) ///
		xscale(range(`ymax')) ///  Uten denne får ikke øverste ylabel noen gridline.
		///yline(`normal_linje') 									///
		ylabel(1/$antall, noticks valuelabel angle(0) labsize(*`tekstskalering') nogrid) ///
		yscale(titlegap(3) range(`xmin' `xmax'))	 ///
		ytitle("")			///
		graphregion(fcolor(white) lcolor(white) ilcolor(white)) ///
		plotregion(fcolor(white) margin(zero)) 					///
		legend(off) 											///
		/*note(" " "`missingtekst' ", size(small) )		*/	///
		caption("Trening sesjon: Indikator.txt, batchnr. `batchnr'", position(5) ring(5) size(vsmall) color(gs9) )	///
		///text(`batchnr_yplass' `xmax' "`inndata'", 	///
		///	placement(w) color(gs9) justification(left) size(vsmall)) ///
		/*text(73 `normal_tekst_xplass' "{bf:`strek' Hele landet}", color(`landsfarge') size(medsmall) placement(west)) */ ///
		) ///
		///(`h'bar andel radnr if Sted_kode=="`nummer'",  /// Plotter bare aktuell kommune, i avvikende farge
		///color("60 90 170") barwidth(0.8) 				/// og med kommunenavnet oppå søyla.
		///text(`geolabel_yplass' `geolabel_xplass' "$geonavn", orientation(vertical) placement(12) color(black) size(*`tekstskalering')) ///
		///) ///
		(scatter radnr datamangler  if hjemmefylke==$hjemfylke & length(Sted_kode)>2 , /// Setter på symbol der søyle mangler
		msymbol(smcircle) msize(*`tekstskalering') mcolor(gs4) ///
		)													///
		(bar fylkestall radnr if radnr == `i', horizontal	///		Uthever aktuelt fylke 
		color("`fylkesfarge'") barwidth(0.8) )				///
		(bar fylkestall radnr if geo == 0 ,	horizontal		///		Søyle for landstallet
		color("`landsfarge'") barwidth(0.8) )	
	*gr_edit plotregion1.AddLine added_lines editor 0.5 `normal_linje' 11.5 `normal_linje'
	*gr_edit plotregion1.added_lines[1].style.editstyle  ///
	*	linestyle( width(thick) color(`landsfarge') pattern(solid)) 
*	}
	*/
	* Styrer figurstørrelsen i pixler ved eksport. Kan velge å sette bare én av dem.
	graph export `fil1', width(1200) /*height()*/ replace
	
} //SLUTT HOVEDLØKKE
exit
*===============================================================================
/*	Styre grafens utseende og utforming:
		// "asis" betyr "ikke beregn mean e.l."
		// "graphregion" er ytre og "plot.." indre del. "graphreg..(ilcolor(white))" fjernet ytre ramme rundt figuren.
		// "fcolor" er fyll-fargen, "margin" er avstand fra selve plottet og ut til aksene.
		//	   I et barplott er det ikke avstand under, men "margin(zero)" fjerner bakgrunnsfarge
		//     over øverste gridline.
		// "...gap" styrer avstand fra marg til søyle og mellom søyler, med søylebredden som enhet.
		// "blabel()" setter labels på hver søyle. "blabel(bar...)" viser søyleverdien.
		// "yscale" styrer lengden, og "ylabel" merker og tall, på y-aksen.
		// "labsize" er label-tekststørr., "glcolor" er gridlines. Grayscale høyere tall er lysere, gs16 er hvit.
		// "position()" er 9 o'clock, ring() er avstand fra sentrum: 0 er inni plottet, 0.5 mærmest mulig utenfor.
		// "placement()" er 12 0'clock, eller north/neast/east etc, eller .. (se help compassdirstyle):
		// 		text(y  x  "tekst", orientation(vertical) placement(12)) gir venstrejustert tekst som starter i (y x) og går loddrett oppover.
		// ( {bf} er en SMCL-kode for Boldface tekst, se "help graph text". )
		// Fjernes note'n helt, går aksetekstene ut av bildet nederst!
		// Flere Notes må ha option "suffix", ellers gjelder bare siste tekst. De får samme posisjon (fra 
		// 		siste kommando), mens tekst-size har ikke-intuitiv effekt (virker på en annen linje enn du tror!).
		// For å få tekster både til venstre og høyre under grafen, må de ha ulik type. Note og Caption 
		//		kan styres uavhengig.
		
*/
