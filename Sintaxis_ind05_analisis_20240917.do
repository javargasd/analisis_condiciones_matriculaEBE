*************************************
*FED2024-2025:Analisis de condiciones
*************************************
*Indicador05: Porcentaje de personas con discapacidad (PCD) identificados en la BIPED de 0 a 20 años que no han culminado la educación básica y que son matriculados en servicios de educación básica.
*Elaborado por: Javier Vargas Díaz
*Fecha: 06/09/2024


*0. Definición de directorio de trabajo
***************************************
clear all
set more off
global dir "F:\informacion\FED\2. Diseño e implementacion\2. 2024-2025\2024-2025\Definición de metas\diseño\Data\variables"
	global codigo		"$dir\codigo"
	global input		"$dir\input"
	global temp			"$dir\temp"
	global output		"$dir\output"
	global script		"$dir\script"
	global consolidado	"$dir\consolidado" 
	global analisis_ebe	"$dir\analisis_ebe"


*1. OFERTA: N° de vacantes por UBIGEO (varias fuentes)
**********************************************************

	*1.1. Definición de IE potenciales de la EB
	*******************************************
	
		*1.1.0. Padron general
		/*import excel using "$input\Padron_web20240809.xlsx", sheet("Padron_web20240809") firstrow clear
		save "$input\Padron_web20240809.dta", replace*/			
		
		use "$input\Padron_web20240809.dta", clear	
			rename *, low
			drop if anexo!="0"
			*Añadido por javier (se quita a LM)	
			drop if d_region=="DRE LIMA METROPOLITANA" 
			duplicates report cod_mod
			table d_niv_mod, by(niv_mod) concise

			gen 	serv_EB=1 if niv_mod!="K0" & niv_mod!="L0" & niv_mod!="M0" & niv_mod!="P0" & niv_mod!="S0" & niv_mod!="T0"
			keep if serv_EB==1

			run "$script\d_nivel_2024_09_13.do"
			run "$script\d_modalidad_2024_09_13.do"
			tab d_nivel d_modalidad, m
			
			keeporder cod_mod anexo codgeo d_region d_dpto d_prov d_dist codooii niv_mod d_niv_mod serv_EB nivel modalidad d_nivel d_modalidad d_estado tseccion talumno tdocente ges_dep d_ges_dep gestion d_gestion dareacenso tipoprog d_tipoprog area_censo d_cod_car d_forma
				
			sort d_niv_mod
				
		save "$analisis_ebe\ie_servEB_completo.dta", replace	

		use "$analisis_ebe\ie_servEB_completo.dta", clear
			
			drop if d_estado=="Inactiva"	
			tab d_nivel d_modalidad, m

		save "$analisis_ebe\ie_servEB.dta", replace				

		
		*1.1.1 IE EBE
		import excel using "$input\Padron_web_20240809_EBE.xlsx", sheet("Padron_web") firstrow clear
		save "$input\Padron_web20240809_EBE.dta", replace		
		
		use "$input\Padron_web20240809_EBE.dta", clear	
			rename *, low
			drop if anexo!="0"

			gen ie_prite = (tipodeservicioebe == "PRITE")
			gen ie_cebe_inicial = (tipodeservicioebe == "CEBE" & d_niv_mod == "Básica Especial-Inicial")
			gen ie_cebe_primaria = (tipodeservicioebe == "CEBE" & d_niv_mod == "Básica Especial-Primaria")
			gen seccion_prite = (tipodeservicioebe == "PRITE") * tseccion
			gen seccion_ebe_inicial = (tipodeservicioebe == "CEBE" & d_niv_mod == "Básica Especial-Inicial") * tseccion
			gen seccion_ebe_primaria = (tipodeservicioebe == "CEBE" & d_niv_mod == "Básica Especial-Primaria") * tseccion

			foreach var of varlist ie_prite ie_cebe_inicial ie_cebe_primaria seccion_prite seccion_ebe_inicial seccion_ebe_primaria {
				replace `var' = 0 if `var' == .
			}

			duplicates report cod_mod
			duplicates drop cod_mod anexo, force /*0 observations deleted*/

			rename tseccion tseccion_ebe

			merge 1:1 cod_mod using "$analisis_ebe\ie_servEB", keep(1 3) keepusing(serv_EB)
			drop if _merge==1 /*0 observations deleted*/			
			keep cod_mod anexo tipodeservicioebe talumno tseccion_ebe ie_prite ie_cebe_inicial ie_cebe_primaria seccion_prite seccion_ebe_inicial seccion_ebe_primaria codgeo
					
		save "$analisis_ebe\ie_ebe.dta", replace


		*1.1.2. IE que fueron atendidas por SANEE
		import dbase using "$input\SaaNee.dbf", clear
			rename *, low
			drop if anexo!="0"
				
			rename (cod_mod) (cod_SANEE)
			rename (cmod_san ie_san) (cod_mod nomie_atendida)
			
			duplicates report cod_mod
			duplicates drop cod_mod anexo, force /*296 observations deleted*/
			*table niv_san, c(sum docente) row format(%10.0fc)
			gen servicio_atendidoSAANEE=1
				
			merge 1:1 cod_mod using "$analisis_ebe\ie_servEB", keep(1 3) keepusing(codgeo codooii serv_EB d_niv_mod d_estado tseccion d_prov d_dist)
			drop if _merge==1 /*94 observations deleted*/	
			
			rename tseccion tseccion_IEsanee
			
			keeporder cod_mod anexo codgeo codooii serv_EB d_niv_mod tseccion_IEsanee servicio_atendidoSAANEE d_prov d_dist	
				
		save "$analisis_ebe\EB_saaneeATENDIDOS.dta", replace		
			
			
		*1.1.3. IE con docentes EBE
		import excel using "$input\NEXUS_AGOSTO_30_08_2024_V2.xlsx", sheet("Reporte") firstrow clear
		save "$input\NEXUS_AGOSTO_30_08_2024_V2.dta", replace		

		use "$input\NEXUS_AGOSTO_30_08_2024_V2.dta", clear	
			rename *, low
			gen anexo="0"		

			rename codmodce cod_mod

			gen t_docente_EBE = strpos(desctipotrab,"DOCENTE")!=0

			drop if cod_mod=="" /*0 observations deleted*/
			collapse(sum) t_docente_EBE, by(cod_mod)
			
			duplicates report cod_mod
			duplicates drop cod_mod, force /*0 observations deleted*/
			
			merge 1:1 cod_mod using "$analisis_ebe\ie_servEB", keep(1 3) keepusing(serv_EB)
			drop if _merge==1 /*0 observations deleted*/	
			
			keeporder cod_mod t_docente_EBE
			
		save "$analisis_ebe\ie_docentesEBE.dta", replace	

		
		*1.1.4. IE que atendieron estudiantes BIPED (30-06-2024)
		import excel using "$input\20240808_IndicadorMatr BIPED_ReporteLB.xlsx", sheet("Reporte_nominal") firstrow clear
		save "$input\20240808_IndicadorMatr BIPED_ReporteLB.dta", replace		

		use "$input\20240808_IndicadorMatr BIPED_ReporteLB.dta", clear	
			rename *, low
			gen anexo="0"		

			rename cumple pcd_atendidos
			
			drop if cod_mod_siagie==. /*29,725 observations deleted*/
			collapse(sum) pcd_atendidos, by(cod_mod_siagie)
			rename cod_mod_siagie cod_mod
			tostring cod_mod, replace
			replace cod_mod = string(real(cod_mod), "%07.0f")
			
			duplicates report cod_mod
			duplicates drop cod_mod, force /*0 observations deleted*/
		
			merge 1:1 cod_mod using "$analisis_ebe\ie_servEB", keep(1 3) keepusing(serv_EB)
			drop if _merge==1 /*4 observations deleted*/	
			
			keeporder cod_mod pcd_atendidos

		save "$analisis_ebe\ie_atendioBIPED.dta", replace				
	

		*1.1.5. Consolidación
		use "$analisis_ebe\ie_servEB", clear
			drop d_estado talumno ges_dep d_ges_dep gestion d_gestion tipoprog d_tipoprog
			
			* filtro01: servicio EBE		
			merge 1:1 cod_mod using "$analisis_ebe\ie_ebe", gen(m1) keep(1 2 3) keepusing(tipodeservicioebe)
			gen filtro01=1 if m1==3
			drop if m1==2
			drop m1
						
			* filtro02: servicio atendido por SANEE			
			merge 1:1 cod_mod using "$analisis_ebe\EB_saaneeATENDIDOS", gen(m2) keep(1 2 3) keepusing(tseccion_IEsanee)
			gen filtro02=1 if m2==3
			drop if m2==2
			drop m2

			* filtro03: servicio con docentes EBE		
			merge 1:1 cod_mod using "$analisis_ebe\ie_docentesEBE", gen(m3) keep(1 2 3) keepusing(t_docente_EBE)
			gen filtro03=1 if m3==3
			drop if m3==2
			drop m3
			
			* filtro04: servicio que atendio estudiantes EBE	
			merge 1:1 cod_mod using "$analisis_ebe\ie_atendioBIPED", gen(m4) keep(1 2 3) keepusing(pcd_atendidos)
			gen filtro04=1 if m4==3
			drop if m4==2
			drop m4
		
		drop if anexo!="0"


		*1.1.6. IE que podrian atender estudiantes con necesidades especiales
		gen 	ie_potencial=1 if filtro01==1
		replace ie_potencial=1 if filtro02==1
		replace ie_potencial=1 if filtro03==1	
		replace ie_potencial=1 if filtro04==1	
		replace ie_potencial=0 if ie_potencial==.
		
		*bysort d_dpto: ta d_prov ie_potencial, m
		*bysort d_dpto: ta d_prov ie_potencial, m row nofreq
		
			foreach var of varlist filtro01 tseccion_IEsanee filtro02 t_docente_EBE filtro03 pcd_atendidos filtro04 ie_potencial {
				replace `var' = 0 if `var' == .
			}
			
		save "$analisis_ebe\padron_iefinal.dta", replace


	*1.2. Cantidad de vacantes (estudiantes que podrían atender) en las IE potenciales (según el nivel y modalidad)
	***************************************************************************************************************
	
	use "$analisis_ebe\padron_iefinal", clear	
		*order iged region ue tipo_entidad iged_nompropio region_nompropio tipo_entidad_nompropio macroregion_nompropio		
		replace pcd_atendidos=0 if pcd_atendidos==.
		
		* Generamos la variable vacantes_potenciales, que indica cuantas vacantes estarian disponibles para atender a PCD de 0 a 20 años
			gen  vacantes_potenciales=.
			
			* normativa
			sort t_docente_EBE
			replace tdocente=t_docente_EBE if t_docente_EBE>tdocente
			
			tab tipodeservicioebe niv_mod
			
			replace vacantes_potenciales= 6  * tdocente if ie_potencial==1 & tipodeservicioebe=="CEBE" & niv_mod=="E1"
			replace vacantes_potenciales= 8  * tdocente if ie_potencial==1 & tipodeservicioebe=="CEBE" & niv_mod=="E2"
			replace vacantes_potenciales= 12 * tdocente if ie_potencial==1 & tipodeservicioebe=="PRITE"
			
				*br if tdocente==0 & ie_potencial==1 & tipodeservicioebe=="CEBE" & niv_mod=="E1"
				*br if tdocente==0 & ie_potencial==1 & tipodeservicioebe=="CEBE" & niv_mod=="E2"
				*br if tdocente==0 & ie_potencial==1 & tipodeservicioebe=="PRITE"
			
			*ajuste para aquellos casos donde las vacantes potenciales son cero
			replace vacantes_potenciales= 6 			if ie_potencial==1 & tipodeservicioebe=="CEBE" & niv_mod=="E1" & 	vacantes_potenciales==0	
			replace vacantes_potenciales= 8				if ie_potencial==1 & tipodeservicioebe=="CEBE" & niv_mod=="E2" & 	vacantes_potenciales==0	
			replace vacantes_potenciales= 12			if ie_potencial==1 & tipodeservicioebe=="PRITE" & niv_mod=="E0" & vacantes_potenciales==0	
			replace vacantes_potenciales= 0				if vacantes_potenciales==.
			rename codgeo ubigeo
			
			* En las IE potenciales se atenderá como mínimo a la misma cantidad de PCD que ya se atendió
			replace vacantes_potenciales= pcd_atendidos if pcd_atendidos>vacantes_potenciales & ie_potencial==1
			
			
		*Ajuste 1 plaza por niveles (incluido por Javier)
			*Inicial
			replace vacantes_potenciales=2 if ie_potencial==0 & d_modalidad=="EBR" & d_nivel=="Inicial" 
			*& d_forma=="Escolarizada" & area_censo=="1"
			
			*Primaria
			replace vacantes_potenciales=2 if ie_potencial==0 & d_modalidad=="EBR" & d_nivel=="Primaria" 
			
			*& (d_cod_car=="Polidocente completa" | d_cod_car=="Polidocente Multigrado") & area_censo=="1"			
			*Secundaria
			replace vacantes_potenciales=2 if ie_potencial==0 & d_modalidad=="EBR" & d_nivel=="Secundaria" 
			*& area_censo=="1" & d_cod_car=="No aplica"
			
		collapse (sum) serv_EB pcd_atendidos ie_potencial vacantes_potenciales, by(ubigeo d_dpto d_prov d_dist d_nivel d_modalidad)
		table d_dpto, c(sum serv_EB sum pcd_atendidos sum ie_potencial sum vacantes_potenciales) format(%7.0fc) row

	save "$analisis_ebe\vacantes_potencial_nivel_mod_IE.dta", replace


