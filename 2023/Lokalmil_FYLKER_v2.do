* TEMAFIGUR 2019: FORNØYD MED LOKALMILJØET (Ungdata) - FYLKETS KOMMUNER SAMLET
* 
* Utg.pkt. i Skjenketidsslutt-grafen fra Fylker 2018.
*
/* 	Spec kommune: 
	Søyler for hver kommune i fylket, som viser stengetiden.
	Markere aktuell kommune med avvikende farge.
	Rød linje for "normaltiden" 01:00.
	Symbol i grafen og forklaring i Note nedenfor hvis kommunen mangler tall. Annen 
	mekanisme enn i Alko/hasj-figuren.
	(Fylkes- og landstall gir ingen mening, bør bare slettes hvis de forekommer.)
	
	FYLKER: Graf uten spesielt markert kommune.
	TEST: Navn på alle søyler.
	
	V2: 07.03.19 - Legge inn forklarende tekst i grafen: grønn linje er hele landet.
	
Inndata: Indikator.txt for KOMMUNER, der alle tallene er ferdig preppet fram.

Figur nr 6

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
	
	- 10.03.2023: Lagt i Git lokale repo/Temafigurer/2023.
	- 13.03.2023: Lagt til at Hele landet kommer som egen søyle innen hvert fylke, og 
	  tatt bort horisontal linje for landstallet.
	
*/
*===============================================================================
set more off
set graphics on
pause on
macro drop _all

* REDIGER/SJEKK
*-----------------------------------------------------------------
local profiltype = "FHP"
local profilaar ="2023"		//Henter Geomaster fra dette året.
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
	local lokmilj = 21
} 
*INNDATA:
* For UTVIKLING
*local datakatalog "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON\PRODUKTER\SSRS_filer/`profilaar'/`geonivaa'\FigurOgTabell"
*local datafil "Indikator_ny.txt"

* SKARP - Tar den som faktisk er lastet opp FOR KOMMUNENE - fra backup av batchen.
local datakatalog "F:\Forskningsprosjekter\PDB 2455 - Helseprofiler og til_\Profiler\0_Sikkerhetskopier\2023_PDF_FRYS\Folkehelseprofiler\kommune\Kommune-2023-02-08-15-51"
local datafil "Indikator.txt"

global geomaster "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/Masterfiler/`profilaar'\Stedsnavn_SSB_TIL_GRAFER_Unicode.dta"
	/* I denne ligger: «Sted_kode», string stedskode ned til bydel dvs 6-sifret
	   (dvs. geo-numre med ledende null). 
	   «Sted», stedsnavn (inkl. fylkesangivelse for doble kommunenavn).
	   «geo», numerisk stedskode, med kortversjon av navn som value label. 
    */

*UTDATA, FOR TESTING:
*local targetkatalog "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON\PRODUKTER\SSRS_filer/`profilaar'/`geonivaa'\Temafigurer\TEST"

*SKARP:
local targetkatalog "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON\PRODUKTER\SSRS_filer/`profiltype'/`profilaar'/`geonivaa'\Temafigurer\Lokalmiljo"
*===============================================================================

* KJØRING:
*-----------------------------------------------------------------
cd "`targetkatalog'"
import delimited using "`datakatalog'/`datafil'", varnames(1) clear
pause
* Droppe unødvendige variabler og rader
keep if lpnr==`lokmilj'
* Sjekker indik.tittel
assert regexm(indikator, "lokalmilj") 
keep if spraakid=="BOKMAAL"
*exit
* Ta vare på landstallet: HER SKAL VÆRE BARE ÉN VERDI for alle tre år!
	//Post-covid er det separate landstall for hvert år, men de er temmelig like.
	//- Til horisontal linje for Landet: bruk local.
	//- Til søyle for landet inniblant kommunene: legge landstallet i kommunetall-kolonnen.
	//  Det må trikses til lengre ned.
local landstall = verdi_referansenivaa


keep sted_kode indikator verdi_lavestegeonivaa datotag_side4_innfilutfil
pause
****Merge på geo-navn fra masterfil: BRUKES OGSÅ i filtrering av geonivåer.
rename sted_kode geo
merge 1:1 geo using "$geomaster"	//Innfører rader for fylker, bydeler og HReg.
	*pause Etter merge geomaster
drop if geo > 30000
drop if geo > 54 & geo < 100
*drop if geo==0	//Må beholde landet og fylkene
drop _merge

*------------------------------------------------------------------------
**** SPLITT: Bydeler krever litt andre detaljer, men parallelt opplegg.
**** FYLKER skal ha samme data som kommuner, men grafen er litt annerledes.
*if "`geonivaa'" == "kommune" | "`geonivaa'" == "fylke" {

	**** Drop lavere geonivåer
