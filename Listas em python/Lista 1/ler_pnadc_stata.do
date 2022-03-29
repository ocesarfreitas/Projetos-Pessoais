
//PAINEL 1 E 2
datazoom_pnadcontinua, years(2012 2013 2014) original("F:\pnadc") saving("F:\pnadc\pnadstata") idrs

//PAINEL 3
datazoom_pnadcontinua, years(2013 2014 2015 ) original("F:\pnadc") saving("F:\pnadc\pnadstata") idrs

//PAINEL 4
datazoom_pnadcontinua, years(2014 2015 2016 ) original("F:\pnadc") saving("F:\pnadc\pnadstata") idrs

//PAINEL 5
datazoom_pnadcontinua, years(2015 2016 2017 ) original("F:\pnadc") saving("F:\pnadc\pnadstata") idrs

//PAINEL 6
datazoom_pnadcontinua, years(2017 2018 2019 ) original("F:\pnadc") saving("F:\pnadc\pnadstata") idrs


//PAINEL 7 
datazoom_pnadcontinua, years(2018 2019 2020 ) original("F:\pnadc") saving("F:\pnadc\pnadstata") idrs

//PAINEL 8 
datazoom_pnadcontinua, years(2019 2020 2021 ) original("F:\pnadc") saving("F:\pnadc\pnadstata") idrs

//PAINEL 9
datazoom_pnadcontinua, years(2020 2021 ) original("F:\pnadc") saving("F:\pnadc\pnadstata") idrs



*use "E:\pnadc\pnadstata\PNAD_painel_1_rs.dta"
*append using "E:\pnadc\pnadstata\PNAD_painel_2_rs.dta"
*append using "E:\pnadc\pnadstata\PNAD_painel_3_rs.dta" "E:\pnadc\pnadstata\PNAD_painel_4_rs.dta" "E:\pnadc\pnadstata\PNAD_painel_5_rs.dta" /*
 **/"E:\pnadc\pnadstata\PNAD_painel_6_rs.dta" "E:\pnadc\pnadstata\PNAD_painel_7_rs.dta" "E:\pnadc\pnadstata\PNAD_painel_8_rs.dta"

*save "E:\pnadc\pnadstata\PNAD_ORIGINAL_RS.dta"


capture drop trimestre
destring Trimestre, generate (trimestre)

capture drop idind_num
egen idind_num=group(idind)


tostring painel UF UPA V1008, generate(painelstr UFstr UPAstr V1008str) // transforma em string vari√°veis que comp√µem o c√≥digo do domic√≠lio
gen str zero="0" // cria uma vari√°vel de zeros do tipo string
replace V1008str=zero+V1008str if V1008<10 // adiciona um zero na frente dos n√∫meros menores de 10
gen str iddom = painelstr+UFstr+UPAstr+zero+V1008str // gera o c√≥digo do domic√≠lio adicionando as strings
drop painelstr UFstr zero UPAstr V1008str // exclui vari√°veis auxiliares

capture drop iddom_num
egen iddom_num=group(iddom)


gen qdata = yq(Ano, trimestre)
format qdata %tq

//DATA:
//TRANSFORMA A VARI√ÅVEL TRIMESTRE EM N√öMERO
encode Trimestre, gen(trim)
*drop Trimestre
//GERA A VARI√ÅVEL DE DATA
gen int date = yq(Ano, trim)
format %tqCCYY-!Qq date

sort iddom  idind  date
browse iddom  iddom_num idind idind_num Ano trimestre date

iis idind_num
tis date
*xtdescribe


isid idind_num date
bysort idind_num date: assert _N == 1 
duplicates report idind date
duplicates tag idind_num date, gen(isdup)
sort iddom idind date
browse UPA date iddom_num idind_num V1008 V1016 V2001 V2003 V2005 V2007 V2009 

** vari·vel indicadora para ser filho(a) de diversas idades

gen filho_menor_10=1 if V2009<=10&V2005==4 // 4=filho ambos
replace filho_menor_10=1 if V2009<=10&V2005==5 // 5=filho apenas resp
replace filho_menor_10=1 if V2009<=10&V2005==6 // 6=enteado
replace filho_menor_10=0 if filho_menor_10==.

gen filho_11a18=1 if V2009<=18&V2005==4
replace filho_11a18=1 if V2009<=18&V2005==5
replace filho_11a18=1 if V2009<=18&V2005==6
replace filho_11a18=. if V2009<=10
replace filho_11a18=0 if filho_11a18==.

