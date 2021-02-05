/*	TEMAFIGUR FOLKEHELSEPROFIL-2021: ANDEL SOM ER LITE FYSISK AKTIVE (Ungdata)
	- søylediagram med kommune, fylke og land for det siste av de årene kommunen 
	  har tall i løpet av perioden 2018-2020. 

*		OBS VED GJENBRUK: Ny mappestruktur for produktene ifm OVP sep-2020.
*
	Figurplassering: Øverst side 3 (plass nr. 4)
	
	Inndata: Flatfil Indikator.txt, der riktige fylkes- og landstall er plukket ut 
	(ulikt for kommunene etter når de gjorde Ungdata). Se også AlkoHasj-figur 2018.
	
	***VED GJENBRUK: døp om indikatorene til "Indik1" etc, så er det kjappere neste gang!
	
	07.09.20 OBS: Vi la inn dobbeltstjerne ist.f. kommunetallet, for å markere spesielt 
	de geo som ikke hadde Ungdata-tall med en egen fotnote. Da kræsjet "generate" i 
	måltall-håndteringen, så alle kommuner fikk missing ...! Se ca. linje 100.
*/
*===============================================================================
set more off
set graphics on
pause on

* REDIGER/SJEKK
*-----------------------------------------------------------------
local modus = "TEST" 	//Tillatt: TEST, SKARP  - styrer både utdata og løkke for én eller alle grafer.
local profilaar = "2021"	//
local geonivaa = "kommune" 	//Tillatte verdier: "kommune", "bydel".  Ungdata brukes ikke i "fylke".
local fig_nr = 4		//Bestemmer hvor på sidene figuren skal stå.
						//s.2 -> fig.1-2-3, s.3 -> fig.4-5-6.
						//OBS: ER UAVHENGIG AV figurens nummer i profilteksten!

*Indikatorenes nummer i tabellen - se tabell FRISKVIK. DUMMY per 19.1.21
if "`geonivaa'" == "kommune" {
	local Indik1 = 22		// Faktisk
	*local loktilbud=18
} // fra Ungdata - for KOMMUNER
else if "`geonivaa'" == "bydel" {
	local Indik1 = 18		// Faktisk
	*local loktilbud=18
} // fra Ungdata - for BYDEL 
else if "`geonivaa'" == "fylke" {
	local trygghet=.
	*local loktilbud=7
} // Ungdata brukes ikke på fylkesnivå

local Indik1tekst "Lite fysisk aktive"
						
*INNDATA: 
*-----------------
/* For UTVIKLING
*local datakatalog "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON\PRODUKTER\SSRS_filer/`profilaar'/`geonivaa'\FigurOgTabell"
*local datafil "Indikator_ny.txt"
local datakatalog "N:\Helseprofiler_Rapportgenerator\Folkehelseprofiler\Importfiler\PROD/`geonivaa'\Flatfiler\FHP_2020"
local datafil "Indikator.txt"
	*/

* SKARP - Tar den som faktisk er lastet opp
local datakatalog "N:\Helseprofiler_Rapportgenerator\Folkehelseprofiler\Importfiler\PROD/`geonivaa'\Flatfiler"
local datafil "Indikator.txt"
	*/

local geomaster "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/Masterfiler/`profilaar'\Stedsnavn_SSB_TIL_GRAFER_Unicode.dta"
	/* I denne ligger: «Sted_kode», string stedskode ned til bydel dvs 6-sifret
	   (dvs. geo-numre med ledende null). 
	   «Sted», stedsnavn (inkl. fylkesangivelse for doble kommunenavn).
	   «geo», numerisk stedskode, med kortversjon av navn som value label. 
	   «GEO», nøyaktig maken men med Caps, så merge finner en av dem!
    */

*ANTALL ÅR Å SLÅ SAMMEN (Ungdata - unødv. når Indikator.txt er inndata, der er tallene ferdiglaget)
*local ant_perioder=3

