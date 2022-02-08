/* STATISK FIGUR 2022: ANDEL SOM ER LITE FORNØYD, ETTER ANTALL RISIKOFAKTORER
	Spec: Søyler, stående. Y-linjer for hver 20, opptil 100. 
	Søylefarge som inngår i FHP-fargene.
	Ta bort gridlines fra y-aksen.
	Ta bort desimaler fra søyle-labels.
	*/
	
/* Data
	X	Y
	0	6,9
	1	20,8
	2	44,2
	3	64,5
	4+	83,2
*/

* Hvor lagre resultatgraf

global target "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON\PRODUKTER\SSRS_filer/FHP/2022/kommune"

/*SKARP:
global skarptarget "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON\PRODUKTER\SSRS_filer/2022/`geonivaa'\Temafigurer\Valgdeltakfig"
*/
cd "$target"
*-------------------------------------
clear
input riskfakt andel 
0 7
1 21
2 44
3 65
4 83
end

* Value labels til bruk på x-aksen
label define riskfakt 0 "0" 1 "1" 2 "2" 3 "3" 4 "4+"
label values riskfakt riskfakt

* Sette noen parametre
global ymax = 100
local mindrelik = ustrunescape("\u2a7d")
local yaksetekst "Andel lite fornøyde (fornøydhet `mindrelik' 5), i prosent"	
local xaksetekst "Antall risikofaktorer"

* Avvist forslag:
*	local tittel "Andel som er lite fornøyde med livet (skårer 0–5)"
*	local yaksetekst "Prosent"

* Søylefarge i hht. FHIs webpalett
local landsfarge "57 60 97"		//Mørk blå, FHIblue3 = hex #393c61
local kommunefarge "9 117 181"	//Mellomblå
 
 * Landsfarge sist "152 179 39"



graph twoway ///
	(bar andel riskfakt ,		/// 
	color("`landsfarge'") barwidth(0.6) 						///
	ylabel(0(20)$ymax, angle(horizontal) nogrid)	///		
	ytitle("`yaksetekst'", size(medium) orientation(vertical)) ///
	yscale(range($ymax )) ///  Uten denne får ikke øverste ylabel noen gridline.
	///yline(`normal_linje') 									///
	xlabel(, valuelabel) ///, noticks valuelabel angle(90) labsize(*`tekstskalering')) xscale(titlegap(3) range(`xmin' `xmax'))	///
	xtitle("`xaksetekst'", size(medium))			///
	graphregion(fcolor(white) lcolor(white) ilcolor(white)) ///
	plotregion(fcolor(white) margin(zero)) 					///
	legend(off) 											///
	) ///
	(scatter  andel riskfakt, msymbol(none) mlabpos(12) mlabel(andel) mlabcolor(black) mlabsize(*1.2) xscale(range(-0.5, 4.5)))
		
graph export "Andel_lite_fornøyde_etter_riskfakt.png", width(1200) /*height()*/ replace