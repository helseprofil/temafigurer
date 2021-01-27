* TEMAFIGUR 2021: TRENER MINDRE ENN UKENTLIG, SESJONSDATA
* 
*		OBS VED GJENBRUK: Ny mappestruktur for produktene ifm OVP sep-2020.
*
/* 	Utgangspunkt: Valgdeltakelse 2020

Spec: 
	År "2018_2019" (er eneste).
	Kjonn == 0 ?
	Søyler Kommune-Fylke-Land (Bydel-Kommune-Land)
	Måltall: meis
	Prosenttall vises på søylene

Figur nr 5 (midten s.3)

Data til label "kommunenavn": 
Merge på en masterfil med de navnene vi bruker hele veien.

Inndata-filnavnet (som har datotag) ligger som grå minitekst 
nederst i hjørnet på figurene.

OBS FARGER - Nye fargekoder i 2019, ikke lagt inn her.
Rekkefølge på fargene 2019 var -> kommune mørk blå, fylke lys blå, Landet grønn.

F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON\BIN\Z_Profiler\2020\Temafigurscript

*/
*===============================================================================
set more off
set graphics on
pause on

* REDIGER/SJEKK
*-----------------------------------------------------------------
local profilaar ="2021"
local geonivaa ="kommune" //Tillatte verdier: "kommune". Vet ikke "fylke" ennå. BRUKES IKKE i "bydel".
local fig_nr =5			//Bestemmer hvor på sidene figuren skal stå.
						//s.2 -> fig.1-2-3, s.3 -> fig.4-5-6.
						//OBS: ER UAVHENGIG AV figurens nummer i profilteksten!
						
*INNDATA:
*local kildekatalog "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON\PRODUKTER\KUBER\NORGESHELSA\NH2017NESSTAR"
local kildekatalog "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON\PRODUKTER\KUBER\KOMMUNEHELSA\KH2021NESSTAR"
*local kildekatalog "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON\PRODUKTER\KUBER\KOMMUNEHELSA\DATERT\csv"

local inndata "FORSVARET_TRENING_2021-01-06-17-59"

local geomaster "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/Masterfiler/`profilaar'\Stedsnavn_SSB_TIL_GRAFER_Unicode.dta"
	/* I denne ligger: «Sted_kode», string stedskode ned til bydel dvs 6-sifret
	   (dvs. geo-numre med ledende null). 
	   «Sted», stedsnavn (inkl. fylkesangivelse for doble kommunenavn).
	   «geo», numerisk stedskode, med kortversjon av navn som value label. 
    */

*UTDATA, HUSK: Ikke i BIN-katalogen.

*FOR TESTING:
*local targetkatalog "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON\PRODUKTER\SSRS_filer\FHP\2021\Kommune\Temafigurer\TEST"

*SKARP:
local targetkatalog "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON\PRODUKTER\SSRS_filer/FHP/`profilaar'/`geonivaa'\Temafigurer\Trening_sesjon"
*===============================================================================

* KJØRING:
*-----------------------------------------------------------------
cd "`kildekatalog'"
import delimited using "`inndata'", delimiter(";") varnames(1) clear

* Droppe unødvendige variabler og rader
levelsof aar, local(alleaar) clean //Clean dropper quotes, må til for å få match med variabelen etterpå.
local aarmax = word(`"`alleaar'"', -1) //siste ord i den sorterte rekka. 
keep if aar==`"`aarmax'"'
keep if kjonn == 0
*keep if type_valg == "KOMMUNEVALG"
keep geo aar meis

	
****Merge på geo-navn fra masterfil
merge 1:1 geo using "`geomaster'"
	*pause Etter merge geomaster
drop if _merge == 2					//Helseregioner og bydeler finnes ikke i dataene	
	
	/***************************
	drop if geo==30116 | geo==30117	//Sentrum og Marka er med i Geomaster
	***************************/
	
*------------------------------------------------------------------------
**** SPLITT: Bydeler krever litt andre detaljer, men parallelt opplegg.
if "`geonivaa'" == "kommune" | "`geonivaa'" == "fylke" {

 	**** Drop lavere geonivåer
	if "`geonivaa'" == "fylke" drop if geo>54 //Dropper også evt. HReg.
	if "`geonivaa'" == "kommune" drop if geo>30000

	****Lage variabler med fylkestallene
	gen hjemmefylke =int(geo/100) //nærmeste integer ved trunkering
	replace hjemmefylke =geo if geo<=54 //Fylkene selv

	gen fylkestall =meis if geo<=54
	sort hjemmefylke geo //sikrer at selve fylket kommer først
	replace fylkestall = fylkestall[_n-1] if fylkestall==.
		//Nå fikk Oslo verdi både for fylke og kommune

	****Lage variabel med fylkesnavn, til label i grafen
	gen fylkesnavn =Sted if geo<=54 
	replace fylkesnavn = fylkesnavn[_n-1] if fylkesnavn==""

} //FERDIG IF KOMMUNE/FYLKE
*--------------------------------------------------------------------------

