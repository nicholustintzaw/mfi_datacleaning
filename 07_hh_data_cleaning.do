/*******************************************************************************

//	Project:		MP Myanmar
// 	Task:			Perform data cleaning on HH survey data (+ some data checking) 
// 	Author: 		Nicholus Tint Zaw
// 	Last update: 	Sept 18 2019

*******************************************************************************/

********************************************************************************
// Settings for stata
pause on
clear all
clear mata
set more off
set scrollbufsize 100000
set mem 100m
set matsize 11000
set maxvar 32767
set excelxlsxlargefile on

********************************************************************************
********************************************************************************
// Lise
if "`c(username)'" == "lmasselus" {
		global BL_HFC	"C:\Users\lmasselus\Box\07 Microfinance Plus\07_Questionnaires&Data\0_Baseline - HFC"	
		global root		"C:\Users\lmasselus\Documents\01_PROJECTS\01_Microfinance Plus\2_Myanmar\Data and Analysis\0_Data analysis and cleaning"	
		global output	"$root\03_Output"

}

** USE POST HFC DATA **
use "$BL_HFC/05_data/02_survey/03_Clean_data/S2_Baseline_survey_final_postHFC.dta", clear


********************************************************************************
** Survey info and identity verification **
********************************************************************************

// enum
tab enum, m
tab	enum_id, m
count if enum != enum_id

destring enum_name, replace
tab	enum_name, m
count if enum_id != enum_name

tab	enum_nm, m

// drop repeat var
drop enum_id enum_name 

// enum_phone
tab enum_phone, m

// date
tab date, m

// time
tab time, m
gen time1 = clock(time, "hms")
format time1 %tcHH:MM
order time1, after(time)
drop time
rename time1 time

// calculated var from surveyCTO
destring ppp_50cents ppp_2usd formal_inst rf_code dk_code gni ppi_or_gni, replace

tab	lcu,m
tab	ppp_50cents,m
tab	ppp_2usd,m
tab	formal_inst,m
tab	rf_code,m
tab	dk_code,m
tab	gni,m
tab	ppi_or_gni,m


// partid
tab partid, m

//	partid_repeat
tab partid_repeat, m
tostring partid_repeat, replace

count if partid != partid_repeat

		// Lise added
		preserve
			keep if partid != partid_repeat
			keep partid partid_repeat vil_id village_id village tract
			export excel using "$output\data_checks", sheet("partid mismatch") sheetreplace first(var)		
		restore
* LM_2503 - let's find out where these mismatches were corrected. After, we can drop the variable partid_repeat

* drop partid_repeat


// name
tab name, m
	
// name_father
tab name_father, m

// name_nickname_yn
tab name_nickname_yn, m

// name_nickname
tab name_nickname, m

// phone
tab phone, m

gen phone_number = phone
	replace phone_number = subinstr(phone_number, "၀","0",.)
	replace phone_number = subinstr(phone_number, "၁","1",.)
	replace phone_number = subinstr(phone_number, "၂","2",.)
	replace phone_number = subinstr(phone_number, "၃","3",.)
	replace phone_number = subinstr(phone_number, "၄","4",.)
	replace phone_number = subinstr(phone_number, "၅","5",.)
	replace phone_number = subinstr(phone_number, "၆","6",.)
	replace phone_number = subinstr(phone_number, "၇","7",.)
	replace phone_number = subinstr(phone_number, "၈","8",.)
	replace phone_number = subinstr(phone_number, "၉","9",.)

replace phone_number = subinstr(phone_number, "", "",.)
moss phone_number, match("([0-9]+)")  regex
order phone_number, after(phone)

replace phone_number = _match1 + _match2

gen phone_yesno = (length(phone_number)>=8)
order phone_yesno, before(phone)
tab phone_yesno, m

replace phone_number = "." if phone_yesno == 0 // Lise
	
** drop un-necessary variables resulted from moss comend
drop _match1 _match2 phone phone_yesno

ren phone_number phone // Lise

// gender
tab gender, m

// nrc_yn
tab nrc_yn, m

* NCL note: NRC data cleaning code were programmed at seperate dofile
* purpose is to apply for other program dataset for dataset matching purpose
// nrc
do "$BL_HFC/02_dofiles/_hh_nrc_cleaning.do" 

replace nrc_region = "" if nrc_yn == 0 
replace nrc_township = "" if nrc_yn == 0 
replace nrc_status = "" if nrc_yn == 0 
replace nrc_digits = "" if nrc_yn == 0 

destring nrc_region, replace
tab nrc_region, m
tab nrc_township, m
tab nrc_status, m
tab nrc_digits, m

* NCL questions >> if you want to make dataset matching, could you please share me the directories of datasets
	** LM_2503: I believe Teun used this variable to match with VF dataset in order to calculate take-up rates


// state
destring state, replace
tab state, m

// state_name
tab state_name, m

// vf_branch
destring vf_branch, replace
tab vf_branch, m

// vf_branch_name
tab	vf_branch_name, m

// vil_id
tab vil_id, m

// vil_id_rep
tab vil_id_rep, m

count if vil_id != vil_id_rep
// NCL note: 32 unmatched un-matched observation noticed
// it was only 23 before data correction on 101 village id mis-matched case you provided
		
		// Lise added
		preserve
			keep if vil_id != vil_id_rep
			keep partid vil_id vil_id_rep village_id village tract
			export excel using "$output\data_checks", sheet("vil_id and vil_id_rep") sheetreplace first(var)		
		restore
		
		
// village
destring village, replace
tab village, m

// village_rep
destring village_rep, replace
tab village_rep, m
		
count if village != village_rep

// NCL note: 43 un-matched observation noticed, not changed after HFC data correction

		// Lise added
		preserve
			keep if village != village_rep
			keep partid village_rep village vil_id village_id village tract
			export excel using "$output\data_checks", sheet("village and village_rep") sheetreplace first(var)		
		restore

// village_id
destring village_id, replace
tab village_id, m

count if village_id != vil_id
distinct village_id vil_id if village_id != vil_id

/* 8 un-matched observation were noticed and they were come from 8 different villages
	** LM_2503: see word document for additional cleaning
	
            |        Observations
            |      total   distinct
------------+----------------------
 village_id |          8          8
     vil_id |          8          8
*/


		// Lise added
		preserve
			keep if village_id != vil_id
			keep partid village vil_id village_id village tract
			export excel using "$output\data_checks", sheet("village_id and vil_id") sheetreplace first(var)		
		restore

// village_name
tab	village_name

// tract
destring tract, replace
tab tract, m

// tract_name
tab tract_name, m

// confirm
tab confirm, m

// dropout_reason
replace dropout_reason = ".m" if confirm == 1
tab dropout_reason, m  // LM_2503: Have you translated dropout_reason?

// spouse
replace spouse = .m if confirm == 0
replace spouse = .m if consent == 0 // added by Lise

tab spouse, m

// sp_name
replace sp_name = ".m" if spouse != 1
tab sp_name, m

// spouse_present
replace spouse_present = .m if spouse != 1
tab spouse_present, m

// spouse_mi_reason
replace spouse_mi_reason = .m if spouse_present != 0 
tab spouse_mi_reason, m

// spouse_mi_reason_osp
tab spouse_mi_reason_osp, m
	* br spouse_mi_reason spouse_mi_reason_osp if !mi(spouse_mi_reason_osp) // osp has been recoded
	drop spouse_mi_reason_osp // Lise added

// consent
replace consent = .m if confirm == 0
tab consent, m
	
// refusal
replace refusal = .m if consent != 0
lab def refusal 7"Sample respondent is travelling", add
lab val refusal refusal 
tab refusal, m

// refusal_osp
replace refusal_osp = ".m" if refusal != -66
tab refusal_osp, m 
		
		// LM_2503 added
		replace refusal = 7 if key == "uuid:1e055094-60c6-4e0b-8980-ff1d2c289cf0" // travelling
		replace refusal = 7 if key == "uuid:6fbff26f-3043-40a8-8ca3-43b2978443e2" // travelling
		replace refusal = 7 if key == "uuid:c13edff9-7141-457e-addf-0d7614df6396" // travelling
		replace refusal = 7 if key == "uuid:7841ec0e-a30a-4dd2-a35c-b3aeea6e5e49" // travelling
		replace refusal = 7 if key == "uuid:9a874d2d-fde4-4471-8a9e-fdb9ee61b850" // travelling
		replace refusal = 7 if key == "uuid:b0d40a56-5157-40ed-ac39-4b306b625d35" // travelling
		replace refusal = 7 if key == "uuid:92f32f06-6f1d-49cd-a289-62af2f483df2" // travelling
		replace refusal = 7 if key == "uuid:e9d85ad7-64ce-48b8-803b-ee37d49a5bcf" // travelling
		replace refusal = 7 if key == "uuid:0ec72775-cd47-4acb-85d0-51d9349c3f62" // travelling
		replace refusal = 7 if key == "uuid:5daed9a1-b533-4f96-b966-18795ad00ec5" // travelling
		// NOTE: the three remaining "other" should actually be dropouts, instead of no consent. Lise will clean this
		
		replace refusal_osp = ".m" if refusal != -66
		
// sign1
replace sign1 = ".m" if consent != 1
tab sign1, m

// sign1_know
replace sign1_know = .m if consent != 1
tab sign1_know, m

// photo_signature1
* destring photo_signature1, replace
replace photo_signature1 = ".m" if sign1_know != 0
tab photo_signature1, m

//	audio_consent
replace audio_consent = .m if consent != 1
tab audio_consent, m

//	gps_consent
replace gps_consent = .m if consent != 1
replace gps_consent = .n if consent == 1 & mi(gps_consent) // variable gps_consent was added to survey during data collection
tab gps_consent, m

// geopointlatitude geopointlongitude geopointaltitude geopointaccuracy
local geopoint geopointlatitude geopointlongitude geopointaltitude geopointaccuracy