*UTDATA, FOR TESTING:
if "`modus'" == "TEST" {
	local targetkatalog "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON\PRODUKTER\SSRS_filer\FHP/`profilaar'/`geonivaa'\Temafigurer\TEST"
}
*else local targetkatalog "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON\PRODUKTER\SSRS_filer\FHP/`profilaar'/`geonivaa'\Temafigurer\Fysakt_Ungdata"
else local targetkatalog "C:\Users\stbj\Documents\1-FHI\Mellomlager" //Hjemme går det mye fortere å skrive til C:.

*===============================================================================

* KJØRING:
*-----------------------------------------------------------------
***cd "`kildekatalog'"

import delimited "`datakatalog'/`datafil'" , encoding("UTF-8") stringcols(2) clear //Bevarer Sted_kode som string
*use "`datakatalog'/`datafil'" ,clear
*	pause
keep if lpnr==`Indik1' // | lpnr==`loktilbud'
keep if spraakid=="BOKMAAL"

* Sjekker indik.tittel 
assert regexm(indikator, "`Indik1tekst'")	
	*assert regexm(indikator, "lokalmilj") | regexm(indikator, "treffst[ae]d[ae]r")


	*pause Sjekk inndatarader

* Ta fram de variablene som plottes:
	//skjermtidmeis fylkesskjermtid landsskjermtid 
	//Må altså reshape etter LPnr og rename
	//Men først prepper jeg de tre tallvariablene, de er tekst i innfilen.

keep sted_kode omraade_kode lpnr verdi_lavestegeonivaa verdi_mellomgeonivaa verdi_referansenivaa ///
	datotag_side4_innfilutfil
rename sted_kode Sted_kode
	*pause
	*exit
if "`geonivaa'" !="fylke" {	//Der er denne var. numerisk, og missing.
	replace verdi_lavestegeonivaa = subinstr(verdi_lavestegeonivaa, "-", "",.)
	replace verdi_lavestegeonivaa = subinstr(verdi_lavestegeonivaa, "**", "",.)
	destring verdi_lavestegeonivaa , dpcomma gen(meis) 
}
capture confirm variable meis
if _rc!=0 gen meis=.		//Må opprettes for fylkene, ellers kræsjer det nedenfor
replace verdi_mellomgeonivaa = subinstr(verdi_mellomgeonivaa, "-", "",.)
destring verdi_mellomgeonivaa , dpcomma gen(fylkes)
replace verdi_referansenivaa = subinstr(verdi_referansenivaa, "-", "",.)
destring verdi_referansenivaa , dpcomma gen(lands)
drop verdi*

		/* Reshape brukes når det er to indikatorer som skal plottes. Trengs ikke for TRYGGHET.
		gen indik= "lokalmilj"					//Til reshape-navn
		replace indik= "lokaltilbud" if lpnr==`loktilbud'
		drop lpnr
		reshape wide @meis fylkes lands, i(Sted_kode) j(indik) string
			*pause Etter reshape
			
		*Nå har vi tre tallvariabler for hver indik (hvorav de to "...meis" er tomme for fylkene)
		*------------------------------------------------------------------------
		*/
*Nå har vi tre tallvariabler - meis, fylkes og lands.
	
****Merge på geo-navn fra masterfil
merge 1:1 Sted_kode using "`geomaster'"
//Her vil det være mye mismatch: Datafilen Indikator.txt har jo bare ett geonivå.
//Må ta vare på nødvendige navn før mismatchene ryddes vekk.
	*pause Etter merge geomaster
	*exit
*------------------------------------------------------------------------
****For skalering av y-aksen: 
	/* VURDER: Dersom dette avsnittet plasseres foran der jeg renser vekk uvedkommende geo-nivå,
	   vil alle profiltyper (fylke, kommune og bydel) få samme y-akse i samme år.
	   Står avsnittet etter nivå-rensing, vil geonivåene få hver sin lengde på y-aksen.*/
* Lokaltilbud var både høyeste og laveste verdi.	   
if "`geonivaa'"!="fylke" quietly summarize meis	
else quietly summarize fylkes
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
		