*	drop if strlen(Sted_kode)>4
*	if "`geonivaa'" == "fylke"   drop if strlen(Sted_kode)>2 //Dropper ikke evt. HReg!
*	if "`geonivaa'" == "kommune" drop if strlen(Sted_kode)>4

	****Lage variabler med fylkestallene
	gen hjemmefylke =int(geo/100) //nærmeste integer ved trunkering
	replace hjemmefylke =geo if strlen(Sted_kode)==2 //Fylkene selv, og Hele landet.
	
	****Lage landstall som kan plottes inni hvert fylke
	levelsof hjemmefylke if geo > 0 , local(f_liste)	//Telle fylker
	local ant_fylker = wordcount("`f_liste'")
	expand = `ant_fylker' if geo == 0					//Gir én landstall-rad for hvert fylke
	replace verdi_lave = "`landstall'" if geo == 0		//Fyller inn verdien, til plottet
	sort geo											//Legger Hele landet først
	forvalues f = 1/`ant_fylker' {						//Tilordne fylkesangivelse til landstall-radene
		replace hjemmefylke = real(word("`f_liste'", `f')) in `f'
	}
	replace geo = 1000 if geo == 0						//For å få landstallet sortert som en kommune

*	gen fylkestall =rate if strlen(Sted_kode)==2
	sort hjemmefylke geo //sikrer at selve fylket kommer først
*	replace fylkestall = fylkestall[_n-1] if fylkestall==.
		//Nå fikk Oslo verdi både for fylke og kommune

	****Lage variabel med fylkesnavn, til label i grafen
	gen fylkesnavn =Sted if strlen(Sted_kode)==2
	replace fylkesnavn = fylkesnavn[_n-1] if fylkesnavn==""
	
	****Nå har vi rader uten tall for selve fylkene, bruker dem til å sette opp grafen.
	
*} //FERDIG IF KOMMUNE/FYLKE
*--------------------------------------------------------------------------

sort hjemmefylke geo

****Tell rader - skal være lik antall kommuner/fylker
quietly describe
global antall = r(N)
gen radnr =_n	//løkkestyring

*Finne første og siste rad i hvert fylke (til x-aksen)
	//Disse tallene endres ikke av sorteringen til grafen i neste avsnitt.
gen forsterad = radnr if hjemmefylke > hjemmefylke[_n-1]
replace forsterad = 1 in 1 //Der virker ikke testen ovenfor
replace forsterad = forsterad[_n-1] if forsterad == .
gen sisterad = radnr if hjemmefylke < hjemmefylke[_n+1]
gsort -hjemmefylke -geo										//Sorterer fallende
replace sisterad =sisterad[_n-1] if sisterad == .

* Sortere etter ønsket rekkefølge i grafen:
*------------------------------------------
/* A) Viser kommunene i nummerrekkefølge (Opprinnelig metode).
*    Da er radnr allerede satt.
 sort hjemmefylke geo	
 */
 
/* B) Viser kommunene etter stigende indikatorverdi.
*    Må resette radnr, som brukes til labelling.
*    _Antallet_ radnr per fylke er uendret, så forsterad og sisterad stemmer.
sort hjemmefylke verdi_lave	
replace radnr = _n		
 */

* C) Viser kommunene etter synkende indikatorverdi.
*    Må resette radnr, som brukes til labelling.
*    _Antallet_ radnr per fylke er uendret, så forsterad og sisterad stemmer.
*	 Men for å bevare fylket forrest med synkende sortering, må jeg trikse med tall.
replace verdi_lave = "99999" if length(Sted_kode) == 2 & geo != 1000	//OBS unngå landstallet, 'geo 1000'.
gsort hjemmefylke -verdi_lave	
replace radnr = _n	
replace verdi_lave = "" if length(Sted_kode) == 2 & geo != 1000			//ditto
 */


*Lage en label til x-aksen i fylkesgrafene
*forvalues i = 1/4 {
forvalues i = 1/$antall {
	local navn = Sted[`i']
	label define radnr `i' "`navn'", add
} //end -forvalues-
label values radnr radnr