foreach var in `geopoint' {
	replace `var' = .m if consent != 1 & mi(`var')
	replace `var' = .n if key == "uuid:69ecbcb2-6c5e-4c40-8015-1575b957d91d" // added LM_2503, coordinate was taken from different HH
}

// gps2
replace gps2 = .m if mi(gps2) & consent != 1
replace gps2 = .n if mi(gps2) & consent == 1 & !mi(geopointlatitude)
replace gps2 = .m if mi(gps2) & consent == 1 & mi(geopointlatitude)
replace gps2 = .m if key == "uuid:69ecbcb2-6c5e-4c40-8015-1575b957d91d" // added LM_2503, coordinate was taken from different HH

tab gps2, m

// gps2_osp
replace gps2_osp = ".m" if gps2 != -66
tab gps2_osp, m 

	
//	n_sp
tab n_sp, m
* note: did not understand on this variable 
* the frequency table result did not matched with xls form definition 
drop n_sp // Lise 


//	consent_sp
replace consent_sp = .m if spouse_present != 1 | consent != 1
tab consent_sp, m

//	audio_consent_sp
replace audio_consent_sp = .m if spouse_present != 1 | consent != 1
replace audio_consent_sp = .n if spouse_present == 1 & consent == 1 & audio_consent_sp == .
tab audio_consent_sp, m

//	refusal_sp
replace refusal_sp = .m if consent_sp != 0 
	lab def refusal_sp 7"Sample respondent is travelling", add
	lab val refusal_sp refusal_sp 
tab refusal_sp, m

//	refusal_sp_osp

	// added LM_2503
	replace refusal_sp = 7 if refusal_sp == -66 // spouse is travelling - recoded
	
replace refusal_sp_osp = ".m" if refusal_sp != -66
tab refusal_sp_osp, m 
	
//	sign2
replace sign2 = ".m" if consent_sp != 1
replace sign2 = ".n" if consent_sp == 1 & mi(sign2)
tab sign2, m

//	sign2_know
replace sign2_know = .m if consent_sp != 1
tab sign2_know, m

//	photo_signature2
destring photo_signature2, replace
replace photo_signature2 = .m if sign2_know != 0
tab photo_signature2, m

//	svy_loc
replace svy_loc = .m if consent != 1
tab svy_loc, m

*** LM_2503 checked until here 
********************************************************************************
** Household and respondent characteristics 
********************************************************************************
// age
replace age = .m if consent != 1
tab age, m

// marital_status
replace marital_status = .m if consent != 1	
tab marital_status, m

// marital_status_osp
replace marital_status_osp = "" if marital_status != -66
destring marital_status_osp, replace 
replace marital_status_osp = .m if mi(marital_status_osp)
tab marital_status_osp, m

// head
replace head = .m if consent != 1	
tab head, m

// education
replace education = .m if consent != 1	
tab education, m

// education_osp
replace education_osp = "" if education != -66
destring education_osp, replace 
replace education_osp = .m if mi(education_osp)
tab education_osp, m

// ppi_mm_educ
replace ppi_mm_educ = .m if gender != 0 | consent != 1
tab ppi_mm_educ, m

// occupation
replace occupation = .m if consent != 1	
tab occupation, m

// occupation_osp
replace occupation_osp = ".m" if occupation != -66
tab occupation_osp, m // ------------------------------------------------------ TO DO: Please recode occupation if occupation == -66, or translate occupation_osp

// distance_transport
replace distance_transport = .m if consent != 1	
tab distance_transport, m 

// distance_transport_osp
replace distance_transport_osp = ".m" if distance_transport != -66
tab distance_transport_osp, m // ------------------------------------------------------ TO DO: Please recode distance_transport if distance_transport_osp == -66, or translate distance_transport_osp

// distance_minutes
replace distance_minutes = .m if consent != 1	
tab distance_minutes, m


** Household definition **
// hhnum
replace hhnum = .m if consent != 1	
tab hhnum, m

// hhnum_minors
replace hhnum_minors = .m if consent != 1	
tab hhnum_minors, m

// hhnum_schoolage
replace hhnum_schoolage = .m if consent != 1 | hhnum_minors == 0 | hhnum_minors == .d
replace hhnum_schoolage = .n if hhnum_schoolage == . & !mi(hhnum_minors)
tab hhnum_schoolage, m

// hhnum_schoolgoing
replace hhnum_schoolgoing = .m if consent != 1 | hhnum_schoolage == 0 | hhnum_schoolage == .m
replace hhnum_schoolgoing = .n if hhnum_schoolgoing == . & !mi(hhnum_schoolage) | hhnum_schoolage == .n
tab hhnum_schoolgoing, m


** Education, health and clothing spending **
//edu_spend
replace edu_spend = ".m" if consent != 1
tab edu_spend, m

drop edu_spend_1 edu_spend_2 edu_spend_3 edu_spend_4 edu_spend__88 edu_spend__99

split edu_spend, p(" ")
destring edu_spend1 edu_spend2, replace

lab def yesno 1"yes" 0"no"

forvalue x = 1/4 {
	gen edu_spend_`x' = (edu_spend1 == `x' | edu_spend2 == `x')
	replace edu_spend_`x' = .m if edu_spend == ".m"
	tab edu_spend_`x', m
	order edu_spend_`x', before(edu_children)
	lab val edu_spend_`x' yesno
}
drop edu_spend1 edu_spend2

lab var edu_spend_1	"No expenditures"
lab var edu_spend_2	"Children in your household"
lab var edu_spend_3	"Adult household members"
lab var edu_spend_4	"People outside your household"


** Education 
// edu_children
tab1 edu_spend_2 edu_children
replace edu_children = .m if edu_spend_2 != 1
tab	edu_children, m

// check23
replace check23 = .m if edu_children <=5000000 | mi(edu_children)
tab	check23, m

// edu_mem
tab1 edu_spend_3 edu_mem
replace edu_mem = .m if edu_spend_3 != 1
tab	edu_mem, m

// check24
replace check24 = .m if edu_mem <=5000000 | mi(edu_mem)
tab check24, m

// edu_nonmem
tab1 edu_spend_4 edu_nonmem
replace edu_nonmem = .m if edu_spend_4 != 1
tab	edu_nonmem, m

// check26
replace check26 = .m if edu_nonmem <=5000000 | mi(edu_nonmem)
tab check26, m


** Health
// h_spend
replace h_spend = ".m" if consent != 1
tab h_spend, m

drop h_spend_1 h_spend_2 h_spend_3 h_spend_4 h_spend__88 h_spend__99

split h_spend, p(" ")
destring h_spend1 h_spend2, replace

forvalue x = 1/4 {
	gen h_spend_`x' = (h_spend1 == `x' | h_spend2 == `x')
	replace h_spend_`x' = .m if h_spend == ".m"
	tab h_spend_`x', m
	order h_spend_`x', before(h_children)
	lab val h_spend_`x' yesno
}

drop h_spend1 h_spend2

lab var h_spend_1	"No expenditures"
lab var h_spend_2	"Children in your household"
lab var h_spend_3	"Adult household members"
lab var h_spend_4	"People outside your household"


// h_children
tab1 h_spend_2 h_children
replace h_children = .m if h_spend_2 != 1
replace h_children = .n if h_spend_2 == 1 & mi(h_children)
tab h_children, m

// check27
replace check27 = .m if h_children <=10000000 | mi(h_children)
tab check27, m

// h_mem
tab1 h_spend_3 h_mem
replace h_mem = .m if h_spend_3 != 1
tab h_mem, m

// check28
replace check28 = .m if h_mem <=10000000 | mi(h_mem)
tab check28, m

// h_nonmem
tab1 h_spend_4 h_nonmem
replace h_nonmem = .m if h_spend_4 != 1
tab h_nonmem, m

// check30
replace check30 = .m if h_nonmem <=10000000 | mi(h_nonmem)
tab check30, m


** Cloth
// c_spend
replace c_spend = ".m" if consent != 1
tab c_spend, m

drop c_spend_1 c_spend_2 c_spend_3 c_spend_4 c_spend__88 c_spend__99

split c_spend, p(" ")
destring c_spend1 c_spend2, replace

forvalue x = 1/4 {
	gen c_spend_`x' = (c_spend1 == `x' | c_spend2 == `x')
	replace c_spend_`x' = .m if c_spend == ".m"
	replace c_spend_`x' = .d if c_spend == "-88"
	tab c_spend_`x', m
	order c_spend_`x', before(c_children)
	lab val c_spend_`x' yesno
}

drop c_spend1 c_spend2

lab var c_spend_1	"No expenditures"
lab var c_spend_2	"Children in your household"
lab var c_spend_3	"Adult household members"
lab var c_spend_4	"People outside your household"

// c_children
tab1 c_spend_2 c_children
replace c_children = .m if c_spend_2 != 1
replace c_children = .n if c_spend_2 == 1 & mi(c_children)
tab	c_children, m

// check31
replace check31 = .m if c_children <=2000000 | mi(c_children)
tab check31, m

// c_mem
tab1 c_spend_3 c_mem
replace c_mem = .m if c_spend_3 != 1
tab c_mem, m

// check32
replace check32 = .m if c_mem <=2000000 | mi(c_mem)
tab check32, m

// c_nonmem
tab1 c_spend_4 c_nonmem
replace c_nonmem = .m if c_spend_4 != 1
tab c_nonmem, m

// check34
replace check34 = .m if c_nonmem <=2000000 | mi(c_nonmem)
tab check34, m

** Homestead characteristics **
// house_type
replace house_type = .m if consent != 1
tab house_type, m

// house_type_osp
replace house_type_osp = "" if house_type != -66
destring house_type_osp, replace
replace house_type_osp = .m if mi(house_type_osp)
tab house_type_osp, m

// house_shared
replace house_shared = .m if consent != 1
tab house_shared, m

// house_ownership
replace house_ownership = .m if consent != 1
tab house_ownership, m

// house_ownership_osp
replace house_ownership_osp = ".m" if house_ownership != -66
tab house_ownership_osp, m  // ------------------------------------------------------ TO DO: Please recode house_ownership if house_ownership == -66, or translate house_ownership_osp

// water
replace water = ".m" if consent != 1
tab water, m

drop water_1 water_2 water_3 water_4 water_5 water_6 water_7 water_8 water_9 water_10 water__66 water__88 water__99

split water, p(" ")
destring water1 water2 water3, replace

foreach var of varlist water1 water2 water3 {
	replace `var' = 11 if `var' == -66
}