*Ymin: 
if "`geonivaa'"!="fylke" quietly summarize meis
else quietly summarize fylkes
local minverdi =r(min)
local ymin =round(`minverdi'-2, 2)	//Legger litt buffer under, for at søylen alltid 
									//skal ha en viss lengde, og Runder av til nærmeste 2-tall. 
									//SEES I SMNHENG med gridlines i grafen.
if `ymin' > `minverdi' local ymin =`ymin'-2

*Eller, hvis ymin viser seg å bli énsifret: Penere å starte på null.
local ymin =0
	di "ymin: " `ymin'
*pause
*-------------------------------------------------------------------------------
**** SPLITT: Bydeler krever litt andre detaljer, men parallelt opplegg.
*    Noe her er unødv (f.eks. geo-rensing), men beholder det en bloc.
if "`geonivaa'" == "kommune" | "`geonivaa'" == "fylke" {

	**** Drop lavere geonivåer
	if "`geonivaa'" == "fylke" drop if geo>54 //Dropper også evt. HReg.
	if "`geonivaa'" == "kommune" drop if geo>30000

	****Lage styring av fylker - tallene har vi allerede i barometertabellen
	gen hjemmefylke =int(geo/100) //nærmeste integer ved trunkering
	replace hjemmefylke =geo if geo<=54 //Fylkene selv

	*gen fylkesskjermtid =skjermtidmeis if geo<=54
	*gen fylkeshasj =hasjmeis if geo<=54
	sort hjemmefylke geo //sikrer at selve fylket kommer først
	*replace fylkesskjermtid = fylkesskjermtid[_n-1] if fylkesskjermtid==.
	*replace fylkeshasj = fylkeshasj[_n-1] if fylkeshasj==.
		//Nå fikk Oslo verdi både for fylke og kommune
*exit
	****Lage variabel med fylkesnavn, til label i grafen.
	gen fylkesnavn =Sted if geo<=54
	replace fylkesnavn = fylkesnavn[_n-1] if fylkesnavn==""
	drop if _merge==2	//Fjerner andre geonivåer

} //FERDIG IF KOMMUNE/FYLKE
*--------------------------------------------------------------------------

else if "`geonivaa'" == "bydel" {
* Tilrettelegger bydelstallene etter samme mønster som Kommune. Grafen er lik.

	**** Drop fylker 
	drop if geo<=54 & geo!=0

	****Lage variabler med tallene for hele kommunen (beholder var-navnet "fylke...")
	*   Skal ha bydel-kommune-Norge.
	gen hjemmefylke =int(geo/100) //nærmeste integer ved trunkering
	replace hjemmefylke =geo if geo==301 | geo==1103 | geo==4601 | geo==5001 //Storbyene selv

	*gen fylkesskjermtid =skjermtidmeis if geo<=30000 //Lagrer KOMMUNEtallet
	*gen fylkeshasj =hasjmeis if geo<=30000 //Lagrer KOMMUNEtallet
	sort hjemmefylke geo //sikrer at selve storbyene kommer først. Kommunetallet fylles ut for bydelene:
	*replace fylkesskjermtid = fylkesskjermtid[_n-1] if fylkesskjermtid==.
	*replace fylkeshasj = fylkeshasj[_n-1] if fylkeshasj==.

*exit
	****Lage variabel med fylkesnavn, til label i grafen. For bydel er det storbyens kommunenavn.
	gen fylkesnavn =Sted if geo==301 | geo==1103 | geo==4601 | geo==5001
	replace fylkesnavn = fylkesnavn[_n-1] if fylkesnavn==""
	drop if _merge==2	//Fjerner andre geonivåer

	****Kvitte oss med kommuner uten bydeler (men beholde landet)
	drop if hjemmefylke<301 & geo!=0

} //FERDIG IF BYDEL
*--------------------------------------------------------------------------

	*exit
	
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

****Lage ny variabel med bare landstallet - trengs ikke med barometertabellen som inndata
sort geo
*gen landsskjermtid =skjermtidmeis[1]
*gen landshasj =hasjmeis[1]

****Tell rader - skal være lik antall kommuner/fylker
quietly describe	//BYDELER: Storbyene ligger igjen, men de hoppes over i selve graf-løkka.
local antall=r(N)
gen radnr =_n	//løkkestyring
	*pause Sjekk indik, hvilken er høyest/lavest?
	
****Label på ting -> lesbar Legend automatisk
*label var skjermtidmeis "Kommune"			//I grafen overstyres med aktuelt geonavn.
*label var fylkesskjermtid "Fylke"		//Ditto.
label var lands "Norge"
*label var landslokaltilbud "Norge"

local yaksetekst "Andel (prosent), standardisert"
*local loktilbudtekst "Treffsteder"
	*local yaksetekst "{bf:Vaksinasjonsdekning (prosent)}"  //Bold

****Plukke ut batchnummer, til å vise i grafen
local batchnummer = datotag_side4_innfilutfil
local inndata = "`Indik1tekst' (Ungd), `datafil'" + ", batch `batchnummer'"

* Dummyvariabel for å dele opp figuren i grupper
*gen dummy=.

cd "`targetkatalog'"

	/*For utvikling:
	replace fylkeslokalmilj=. in 5
	replace fylkeslokaltilbud=. in 6
	*/
*exit
*-----------------------------------------------------------------------
* SELVE FIGUREN
*-----------------------------------------------------------------------

* Fargekoder for søylene
local kommfarge "57 60 97"		//mørk blå
local fylkesfarge "9 117 181"	//mellomblå - koder ihht 2020-palett fra Heidi Grotle
local landsfarge "112 163 0"	//grønn

	/*	local kommfarge "57 60 97"		//mørk blå - 2020 FHP-palett
		local fylkesfarge "56 188 215"	//lys blå/turkis
		local landsfarge "152 179 39"	//grønn
	*/
**** Løkke gjennom alle rader ==================================================
if "`modus'" == "TEST" {
	local ifsetning = "i = 125/125"	//Lager én graf
}
else local ifsetning = "i = 1/`antall'"	//Kjører alt

forvalues `ifsetning' {
*local i=5 //for testing av graf
	//bygg filnavn fra kommunenummeret i rad x (subscripting)
	local nummer = Sted_kode[`i']
	local fil1   = "`nummer'" + "_`fig_nr'_tema.png"
	noisily di "`fil1'"
	
	//Finn kommune/fylkesnavn, til label i grafen. 
	local geonavn = Sted[`i']
	local fylkenavn = fylkesnavn[`i']
*di "Fylke: `fylkenavn'"
*pause	
	//Forberede merking av evt. missing søyler
	local Indik1stjerne = "" //Nullstiller før testen for denne kommunen
*	local loktilbudstjerne=""
	local fylkesInd1stj = ""
*	local fylkestilbudstj=""
	local anontekst  = ""
	
	local stjernesymbol=ustrunescape("\u25CF") //Unicode hex-kode 25CF er fylt svart sirkel
	
	if "`geonivaa'" == "kommune" | "`geonivaa'" == "bydel" {	
		if meis[`i'] == . {
			local Indik1stjerne = "`stjernesymbol'"
			local anontekst  = `"`stjernesymbol' Manglende eller" "   utilstrekkelig tallgrunnlag"'
		} //end -lokalmiljmeis-
	/*	if lokaltilbudmeis[`i'] == . {
			local loktilbudstjerne = "`stjernesymbol'"
			local anontekst  = `"`stjernesymbol' Manglende eller" "   utilstrekkelig tallgrunnlag"'
		} //end -lokaltilbudmeis- */
		if fylkes[`i'] == . {
			local fylkesInd1stj = "`stjernesymbol'"
			local anontekst  = `"`stjernesymbol' Manglende eller" "   utilstrekkelig tallgrunnlag"'
		} //end -fylkes milj-
	/*	if fylkeslokaltilbud[`i']==. {
			local fylkestilbudstj = "`stjernesymbol'"
			local anontekst  =`"`stjernesymbol' Manglende eller" "   utilstrekkelig tallgrunnlag"'
		} //end -fylkes tilbud-  */
		
	} //end -kommune bydel-
	
	if "`geonivaa'" == "fylke" {
		if fylkes[`i'] == . {
			local fylkesInd1stj = "`stjernesymbol'"
			local anontekst  = `"`stjernesymbol' Manglende eller" "   utilstrekkelig tallgrunnlag"'
		} //end -fylkeslokalmilj-
	/*	if fylkeslokaltilbud[`i']==. {
			local fylkestilbudstj="`stjernesymbol'"
			local anontekst  =`"`stjernesymbol' Manglende eller" "   utilstrekkelig tallgrunnlag"'
		} //end -fylkeslokaltilbud- */  
	} //end -fylke-
	
	//Dimensjonere plassering av tekster
	//Høyre ende av X-aksen =100 i en bar-graf
	local avstand = `ymax'/25 			//Stedsnavnene avstand fra x-aksen
	local batchnr_yplass = `ymax'/12 	//Kildefilnavnet i hjørnet, avstand fra x-aksen
	local batchnr_Xplass = 103		//Kildefilnavnet i hjørnet, plass på x-aksen - herfra mot venstre
*	local batchnr_Xplass = 98-(length("`inndata'")*0.7) //Kildefilnavnet i hjørnet, plass på x-aksen. Skalert ned siden fonten er liten.
	local anontekst_Xplass = 2
*	local anontekst_Xplass = 100-(length("`anontekst'")) //Forklarende tekstboks
	local anontekst_Yplass = `ymax'-(`ymax'*0.05)
	local Indik1stjerne_Xplass = 21
*	local loktilbudstjerne_Xplass = 61
	local fylkesInd1stj_Xpl  = 50
*	local fylkestilbudstj_Xpl  = 75
	local stjerne_Yplass = `ymax'*0.05
	
		/*Feilsøking
		macro list
		di "avstand: `avstand'"
		di "batchnr_yplass: `batchnr_yplass'"
		di "batchnr_Xplass: `batchnr_Xplass'"
		di "anontekst_Xplass: `anontekst_Xplass'"
		di "anontekst_Yplass: `anontekst_Yplass'"
		di "Indik1stjerne_Xplass: `Indik1stjerne_Xplass'"
*		di "loktilbudstjerne_Xplass: `loktilbudstjerne_Xplass'"
		di "fylkesInd1stj_Xpl: `fylkesmiljstj_Xpl'"
*		di "fylkestilbudstj_Xpl: `fylkestilbudstj_Xpl'"
		di "stjerne_Yplass: `stjerne_Yplass'"
		*/
		
*pause foran graf
	*Kommuner	
	if "`geonivaa'"=="kommune" | "`geonivaa'"=="bydel" {
	graph bar (asis) meis fylkes lands /* dummy lokaltilbudmeis fylkeslokaltilbud landslokaltilbud */ if radnr ==`i', ///
		graphregion(fcolor(white) lcolor(white) ilcolor(white)) ///
		plotregion(fcolor(white) margin(zero)) ///
		outergap(100) bargap(100) bar(1, color("`kommfarge'")) bar(2, color("`fylkesfarge'")) bar(3, color("`landsfarge'")) ///
	/*	bar(5, color("`kommfarge'")) bar(6, color("`fylkesfarge'")) bar(7, color("`landsfarge'")) */ ///
		blabel(bar, format(%04.1g) size(medium)) /// Viser bar-høyden på hver søyle
		///yscale(range(`ymax') noextend) ylabel(0 10 20 30 40 50 60 70 75, angle(horizontal) labsize(medium) glcolor(gs12)) ///
		/// yscale(range(100) noextend) ylabel(0 10 20 30 40 50 60 70 80 90 100, angle(horizontal) labsize(medium) glcolor(gs12)) ///
		yscale(range(`ymax') /*noextend*/) ylabel(0 (10) `ymax', angle(horizontal) labsize(medium) glcolor(white)) ///
		ytitle("`yaksetekst'", size(medium) orientation(vertical)) ///
		///subtitle("`yaksetekst'", size(large) position(9) ring(0.5) orientation(vertical)) /// For komb. med lang 75-label på aksen
	/*	legend(order(1 2 3) rows(1) ring(4) label(1 "`geonavn'") label(2 "`fylkenavn'") label(3 "Hele landet"), ) */ /// Blir lave og avlange fargemerker
		legend(off) ///
		text(-`avstand' 21 "`geonavn'", size(medlarge))    ///
		text(-`avstand' 50 "`fylkenavn'", size(medlarge))    ///
		text(-`avstand' 78 "Hele landet", size(medlarge)) ///
		text(-`batchnr_yplass' `batchnr_Xplass' "`inndata'", ///
			placement(sw) color(gs9) justification(left) size(vsmall)) ///
		text(`stjerne_Yplass' `Indik1stjerne_Xplass' "`Indik1stjerne'", size(vlarge))	///
	/*	text(`stjerne_Yplass' `loktilbudstjerne_Xplass' "`loktilbudstjerne'", size(vlarge))	*/ ///
		text(`stjerne_Yplass' `fylkesInd1stj_Xpl' "`fylkesInd1stj'", size(vlarge))	///
	/*	text(`stjerne_Yplass' `fylkestilbudstj_Xpl' "`fylkestilbudstj'", size(vlarge))	*/ ///
		text(`anontekst_Yplass' `anontekst_Xplass' "`anontekst'", color(black) placement(e) justification(left)) ///
		note(" " " ", size(vsmall) )
	}	
	*Fylker	
	else if "`geonivaa'"=="fylke" {		//IKKE AKTUELT FOR UNGDATA-GRAFER
	graph bar (asis) fylkes lands /* dummy fylkeshasj landshasj */ if radnr ==`i', ///
		graphregion(fcolor(white) lcolor(white) ilcolor(white)) ///
		plotregion(fcolor(gs15) margin(zero)) ///
		outergap(100) bargap(100) bar(1, color("`fylkesfarge'")) bar(2, color("`landsfarge'"))  ///
	/*	bar(4, color("234 153 6")) bar(5, color("0 153 0")) */ ///
		blabel(bar, format(%3.0f) size(medium)) /// Viser bar-høyden på hver søyle
		///yscale(range(`ymax') noextend) ylabel(0 10 20 30 40 50 60 70 80 90 100, angle(horizontal) labsize(medium) glcolor(gs12)) ///
		yscale(range(`ymax') /*noextend*/) ylabel(0 (5) `ymax', angle(horizontal) labsize(medium) glcolor(gs12)) ///
		ytitle("`yaksetekst'", size(medium) orientation(vertical)) ///
		///subtitle("`yaksetekst'", size(large) position(9) ring(0.5) orientation(vertical)) ///
		legend(order(1 2) rows(1) ring(4) label(1 "`fylkenavn'") label(2 "Hele landet"), ) ///
		text(-`avstand' 50 "`Indik1tekst'", size(medlarge))    ///
	/*	text(-`avstand' 75 "`hasjtekst'", size(medlarge)) */ ///
		text(-`batchnr_yplass' `batchnr_Xplass' "`inndata'", ///
			placement(sw) color(gs9) justification(left) size(vsmall)) ///
		text(`stjerne_Yplass' `fylkestryggstj_Xpl' "`fylkestryggstj'", size(vlarge))	///
	/*	text(`stjerne_Yplass' `fylkeshasjstj_Xpl' "`fylkeshasjstj'", size(vlarge))	*/ ///
		text(`anontekst_Yplass' `anontekst_Xplass' "`anontekst'", color(black) placement(w) justification(left)) ///
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
		
		FARGER: color("0 153 0") er grønn, kommunen.
		color("234 153 6") er oransje, fylket.
		color("67 103 189") er blå, Hele landet.
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