* Lage en y-verdivariabel
replace verdi_lave = subinstr(verdi_lave, "**", ".",.)
destring verdi_lave, gen(andel)

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
/*Ymax: Setter til 100
summarize andel
global maxverdi =r(max)
global ymax =$maxverdi */
global ymax =100

di "ymax: " $ymax
di "maxverdi: " $maxverdi
		
****Dummyvariabel for å markere manglende data
gen datamangler = 2  if missing(andel) //y-verdi like over x-aksen

****Batchnummer, til tekst i hjørnet av figuren
local batchnr = datotag_side4_innfilutfil[2]	//Første rad er tom

cd "`targetkatalog'"

*-----------------------------------------------------------------------
* SELVE FIGUREN
*-----------------------------------------------------------------------
* Søylefarge i hht. FHIs webpalett
local kommunefarge "46 161 192"
local landsfarge "57 60 97"

* Unicode-tegn for landslinja, til forklaringstekst
local strek = ustrunescape("\u25AC")

**** Løkke gjennom alle rader
	*Fylkesgrafer: må styres separat (gidder ikke kjøre 422 ...)
	gen startflagg =_n if geo < 100
	levelsof startflagg, local(start)
	
	*forvalues i=112/112 {	//Tønsberg
	*forvalues i=414/414 {	//Høylandet -TRL, kort søyle
	*forvalues i=20/20 {		//Ski
	
	*local start = 29		//Kjøre bare én graf

foreach i of local start {
*local i=393 //for testing av graf
	//bygg filnavn fra kommunenummeret i rad x (subscripting)
	local nummer =Sted_kode[`i']
	local fil1   ="`nummer'" + "_`fig_nr'_tema.png"
	noisily di "`fil1'"
	
	//Finn kommune/fylkesnavn, til label i grafen. 
	global geonavn =Sted[`i']
	local fylkenavn =fylkesnavn[`i']
	global hjemfylke = hjemmefylke[`i']
di "local Fylkenavn rett etter fylling, i løkka: `fylkenavn' "	

****Aksetekster
	local yaksetekst "Andel (prosent), standardisert"
	*local yaksetekst "{bf:Andel (prosent)}"  //Bold
	if "`geonivaa'" == "kommune" | "`geonivaa'" == "fylke" local xaksetekst "Kommunene i `fylkenavn'" 	
	if "`geonivaa'" == "bydel" local xaksetekst "`fylkenavn'" 	//For bydel er "fylkenavn" hardkodet tekst.
	if "`nummer'"  == "03"  local xaksetekst "" 				//Oslo har ingen underliggende kommuner
*di "Xaksetekst, som inneholder fylkenavn: `xaksetekst' "

	//Dimensjonere plassering av tekster og andre ting
	local minste_x = forsterad[`i'] +1	//Hopper over selve fylket, som ligger først
	local xmin= `minste_x'-0.7			//Starten på x-aksen - varierer jo med fylke.
	local storste_x = sisterad[`i']
	local xmax= `storste_x'+0.7			//Slutten på x-aksen

*	local batchnr_yplass = -55 	//Kildefilnavnet i hjørnet, avstand fra x-aksen: Styrer annerledes.
*	local batchnr_Xplass = `xmax'-(length("`inndata'")/4) //Kildefilnavnet i hjørnet, plass på x-aksen: Bruker xmax.
	local geolabel_yplass = $ymin+0.5
	local geolabel_xplass = radnr[`i']
	local normal_linje	  = `landstall'
	local normal_tekst_yplass	= `normal_linje'+0.2
	local normal_tekst_xplass	= `xmax'
	
	//Skalere søyleteksten. Fant at en passende faktor (y) varierer slik: y=-0,021x+1,689 der x er antall søyler.
	local antallsoyler = sisterad[`i']-forsterad[`i']+1
*	local tekstskalering = -0.021*`antallsoyler'+1.689
	local tekstskalering = -0.02*`antallsoyler'+1.7	
	if "`geonivaa'" == "fylke" & `tekstskalering'>1 local tekstskalering=1
*noisily di "tekstskalering `tekstskalering'"	
	//Markere missing søyler: Symbol i grafen, forklarende Note nedenfor. Note vises bare 
	//hvis det fins kommuner med missing i fylket.
	quietly count if datamangler != . & hjemmefylke == $hjemfylke & length(Sted_kode) > 2		//Må ikke telle med selve fylkesraden
	if `r(N)'!= 0 local missingtekst = ustrunescape("\u25CF")+" Kommunen mangler data."
		else local missingtekst = " "
	

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
	*Fylker	
*	else if "`geonivaa'"=="fylke" {
	graph twoway ///
		(bar andel radnr if hjemmefylke==$hjemfylke & geo > 100 ,		/// Hoppe over selve fylket
		color("`kommunefarge'") barwidth(0.8) 						///
		ylabel(0(10)$ymax, angle(horizontal) valuelabel glcolor(gs12))	///		
		ytitle("`yaksetekst'", size(medium) orientation(vertical)) ///
		yscale(range($ymax)) ///  Uten denne får ikke øverste ylabel noen gridline.
		///yline(`normal_linje') 									///
		xlabel(`minste_x'/`storste_x', noticks valuelabel angle(90) labsize(*`tekstskalering')) xscale(titlegap(3) range(`xmin' `xmax'))	///
		xtitle("`xaksetekst'", size(medium))			///
		graphregion(fcolor(white) lcolor(white) ilcolor(white)) ///
		plotregion(fcolor(white) margin(zero)) 					///
		legend(off) 											///
		subtitle("Siste tilgjengelige Ungdata-tall for kommunen")	///
		note(" " "`missingtekst' ", size(small) )			///
		caption("Lokalmiljø: Indikator.txt, batchnr. `batchnr'", position(5) ring(5) size(vsmall) color(gs9) )	///
		///text(`batchnr_yplass' `xmax' "`inndata'", 	///
		///	placement(w) color(gs9) justification(left) size(vsmall)) ///
		/*text(95 `normal_tekst_xplass' "{bf:`strek' Hele landet}", color(`landsfarge') size(medsmall) placement(west))*/ ///
		) ///
		///(bar andel radnr if Sted_kode=="`nummer'",  /// Plotter bare aktuell kommune, i avvikende farge
		///color("60 90 170") barwidth(0.8) 				/// og med kommunenavnet oppå søyla.
		///text(`geolabel_yplass' `geolabel_xplass' "$geonavn", orientation(vertical) placement(12) color(black) size(*`tekstskalering')) ///
		///) ///
		(scatter datamangler radnr if hjemmefylke==$hjemfylke & length(Sted_kode)>2 , /// Setter på symbol der søyle mangler
		msymbol(smcircle) msize(*`tekstskalering') mcolor(gs4) ///
		) ///
		(bar andel radnr if hjemmefylke==$hjemfylke & geo == 1000 ,		/// Landstallet som egen søyle
		color("`landsfarge'") barwidth(0.8) 							///
		)
	*gr_edit plotregion1.AddLine added_lines editor `xmin' `normal_linje' `xmax' `normal_linje'
	*gr_edit plotregion1.added_lines[1].style.editstyle  ///
		linestyle( width(thick) color(`landsfarge') pattern(solid)) 
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