forvalue x = 1/11 {
	gen water_`x' = (water1 == `x' | water2 == `x' | water3 == `x')
	replace water_`x' = .m if water == ".m"
	tab water_`x', m
	order water_`x', before(water_osp)
	lab val water_`x' yesno	

}

drop water1 water2 water3

lab var water_1 "Municiple Pipe"
lab var water_2 "River Water/ Stream or Creek Water"
lab var water_3 "Pound with Cover"
lab var water_4 "Pound without cover "
lab var water_5 "Well with manual Pump"
lab var water_6 "Well with electric Pump"
lab var water_7 "Well Without Pump"
lab var water_8 "Rain Water"
lab var water_9 "Digging for water"
lab var water_10 "buy drinking water"
lab var water_11 "other water soure"

// water_osp
replace water_osp = ".m" if water_11 != 1
tab water_osp, m // ------------------------------------------------------ TO DO: Please recode water if water == -66, or translate water_osp


// lighting
replace lighting = 2 if lighting == 1
replace lighting = .m if consent != 1
tab lighting, m
	// Lise added: ------------------------------------------------------ TO DO, could you add this change to the HFC replacements excel sheet? 
	replace lighting = 7 if lighting_osp == "Candel"
	replace lighting = 8 if lighting_osp == "Battery"
	
// lighting_osp
replace lighting_osp = ".m" if lighting != -66
tab lighting_osp, m

// toilet
replace toilet = .m if consent != 1
tab toilet, m

// toilet_osp
replace toilet_osp = ".m" if toilet != -66 
tab toilet_osp, m

// toilet_share
replace toilet_share = .m if consent != 1 | toilet == 6 | toilet == .r
tab toilet_share, m

// ppi_mm_rooms
replace ppi_mm_rooms = .m if consent != 1
tab ppi_mm_rooms, m

** Observation (enumerator not inside household)
// ppi_mm_floor
replace ppi_mm_floor = .m if consent != 1 | svy_loc != 0
tab ppi_mm_floor, m

// ppi_mm_walls
replace ppi_mm_walls = .m if consent != 1 | svy_loc != 0
tab ppi_mm_walls, m

// roof
replace roof = .m if consent != 1 | svy_loc != 0
tab roof, m

// roof_osp
replace roof_osp = "" if roof != -66 
destring roof_osp, replace
replace roof_osp = .m if mi(roof)
tab roof_osp, m

// ppi_mm_stove
replace ppi_mm_stove = .m if consent != 1
tab ppi_mm_stove, m

// plot_number
replace plot_number = .m if consent != 1
tab plot_number, m

** land
forvalue x = 1/5 {

	// plot_size
	replace plot_size_`x' = .m if consent != 1 | plot_number < `x'
	replace plot_size_`x' = .m if plot_number > `x' & !mi(plot_number)

	tab plot_size_`x', m
	
	// plotmeasure
	replace plotmeasure_`x' = .m if consent != 1 | plot_number < `x'
	replace plotmeasure_`x' = .m if plot_number > `x' & !mi(plot_number)
	
	tab plotmeasure_`x', m
	
	// plotsmeasure_osp
	replace plotsmeasure_osp_`x' = "" if plotmeasure_`x' == -66
	destring plotsmeasure_osp_`x', replace
	replace plotsmeasure_osp_`x' = .m if mi(plotsmeasure_osp_`x')
	tab plotsmeasure_osp_`x', m

}


//	plot_size_total
replace plot_size_total = .m if consent != 1 | plot_number <= 5
tab plot_size_total, m

//	plotmeasure_total
replace plotmeasure_total = .m if consent != 1 | plot_number <= 5
tab plotmeasure_total, m

//	plotsmeasure_total_osp
replace plotsmeasure_total_osp = "" if plotmeasure_total == -66
destring plotsmeasure_total_osp, replace
replace plotsmeasure_total_osp = .m if mi(plotsmeasure_total_osp)
tab plotsmeasure_total_osp, m


** Household assets 
// a1 - a27
forvalue x = 1/27 {
	replace a`x' = .m  if consent != 1
	tab a`x', m
	
	replace a`x'_n = .m  if a`x' != 1
	tab a`x'_n, m

}

// a27
tab a27, m

// a27_osp
replace a27_osp = ".m" if a27 != 1
tab a27_osp, m // ------------------------------------------------------ TO DO: Please translate a27_osp

// a27_n
tab a27_n, m

// ppi_mm_tv
tab ppi_mm_tv a17

replace ppi_mm_tv = .m if a17 == 1 | mi(a17)
replace ppi_mm_tv = .n if ppi_mm_tv == .
tab ppi_mm_tv, m

// ppi_mm_vehicle1
replace ppi_mm_vehicle1 = .m if a2 == 1 & a3 == 1 & a4 == 1 & a5 == 1
replace ppi_mm_vehicle1 = .m if mi(a2) & mi(a3) & mi(a4) & mi(a5)
tab ppi_mm_vehicle1, m


// ppi_mm_vehicle2
replace ppi_mm_vehicle2 = .m if a1 == 1 & a2 == 1 & a3 == 1 & a4 == 1 & a5 ==1 & ppi_mm_vehicle1 == 1
replace ppi_mm_vehicle2 = .m if mi(a1) & mi(a2) & mi(a3) & mi(a4) & mi(a5) & mi(ppi_mm_vehicle1)
tab ppi_mm_vehicle2, m

// ppi_mm_cupboard1
replace ppi_mm_cupboard1 = .m if consent != 1
tab ppi_mm_cupboard1, m

// ppi_mm_cupboard2
replace ppi_mm_cupboard2 = .m if consent != 1
tab ppi_mm_cupboard2, m

// ppi_mm_animals1
replace ppi_mm_animals1 = .m if consent != 1
tab ppi_mm_animals1, m

// ppi_mm_animals2
replace ppi_mm_animals2 = .m if ppi_mm_animals1 != 1 
tab ppi_mm_animals2, m

// ppi_mm_animals3
replace ppi_mm_animals3 = .m if ppi_mm_animals1 != 1 | ppi_mm_animals2 != 1
tab ppi_mm_animals3, m


** Economic activities ** 
** Income sources

// inc_smf_crops
replace inc_smf_crops = .m if consent != 1
tab inc_smf_crops, m

// inc_crops_med
replace inc_crops_med = .m if consent != 1
tab inc_crops_med, m

// inc_crops_large
replace inc_crops_large = .m if consent != 1
tab inc_crops_large, m

// inc_smf_livestock
replace inc_smf_livestock = .m if consent != 1
tab inc_smf_livestock, m

// inc_self_biz
replace inc_self_biz = .m if consent != 1
tab inc_self_biz, m

// inc_salary
replace inc_salary = .m if consent != 1
tab inc_salary, m

// inc_cas_wage
replace inc_cas_wage = .m if consent != 1
tab inc_cas_wage, m

// inc_pension
replace inc_pension = .m if consent != 1
tab inc_pension, m

// inc_soc_assis
replace inc_soc_assis = .m if consent != 1
tab inc_soc_assis, m

// inc_gov_transf
replace inc_gov_transf = .m if consent != 1
tab inc_gov_transf, m 

// inc_nongov_transf
replace inc_nongov_transf = .m if consent != 1
tab inc_nongov_transf, m 

// inc_oth
replace inc_oth = .m if consent != 1
tab inc_oth, m

// inc_osp
replace inc_osp = ".m" if inc_oth != 1
tab inc_osp, m

// inc_none
replace inc_none = ".m" if 	inc_smf_crops != 0 | inc_crops_med != 0 | inc_crops_large != 0 | ///
							inc_smf_livestock != 0 | inc_self_biz != 0 | inc_salary != 0 | ///
							inc_cas_wage != 0 | inc_pension != 0 | inc_soc_assis != 0 | ///
							inc_gov_transf != 0 | inc_oth != 0 

tab inc_none, m

// inc_mem
/* note
br if !mi(inc_mem) & inc_smf_crops != 1 & inc_smf_livestock != 1 & inc_self_biz != 1 & inc_salary != 1 & inc_cas_wage != 1 & inc_pension != 1 & inc_soc_assis != 1 & inc_gov_transf != 1 & inc_nongov_transf != 1 & inc_oth != 1

found one obs which mentioned the number of HH income and hh member data, 
but the income source data variables missing
treat that one as missing in following variable
*/
replace inc_mem = .m if	inc_smf_crops != 1 & inc_smf_livestock != 1 & inc_self_biz != 1 & ///
						inc_salary != 1 & inc_cas_wage != 1 & inc_pension != 1 & ///
						inc_soc_assis != 1 & inc_gov_transf != 1 & inc_nongov_transf != 1 & inc_oth != 1

tab inc_mem, m



** listing of household members
forvalue x = 1/9 {
	// hh_name
	di "hh_name_`x'"
	replace hh_name_`x' = ".m" if inc_mem < `x' | mi(inc_mem)
	tab hh_name_`x', m

	// hh_name_rel
	destring hh_name_rel_`x', replace
	replace hh_name_rel_`x' = .m if inc_mem < `x' | mi(inc_mem)
	tab hh_name_rel_`x', m
	
	// hh_name_rel_osp
	replace hh_name_rel_osp_`x' = ".m" if hh_name_rel_`x' != -66
	tab hh_name_rel_osp_`x' , m
}


** Smallholder farming – crops
// smf_crops_earner
replace smf_crops_earner = ".m" if inc_smf_crops != 1
tab smf_crops_earner, m
tab1 smf_crops_earner_1 smf_crops_earner_2 smf_crops_earner_3 smf_crops_earner_4 smf_crops_earner_5 smf_crops_earner_6 smf_crops_earner_7 smf_crops_earner_8 smf_crops_earner_9 smf_crops_earner_10 smf_crops_earner_11 smf_crops_earner_12 smf_crops_earner_13 smf_crops_earner_14 smf_crops_earner_15


// smf_crops_earner_osp
destring smf_crops_earner_osp, replace
replace smf_crops_earner_osp = .m if smf_crops_earner == "-66"
tab smf_crops_earner_osp, m

// smf_crops_name
tab1 smf_crops_name*


forvalue x = 1/4 {
	// smf_crops_day
	replace smf_crops_day_`x' = .m if mi(smf_crops_id_`x')
	tab smf_crops_day_`x', m
	
	// smf_crops_hrs
	replace smf_crops_hrs_`x' = .m if mi(smf_crops_id_`x')
	tab smf_crops_hrs_`x', m
	
	// smf_crops_inc
	replace smf_crops_inc_`x' = .m if mi(smf_crops_id_`x')
	tab smf_crops_inc_`x', m
	
	// check35
	replace check35_`x' = .m if mi(smf_crops_id_`x') | smf_crops_inc_`x' <= 5000000
	tab check35_`x', m
	
}

// smf_crops_id
destring smf_crops_id*, replace
tab1 smf_crops_id*

// construct new variables based on the hh member id numbers 
forvalue x = 1/6 {

	gen smf_crops_day_earner_`x' 		= smf_crops_day_1 if smf_crops_id_1 == `x'
	replace smf_crops_day_earner_`x' 	= smf_crops_day_2 if smf_crops_id_2 == `x'
	replace smf_crops_day_earner_`x' 	= smf_crops_day_3 if smf_crops_id_3 == `x'
	replace smf_crops_day_earner_`x' 	= smf_crops_day_4 if smf_crops_id_4 == `x'
	replace smf_crops_day_earner_`x' 	= .m if mi(smf_crops_day_earner_`x')
	
	gen smf_crops_hrs_earner_`x' 		= smf_crops_hrs_1 if smf_crops_id_1 == `x'
	replace smf_crops_hrs_earner_`x' 	= smf_crops_hrs_2 if smf_crops_id_2 == `x'
	replace smf_crops_hrs_earner_`x' 	= smf_crops_hrs_3 if smf_crops_id_3 == `x'
	replace smf_crops_hrs_earner_`x' 	= smf_crops_hrs_4 if smf_crops_id_4 == `x'
	replace smf_crops_hrs_earner_`x' 	= .m if mi(smf_crops_hrs_earner_`x')
	
	gen smf_crops_inc_earner_`x' 		= smf_crops_inc_1 if smf_crops_id_1 == `x'
	replace smf_crops_inc_earner_`x' 	= smf_crops_inc_2 if smf_crops_id_2 == `x'
	replace smf_crops_inc_earner_`x' 	= smf_crops_inc_3 if smf_crops_id_3 == `x'
	replace smf_crops_inc_earner_`x' 	= smf_crops_inc_4 if smf_crops_id_4 == `x'
	replace smf_crops_inc_earner_`x' 	= .m if mi(smf_crops_inc_earner_`x')
	
	gen check35_earner_`x' 		= check35_1 if smf_crops_id_1 == `x'
	replace check35_earner_`x' 	= check35_2 if smf_crops_id_2 == `x'
	replace check35_earner_`x' 	= check35_3 if smf_crops_id_3 == `x'
	replace check35_earner_`x' 	= check35_4 if smf_crops_id_4 == `x'
	replace check35_earner_`x' 	= .m if mi(check35_earner_`x')

	order smf_crops_day_earner_`x' smf_crops_hrs_earner_`x' smf_crops_inc_earner_`x' check35_earner_`x', before(crops_med_earner)

}

** Crop farming - medium scale (5-10 acres)
// crops_med_earner
replace crops_med_earner = ".m" if inc_crops_med != 1 
tab crops_med_earner, m

// crops_med_earner_osp
destring crops_med_earner_osp, replace
replace crops_med_earner_osp = .m if crops_med_earner == "-66"
tab crops_med_earner_osp, m


forvalue x = 1/4 {
	// crops_med_day
	replace crops_med_day_`x' = .m if mi(crops_med_id_`x')
	tab crops_med_day_`x', m
	
	// crops_med_hrs
	replace crops_med_hrs_`x' = .m if mi(crops_med_id_`x')
	tab crops_med_hrs_`x', m
	
	// crops_med_inc
	replace crops_med_inc_`x' = .m if mi(crops_med_id_`x')
	tab crops_med_inc_`x', m
	
	// check351
	replace check351_`x' = .m if mi(crops_med_id_`x') | crops_med_inc_`x' <= 5000000
	tab check351_`x', m
	
}