*2. DEMANDA: N° de personas con PCD por UBIGEO (BIPED)
******************************************************

use "$input\20240808_IndicadorMatr BIPED_ReporteLB.dta", clear	

	gen anexo="0"
	rename (cumple no_cumple total) (tot_pcd_atend tot_pcd_no_atend tot_pcd)

	tab RESULTADO tot_pcd_atend, m

	merge 1:1 DNI using "$input\2024_02_21_DEBE_BIPED.dta", keepusing(FE_NACIMIENTO_RE GRAVEDAD_DISCAPACIDAD) keep(1 3) nogen
	rename *, low
	drop region
	
save "$temp\20240808_IndicadorMatr BIPED_ReporteLB_edit.dta", replace


	*2.1. PCD matriculados en el 2024 (según el nivel y modalidad que necesitan en el año escolar 2024)
	***************************************************************************************************
		
		*2.2.1. PCD matriculados en el 2024 - Continuidad, Reinserción y Acceso (matriculados en el 2024)
		use "$temp\20240808_IndicadorMatr BIPED_ReporteLB_edit.dta", clear	

			keep if tot_pcd_atend==1 & (resultado=="CONTINUIDAD" | resultado=="REINSERCION" | resultado=="ACCESO")

			rename cod_mod_siagie cod_mod
			tostring cod_mod, replace
			replace cod_mod = string(real(cod_mod), "%07.0f")

			merge m:1 cod_mod anexo using "$analisis_ebe\ie_servEB_completo", keepusing(d_nivel d_modalidad) keep(1 3)
			*table d_niv_mod_siagie gravedad_discapacidad, row column
			*table dsc_grado_biped, by(d_niv_mod_siagie) concise

			* Generamos la modalidad y el nivel demandado por la PCD
			rename (d_nivel d_modalidad) (demd_nivel demd_modalidad)
			tab demd_nivel demd_modalidad, m
			
			*table departamento_re, c(sum tot_pcd_atend) format(%7.0fc) row m
			*table demd_nivel demd_modalidad, c(sum tot_pcd_atend) format(%7.0fc) row colum m
			collapse (sum) tot_pcd_atend, by(ubigeo_re departamento_re provincia_re distrito_re demd_nivel demd_modalidad)
			
		save "$temp\BIPED_matr_cont_rein_acce.dta", replace
		

	*2.2. PCD no matriculados en el 2024 (según el nivel y modalidad que necesitan en el año escolar 2024)
	******************************************************************************************************

		*2.2.1. PCD no matriculados en el 2024 - Continuidad (matriculados en el 2023)
		use "$temp\20240808_IndicadorMatr BIPED_ReporteLB_edit.dta", clear	

			keep if tot_pcd_no_atend==1 & resultado=="CONTINUIDAD"

			rename cod_mod_biped cod_mod
			tostring cod_mod, replace
			replace cod_mod = string(real(cod_mod), "%07.0f")

			merge m:1 cod_mod anexo using "$analisis_ebe\ie_servEB_completo", keepusing(d_nivel d_modalidad) keep(1 3)
			*table d_niv_mod_siagie gravedad_discapacidad, row column
			*table dsc_grado_biped, by(d_niv_mod_siagie) concise

			tab d_nivel d_modalidad, m

			* Generamos la modalidad demandada por la PCD
			gener demd_modalidad=d_modalidad

			* Generamos el nivel demandado por la PCD
			gener demd_nivel=""
			
				* EBR: Se asigna el siguiente nivel a los que aprobaron el último grado del nivel
				tab dsc_grado_biped	sf_regular_biped if d_nivel=="Inicial" & d_modalidad=="EBR"
				replace demd_nivel="Primaria" if d_nivel=="Inicial" & d_modalidad=="EBR" & (dsc_grado_biped=="5 AÑOS" | dsc_grado_biped=="GRUPO 5 AÑOS") & sf_regular_biped!=""
				replace demd_nivel="Inicial" if d_nivel=="Inicial" & d_modalidad=="EBR" & demd_nivel==""
			
				tab dsc_grado_biped sf_regular_biped if d_nivel=="Primaria" & d_modalidad=="EBR"
				replace demd_nivel="Secundaria" if d_nivel=="Primaria" & d_modalidad=="EBR" & (dsc_grado_biped=="SEXTO") & sf_regular_biped=="APROBADO"
				replace demd_nivel="Primaria" if d_nivel=="Primaria" & d_modalidad=="EBR" & demd_nivel==""

				tab dsc_grado_biped sf_regular_biped if d_nivel=="Secundaria" & d_modalidad=="EBR"
				replace demd_nivel="Egresado" if d_nivel=="Secundaria" & d_modalidad=="EBR" & (dsc_grado_biped=="QUINTO") & sf_regular_biped=="APROBADO"
				replace demd_nivel="Secundaria" if d_nivel=="Secundaria" & d_modalidad=="EBR" & demd_nivel==""

				tab demd_nivel d_nivel if d_modalidad=="EBR", m

				* EBA: Se asigna el siguiente nivel a los que aprobaron el último grado del nivel
				tab dsc_grado_biped sf_regular_biped if d_nivel=="Primaria" & d_modalidad=="EBA"
				replace demd_nivel="Secundaria" if d_nivel=="Primaria" & d_modalidad=="EBA" & (dsc_grado_biped=="INTERMEDIO TERCERO") & sf_regular_biped=="APROBADO"
				replace demd_nivel="Primaria" if d_nivel=="Primaria" & d_modalidad=="EBA" & demd_nivel==""

				tab dsc_grado_biped sf_regular_biped if d_nivel=="Secundaria" & d_modalidad=="EBA"
				replace demd_nivel="Egresado" if d_nivel=="Secundaria" & d_modalidad=="EBA" & (dsc_grado_biped=="AVANZADO QUINTO") & sf_regular_biped=="APROBADO"
				replace demd_nivel="Secundaria" if d_nivel=="Secundaria" & d_modalidad=="EBA" & demd_nivel==""

				tab demd_nivel d_nivel if d_modalidad=="EBA", m

				* EBE: Se asigna el siguiente nivel a los que aprobaron el último grado del nivel
				tab dsc_grado_biped	sf_regular_biped if d_nivel=="Inicial" & d_modalidad=="EBE"
				replace demd_nivel="Primaria" if d_nivel=="Inicial" & d_modalidad=="EBE" & (dsc_grado_biped=="5 AÑOS") & sf_regular_biped!=""
				replace demd_nivel="Inicial" if d_nivel=="Inicial" & d_modalidad=="EBE" & demd_nivel==""
			
				tab dsc_grado_biped sf_regular_biped if d_nivel=="Primaria" & d_modalidad=="EBE"
				replace demd_nivel="Egresado" if d_nivel=="Primaria" & d_modalidad=="EBE" & (dsc_grado_biped=="PRIMARIA SEXTO") & sf_regular_biped=="APROBADO"
				replace demd_nivel="Primaria" if d_nivel=="Primaria" & d_modalidad=="EBE" & demd_nivel==""

				tab demd_nivel d_nivel if d_modalidad=="EBE", m

			*table departamento_re, c(sum tot_pcd_no_atend) format(%7.0fc) row m
			*table demd_nivel demd_modalidad, c(sum tot_pcd_no_atend) format(%7.0fc) row colum m
			collapse (sum) tot_pcd_no_atend, by(ubigeo_re departamento_re provincia_re distrito_re demd_nivel demd_modalidad)
			rename tot_pcd_no_atend tot_pcd_no_atend_cont

		save "$temp\BIPED_no_matr_cont.dta", replace


		*2.2.2. PCD no matriculados en el 2024 - Reinserción (matriculados en años previos al 2023)
		use "$temp\20240808_IndicadorMatr BIPED_ReporteLB_edit.dta", clear	

			keep if tot_pcd_no_atend==1 & resultado=="REINSERCION"

			rename cod_mod_biped cod_mod
			tostring cod_mod, replace
			replace cod_mod = string(real(cod_mod), "%07.0f")

			merge m:1 cod_mod anexo using "$analisis_ebe\ie_servEB_completo", keepusing(d_nivel d_modalidad) keep(1 3)
			*table d_niv_mod_siagie gravedad_discapacidad, row column
			*table dsc_grado_biped, by(d_niv_mod_siagie) concise

			tab d_nivel d_modalidad, m

			* Generamos la modalidad demandada por la PCD
			gener demd_modalidad=d_modalidad

			* Generamos el nivel demandado por la PCD
			gener demd_nivel=""
			
				* EBR: Se asigna el siguiente nivel a los que aprobaron el último grado del nivel
				tab dsc_grado_biped	sf_regular_biped if d_nivel=="Inicial" & d_modalidad=="EBR"
				replace demd_nivel="Primaria" if d_nivel=="Inicial" & d_modalidad=="EBR" & (dsc_grado_biped=="5 AÑOS" | dsc_grado_biped=="GRUPO 5 AÑOS") & sf_regular_biped!=""
				replace demd_nivel="Inicial" if d_nivel=="Inicial" & d_modalidad=="EBR" & demd_nivel==""
			
				tab dsc_grado_biped sf_regular_biped if d_nivel=="Primaria" & d_modalidad=="EBR"
				replace demd_nivel="Secundaria" if d_nivel=="Primaria" & d_modalidad=="EBR" & (dsc_grado_biped=="SEXTO") & sf_regular_biped=="APROBADO"
				replace demd_nivel="Primaria" if d_nivel=="Primaria" & d_modalidad=="EBR" & demd_nivel==""

				tab dsc_grado_biped sf_regular_biped if d_nivel=="Secundaria" & d_modalidad=="EBR"
				replace demd_nivel="Egresado" if d_nivel=="Secundaria" & d_modalidad=="EBR" & (dsc_grado_biped=="QUINTO") & sf_regular_biped=="APROBADO"
				replace demd_nivel="Secundaria" if d_nivel=="Secundaria" & d_modalidad=="EBR" & demd_nivel==""

				tab demd_nivel d_nivel if d_modalidad=="EBR", m

				* EBA: Se asigna el siguiente nivel a los que aprobaron el último grado del nivel
				tab dsc_grado_biped sf_regular_biped if d_nivel=="Primaria" & d_modalidad=="EBA"
				replace demd_nivel="Secundaria" if d_nivel=="Primaria" & d_modalidad=="EBA" & (dsc_grado_biped=="INTERMEDIO TERCERO") & sf_regular_biped=="APROBADO"
				replace demd_nivel="Primaria" if d_nivel=="Primaria" & d_modalidad=="EBA" & demd_nivel==""

				tab dsc_grado_biped sf_regular_biped if d_nivel=="Secundaria" & d_modalidad=="EBA"
				replace demd_nivel="Egresado" if d_nivel=="Secundaria" & d_modalidad=="EBA" & (dsc_grado_biped=="AVANZADO QUINTO") & sf_regular_biped=="APROBADO"
				replace demd_nivel="Secundaria" if d_nivel=="Secundaria" & d_modalidad=="EBA" & demd_nivel==""

				tab demd_nivel d_nivel if d_modalidad=="EBA", m

				* EBE: Se asigna el siguiente nivel a los que aprobaron el último grado del nivel
				tab dsc_grado_biped	sf_regular_biped if d_nivel=="Inicial" & d_modalidad=="EBE"
				replace demd_nivel="Primaria" if d_nivel=="Inicial" & d_modalidad=="EBE" & (dsc_grado_biped=="5 AÑOS") & sf_regular_biped!=""
				replace demd_nivel="Inicial" if d_nivel=="Inicial" & d_modalidad=="EBE" & demd_nivel==""
			
				tab dsc_grado_biped sf_regular_biped if d_nivel=="Primaria" & d_modalidad=="EBE"
				replace demd_nivel="Egresado" if d_nivel=="Primaria" & d_modalidad=="EBE" & (dsc_grado_biped=="PRIMARIA SEXTO") & sf_regular_biped=="APROBADO"
				replace demd_nivel="Primaria" if d_nivel=="Primaria" & d_modalidad=="EBE" & demd_nivel==""

				tab demd_nivel d_nivel if d_modalidad=="EBE", m

			*table departamento_re, c(sum tot_pcd_no_atend) format(%7.0fc) row m
			*table demd_nivel demd_modalidad, c(sum tot_pcd_no_atend) format(%7.0fc) row colum m
			collapse (sum) tot_pcd_no_atend, by(ubigeo_re departamento_re provincia_re distrito_re demd_nivel demd_modalidad)
			rename tot_pcd_no_atend tot_pcd_no_atend_rein

		save "$temp\BIPED_no_matr_rein.dta", replace


		*2.2.3. PCD no matriculados en el 2024 - Acceso (nunca se matricularon)
		use "$temp\20240808_IndicadorMatr BIPED_ReporteLB_edit.dta", clear	

			keep if tot_pcd_no_atend==1 & resultado=="ACCESO"

			tab edad_cumplida gravedad_discapacidad, m

			/*summarize edad_cumplida, detail
			local corte1 = 7
			local corte2 = 13
			histogram edad_cumplida if (gravedad_discapacidad=="Leve o Moderado" | gravedad_discapacidad=="Severo"), ///
				discrete frequency lcolor(black) lwidth(medium) addlabels ///
				xline(`corte1', lcolor(green) lpattern(dash) lwidth(medium)) ///
				xline(`corte2', lcolor(red) lpattern(dash) lwidth(medium)) ///
				xtitle("Edad de la PCD") ytitle("N° de la PCD") by(gravedad_discapacidad)*/
			
			* Generamos la modalidad y el nivel demandado por la PCD
			gen demd_modalidad=""
			gen demd_nivel=""
			
				* EBR inicial   : Leve o moderado -  0 a  6 años
				replace demd_modalidad="EBR"	if edad_cumplida<=6	& gravedad_discapacidad=="Leve o Moderado"
				replace demd_nivel="Inicial"	if edad_cumplida<=6	& gravedad_discapacidad=="Leve o Moderado"
				* EBR primaria  : Leve o moderado -  7 a 12 años
				replace demd_modalidad="EBR"	if edad_cumplida>=7	& edad_cumplida<=12 & gravedad_discapacidad=="Leve o Moderado"
				replace demd_nivel="Primaria"	if edad_cumplida>=7	& edad_cumplida<=12 & gravedad_discapacidad=="Leve o Moderado"
				* EBR secundaria: Leve o moderado - 13 a 18 años
				replace demd_modalidad="EBR" 	if edad_cumplida>=13 & edad_cumplida<=18 & gravedad_discapacidad=="Leve o Moderado"
				replace demd_nivel="Secundaria" if edad_cumplida>=13 & edad_cumplida<=18 & gravedad_discapacidad=="Leve o Moderado"

				* EBA primaria  : Leve o moderado -  19 a 20 años
				replace demd_modalidad="EBA"	if edad_cumplida>=19 & edad_cumplida<=20 & gravedad_discapacidad=="Leve o Moderado"
				replace demd_nivel="Primaria"	if edad_cumplida>=19 & edad_cumplida<=20 & gravedad_discapacidad=="Leve o Moderado"

				* EBE inicial   : Severo -  0 a  6 años
				replace demd_modalidad="EBE"	if edad_cumplida<=6	& (gravedad_discapacidad=="Severo" | gravedad_discapacidad=="No especifica")
				replace demd_nivel="Inicial"	if edad_cumplida<=6	& (gravedad_discapacidad=="Severo" | gravedad_discapacidad=="No especifica")
				* EBE primaria  : Severo -  7 a 20 años
				replace demd_modalidad="EBE"	if edad_cumplida>=7	& (gravedad_discapacidad=="Severo" | gravedad_discapacidad=="No especifica")
				replace demd_nivel="Primaria"	if edad_cumplida>=7	& (gravedad_discapacidad=="Severo" | gravedad_discapacidad=="No especifica")
				
			*table departamento_re, c(sum tot_pcd_no_atend) format(%7.0fc) row m
			*table demd_nivel demd_modalidad, c(sum tot_pcd_no_atend) format(%7.0fc) row colum m
			collapse (sum) tot_pcd_no_atend, by(ubigeo_re departamento_re provincia_re distrito_re demd_nivel demd_modalidad)
			rename tot_pcd_no_atend tot_pcd_no_atend_acce

		save "$temp\BIPED_no_matr_acce.dta", replace


	*2.3. Cantidad de PCDestudiantes que podrían atender las IE potenciales (según el nivel y modalidad)
	****************************************************************************************************
	
	use "$temp\BIPED_matr_cont_rein_acce.dta", clear
	append using "$temp\BIPED_no_matr_cont.dta"
	append using "$temp\BIPED_no_matr_rein.dta"
	append using "$temp\BIPED_no_matr_acce.dta"

	collapse (sum) tot_pcd_atend tot_pcd_no_atend_cont tot_pcd_no_atend_rein tot_pcd_no_atend_acce, by(ubigeo_re departamento_re provincia_re distrito_re demd_nivel demd_modalidad)
	gen	vacantes_demandadas= tot_pcd_atend + tot_pcd_no_atend_cont + tot_pcd_no_atend_rein + tot_pcd_no_atend_acce
	*table departamento_re, c(sum tot_pcd_atend sum tot_pcd_no_atend_cont sum tot_pcd_no_atend_rein sum tot_pcd_no_atend_acce) format(%7.0fc) row m
	
	rename (ubigeo_re demd_nivel demd_modalidad) (ubigeo d_nivel d_modalidad)

	save "$analisis_ebe\vacantes_demandadas_nivel_mod_IE.dta", replace