else if "`geonivaa'" == "bydel" {
* Tilrettelegger bydelstallene etter samme mønster som Kommune. Grafen er lik.

	**** Drop fylker og Marka/Sentrum
	drop if geo<=54 & geo!=0
	drop if geo==30116 | geo==30117

	****Lage variabler med tallene for hele kommunen (beholder var-navnet "fylke...")
	*   Skal ha bydel-kommune-Norge.
	gen hjemmefylke =int(geo/100) //nærmeste integer ved trunkering
	replace hjemmefylke =geo if geo==301 | geo==1103 | geo==4601 | geo==5001 //Storbyene selv

	gen fylkestall =meis if geo<=5444 //Lagrer KOMMUNEtallet
	sort hjemmefylke geo //sikrer at selve storbyene kommer først. Kommunetallet fylles ut for bydelene:
	replace fylkestall = fylkestall[_n-1] if fylkestall==.

	****Lage variabel med fylkesnavn, til label i grafen. For bydel er det storbyens kommunenavn.
	gen fylkesnavn =Sted if geo==301 | geo==1103 | geo==4601 | geo==5001
	replace fylkesnavn = fylkesnavn[_n-1] if fylkesnavn==""

	****Kvitte oss med kommuner uten bydeler (men beholde landet)
	drop if hjemmefylke<301 & geo!=0

} //FERDIG IF BYDEL

****   Velge ut aktuelt geo-nivå
if "`geonivaa'"=="kommune" { //Bydeler ble droppet ovenfor.
	drop if geo<100 & geo!=0
	}
else if "`geonivaa'"=="fylke" {
	drop if geo>54
	}
else if "`geonivaa'"=="bydel" {
	drop if geo<30000 & geo!=0
	} 
else {
	di "Skriv inn gyldig geo-nivå i scriptet"
	exit
	}

****Lage ny variabel med bare landstallet
sort geo
gen landstall =meis[1]
drop in 1		//Nå trenger vi ikke raden for landet lenger.

****Tell rader - skal være lik antall kommuner/fylker
quietly describe	//BYDELER: Storbyene ligger igjen, men de hoppes over i selve graf-løkka.
local antall=r(N)
gen radnr =_n	//løkkestyring

****For skalering av y-aksen: (FOR INFLUENSA: OVERSTYRES ETTERPÅ ...)
	/* VURDER: Dersom dette avsnittet plasseres foran der jeg renser vekk uvedkommende geo-nivå,
	   vil alle profiltyper (fylke, kommune og bydel) få samme y-akse i samme år.
	   Står avsnittet etter nivå-rensing, vil geonivåene få hver sin lengde på y-aksen.*/