// crops_med_id
destring crops_med_id_*, replace
tab1 crops_med_id*

// crops_med_name
tab1 crops_med_name*

// crops_med_day
// crops_med_hrs
// crops_med_inc
// check351

// construct new variables based on the hh member id numbers 
forvalue x = 1/9 {

	gen crops_med_day_earner_`x' 		= crops_med_day_1 if crops_med_id_1 == `x'
	replace crops_med_day_earner_`x' 	= crops_med_day_2 if crops_med_id_2 == `x'
	replace crops_med_day_earner_`x' 	= crops_med_day_3 if crops_med_id_3 == `x'
	replace crops_med_day_earner_`x' 	= crops_med_day_4 if crops_med_id_4 == `x'
	replace crops_med_day_earner_`x' 	= .m if mi(crops_med_day_earner_`x')
	
	gen crops_med_hrs_earner_`x' 		= crops_med_hrs_1 if crops_med_id_1 == `x'
	replace crops_med_hrs_earner_`x' 	= crops_med_hrs_2 if crops_med_id_2 == `x'
	replace crops_med_hrs_earner_`x' 	= crops_med_hrs_3 if crops_med_id_3 == `x'
	replace crops_med_hrs_earner_`x' 	= crops_med_hrs_4 if crops_med_id_4 == `x'
	replace crops_med_hrs_earner_`x' 	= .m if mi(crops_med_hrs_earner_`x')
	
	gen crops_med_inc_earner_`x' 		= crops_med_inc_1 if crops_med_id_1 == `x'
	replace crops_med_inc_earner_`x' 	= crops_med_inc_2 if crops_med_id_2 == `x'
	replace crops_med_inc_earner_`x' 	= crops_med_inc_3 if crops_med_id_3 == `x'
	replace crops_med_inc_earner_`x' 	= crops_med_inc_4 if crops_med_id_4 == `x'
	replace crops_med_inc_earner_`x' 	= .m if mi(crops_med_inc_earner_`x')
	
	gen check351_earner_`x' 		= check351_1 if crops_med_id_1 == `x'
	replace check351_earner_`x' 	= check351_2 if crops_med_id_2 == `x'
	replace check351_earner_`x' 	= check351_3 if crops_med_id_3 == `x'
	replace check351_earner_`x' 	= check351_4 if crops_med_id_4 == `x'
	replace check351_earner_`x' 	= .m if mi(check351_earner_`x')

	order crops_med_day_earner_`x' crops_med_hrs_earner_`x' crops_med_inc_earner_`x' check351_earner_`x', before(crops_large_earner)

}

** Crop farming - large scale (> 10 acres)
// crops_large_earner
replace crops_large_earner = ".m" if inc_crops_large != 1
tab crops_large_earner, m

// crops_large_earner_osp
destring crops_large_earner_osp, replace
replace crops_large_earner_osp = .m if crops_large_earner == "-66"
tab crops_large_earner_osp, m


forvalue x = 1/3 {
	// crops_large_day
	replace crops_large_day_`x' = .m if mi(crops_large_id_`x')
	tab crops_large_day_`x', m
	
	// crops_large_hrs
	replace crops_large_hrs_`x' = .m if mi(crops_large_id_`x')
	tab crops_large_hrs_`x', m
	
	// crops_large_inc
	replace crops_large_inc_`x' = .m if mi(crops_large_id_`x')
	tab crops_large_inc_`x', m
	
	// check352
	replace check352_`x' = .m if mi(crops_large_id_`x') | crops_large_inc_`x' <= 5000000
	tab check352_`x', m
	
}


// crops_large_id
destring crops_large_id*, replace
tab1 crops_large_id*

// crops_large_name
tab1 crops_large_name*, m

// construct new variables based on the hh member id numbers 
forvalue x = 1/4 {

	gen crops_large_day_earner_`x' 		= crops_large_day_1 if crops_large_id_1 == `x'
	replace crops_large_day_earner_`x' 	= crops_large_day_2 if crops_large_id_2 == `x'
	replace crops_large_day_earner_`x' 	= crops_large_day_3 if crops_large_id_3 == `x'
	replace crops_large_day_earner_`x' 	= .m if mi(crops_large_day_earner_`x')
	
	gen crops_large_hrs_earner_`x' 		= crops_large_hrs_1 if crops_large_id_1 == `x'
	replace crops_large_hrs_earner_`x' 	= crops_large_hrs_2 if crops_large_id_2 == `x'
	replace crops_large_hrs_earner_`x' 	= crops_large_hrs_3 if crops_large_id_3 == `x'
	replace crops_large_hrs_earner_`x' 	= .m if mi(crops_large_hrs_earner_`x')
	
	gen crops_large_inc_earner_`x' 		= crops_large_inc_1 if crops_large_id_1 == `x'
	replace crops_large_inc_earner_`x' 	= crops_large_inc_2 if crops_large_id_2 == `x'
	replace crops_large_inc_earner_`x' 	= crops_large_inc_3 if crops_large_id_3 == `x'
	replace crops_large_inc_earner_`x' 	= .m if mi(crops_large_inc_earner_`x')
	
	gen check352_earner_`x' 		= check352_1 if crops_large_id_1 == `x'
	replace check352_earner_`x' 	= check352_2 if crops_large_id_2 == `x'
	replace check352_earner_`x' 	= check352_3 if crops_large_id_3 == `x'
	replace check352_earner_`x' 	= .m if mi(check352_earner_`x')

	order crops_large_day_earner_`x' crops_large_hrs_earner_`x' crops_large_inc_earner_`x' check352_earner_`x', before(smf_livestock_earner)

}



** Smallholder farming – livestock
// smf_livestock_earner
replace smf_livestock_earner = ".m" if inc_smf_livestock != 1 
tab smf_livestock_earner, m

// smf_livestock_earner_osp
destring smf_livestock_earner_osp, replace
replace smf_livestock_earner_osp = .m if smf_livestock_earner == "-66"

forvalue x = 1/2 {
	// smf_livestock_day
	replace smf_livestock_day_`x' = .m if mi(crops_large_id_`x')
	tab smf_livestock_day_`x', m
	
	// smf_livestock_hrs
	replace smf_livestock_hrs_`x' = .m if mi(crops_large_id_`x')
	tab smf_livestock_hrs_`x', m
	
	// smf_livestock_inc
	replace smf_livestock_inc_`x' = .m if mi(crops_large_id_`x')
	tab smf_livestock_inc_`x', m
	
	// check36
	replace check36_`x' = .m if mi(crops_large_id_`x') | smf_livestock_inc_`x' <= 5000000
	tab check36_`x', m
	
}

// smf_livestock_id
destring smf_livestock_id*, replace
tab1 smf_livestock_id*, m

// smf_livestock_name
tab1 smf_livestock_name*, m

// construct new variables based on the hh member id numbers 
forvalue x = 1/4 {

	gen smf_livestock_day_earner_`x' 		= smf_livestock_day_1 if crops_large_id_1 == `x'
	replace smf_livestock_day_earner_`x' 	= smf_livestock_day_2 if crops_large_id_2 == `x'
	replace smf_livestock_day_earner_`x' 	= .m if mi(smf_livestock_day_earner_`x')
	
	gen smf_livestock_hrs_earner_`x' 		= smf_livestock_hrs_1 if crops_large_id_1 == `x'
	replace smf_livestock_hrs_earner_`x' 	= smf_livestock_hrs_2 if crops_large_id_2 == `x'
	replace smf_livestock_hrs_earner_`x' 	= .m if mi(smf_livestock_hrs_earner_`x')
	
	gen smf_livestock_inc_earner_`x' 		= smf_livestock_inc_1 if crops_large_id_1 == `x'
	replace smf_livestock_inc_earner_`x' 	= smf_livestock_inc_2 if crops_large_id_2 == `x'
	replace smf_livestock_inc_earner_`x' 	= .m if mi(smf_livestock_inc_earner_`x')
	
	gen check36_earner_`x' 		= check36_1 if crops_large_id_1 == `x'
	replace check36_earner_`x' 	= check36_2 if crops_large_id_2 == `x'
	replace check36_earner_`x' 	= .m if mi(check352_earner_`x')

	order smf_livestock_day_earner_`x' smf_livestock_hrs_earner_`x' smf_livestock_inc_earner_`x' check36_earner_`x', before(self_biz_earner)

}


** Self-employed business
// self_biz_earner
replace self_biz_earner = ".m" if inc_self_biz != 1
replace self_biz_earner = ".n" if inc_self_biz == 1 & self_biz_earner == ""
tab self_biz_earner, m

// self_biz_osp
destring self_biz_osp, replace
replace self_biz_osp = .m if self_biz_earner != "-66"
tab self_biz_osp, m

// self_biz_id
tab1 self_biz_id*

// self_biz_name
tab1 self_biz_name*

// bus_num
tab1 bus_num_1 bus_num_2 bus_num_3 bus_num_4 bus_num_5, m

forvalue x = 1/5 {
	destring self_biz_id_`x', replace
	replace bus_num_`x' = .m if mi(self_biz_id_`x')
	replace bus_num_`x' = .n if !mi(self_biz_id_`x') & mi(bus_num_`x')
}