*3. OFERTA Y DEMANDA: N° de vacantes y N° de personas con PCD por UBIGEO, NIVEL y MODALIDAD
*******************************************************************************************

use "$analisis_ebe\vacantes_potencial_nivel_mod_IE", clear
drop if d_prov=="LIMA"
merge 1:1 ubigeo d_nivel d_modalidad using "$analisis_ebe\vacantes_demandadas_nivel_mod_IE.dta"
	
	keeporder ubigeo d_dpto d_prov d_dist d_nivel d_modalidad serv_EB ie_potencial vacantes_potenciales vacantes_demandadas _merge

			foreach var of varlist serv_EB ie_potencial vacantes_potenciales vacantes_demandadas {
				replace `var' = 0 if `var' == .
			}	
	
	merge m:m ubigeo using "$analisis_ebe\vacantes_potencial_nivel_mod_IE.dta", keepusing(d_dpto d_prov d_dist) nogen update
	
	gen		matricula_max=vacantes_potenciales if vacantes_potenciales<vacantes_demandadas
	replace matricula_max=vacantes_demandadas if vacantes_potenciales>=vacantes_demandadas
	
	* Reportes
	table d_dpto if d_prov!="LIMA", c(sum vacantes_demandadas sum vacantes_potenciales sum matricula_max) format(%7.0fc) row colum m
	
	*Se quita a LM (incluido por Javier)
	br if d_prov=="LIMA"
	drop if d_prov=="LIMA"
	
	collapse (sum) vacantes_potenciales vacantes_demandadas matricula_max, by(d_dpto)
	
save "$analisis_ebe\analisis_oferta_demanda", replace	

*Revisión con linea de base (incluido por Javier)
import excel using "$input\20240808_IndicadorMatr BIPED_ReporteLB.xlsx", sheet("Reporte_DRE") cellrange("B6:E31")firstrow clear
		rename (DRE Cumple Nocumple Total) (d_dpto tot_pcd_atend tot_pcd_no_atend total_pcd)
		merge 1:1 d_dpto using "$analisis_ebe\analisis_oferta_demanda", nogen
		
		gen linea_base=100*(tot_pcd_atend/total_pcd)
		gen valor_esperadomax=100*(matricula_max/vacantes_demandadas)	
		
		order d_dpto tot_pcd_atend tot_pcd_no_atend total_pcd linea_base
		
		gen difere_atencion=tot_pcd_atend-matricula_max
		sort difere_atencion

		gen dif_por=valor_esperadomax-linea_base
		sort dif_por
		table d_dpto, c(sum tot_pcd_atend sum tot_pcd_no_atend sum total_pcd sum vacantes_demandadas sum matricula_max) format(%7.0fc) row colum m