quietly summarize meis
local maxverdi =r(max)
local ymax =round(`maxverdi', 5) //Runder av til nærmeste 5-tall. SEES I SMNHENG med gridlines i grafen.
if `ymax' < `maxverdi' local ymax = `maxverdi'+0.5 
local ymax = ceil(`ymax') 		//Runder oppover til nærmeste heltall
	*INFLUENSAVAKS: Maksverdi er under 70, men policytarget er 75 %. Vi vil 
	*vise target i diagrammet, så vi setter maksverdi manuelt.
	*local ymax=77		// Gir litt luft over den markerte linja.
	di "ymax: " `ymax'
	di "maxverdi: " `maxverdi'
		
*Ymin: 
quietly summarize meis 
local minverdi =r(min)
local ymin =round(`minverdi'-2, 2)	//Legger litt buffer under, for at søylen alltid 
									//skal ha en viss lengde, og Runder av til nærmeste 2-tall. 
									//SEES I SMNHENG med gridlines i grafen.
if `ymin' > `minverdi' local ymin =`ymin'-2

*Eller, hvis ymin viser seg å bli énsifret: Penere å starte på null.
*local ymin =0
	di "ymin: " `ymin'

****Label på ting -> lesbar Legend automatisk
label var meis "Kommune"			//I grafen overstyres med aktuelt geonavn.
label var fylkestall "Fylke"		//Ditto.
label var landstall "Norge"

local yaksetekst "Andel (prosent, standardisert)"
*local yaksetekst "{bf:Valgdeltakelse (prosent)}"  //Bold
*local xaksetekst "Målsetting: 75 % vaksinasjonsdekning."

cd "`targetkatalog'"

*-----------------------------------------------------------------------
* SELVE FIGUREN
*-----------------------------------------------------------------------

**** Løkke gjennom alle rader
*forvalues i=18/18 {
forvalues i=1/`antall' {
*local i=1 //for testing av graf
	//bygg filnavn fra kommunenummeret i rad x (subscripting)
	local nummer =Sted_kode[`i']
	local fil1   ="`nummer'" + "_`fig_nr'_tema.png"
	noisily di "`fil1'"
	
	//Finn kommune/fylkesnavn, til label i grafen. 
	local geonavn =Sted[`i']
	local fylkenavn =fylkesnavn[`i']
	
	//Forberede merking av evt. missing søyler
		//Klippet fra et script med to plott, variabel A og B
	local A_stjerne="" //Nullstiller før testen for denne kommunen
*	local B_stjerne=""
	local fylkesA_stj=""
*	local fylkesB_stj=""
	local anontekst  =""
	
	local stjernesymbol=ustrunescape("\u25CF") //Unicode hex-kode 25CF er fylt svart sirkel
	
	if "`geonivaa'"=="kommune" | "`geonivaa'"=="bydel" {	
		if meis[`i']==. {
			local A_stjerne="`stjernesymbol'"
			local anontekst  =`"`stjernesymbol' Manglende eller" "   utilstrekkelig tallgrunnlag"'
		} //end -var. A-
	/*	if <meis var.B>[`i']==. {
			local B_stjerne="`stjernesymbol'"
			local anontekst  =`"`stjernesymbol' Manglende eller" "   utilstrekkelig tallgrunnlag"'
		} //end -var. B- */
		if fylkestall[`i']==. {
			local fylkesA_stj = "`stjernesymbol'"
			local anontekst  =`"`stjernesymbol' Manglende eller" "   utilstrekkelig tallgrunnlag"'
		} //end -fylkes var.A-
	/*	if fylkes<meis var.B>[`i']==. {
			local fylkesB_stj = "`stjernesymbol'"
			local anontekst  =`"`stjernesymbol' Manglende eller" "   utilstrekkelig tallgrunnlag"'
		} //end -fylkes var.B-  */
		
	} //end -kommune bydel-
	
	if "`geonivaa'"=="fylke" {
		if fylkestall[`i']==. {
			local fylkesA_stj="`stjernesymbol'"
			local anontekst  =`"`stjernesymbol' Manglende eller" "   utilstrekkelig tallgrunnlag"'
		} //end -fylkes var.A-
	/*	if fylkes<meis var.B>[`i']==. {
			local fylkesB_stj="`stjernesymbol'"
			local anontekst  =`"`stjernesymbol' Manglende eller" "   utilstrekkelig tallgrunnlag"'
		} //end -fylkes var.B- */  
	} //end -fylke-

	
	//Dimensjonere plassering av tekster
	local avstand= `ymax'/25 			//Stedsnavnene avstand fra x-aksen
	local batchnr_yplass = `ymax'/12 	//Kildefilnavnet i hjørnet, avstand fra x-aksen
	local batchnr_Xplass = 98-(length("`inndata'")) //Kildefilnavnet i hjørnet, plass på x-aksen
	local anontekst_Xplass = 2
*	local anontekst_Xplass = 100-(length("`anontekst'")) //Forklarende tekstboks
	local anontekst_Yplass = `ymax'-(`ymax'*0.04)
	local A_stjerne_Xplass = 21
*	local B_stjerne_Xplass = 61
	local fylkesA_stj_Xpl  = 50
*	local fylkesB_stj_Xpl  = 75
	local stjerne_Yplass = `ymax'*0.05

	//Sette fargekoder
	local kommfarge "57 60 97"		//mørk blå
	local fylkesfarge "9 117 181"	//mellomblå/turkis
	local landsfarge "112 163 0"	//dus grønn

			* 2018-farger:
			*	local kommfarge 	"0 153 0"		//grønn
			*	local fylkesfarge 	"234 153 6"		//orange
			*	local landsfarge 	"67 103 189" 	//blå
	
	*Kommuner	
	if "`geonivaa'"=="kommune" | "`geonivaa'"=="bydel" {
	graph bar (asis) meis fylkestall landstall  if radnr ==`i', ///
		graphregion(fcolor(white) lcolor(white) ilcolor(white)) ///
		plotregion(fcolor(white) margin(zero)) ///
/*		outergap(100) bargap(100) bar(1, color("0 153 0")) bar(2, color("234 153 6")) bar(3, color("67 103 189")) */ ///
		outergap(100) bargap(100) bar(1, color("`kommfarge'")) bar(2, color("`fylkesfarge'")) bar(3, color("`landsfarge'")) ///
		blabel(bar, format(%3.0f) size(medium)) /// Viser bar-høyden på hver søyle
		///yscale(range(`ymax') noextend) ylabel(0 10 20 30 40 50 60 70 75, angle(horizontal) labsize(medium) glcolor(gs12)) ///
		///yscale(range(100) noextend) ylabel(0 10 20 30 40 50 60 70 80 90 100, angle(horizontal) labsize(medium) glcolor(gs12)) ///
		yscale(range(`ymax') noextend) ylabel(0 (5) `ymax', angle(horizontal) labsize(medium) glcolor(gs12)) ///
		ytitle("`yaksetekst'", size(medium) orientation(vertical)) ///
		///subtitle("`yaksetekst'", size(large) position(9) ring(0.5) orientation(vertical)) /// For komb. med lang 75-label på aksen
		legend(off) ///
		text(-`avstand' 21 "`geonavn'", size(medlarge))    ///
		text(-`avstand' 50 "`fylkenavn'", size(medlarge))    ///
		text(-`avstand' 78 "Hele landet", size(medlarge)) ///
		text(-`batchnr_yplass' `batchnr_Xplass' "`inndata'", ///
			placement(se) color(gs9) justification(left) size(vsmall)) ///
		text(`stjerne_Yplass' `A_stjerne_Xplass' "`A_stjerne'", size(vlarge))	///
	/*	text(`stjerne_Yplass' `B_stjerne_Xplass' "`B_stjerne'", size(vlarge))	*/ ///
		text(`stjerne_Yplass' `fylkesA_stj_Xpl' "`fylkesA_stj'", size(vlarge))	///
	/*	text(`stjerne_Yplass' `fylkesB_stj_Xpl' "`fylkesB_stj'", size(vlarge))	*/ ///
		text(`anontekst_Yplass' `anontekst_Xplass' "`anontekst'", color(black) placement(e) justification(left)) ///
		note(" " " ", size(vsmall) )
	}	
	*Fylker	
	else if "`geonivaa'"=="fylke" {
	graph bar (asis) fylkestall landstall  if radnr ==`i', ///
		graphregion(fcolor(white) lcolor(white) ilcolor(white)) ///
		plotregion(fcolor(gs15) margin(zero)) ///
/*		outergap(100) bargap(100) bar(1, color("234 153 6")) bar(2, color("67 103 189")) */ ///
		outergap(100) bargap(100) bar(1, color("`fylkesfarge'")) bar(2, color("`landsfarge'"))  ///
		blabel(bar, format(%3.0f) size(medium)) /// Viser bar-høyden på hver søyle
		///yscale(range(`ymax') noextend) ylabel(0 10 20 30 40 50 60 70 80 90 100, angle(horizontal) labsize(medium) glcolor(gs12)) ///
		yscale(range(`ymax') noextend) ylabel(0 (5) `ymax', angle(horizontal) labsize(medium) glcolor(gs12)) ///
		ytitle("`yaksetekst'", size(medium) orientation(vertical)) ///
		///subtitle("`yaksetekst'", size(large) position(9) ring(0.5) orientation(vertical)) ///
		legend(off) ///
		text(-`avstand' 30 "`fylkenavn'", size(medlarge))    ///
		text(-`avstand' 70 "Hele landet", size(medlarge)) ///
		text(-`batchnr_yplass' `batchnr_Xplass' "`inndata'", ///
			placement(se) color(gs9) justification(left) size(vsmall)) ///
		note(" " " ", size(vsmall))
	}	


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
		// ( {bf} er en SMCL-kode for Boldface tekst, se "help graph text". )
		// Fjernes note'n helt, går aksetekstene ut av bildet nederst!
		
	- Tre søylegrupper tilsv utd-grp. Kommer med over().
		V6: søylegrupper per Geo - dvs. motsatt av V5.
		"yvaroptions" ascategory og asyvars klarte ikke å bytte om, måtte reshape filen.
	- søylefarger: V6: må være utd-gruppene.
	- Yskala: Bruker ymin-ymax locals.
		"yscale()" kan ikke forkorte aksen!
		"ylabel(65(5)100)" forlenger aksen til 100, men forkorter ikke mellom 0 og 65.
		"exclude0" løste problemet!
	- Aksetekst: Value label på utdann tilstrekkelig? OK.
	- Legend med kommune- og fylkesnavn, på én linje.
	- Missing håndteres som ønsket: Søylene plottes med null høyde. 
		Det fins en option "missing", som beholder "missing" som en kategori - ikke testet.
		Det er 75 missing flx1 (dvs. grunnskole) blant kommunene, og en del Univ/høy (2016).
*/