forvalue x = 1/5 {

	forvalue y = 1/3 {

	// bus_type
	replace bus_type_`x'_`y' = .m if mi(bus_num_`x') | bus_num_`x' < `y'
	
	// bus_type_osp
	replace bus_type_osp_`x'_`y' = ".m" if mi(bus_num_`x') | bus_num_`x' < `y' | bus_type_`x'_`y' != -66
	
	// bus_income_name
	replace bus_income_name_`x'_`y' = .m if mi(bus_num_`x') | bus_num_`x' < `y'
	
	// bus_name
	replace bus_name_`x'_`y' = ".m" if mi(bus_num_`x') | bus_num_`x' < `y' | bus_income_name_`x'_`y' != 1
	
	// bus_collaborate
	replace bus_collaborate_`x'_`y' = .m if mi(bus_num_`x') | bus_num_`x' < `y'
	
	// bus_collaborate_who
	replace bus_collaborate_who_`x'_`y' = .m if mi(bus_num_`x') | bus_num_`x' < `y' | bus_collaborate_`x'_`y' != 1
	
	// bus_collaborate_who_osp
	replace bus_collaborate_who_osp_`x'_`y' = ".m" if mi(bus_num_`x') | bus_num_`x' < `y' | bus_collaborate_who_`x'_`y' != -66
	
	// bus_spec
	replace bus_spec_`x'_`y' = .m if mi(bus_num_`x') | bus_num_`x' < `y' | bus_collaborate_who_`x'_`y' != 1 | bus_collaborate_who_`x'_`y' != 5 
	
	// bus_location
	replace bus_location_`x'_`y' = .m if mi(bus_num_`x') | bus_num_`x' < `y'
	
	// bus_location_home
	replace bus_location_home_`x'_`y' = .m if mi(bus_num_`x') | bus_num_`x' < `y' | bus_location_`x'_`y' != 1
	
	// self_biz_day
	replace self_biz_day_`x'_`y' = .m if mi(bus_num_`x') | bus_num_`x' < `y'
	
	// self_biz_hrs
	replace self_biz_hrs_`x'_`y' = .m if mi(bus_num_`x') | bus_num_`x' < `y'
	
	// bus_profit
	replace bus_profit_`x'_`y' = .m if mi(bus_num_`x') | bus_num_`x' < `y'
	
	// check337
	replace check337_`x'_`y' = .m if mi(bus_num_`x') | bus_num_`x' < `y' | bus_profit_`x'_`y' <= 30000000
	
	// bus_share_profit
	replace bus_share_profit_`x'_`y' = .m if mi(bus_num_`x') | bus_num_`x' < `y' | bus_collaborate_`x'_`y' != 1
	
	// bus_materials
	replace bus_materials_`x'_`y' = .m if mi(bus_num_`x') | bus_num_`x' < `y'
	
	// bus_employnum
	replace bus_employnum_`x'_`y' = .m if mi(bus_num_`x') | bus_num_`x' < `y'
	
	// bus_days
	replace bus_days_`x'_`y' = .m if mi(bus_num_`x') | bus_num_`x' < `y' | bus_employnum_`x'_`y' <= 0 
	 
	// bus_employfam
	replace bus_employfam_`x'_`y' = .m if mi(bus_num_`x') | bus_num_`x' < `y' | bus_employnum_`x'_`y' <= 0 
	
	// bus_inv
	replace bus_inv_`x'_`y' = .m if mi(bus_num_`x') | bus_num_`x' < `y'
	
	// bus_inv_type
	replace bus_inv_type_`x'_`y' = ".m" if mi(bus_num_`x') | bus_num_`x' < `y' | bus_inv_`x'_`y' != 1
	
	// bus_inv_type_osp
	replace bus_inv_type_osp_`x'_`y' = ".m" if mi(bus_num_`x') | bus_num_`x' < `y' // | bus_inv_type_`x'_`y' != "-66" 
	
	// bus_inv_amount
	replace bus_inv_amount_`x'_`y' = .m if mi(bus_num_`x') | bus_num_`x' < `y' | bus_inv_`x'_`y' != 1
	
	// check37
	replace check37_`x'_`y' = .m if mi(bus_num_`x') | bus_num_`x' < `y' | bus_inv_amount_`x'_`y' <= 30000000
	
	}
}

// Note: Not generate new variable for each HH members who are doing this type of job
// as it applied the nested loop in the ODK programming, the variable construction for each HH members will be a little bit challenging

/*
bus_type
bus_type_osp
bus_income_name
bus_name
bus_collaborate
bus_collaborate_who
bus_collaborate_who_osp
bus_spec
bus_location
bus_location_home
self_biz_day
self_biz_hrs
bus_profit
check337
bus_share_profit
bus_materials
bus_employnum
bus_days 
bus_employfam
bus_inv
bus_inv_type
bus_inv_type_osp
bus_inv_amount
check37
*/


** Salaried employment
// salary_earner
replace salary_earner = ".m" if inc_salary != 1 
tab salary_earner, m

// salary_osp
destring salary_osp, replace
replace salary_osp = .m if salary_earner != "-66"
tab salary_osp, m


forvalue x = 1/5 {
	// salary_type
	replace salary_type_`x' = .m if mi(salary_id_`x')
	tab salary_type_`x', m
	
	// salary_type_osp
	replace salary_type_osp_`x' = ".m" if mi(salary_id_`x') | salary_type_`x' != -66
	tab salary_type_osp_`x', m
	
	// salary_day
	replace salary_day_`x' = .m if mi(salary_id_`x')
	tab salary_day_`x', m
	
	// salary_hrs
	replace salary_hrs_`x' = .m if mi(salary_id_`x')
	tab salary_hrs_`x', m

	// salary_inc
	replace salary_inc_`x' = .m if mi(salary_id_`x')
	tab salary_inc_`x', m

	// check38
	replace check38_`x' = .m if mi(salary_id_`x') | salary_inc_`x' <= 5000000
	tab check38_`x', m
	
}

// salary_id
destring salary_id*, replace
tab1 salary_id*

// salary_name
tab1 salary_name*

// construct new variables based on the hh member id numbers 
forvalue x = 1/9 {

	gen salary_type_earner_`x' 		= salary_type_1 if salary_id_1 == `x'
	replace salary_type_earner_`x' 	= salary_type_2 if salary_id_2 == `x'
	replace salary_type_earner_`x' 	= salary_type_3 if salary_id_3 == `x'
	replace salary_type_earner_`x' 	= salary_type_4 if salary_id_4 == `x'
	replace salary_type_earner_`x' 	= salary_type_5 if salary_id_5 == `x'
	replace salary_type_earner_`x' 	= .m if mi(salary_type_earner_`x')
	
	gen salary_type_osp_earner_`x' 		= salary_type_osp_1 if salary_id_1 == `x'
	replace salary_type_osp_earner_`x' 	= salary_type_osp_2 if salary_id_1 == `x'
	replace salary_type_osp_earner_`x' 	= salary_type_osp_3 if salary_id_1 == `x'
	replace salary_type_osp_earner_`x' 	= salary_type_osp_4 if salary_id_1 == `x'
	replace salary_type_osp_earner_`x' 	= salary_type_osp_5 if salary_id_1 == `x'
	replace salary_type_osp_earner_`x' 	= ".m" if mi(salary_type_osp_earner_`x')
	
	gen salary_day_earner_`x' 		= salary_day_1 if salary_id_1 == `x'
	replace salary_day_earner_`x' 	= salary_day_2 if salary_id_2 == `x'
	replace salary_day_earner_`x' 	= salary_day_3 if salary_id_3 == `x'
	replace salary_day_earner_`x' 	= salary_day_4 if salary_id_4 == `x'
	replace salary_day_earner_`x' 	= salary_day_4 if salary_id_5 == `x'
	replace salary_day_earner_`x' 	= .m if mi(salary_day_earner_`x')
	
	gen salary_hrs_earner_`x' 		= salary_hrs_1 if salary_id_1 == `x'
	replace salary_hrs_earner_`x' 	= salary_hrs_2 if salary_id_1 == `x'
	replace salary_hrs_earner_`x' 	= salary_hrs_3 if salary_id_1 == `x'
	replace salary_hrs_earner_`x' 	= salary_hrs_4 if salary_id_1 == `x'
	replace salary_hrs_earner_`x' 	= salary_hrs_4 if salary_id_1 == `x'
	replace salary_hrs_earner_`x' 	= .m if mi(salary_hrs_earner_`x')
	
	gen salary_inc_earner_`x' 		= salary_inc_1 if salary_id_1 == `x'
	replace salary_inc_earner_`x' 	= salary_inc_2 if salary_id_2 == `x'
	replace salary_inc_earner_`x' 	= salary_inc_3 if salary_id_3 == `x'
	replace salary_inc_earner_`x' 	= salary_inc_4 if salary_id_4 == `x'
	replace salary_inc_earner_`x' 	= salary_inc_4 if salary_id_5 == `x'
	replace salary_inc_earner_`x' 	= .m if mi(salary_inc_earner_`x')
	
	gen check38_earner_`x' 		= check38_1 if salary_id_1 == `x'
	replace check38_earner_`x' 	= check38_2 if salary_id_1 == `x'
	replace check38_earner_`x' 	= check38_3 if salary_id_1 == `x'
	replace check38_earner_`x' 	= check38_4 if salary_id_1 == `x'
	replace check38_earner_`x' 	= check38_4 if salary_id_1 == `x'
	replace check38_earner_`x' 	= .m if mi(check38_earner_`x')
	
	order 	salary_type_earner_`x' salary_type_osp_earner_`x' salary_day_earner_`x' ///
			salary_hrs_earner_`x' salary_inc_earner_`x' check38_earner_`x', before(cas_wage_earner)

}


** Casual wage employment
// cas_wage_earner
replace cas_wage_earner = ".m" if inc_cas_wage != 1 
replace cas_wage_earner = ".n" if inc_cas_wage == 1 & cas_wage_earner == ""
tab cas_wage_earner, m

// cas_wage_osp
destring cas_wage_osp, replace
replace cas_wage_osp = .m if cas_wage_earner != "-66"
tab cas_wage_osp, m


forvalue x = 1/7 {
	// cas_wage_num
	replace cas_wage_num_`x' = .m if mi(cas_wage_id_`x')
	tab cas_wage_num_`x', m
	
	// cas_wage_type
	replace cas_wage_type_`x' = ".m" if mi(cas_wage_id_`x')
	tab cas_wage_type_`x', m
	
	// cas_wage_type_osp
	replace cas_wage_type_osp_`x' = ".m" if mi(cas_wage_id_`x') | cas_wage_type_`x' != "-66"
	tab cas_wage_type_osp_`x', m
	
	// cas_wage_day
	replace cas_wage_day_`x' = .m if mi(cas_wage_id_`x')
	tab cas_wage_day_`x', m

	// cas_wage_hrs
	replace cas_wage_hrs_`x' = .m if mi(cas_wage_id_`x')
	tab cas_wage_hrs_`x', m
	
	// cas_wage_inc
	replace cas_wage_inc_`x' = .m if mi(cas_wage_id_`x')
	tab cas_wage_inc_`x', m

	// check39
	replace check39_`x' = .m if mi(cas_wage_id_`x') | cas_wage_inc_`x' <= 5000000
	tab check39_`x', m
	
}

// cas_wage_id
destring cas_wage_id_*, replace
tab1 cas_wage_id*

// cas_wage_name
tab1 cas_wage_name*