gen filho_menor_18=1 if V2009<=18&V2005==4
replace filho_menor_18=1 if V2009<=18&V2005==5
replace filho_menor_18=1 if V2009<=18&V2005==6
replace filho_menor_18=0 if filho_menor_18==.

**Vari·vel casado (indica se o individuo tem conjuge ou companheiro de sexo oposto ou mesmo sexo
**Vari·vel n˙mero de filhos de diversas idades 



generate samp_1=(V1016==1)
generate samp_2=(V1016==2)
generate samp_3=(V1016==3)
generate samp_4=(V1016==4)
generate samp_5=(V1016==5)

save "C:\Users\MariaEduarda\Google Drive\econometria-1-2020\pnadc\pnadcontinua\PNAD_painel_7_rs.dta", replace


local samples "samp_1 samp_2 samp_3 samp_4 samp_5"

*keep if samp_1
*keep if samp_2
*keep if samp_3
*keep if samp_4
keep if samp_5

foreach group in `samples' {
	keep if `group' //mantÈm no banco apenas as observaÁıes da subamostra
	
	
	sort iddom_num V2005
	by iddom_num: gen person=_n
	gen casado=0
	by iddom_num: replace casado=1 if V2005==2
	by iddom_num: replace casado=1 if V2005==3
	by iddom_num: replace casado=1 if (person==1&(V2005[2]==2|V2005[2]==3))
	
	
	gen educ_conj = 0
	by iddom_num : replace educ_conj = VD3005[2] if (person==1 & casado==1 & V2005[2]==2)
	by iddom_num : replace educ_conj = VD3005[2] if (person==1 & casado==1 & V2005[2]==3)
	by iddom_num : replace educ_conj = VD3005[1] if ((V2005[2]==2 | V2005[2]==3) & casado==1)
	
	
	browse iddom_num V2005 VD3005 educ_conj  casado person V2007 V2009
	
	by iddom_num: egen num_filho_18=total(filho_menor_18)
	by iddom_num: egen num_filho_menor10=total(filho_menor_10)
	by iddom_num: egen num_filho_11a18=total(filho_11a18)
	
	*by iddom_num: egen renda_domiciliar_hab=total(rend_hab_todos)
	
	
	save "C:\Users\MariaEduarda\Google Drive\econometria-1-2020\pnadc\pnadcontinua\PNAD_painel_7_samp_rs.dta", replace
	use "C:\Users\MariaEduarda\Google Drive\econometria-1-2020\pnadc\pnadcontinua\PNAD_painel_7_rs.dta", clear
}

use "C:\Users\MariaEduarda\Google Drive\econometria-1-2020\pnadc\pnadcontinua\PNAD_painel_7_samp1_rs.dta"   
append using "C:\Users\MariaEduarda\Google Drive\econometria-1-2020\pnadc\pnadcontinua\PNAD_painel_7_samp2_rs.dta" /*
 */"C:\Users\MariaEduarda\Google Drive\econometria-1-2020\pnadc\pnadcontinua\PNAD_painel_7_samp3_rs.dta"   /*
 */"C:\Users\MariaEduarda\Google Drive\econometria-1-2020\pnadc\pnadcontinua\PNAD_painel_7_samp4_rs.dta" /*
 */ "C:\Users\MariaEduarda\Google Drive\econometria-1-2020\pnadc\pnadcontinua\PNAD_painel_7_samp5_rs.dta" 
drop filho_menor_18
drop filho_menor_10
drop filho_11a18
drop person
drop samp_1-samp_5

save "C:\Users\MariaEduarda\Google Drive\econometria-1-2020\pnadc\pnadcontinua\PNAD_painel_7_rs.dta", replace

sort iddom_num idind_num date
browse iddom_num idind_num date V1016 V2005 V2007 V2009 casado num_filho_18 num_filho_menor10 num_filho_11a18 




* vari·veis de interesse
* UF - unidade da federaÁ„o 
* V1022 - situaÁ„o do domicÌlio : urbana e rural
* V1023 - tipode ·rea : capital, regi„o metropolitana ou outra
* V2001 -  # de pessoas no domicÌlio
* V2005 - condiÁ„o no domicÌlio
* V2007 - sexo
* V2008, V20081, V20082 - dia, mÍs e ano de nascimento
* V2009 - idade do morador
* V2010 - cor ou raÁa 
* V3001 - sabe ler e escrever
* V3002 - frequenta a escola?
* V3003A - qual o curso que frequenta 