// construct new variables based on the hh member id numbers 
forvalue x = 1/7 {

	gen cas_wage_num_earner_`x' 		= cas_wage_num_1 if cas_wage_id_1 == `x'
	replace cas_wage_num_earner_`x' 	= cas_wage_num_2 if cas_wage_id_2 == `x'
	replace cas_wage_num_earner_`x' 	= cas_wage_num_3 if cas_wage_id_3 == `x'
	replace cas_wage_num_earner_`x' 	= cas_wage_num_4 if cas_wage_id_4 == `x'
	replace cas_wage_num_earner_`x' 	= cas_wage_num_5 if cas_wage_id_5 == `x'
	replace cas_wage_num_earner_`x' 	= cas_wage_num_6 if cas_wage_id_6 == `x'
	replace cas_wage_num_earner_`x' 	= cas_wage_num_7 if cas_wage_id_7 == `x'
	replace cas_wage_num_earner_`x' 	= .m if mi(cas_wage_num_earner_`x')
	
	gen cas_wage_type_earner_`x' 		= cas_wage_type_1 if cas_wage_id_1 == `x'
	replace cas_wage_type_earner_`x' 	= cas_wage_type_2 if cas_wage_id_2 == `x'
	replace cas_wage_type_earner_`x' 	= cas_wage_type_3 if cas_wage_id_3 == `x'
	replace cas_wage_type_earner_`x' 	= cas_wage_type_4 if cas_wage_id_4 == `x'
	replace cas_wage_type_earner_`x' 	= cas_wage_type_5 if cas_wage_id_5 == `x'
	replace cas_wage_type_earner_`x' 	= cas_wage_type_6 if cas_wage_id_6 == `x'
	replace cas_wage_type_earner_`x' 	= cas_wage_type_7 if cas_wage_id_7 == `x'
	replace cas_wage_type_earner_`x' 	= ".m" if mi(cas_wage_num_earner_`x')
	
	gen cas_wage_type_osp_earner_`x' 		= cas_wage_type_osp_1 if cas_wage_id_1 == `x'
	replace cas_wage_type_osp_earner_`x' 	= cas_wage_type_osp_2 if cas_wage_id_2 == `x'
	replace cas_wage_type_osp_earner_`x' 	= cas_wage_type_osp_3 if cas_wage_id_3 == `x'
	replace cas_wage_type_osp_earner_`x' 	= cas_wage_type_osp_4 if cas_wage_id_4 == `x'
	replace cas_wage_type_osp_earner_`x' 	= cas_wage_type_osp_5 if cas_wage_id_5 == `x'
	replace cas_wage_type_osp_earner_`x' 	= cas_wage_type_osp_6 if cas_wage_id_6 == `x'
	replace cas_wage_type_osp_earner_`x' 	= cas_wage_type_osp_7 if cas_wage_id_7 == `x'
	replace cas_wage_type_osp_earner_`x' 	= ".m" if mi(cas_wage_type_osp_earner_`x')
	
	gen cas_wage_day_earner_`x' 		= cas_wage_day_1 if cas_wage_id_1 == `x'
	replace cas_wage_day_earner_`x' 	= cas_wage_day_2 if cas_wage_id_2 == `x'
	replace cas_wage_day_earner_`x' 	= cas_wage_day_3 if cas_wage_id_3 == `x'
	replace cas_wage_day_earner_`x' 	= cas_wage_day_4 if cas_wage_id_4 == `x'
	replace cas_wage_day_earner_`x' 	= cas_wage_day_5 if cas_wage_id_5 == `x'
	replace cas_wage_day_earner_`x' 	= cas_wage_day_6 if cas_wage_id_6 == `x'
	replace cas_wage_day_earner_`x' 	= cas_wage_day_7 if cas_wage_id_7 == `x'
	replace cas_wage_day_earner_`x' 	= .m if mi(cas_wage_day_earner_`x')	

	gen cas_wage_hrs_earner_`x' 		= cas_wage_hrs_1 if cas_wage_id_1 == `x'
	replace cas_wage_hrs_earner_`x' 	= cas_wage_hrs_2 if cas_wage_id_2 == `x'
	replace cas_wage_hrs_earner_`x' 	= cas_wage_hrs_3 if cas_wage_id_3 == `x'
	replace cas_wage_hrs_earner_`x' 	= cas_wage_hrs_4 if cas_wage_id_4 == `x'
	replace cas_wage_hrs_earner_`x' 	= cas_wage_hrs_5 if cas_wage_id_5 == `x'
	replace cas_wage_hrs_earner_`x' 	= cas_wage_hrs_6 if cas_wage_id_6 == `x'
	replace cas_wage_hrs_earner_`x' 	= cas_wage_hrs_7 if cas_wage_id_7 == `x'
	replace cas_wage_hrs_earner_`x' 	= .m if mi(cas_wage_hrs_earner_`x')	
	
	gen cas_wage_inc_earner_`x' 		= cas_wage_inc_1 if cas_wage_id_1 == `x'
	replace cas_wage_inc_earner_`x' 	= cas_wage_inc_2 if cas_wage_id_2 == `x'
	replace cas_wage_inc_earner_`x' 	= cas_wage_inc_3 if cas_wage_id_3 == `x'
	replace cas_wage_inc_earner_`x' 	= cas_wage_inc_4 if cas_wage_id_4 == `x'
	replace cas_wage_inc_earner_`x' 	= cas_wage_inc_5 if cas_wage_id_5 == `x'
	replace cas_wage_inc_earner_`x' 	= cas_wage_inc_6 if cas_wage_id_6 == `x'
	replace cas_wage_inc_earner_`x' 	= cas_wage_inc_7 if cas_wage_id_7 == `x'
	replace cas_wage_inc_earner_`x' 	= .m if mi(cas_wage_inc_earner_`x')	
	
	gen check39_earner_`x' 		= check39_1 if cas_wage_id_1 == `x'
	replace check39_earner_`x' 	= check39_2 if cas_wage_id_2 == `x'
	replace check39_earner_`x' 	= check39_3 if cas_wage_id_3 == `x'
	replace check39_earner_`x' 	= check39_4 if cas_wage_id_4 == `x'
	replace check39_earner_`x' 	= check39_5 if cas_wage_id_5 == `x'
	replace check39_earner_`x' 	= check39_6 if cas_wage_id_6 == `x'
	replace check39_earner_`x' 	= check39_7 if cas_wage_id_7 == `x'
	replace check39_earner_`x' 	= .m if mi(check39_earner_`x')	

	order 	cas_wage_num_earner_`x' cas_wage_type_earner_`x' cas_wage_type_osp_earner_`x' ///
			cas_wage_day_earner_`x' cas_wage_hrs_earner_`x' cas_wage_inc_earner_`x' ///
			check39_earner_`x', before(pension_earner)

}


** Pension payments
// pension_earner
replace pension_earner = ".m" if inc_pension != 1 
tab pension_earner, m

// pension_osp
destring pension_osp, replace
replace pension_osp = .m if pension_earner != "-66"
tab pension_osp, m

// pension_id
destring pension_id_1, replace
tab1 pension_id*

// pension_name
tab1 pension_name*

// pension_inc
replace pension_inc_1 = .m if mi(pension_id_1)
tab pension_inc_1, m

// check38
replace check40_1 = .m if mi(pension_id_1) | pension_inc_1 <= 5000000
tab check40_1, m

// construct new variables based on the hh member id numbers 
forvalue x = 1/4 {

	gen pension_inc_earner_`x' 		= pension_inc_1 if pension_id_1 == `x'
	replace pension_inc_earner_`x' 	= .m if mi(pension_inc_earner_`x')
	
	gen check40_earner_`x' 		= check40_1 if pension_id_1 == `x'
	replace check40_earner_`x' 	= .m if mi(check40_earner_`x')
	
	order 	pension_inc_earner_`x' check40_earner_`x' , before(soc_assis_earner)

}


** Family/friends assistance
// soc_assis_earner
replace soc_assis_earner = ".m" if inc_soc_assis != 1 
replace soc_assis_earner = ".n" if inc_soc_assis == 1 & soc_assis_earner == ""
tab  soc_assis_earner, m

// soc_assis_osp
destring soc_assis_osp, replace
replace soc_assis_osp = .m if soc_assis_earner != "-66"
tab soc_assis_osp, m


// soc_assis_source
replace soc_assis_source = ".m" if inc_soc_assis != 1
replace soc_assis_source = ".n" if inc_soc_assis == 1 & soc_assis_source == ""
tab soc_assis_source, m

// soc_assis_source_osp
replace soc_assis_source_osp = ".m" if soc_assis_source != "-66"
tab soc_assis_source_osp, m


forvalue x = 1/4 {
	// soc_assis_inc
	replace soc_assis_inc_`x' = .m if mi(soc_assis_id_`x')
	tab soc_assis_inc_`x', m

	// check41
	replace check41_`x' = .m if mi(soc_assis_id_`x') | soc_assis_inc_`x' <= 5000000
	tab check41_`x', m
	
}

// soc_assis_id
destring soc_assis_id*, replace
tab1 soc_assis_id*

// soc_assis_name
tab1 soc_assis_name*


// construct new variables based on the hh member id numbers 
forvalue x = 1/7 {

	gen soc_assis_inc_earner_`x' 		= soc_assis_inc_1 if soc_assis_id_1 == `x'
	replace soc_assis_inc_earner_`x' 	= soc_assis_inc_2 if soc_assis_id_2 == `x'
	replace soc_assis_inc_earner_`x' 	= soc_assis_inc_3 if soc_assis_id_3 == `x'
	replace soc_assis_inc_earner_`x' 	= soc_assis_inc_4 if soc_assis_id_4 == `x'
	replace soc_assis_inc_earner_`x' 	= .m if mi(soc_assis_inc_earner_`x')

	gen check41_earner_`x' 		= check41_1 if soc_assis_id_1 == `x'
	replace check41_earner_`x' 	= check41_2 if soc_assis_id_2 == `x'
	replace check41_earner_`x' 	= check41_3 if soc_assis_id_3 == `x'
	replace check41_earner_`x' 	= check41_4 if soc_assis_id_4 == `x'
	replace check41_earner_`x' 	= .m if mi(check41_earner_`x')
	
	
	order 	soc_assis_inc_earner_`x' check41_earner_`x' , before(gov_transf_earner)

}


** Government transfers (i.e. social safety net)

// gov_transf_earner
replace gov_transf_earner = ".m" if inc_gov_transf != 1
tab gov_transf_earner, m

// gov_transf_osp
destring gov_transf_osp, replace
replace gov_transf_osp = .m if gov_transf_earner != "-66"
tab gov_transf_osp, m

// gov_transf_inc
replace gov_transf_inc_1 = .m if mi(gov_transf_id_1)
tab gov_transf_inc_1, m

// check42
replace check42_1 = .m if mi(gov_transf_id_1) | gov_transf_inc_1 <= 5000000
tab check42_1, m

// gov_transf_id
destring gov_transf_id*, replace
tab1 gov_transf_id*

// gov_transf_name
tab1 gov_transf_name*

// construct new variables based on the hh member id numbers 
forvalue x = 1/7 {

	gen gov_transf_inc_earner_`x' 		= gov_transf_inc_1 if gov_transf_id_1 == `x'
	replace gov_transf_inc_earner_`x' 	= .m if mi(gov_transf_inc_earner_`x')

	gen check42_earner_`x' 		= check42_1 if gov_transf_id_1 == `x'
	replace check42_earner_`x' 	= .m if mi(check42_earner_`x')
	
	
	order 	gov_transf_inc_earner_`x' check42_earner_`x' , before(nongov_transf_earner)

}


** Non-government transfers (i.e. NGOs, church)

// nongov_transf_earner
replace nongov_transf_earner = ".m" if inc_nongov_transf != 1
tab nongov_transf_earner, m

// nongov_transf_osp
replace nongov_transf_osp = ".m" if nongov_transf_earner != "-66"
tab nongov_transf_osp, m

// nongov_transf_inc
replace nongov_transf_inc_1 = .m if mi(nongov_transf_id_1)
tab nongov_transf_inc_1, m

// check43
replace check43_1 = .m if mi(nongov_transf_id_1) | nongov_transf_inc_1 <= 5000000
tab check43_1, m

// nongov_transf_id
destring nongov_transf_id*, replace
tab1 nongov_transf_id*

// nongov_transf_name
tab1 nongov_transf_name*


// construct new variables based on the hh member id numbers 
forvalue x = 1/5 {

	gen nongov_transf_inc_earner_`x' 		= nongov_transf_inc_1 if nongov_transf_id_1 == `x'
	replace nongov_transf_inc_earner_`x' 	= .m if mi(nongov_transf_inc_earner_`x')

	gen check43_earner_`x' 		= check43_1 if nongov_transf_id_1 == `x'
	replace check43_earner_`x' 	= .m if mi(check43_earner_`x')
	
	
	order 	nongov_transf_inc_earner_`x' check42_earner_`x' , before(other_earner)

}


** Other: ${inc_osp}

// other_earner
replace other_earner = ".m" if inc_oth != 1
tab other_earner, m

// other_osp
destring other_osp, replace
replace other_osp = .m if other_earner != "-66"
tab other_osp, m

// other_inc
replace other_inc_1 = .m if mi(other_id_1)
tab other_inc_1, m

// check44
replace check44_1 = .m if mi(other_id_1) | other_inc_1 <= 5000000
tab check44_1, m


// other_id
destring other_id*, replace
tab other_id*

// other_name
tab1 other_name*

// construct new variables based on the hh member id numbers 
forvalue x = 1/5 {

	gen other_inc_earner_`x' 		= other_inc_1 if other_id_1 == `x'
	replace other_inc_earner_`x' 	= .m if mi(other_inc_earner_`x')

	gen check44_earner_`x' 		= check44_1 if other_id_1 == `x'
	replace check44_earner_`x' 	= .m if mi(check44_earner_`x')
	
	
	order 	other_inc_earner_`x' check44_earner_`x' , before(loans)

}


** Debts **

// loans
replace loans = .m if consent != 1
tab loans, m

forvalue x = 1/7 {
	// loan_taker
	replace loan_taker_`x' = .m if `x' > loans | mi(loans)
	tab loan_taker_`x', m

	// loan_detailed	
	// credit_provider
	replace credit_provider_`x' = .m if loan_taker_`x' > 2
	tab credit_provider_`x', m
	
	// credit_provider_osp
	replace credit_provider_osp_`x' = ".m" if credit_provider_`x' != -66
	tab credit_provider_osp_`x', m
	
	// loan_active
	replace loan_active_`x' = .m if loan_taker_`x' > 2
	tab loan_active_`x', m
	
	// loan_amount
	replace loan_amount_`x' = .m if  loan_taker_`x' > 2
	tab loan_amount_`x', m
	
	// check45
	replace check45_`x' = .m if loan_amount_`x' <= 20000000 | mi(loan_amount_`x')
	tab check45_`x', m
	
	// check45a
	replace check45a_`x' = .m if loan_amount_`x' >= 10000 & !mi(loan_amount_`x')
	tab check45a_`x', m

	// loan lenght
	// loan_length_na
	replace loan_length_na_`x' = .m if loan_active_`x' != 0
	tab loan_length_na_`x', m
	
	// loan_length_na_unit
	replace loan_length_na_unit_`x' = .m if loan_active_`x' != 0
	tab loan_length_na_unit_`x', m
	
	// loan_length
	replace loan_length_`x' = .m if loan_active_`x' != 1
	tab loan_length_`x', m

	// loan_length_unit
	replace loan_length_unit_`x' = .m if loan_active_`x' != 1


	// loan_freq
	replace loan_freq_`x' = .m if loan_taker_`x' > 2
	tab loan_freq_`x', m
	
	// loan_freq_osp
	replace loan_freq_osp_`x' = ".m" if loan_freq_`x' != -66
	tab loan_freq_osp_`x', m
	
	// loan_total
	replace loan_total_`x' = .m if loan_taker_`x' > 2
	tab loan_total_`x', m
	
	// loan_ir
	replace loan_ir_`x' = .m if loan_taker_`x' > 2
	tab loan_ir_`x', m
	
	// loan_ir_freq
	replace loan_ir_freq_`x' = .m if loan_ir_`x' != -66
	tab loan_ir_freq_`x', m
	
	// loan_ir_total
	replace loan_ir_total_`x' = .m if loan_taker_`x' > 2
	tab loan_ir_total_`x', m
	
	// loan_coll
	replace loan_coll_`x' = .m if loan_taker_`x' > 2
	tab loan_coll_`x', m
	
	// loan_guar
	replace loan_guar_`x' = .m if loan_taker_`x' > 2
	tab loan_guar_`x', m

}

// red_flag
replace red_flag = .m if consent != 1 
tab red_flag, m

// red_flag_osp
replace red_flag_osp = ".m" if red_flag != 1
tab red_flag_osp, m


** Savings **
// selected_savings
replace selected_savings = ".m" if consent != 1
tab selected_savings, m

// selected_savings_osp
replace selected_savings_osp = ".m" if selected_savings != "-66" 
tab selected_savings_osp, m

// savings_id
destring savings_id*, replace
tab1 savings_id*

// savings_name
tab1 savings_name*

forvalue x = 1/5 {

	// saving_1
	replace saving_1_`x' = .m if mi(savings_id_`x')
	tab saving_1_`x', m
	
	// check46
	replace check46_`x' = .m if saving_1_`x' <= 10000000 | mi(saving_1_`x')
	tab check46_`x', m

}


** Resilience **
// incomechange
replace incomechange = .m if consent != 1 
tab incomechange, m

// predictamount
replace predictamount = .m if consent != 1 
tab predictamount, m

// emergency
replace emergency = ".m" if consent != 1 
tab emergency, m

// emergency_osp
replace emergency_osp = ".m" if emergency != "-66" 
tab emergency_osp, m

// ft_stop_savings_int
replace ft_stop_savings_int = .m if selected_savings == "-88" | selected_savings == "-99" | selected_savings == "10" | consent != 1 
tab ft_stop_savings_int, m

// ft_stop_savings_units
replace ft_stop_savings_units = .m if ft_stop_savings_int == 0 | mi(ft_stop_savings_int)
tab ft_stop_savings_units, m

// ft_stop_network_int
replace ft_stop_network_int = .m if consent != 1 
tab ft_stop_network_int, m

// ft_stop_network_units
replace ft_stop_network_units =.m if consent != 1 
tab ft_stop_network_units, m

// ft_stop_selling_int
replace ft_stop_selling_int = .m if consent != 1 
tab ft_stop_selling_int, m

// ft_stop_selling_units
replace ft_stop_selling_units = .m if consent != 1 
tab ft_stop_selling_units, m

// accss_poss_1w_rnd1
replace accss_poss_1w_rnd1 = .m if consent != 1 
tab accss_poss_1w_rnd1, m

// accss_diffc_1w_rnd1
replace accss_diffc_1w_rnd1 = .m if accss_poss_1w_rnd1 >= 4 | accss_poss_1w_rnd1 == 0
tab accss_diffc_1w_rnd1, m

// accss_src_1w_rnd1
replace accss_src_1w_rnd1 = ".m" if accss_poss_1w_rnd1 >= 4 | accss_poss_1w_rnd1 == 0
tab accss_src_1w_rnd1, m

// accss_src_1w_rnd1_osp
replace accss_src_1w_rnd1_osp = ".m" if accss_src_1w_rnd1 != "-66"
tab accss_src_1w_rnd1_osp, m

// main_source_event
replace main_source_event = .m if length(accss_src_1w_rnd1) < 3 | accss_src_1w_rnd1 == "-66" | accss_src_1w_rnd1 == "-88"
tab main_source_event, m


** Support network **
// sup_care sup_cook sup_hh sup_care2 sup_transp sup_water sup_farm sup_care3 sup_don
local supnet	sup_care sup_cook sup_hh sup_care2 sup_transp sup_water sup_farm sup_care3 sup_don
foreach var in `supnet' {

	replace `var' = .m if consent != 1 
	tab `var', m
}


** Consumption ** 
forvalue x = 1/20 {

	replace c`x' = .m if consent != 1 
	tab c`x', m
	
	replace c`x'_c = .m if c`x' != 1
	tab c`x'_c, m
	
	replace check`x' = .m if c`x'_c <= 50000 | mi(c`x'_c)
	tab check`x', m
}


** Food outside **
// co121
replace co121 = .m if consent != 1  
tab co121, m

// co121_c
replace co121_c = .m if co121 != 1
tab co121_c, m

// check121
replace check121 = .m if co121_c <= 50000 | mi(co121_c)
tab check121, m

// check121a
replace check121a = .m if co121_c >= 50 
tab check121a, m

// co22
replace co22 = .m if consent != 1  
tab co22, m

// co22_c
replace co22_c = .m if co22 != 1
tab co22_c, m

// check22
replace check22 = .m if co22_c <= 50000 | mi(co22_c)
tab check22, m

// check22a
replace check22a = .m if co22_c >= 50
tab check22a, m


** Randomization 1 **
// present_survey
replace present_survey = ".m" if consent != 1 
tab present_survey, m
 
// present_survey_osp
replace present_survey_osp = ".m" if present_survey != "-66"
tab present_survey_osp, m

** struggles1 **
// struggle_life1
destring random, replace

forvalue x = 1/3 {
	replace struggle_life1_`x' = ".m" if consent != 1 | random > 0.25
	replace struggle_life1_`x' = ".n" if random <= 0.25 & struggle_life1_`x' == ""
	tab struggle_life1_`x' , m
	
	replace struggle_life1_`x'_osp = ".m" if struggle_life1_`x' != "-66"
	tab struggle_life1_`x'_osp, m
}

** Subjective wellbeing **
// w_life1
replace w_life1 = .m if consent != 1 | random > 0.25
replace w_life1 = .n if random <= 0.25 & w_life1 == .
tab w_life1, m

// vignette_m_1
replace vignette_m_1 = .m if consent != 1 | random > 0.125
replace vignette_m_1 = .n if random <= 0.125 & vignette_m_1 == .
tab vignette_m_1, m

// vignette_f_1
replace vignette_f_1 = .m if random > 0.25 | random <= 0.125
replace vignette_f_1 = .n if vignette_f_1 == . & (random <= 0.25 & random > 0.125)
tab vignette_f_1, m


** Randomization 2 **
** Subjective wellbeing **

// w_life2
replace w_life2 = .m if random <= 0.25 | random > 0.5
replace w_life2 = .n if w_life2 == . & (random > 0.25 & random <= 0.5)
tab w_life2, m

// vignette_m_2
replace vignette_m_2 = .m if random > 0.375 | random <= 0.25
replace vignette_m_2 = .n if vignette_m_2 == . & (random <= 0.375 & random > 0.25)
tab vignette_m_2, m

// vignette_f_2
replace vignette_f_2 = .m if random > 0.5 | random <= 0.375
replace vignette_f_2 = .n if vignette_f_2 == . & (random <= 0.5 & random > 0.375)
tab vignette_f_2, m


** Financial education ** 
// self_business
replace self_business = .m if consent != 1 
tab self_business, m

** Business practises ** 
// bus_writtenaccount
replace bus_writtenaccount = .m if self_business != 1
replace bus_writtenaccount = .n if bus_writtenaccount == . & self_business == 1
tab bus_writtenaccount, m

// bus_accounts
replace bus_accounts = ".m" if bus_writtenaccount != 1
tab bus_accounts, m

// bus_sepaccounts
replace bus_sepaccounts = .m if bus_writtenaccount != 1
tab bus_sepaccounts, m

// bus_sepcash
replace bus_sepcash = .m if self_business != 1
replace bus_sepcash = .n if bus_sepcash == . & self_business == 1
tab bus_sepcash, m

// bus_planbusiness
replace bus_planbusiness = .m if self_business != 1
replace bus_planbusiness = .n if bus_planbusiness == . & self_business == 1
tab bus_planbusiness, m

// bus_businessprivate
replace bus_businessprivate = .m if bus_planbusiness != 1
tab bus_businessprivate, m

// bus_source
replace bus_source = ".m" if bus_planbusiness != 1
tab bus_source, m

// bus_source_osp
replace bus_source_osp = ".m" if bus_source != "-66"
tab bus_source_osp, m

// bus_fixedsalary
replace bus_fixedsalary = .m if self_business != 1
replace bus_fixedsalary = .n if bus_fixedsalary == . & self_business == 1
tab bus_fixedsalary, m

// bus_personalexpenses
replace bus_personalexpenses = .m if self_business != 1
replace bus_personalexpenses = .n if bus_personalexpenses == . & self_business == 1
tab bus_personalexpenses, m

// bus_registerexp
replace bus_registerexp = .m if bus_personalexpenses != 1 | bus_writtenaccount != 1
tab bus_registerexp, m

// bus_bussales
replace bus_bussales = .m if self_business != 1
replace bus_bussales = .n if bus_bussales == . & self_business == 1
tab bus_bussales, m

// bus_tallysales
replace bus_tallysales = .m if bus_bussales != 1
tab bus_tallysales, m

// bus_busprofits
replace bus_busprofits = .m if self_business != 1
replace bus_busprofits = .n if bus_busprofits == . & self_business == 1
tab bus_busprofits, m

// bus_profits_how
replace bus_profits_how = .m if bus_busprofits != 1
tab bus_profits_how, m

// bus_profits_how_osp
destring bus_profits_how_osp, replace
replace bus_profits_how_osp = .m if bus_profits_how != -66
tab bus_profits_how_osp, m

// bus_calcprofitfreq
replace bus_calcprofitfreq = .m if bus_busprofits != 1
tab bus_calcprofitfreq, m

// bus_info
replace bus_info = ".m" if self_business != 1
replace bus_info = ".n" if bus_info == "" & self_business == 1
tab bus_info, m
 

** Financial literacy **

// plan_l_12m_frq_prst
replace plan_l_12m_frq_prst = .m if consent != 1 
tab plan_l_12m_frq_prst, m

// plan_l_5y_frq_prst
replace plan_l_5y_frq_prst = .m if consent != 1 
tab plan_l_5y_frq_prst, m

// pickthree
replace pickthree = ".m" if consent != 1 
tab pickthree, m

// hh_budget
replace hh_budget = ".m" if consent != 1 
tab hh_budget, m

// hh_budget_osp
replace hh_budget_osp = ".m" if hh_budget != "1 2 -66"
replace hh_budget_osp = ".n" if hh_budget == "1 2 -66" & hh_budget_osp == "."
tab hh_budget_osp, m

// fin_lit1
replace fin_lit1 = .m if consent != 1 
tab fin_lit1, m

// interest
replace interest = .m if consent != 1 
tab interest, m

// inflation
replace inflation = .m if consent != 1 
tab inflation, m

// interest2
replace interest2 = .m if consent != 1 
tab interest2, m

// savings
replace savings = ".m" if consent != 1 
tab savings, m

// savings_osp
replace savings_osp = ".m" if	savings != "-66" &  savings != "1 5 -66" &  savings != "1 2 -66" & ///
								savings != "1 3 -66" &  savings != "1 6 -66" & savings != "1 8 -66" & ///
								savings != "2 -66" &  savings != "2 3 -66" &  savings != "3 5 -66" & ///
								savings != "5 6 -66" &  savings != "6 -66"
tab savings_osp, m

// savings_place
replace savings_place = .m if consent != 1 
tab savings_place, m

// savings_place_osp
replace savings_place_osp = ".m" if savings_place != -66
tab savings_place_osp, m

// fe_agree1
replace fe_agree1 = .m if consent != 1 
tab fe_agree1, m

// fe_agree3
replace fe_agree3 = .m if consent != 1 
tab fe_agree3, m

// risk_diversification
replace risk_diversification = .m if consent != 1 
tab risk_diversification, m

// helped
replace helped = .m if consent != 1 
tab helped, m


** Social capital ** 
// groups_num
replace groups_num = .m if consent != 1
tab groups_num, m

// leadership
replace leadership = .m if groups_num == 0 | mi(groups_num)
tab leadership, m


** Relationship with family ** 
// care
replace care = .m if consent != 1
tab care, m

// respect
replace respect = .m if consent != 1
tab respect, m

** Trust ** 
// sc_family sc_neighbors sc_friends sc_strangers sc_business sc_bankers sc_borrowers sc_gov
local trust sc_family sc_neighbors sc_friends sc_strangers sc_business sc_bankers sc_borrowers sc_gov

foreach var in `trust' {
	replace `var' = .m if consent != 1
	tab `var', m
}


** Participation into community projects **
// com_project
replace com_project = .m if consent != 1 
tab com_project, m

// com_project_part
replace com_project_part = .m if consent != 1 
tab com_project_part, m

// com_project_num
replace com_project_num = .m if com_project_part != 1 
tab com_project_num, m

** Agency **
// ft_money
replace ft_money = .m if consent != 1 
tab ft_money, m

// ft_item
replace ft_item = .m if consent != 1 
tab ft_item, m

// fam_hh_decisions
replace fam_hh_decisions = .m if consent != 1 
tab fam_hh_decisions, m

// fam_hh_expenses
replace fam_hh_expenses = .m if consent != 1 
tab fam_hh_expenses, m

// ag13
replace ag13 = .m if marital_status != 1 & marital_status != 4
replace ag13 = .n if ag13 == . & (marital_status == 1 | marital_status == 4)
tab ag13, m

// ag14
replace ag14 = .m if ag13 != 1
tab ag14, m

// ag18
replace ag18 = .m if consent != 1 
tab ag18, m

// ag19
replace ag19 = .m if consent != 1 
tab ag19, m

// ag20
replace ag20 = .m if consent != 1 
tab ag20, m

// ag21
replace ag21 = .m if consent != 1 
tab ag21, m

// ag22
replace ag22 = .m if consent != 1 
tab ag22, m


** Motivation to change ** 
// mc1 mc2 mc3 mc5 mc7 grit2 grit4 grit5 grit6 grit7 grit8 grit10
local motive mc1 mc2 mc3 mc5 mc7 grit2 grit4 grit5 grit6 grit7 grit8 grit10 

foreach var in `motive' {
	replace `var' = .m if consent != 1 
	tab `var', m
}


** Vision for the future ** 
// hard_work hopeful ladder_wealth ladder_wealth_future ladder_social ladder_social_future
local vision hard_work hopeful ladder_wealth ladder_wealth_future ladder_social ladder_social_future

foreach var in `vision' {
	replace `var' = .m if consent != 1 
	tab `var', m
}


** Randomization 3 ** 
** struggles3 **

// struggle_life3

forvalue x = 1/3 {
	replace struggle_life3_`x' = ".m" if consent != 1 | random <= 0.5 | random > 0.75
	replace struggle_life3_`x' = ".n" if struggle_life3_`x' == "" & (random > 0.5 & random <= 0.75)
	tab struggle_life3_`x' , m
	
	replace struggle_life3_`x'_osp = ".m" if struggle_life3_`x' != "-66"
	tab struggle_life3_`x'_osp, m
}



** Subjective wellbeing **
// w_life3
replace w_life3 = .m if consent != 1 | random <= 0.5 | random > 0.75
tab w_life3, m

// vignette_m_3
replace vignette_m_3 = .m if consent != 1 | random <= 0.5 | random > 0.625
tab vignette_m_3, m

// vignette_f_3
replace vignette_f_3 = .m if consent != 1 | random <= 0.625 | random > 0.75
tab vignette_f_3, m


** Randomization 4 **
** Subjective wellbeing **

// w_life4
replace w_life4 = .m if consent != 1 | random <= 0.75 | random > 1
tab w_life4, m

// vignette_m_4
replace vignette_m_4 = .m if consent != 1 | random <= 0.75 | random > 0.875
replace vignette_m_4 = .n if vignette_m_4 == . & (random > 0.75 & random <= 0.875)
tab vignette_m_4, m

// vignette_f_4
replace vignette_f_4 = .m if consent != 1 | random <= 0.875 | random > 1
tab vignette_f_4, m

// fu_person 
replace fu_person = ".m" if consent != 1 
tab fu_person, m

// fu_relation 
replace fu_relation = .m if consent != 1 
tab fu_relation, m

// fu_relation_osp
destring fu_relation_osp, replace
replace fu_relation_osp = .m if fu_relation != -66
tab fu_relation_osp, m

//  fu_phone 
replace fu_phone = ".m" if consent != 1 
tab fu_phone, m

// loc_address 
replace loc_address = ".m" if consent != 1
tab loc_address, m

// comment1
replace comment1 = .m if consent != 1 
tab comment1, m

// comment2
replace comment2 = ".m" if comment1 != 1
tab comment2, m

** Observation  **
// ppi_mm_floor1
replace ppi_mm_floor1 = .m if consent != 1 | svy_loc != 1
tab ppi_mm_floor1, m

// ppi_mm_walls1
replace ppi_mm_walls1 = .m if consent != 1 | svy_loc != 1
tab ppi_mm_walls1, m

// roof1
replace roof1 = .m if consent != 1 | svy_loc != 1
tab roof1, m

// roof_osp1
replace roof_osp1 = ".m" if roof1 != -66
tab roof_osp1, m


// scomment
tab scomment, m

// scomment_osp
replace scomment_osp = ".m" if scomment != -66
tab scomment_osp, m

// presence_hh
replace presence_hh = .m if consent != 1
tab presence_hh, m

// presence_who
replace presence_who = ".m" if presence_hh != 1
tab presence_who, m

// presence_who_osp
replace presence_who_osp = ".m" if presence_who !=  "-66"
tab presence_who_osp, m

// gps2
tab gps2, m

// gps2_osp
tab gps2_osp, m

// language
tab language, m

// language_osp
replace language_osp = ".m" if language != "-66"
tab language_osp, m

// like_int
tab like_int, m

// scomment1
tab scomment1, m

// scomment2
replace scomment2 = ".m" if scomment1 != 1
tab scomment2, m


*** DATA CLEANING END HERE ***


save "$BL_HFC/05_data/02_survey/03_Clean_data/S2_Baseline_survey_final_postHFC_IPA.dta", replace

//sssssssssssssssssssssssssssssssssssssssssssssssss
/*
** required additional task
** 1 - translation
** 2 - recoding to existing value category if appropriate
set excelxlsxlargefile on


// export variable for translation
/*
ds, has(type string) 
local strvars "`r(varlist)'"
keep `strvars'
*/

keep *osp* key partid
export excel using "$BL_HFC/04_checks/02_outputs/additional_translation.xlsx", firstrow(var) sheet("to translate") replace
