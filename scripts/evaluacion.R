library(tidyverse)
library(openxlsx)
library(extrafont)
# font_import() # use this function first if R was updated
loadfonts(device = "win")

prmtrs <- edit(prmtrs)

#### general prices and yields updater ####
yld_nal_est <- agt_nal %>%
  filter(anio %in% c(2014:2018), idmodalidad != 2) %>% 
  summarise(yld_nal = sum(volumenproduccion * rendimiento) / sum(volumenproduccion))

yld_nal_ini <- 0.375 * yld_nal_est

prmtrs[prmtrs$clave == "pdn_yini", "Magnitud"] <- yld_nal_ini
prmtrs[prmtrs$clave == "pdn_yesta", "Magnitud"] <- yld_nal_est

pmr_nal <- agt_nal %>% 
  filter(anio %in% c(2014:2018), idmodalidad != 2) %>% 
  summarise(pmr_nal = sum(volumenproduccion * preciomediorural) / sum(volumenproduccion))

prmtrs[prmtrs$clave == "com_p_nal", "Magnitud"] <- pmr_nal / 1000

#### ejecucion ####
mod_fin(prmtrs)

md_fn_10 <- mod_fin(prmtrs)
md_fn_xl <- mod_fin(prmtrs)
#### moving to excel ####
wb <- createWorkbook()
modifyBaseFont(wb, fontSize = 9, fontName = "Lato")

addWorksheet(wb, sheetName = "prmtrs", gridLines = FALSE)
setColWidths(wb, "prmtrs", cols = 1:100, widths = 10)
addWorksheet(wb, sheetName = "fin_esq", gridLines = FALSE)
setColWidths(wb, "fin_esq", cols = 1:100, widths = 10)
addWorksheet(wb, sheetName = "flujo", gridLines = FALSE)
setColWidths(wb, "flujo", cols = 1:100, widths = 10)
addWorksheet(wb, sheetName = "edos_fin", gridLines = FALSE)
setColWidths(wb, "edos_fin", cols = 1:100, widths = 10)

headSty <- createStyle(halign = "center", border = "bottom", borderColour = "yellowgreen",
                       borderStyle = "medium", textDecoration = "bold")

writeData(wb, sheet = "prmtrs", x = prmtrs %>% arrange(clave),
          startCol = "E", startRow = 10, headerStyle = headSty,
          borders = "rows", borderColour = "grey95", borderStyle = "thin")
ubicacion <- 10 + nrow(prmtrs) + 5
writeData(wb, sheet = "prmtrs", x = md_fn_xl$inv, startCol = "E",
          startRow = ubicacion, headerStyle = headSty,
          borders = "rows", borderColour = "grey95", borderStyle = "thin")
ubicacion <- ubicacion + nrow(md_fn_xl$inv) + 5
writeData(wb, sheet = "prmtrs", x = md_fn_xl$costos, startCol = "E",
          startRow = ubicacion, headerStyle = headSty,
          borders = "rows", borderColour = "grey95", borderStyle = "thin")

writeData(wb, sheet = "fin_esq", x = md_fn_xl$sch_apy, startCol = "E",
          startRow = 10, headerStyle = headSty, borders = "rows",
          borderColour = "grey95", borderStyle = "thin")
ubicacion <- 10 + nrow(md_fn_xl$sch_apy) + 5
writeData(wb, sheet = "fin_esq", x = md_fn_xl$sch_apy_pct, startCol = "E",
          startRow = ubicacion, headerStyle = headSty, borders = "rows",
          borderColour = "grey95", borderStyle = "thin")
ubicacion <- ubicacion + nrow(md_fn_xl$sch_apy_pct) + 5
writeData(wb, sheet = "fin_esq", x = md_fn_xl$sch_gral, startCol = "E",
          startRow = ubicacion, headerStyle = headSty, borders = "rows",
          borderColour = "grey95", borderStyle = "thin")
ubicacion <- ubicacion + nrow(md_fn_xl$sch_gral) + 5
writeData(wb, sheet = "fin_esq", x = md_fn_xl$loan, startCol = "E",
          startRow = ubicacion, headerStyle = headSty, borders = "rows",
          borderColour = "grey95", borderStyle = "thin")

writeData(wb, sheet = "flujo", x = md_fn_xl$flujo, startCol = "E",
          startRow = 10, headerStyle = headSty, borders = "rows",
          borderColour = "grey95", borderStyle = "thin")
ubicacion <- 10 + nrow(md_fn_xl$flujo) + 5
writeData(wb, sheet = "flujo", x = md_fn_xl$ind_fin %>% gather(key = "indicador", value = "Magnitud"),
          startCol = "E", startRow = ubicacion, headerStyle = headSty,
          borders = "rows", borderColour = "grey95", borderStyle = "thin")
ubicacion <- ubicacion + nrow(md_fn_xl$ind_fin %>% gather(key = "indicador", value = "Magnitud")) + 5
writeData(wb, sheet = "flujo", x = md_fn_xl$sens,
          startCol = "E", startRow = ubicacion, headerStyle = headSty,
          borders = "rows", borderColour = "grey95", borderStyle = "thin")
ubicacion <- ubicacion + nrow(md_fn_xl$sens) + 5
writeData(wb, sheet = "flujo", x = md_fn_xl$prob_van_interval,
          startCol = "E", startRow = ubicacion, headerStyle = headSty,
          borders = "rows", borderColour = "grey95", borderStyle = "thin")

writeData(wb, sheet = "edos_fin", x = md_fn_xl$est_res, startCol = "E",
          startRow = 10, headerStyle = headSty, borders = "rows",
          borderColour = "grey95", borderStyle = "thin")
ubicacion <- 10 + nrow(md_fn_xl$est_res) + 5
writeData(wb, sheet = "edos_fin", x = md_fn_xl$est_fc,
          startCol = "E", startRow = ubicacion, headerStyle = headSty,
          borders = "rows", borderColour = "grey95", borderStyle = "thin")
ubicacion <- ubicacion + nrow(md_fn_xl$est_fc) + 5
writeData(wb, sheet = "edos_fin", x = md_fn_xl$est_sf,
          startCol = "E", startRow = ubicacion, headerStyle = headSty,
          borders = "rows", borderColour = "grey95", borderStyle = "thin")

saveWorkbook(wb, "~/OneDrive/R/evaluaciones/aguacate/test.xlsx", overwrite = TRUE)


#### genarated functions ####
# inputs updater: necesary for changes in parameters
inputs_updt <- function(prmtrs) {
  
  # creating a list from the dataframe to ease the manipulation of parameters
  prm <- list()
  for(i in 1:nrow(prmtrs)) {
    prm[[i]] <- data.frame(prmtrs[i,], stringsAsFactors = F)
    names(prm)[i] <- prmtrs[i,"clave"]
  }
  
  # ejemplo de uso individual
  #prm$pdn_ini$Magnitud
  
  
  # preparing costs to be added to the cash flow
  costos_mxp <- prmtrs %>% 
    filter(Categoría %in% c("cv", "cf")) %>%
    mutate(Magnitud = if_else(Categoría == "cv", Magnitud * cv_fun(prm$pdn_sup$Magnitud, prmtrs) / sum(Magnitud), Magnitud)) %>% 
    mutate(Magnitud = Magnitud * prm$pdn_sup$Magnitud,
           UM = "mxp")
  
  # preparing capital expenses (inversiones) to be added to the cash flow
  inv_mxp <- prmtrs %>% 
    filter(Categoría == "inv") %>% 
    mutate(Magnitud = if_else(UM == "mxp/ha", Magnitud * prm$pdn_sup$Magnitud, Magnitud)) %>% 
    mutate(Magnitud = if_else(UM == "mxp/planta", Magnitud * prm$pdn_sup$Magnitud * prm$pdn_dens$Magnitud, Magnitud)) %>% 
    mutate(UM = "mxp") %>% 
    mutate_if(is.factor, as.character)
  
  inv <- list()
  for(i in 1:nrow(inv_mxp)) {
    inv[[i]] <- data.frame(inv_mxp[i,], stringsAsFactors = F)
    names(inv)[i] <- inv_mxp[i,"clave"]
  }
  
  fl_inv_mxp <- data.frame(periodo = 0:prm$eval_hrz$Magnitud)
  for(i in 1:nrow(inv_mxp)) {
    fl_inv_mxp[,stringr::str_extract(inv_mxp$Concepto[i], "([a-z|A-Z]){4}")] <- inv_mxp$Magnitud[i]
  }
  fl_inv_mxp <- fl_inv_mxp %>% 
    mutate_at(vars(-periodo), ~if_else(periodo == 0, ., 0)) %>% 
    mutate(total = rowSums(select(., -periodo)))
  
  
  # financial scheme
  sch_apy_mxp <- inv_mxp %>%
    filter(subcat1 == "suj_apoyo") %>% 
    select(subcat2, Magnitud) %>% 
    magrittr::set_colnames(c("concepto", "total")) %>% 
    mutate(apoyo = if_else(concepto == "infra", if_else((total * prm$fin_tpctj_inf$Magnitud) > prm$fin_tmto_inf$Magnitud,
                                                        prm$fin_tmto_inf$Magnitud, total * prm$fin_tpctj_inf$Magnitud), 
                           if_else((total * prm$fin_tpctj_equ$Magnitud) > prm$fin_tmto_equ$Magnitud,
                                   prm$fin_tmto_equ$Magnitud, total * prm$fin_tpctj_equ$Magnitud)),
           credito = if_else((total * prm$fin_monto$Magnitud + apoyo) > total, total - apoyo, total * prm$fin_monto$Magnitud),
           aportacion = total - apoyo - credito) %>%
    group_by(concepto) %>% 
    summarise_all(~sum(.)) %>%
    gather(-concepto, key = "fuente", value = "mxp") %>% 
    spread(concepto, mxp) %>% 
    mutate(total = rowSums(select(., -fuente)))
  
  sch_apy_pctj <- sch_apy_mxp %>%
    mutate_at(vars(-fuente), ~./max(.))
  
  sch_gral_mxp <-  data.frame(credito = inv_mxp %>%
                                filter(subcat1 == "suj_cred") %>%
                                summarise(sum(Magnitud)) %>%
                                pull() * prm$fin_monto$Magnitud + sch_apy_mxp %>% filter(fuente == "credito") %>% select(total) %>% pull(),
                              apoyo = sch_apy_mxp %>% filter(fuente == "apoyo") %>% select(total) %>% pull()) %>% 
    mutate(aportacion = sum(inv_mxp$Magnitud) - credito - apoyo) %>% 
    gather(key = "fuente", value = "mxp") %>% 
    mutate(pct = mxp / sum(mxp))
  
  fl_sch_mxp <- data.frame(periodo = 0:prm$eval_hrz$Magnitud) %>% 
    mutate(aportacion = if_else(periodo == 0, sch_gral_mxp %>% filter(fuente == "aportacion") %>% select(mxp) %>% pull(), 0),
           credito = if_else(periodo == 0, sch_gral_mxp %>% filter(fuente == "credito") %>% select(mxp) %>% pull(), 0),
           apoyo = if_else(periodo == 0, sch_gral_mxp %>% filter(fuente == "apoyo") %>% select(mxp) %>% pull(), 0))
  
  # loan taken
  loan <- data.frame(mes = 0:prm$fin_plz$Magnitud) %>%
    mutate(periodo = c(0, rep(1:(prm$fin_plz$Magnitud / 12), each = 12))) %>% 
    mutate(saldo_ini = 0,
           interes = 0,
           pago = 0,
           amort = 0,
           saldo_fin = sch_gral_mxp[sch_gral_mxp$fuente == "credito", "mxp"])
  if(prm$fin_monto$Magnitud != 0) {
    if(prm$fin_pgr$Magnitud != 0) {
      for(i in 2:(prm$fin_pgr$Magnitud + 1)) {
        loan$saldo_ini[i] <- loan$saldo_fin[i - 1]
        loan$interes[i] <- loan$saldo_fin[i - 1] * (prm$fin_tf$Magnitud/12)
        loan$saldo_fin[i] <- loan$saldo_ini[i]
      }
      for(i in (prm$fin_pgr$Magnitud + 2):(prm$fin_plz$Magnitud + 1)) {
        loan$saldo_ini[i] <- loan$saldo_fin[i - 1]
        loan$interes[i] <- loan$saldo_fin[i - 1] * (prm$fin_tf$Magnitud / 12)
        loan$pago[i] <- loan$saldo_fin[1] * (prm$fin_tf$Magnitud/12) /  (1 - (1 + prm$fin_tf$Magnitud/12)^(-(prm$fin_plz$Magnitud - prm$fin_pgr$Magnitud)))
        loan$amort[i] <- loan$pago[i] - loan$interes[i]
        loan$saldo_fin[i] <- loan$saldo_ini[i] - loan$amort[i]
      }
    } else {
      for(i in 2:(prm$fin_plz$Magnitud + 1)) {
        loan$saldo_ini[i] <- loan$saldo_fin[i - 1]
        loan$interes[i] <- loan$saldo_fin[i - 1] * (prm$fin_tf$Magnitud / 12)
        loan$pago[i] <- loan$saldo_fin[1] * (prm$fin_tf$Magnitud/12) /  (1 - (1 + prm$fin_tf$Magnitud/12)^(-prm$fin_plz$Magnitud))
        loan$amort[i] <- loan$pago[i] - loan$interes[i]
        loan$saldo_fin[i] <- loan$saldo_ini[i] - loan$amort[i]
      }
    }
  }
  
  # loan: INPUT
  fl_loan_mxp <- data.frame(periodo = 0:prm$eval_hrz$Magnitud) %>% 
    left_join(loan %>% 
                group_by(periodo) %>% 
                summarise(interes = sum(interes),
                          pago_capital = sum(amort),
                          deuda_lp = min(saldo_fin)),
              by = "periodo") %>% 
    mutate_at(vars(-periodo), ~if_else(is.na(.), 0, .))
  
  # depreciation: INPUT
  activos <- prmtrs %>% 
    filter(grepl("dpn", clave)) %>% 
    select(clave) %>%
    pull() %>% 
    stringr::str_extract("(?<=dpn_)[a-z]+")
  
  fl_dpr_mxp <- data.frame(periodo = 0:prm$eval_hrz$Magnitud)
  for(i in 1:length(activos)) {
    fl_dpr_mxp[, paste0("dpn_", activos[i])] <- inv[[paste0("inv_", activos[i])]]$Magnitud * prm[[paste0("cont_dpn_", activos[i])]]$Magnitud
    fl_dpr_mxp[, paste0("tasa_", activos[i])] <- prm[[paste0("cont_dpn_", activos[i])]]$Magnitud
  }  
  fl_dpr_mxp <- fl_dpr_mxp %>%
    mutate_at(vars(-periodo), ~if_else(periodo == 0, 0, .))
  for(j in 1:length(activos)) {
    for(i in 3:nrow(fl_dpr_mxp)) {
      if(sum(fl_dpr_mxp[2:i, paste0("tasa_", activos[j])]) > 1) {
        fl_dpr_mxp[i, paste0("dpn_", activos[j])] <- 0
      }
    }
  }
  
  fl_dpr_mxp$dpn_total <- fl_dpr_mxp[, paste0("dpn_", activos[1])]
  for(i in 2:length(activos)) fl_dpr_mxp$dpn_total <- fl_dpr_mxp$dpn_total + fl_dpr_mxp[, paste0("dpn_", activos[i])]
  
  
  # production: INPUT
  fl_pd_ton <- data.frame(periodo = 0:prm$eval_hrz$Magnitud,
                          yield = c(rep(0,prm$pdn_ini$Magnitud),
                                    seq(from = prm$pdn_yini$Magnitud,
                                        to = prm$pdn_yesta$Magnitud,
                                        length.out = prm$pdn_esta$Magnitud - prm$pdn_ini$Magnitud + 1),
                                    rep(prm$pdn_yesta$Magnitud, prm$eval_hrz$Magnitud - prm$pdn_esta$Magnitud))) %>% 
    mutate(ton = yield * prm$pdn_sup$Magnitud)
  
  # revenues: INPUT
  fl_ing_mxp <- data.frame(periodo = 0:prm$eval_hrz$Magnitud) %>% 
    mutate(pr_ton = if(prm$com_pr_sel$Magnitud == 1) {prm$com_p_nal$Magnitud * 1000} else {agt_mun %>% 
        filter(idestado == 14, idmunicipio == 86, anio >= 2014) %>% 
        select(anio, sembrada, volumenproduccion, rendimiento, preciomediorural) %>% 
        arrange(anio) %>% 
        summarise(pmr = sum(preciomediorural * volumenproduccion) / sum(volumenproduccion)) %>% 
        pull()}) %>%
    mutate(ing_mxp = pr_ton * fl_pd_ton$ton)
  
  # expenses: INPUT
  fl_cts_mxp <- data.frame(periodo = 0:prm$eval_hrz$Magnitud) %>% 
    mutate(cv = costos_mxp %>% 
             filter(Categoría == "cv") %>% 
             summarise(sum(Magnitud)) %>% 
             pull(),
           cf = costos_mxp %>% 
             filter(Categoría == "cf") %>% 
             summarise(sum(Magnitud)) %>% 
             pull(),
           gpath = c(seq(from = 0, to = 1, length.out = prm$pdn_esta$Magnitud + 1),
                     rep(1, prm$eval_hrz$Magnitud - prm$pdn_esta$Magnitud)),
           cv_mxp = cv * gpath,
           cf_mxp = cf * gpath) %>% 
    mutate_at(vars(-periodo), ~if_else(periodo == 0, 0, .))
  
  # risk analysis series
  serie_pmr <- agt_mun %>%
    filter(anio >= 2016) %>% 
    group_by(anio, idestado) %>% 
    summarise(pmr = sum(preciomediorural * volumenproduccion) / sum(volumenproduccion)) %>%
    ungroup() %>% 
    select(pmr) %>%
    pull()
  
  serie_yld <- agt_mun %>%
    filter(anio >= 2016) %>% 
    group_by(anio, idestado) %>% 
    summarise(pmr = sum(rendimiento * volumenproduccion) / sum(volumenproduccion)) %>%
    ungroup() %>% 
    select(pmr) %>%
    pull()
  
  inputs <- list(prm = prm,
                 costos_mxp = costos_mxp,
                 inv_mxp = inv_mxp,
                 inv = inv,
                 sch_apy_mxp = sch_apy_mxp,
                 sch_apy_pctj = sch_apy_pctj,
                 sch_gral_mxp = sch_gral_mxp,
                 fl_sch_mxp = fl_sch_mxp,
                 fl_inv_mxp = fl_inv_mxp,
                 loan = loan,
                 fl_loan_mxp = fl_loan_mxp,
                 fl_dpr_mxp = fl_dpr_mxp,
                 fl_pd_ton = fl_pd_ton,
                 fl_ing_mxp = fl_ing_mxp,
                 fl_cts_mxp = fl_cts_mxp,
                 serie_pmr = serie_pmr,
                 serie_yld = serie_yld)
  
  return(inputs)
}

# feasability indicators and other formulae
NPV <- function(cf, r) sum(cf / (1 + r)^(seq(along = cf) - 1))
IRR <- function(cf) uniroot(NPV, interval = c(1e-10, 1e+10), extendInt = "yes", cf = cf)$root
pago <- function(monto, r, n) monto * r /(1 - (1 + r)^(-n))

# vnp generator using just the cash flow
mod_fin_flujo <- function(inputs) {
  
  for(i in 1:length(inputs)) assign(names(inputs)[i], inputs[[i]])
  
  flujo <- data.frame(periodo = 0:prm$eval_hrz$Magnitud) %>% 
    mutate(ing = fl_ing_mxp$ing_mxp,
           cv = fl_cts_mxp$cv_mxp,
           cf = fl_cts_mxp$cf_mxp,
           ebitda = ing - cv - cf,
           intereses =  if(prm$eval_sel_flj$Magnitud == 2) {fl_loan_mxp$interes} else {0},
           dpr = fl_dpr_mxp$dpn_total,
           ebt = ebitda - intereses - dpr,
           taxes = if_else(ebt <0, 0, ebt * prm$cont_tax$Magnitud),
           profit = ebt - taxes,
           capex = fl_inv_mxp$total,
           credito = if(prm$eval_sel_flj$Magnitud == 2) {sch_gral_mxp[sch_gral_mxp$fuente == "credito", "mxp"]} else {0},
           apoyo = if(prm$eval_sel_flj$Magnitud == 2) {sch_gral_mxp[sch_gral_mxp$fuente == "apoyo", "mxp"]} else {0},
           wk = 0,
           repayment = if(prm$eval_sel_flj$Magnitud == 2) {fl_loan_mxp$pago_capital} else {0},
           tv = 0)
  for(i in 1:(prm$eval_hrz$Magnitud)) {
    if(flujo$ing[i + 1] - (flujo$cv[i + 1] + flujo$cf[i + 1] + flujo$intereses[i + 1] + flujo$taxes[i + 1]) < 0) {
      flujo$wk[i] <- (flujo$cv[i + 1] + flujo$cf[i + 1] + flujo$intereses[i + 1] + flujo$taxes[i + 1])
    } 
  }
  flujo$tv[prm$eval_hrz$Magnitud + 1] <- flujo$profit[prm$eval_hrz$Magnitud + 1] / prm$eval_td$Magnitud
  flujo <- flujo %>% 
    mutate(fcf = profit - capex + credito + apoyo - wk - repayment + dpr + tv,
           factor_dto = 1/(1 + prm$eval_td$Magnitud)^periodo,
           fcf_pv = fcf * factor_dto,
           fcf_pv_cum = cumsum(fcf_pv))
  
  
  fi_df <- data.frame(npv = NPV(flujo$fcf, prm$eval_td$Magnitud))
  
  return(list(van = fi_df$npv / 1000))
}
mod_fin_flujo_esc <- function(inputs) {
  
  for(i in 1:length(inputs)) assign(names(inputs)[i], inputs[[i]])
  
  flujo <- data.frame(periodo = 0:prm$eval_hrz$Magnitud) %>% 
    mutate(ing = fl_ing_mxp$ing_mxp,
           cv = cv_fun(prm$eval_hrz$Magnitud, prmtrs_aux),
           cf = fl_cts_mxp$cf_mxp,
           ebitda = ing - cv - cf,
           intereses =  if(prm$eval_sel_flj$Magnitud == 2) {fl_loan_mxp$interes} else {0},
           dpr = fl_dpr_mxp$dpn_total,
           ebt = ebitda - intereses - dpr,
           taxes = if_else(ebt <0, 0, ebt * prm$cont_tax$Magnitud),
           profit = ebt - taxes,
           capex = fl_inv_mxp$total,
           credito = if(prm$eval_sel_flj$Magnitud == 2) {sch_gral_mxp[sch_gral_mxp$fuente == "credito", "mxp"]} else {0},
           apoyo = if(prm$eval_sel_flj$Magnitud == 2) {sch_gral_mxp[sch_gral_mxp$fuente == "apoyo", "mxp"]} else {0},
           wk = 0,
           repayment = if(prm$eval_sel_flj$Magnitud == 2) {fl_loan_mxp$pago_capital} else {0},
           tv = 0)
  for(i in 1:(prm$eval_hrz$Magnitud)) {
    if(flujo$ing[i + 1] - (flujo$cv[i + 1] + flujo$cf[i + 1] + flujo$intereses[i + 1] + flujo$taxes[i + 1]) < 0) {
      flujo$wk[i] <- (flujo$cv[i + 1] + flujo$cf[i + 1] + flujo$intereses[i + 1] + flujo$taxes[i + 1])
    } 
  }
  #flujo$tv[prm$eval_hrz$Magnitud + 1] <- flujo$profit[prm$eval_hrz$Magnitud + 1] / prm$eval_td$Magnitud
  flujo <- flujo %>% 
    mutate(fcf = profit - capex + credito + apoyo - wk - repayment + dpr + tv,
           factor_dto = 1/(1 + prm$eval_td$Magnitud)^periodo,
           fcf_pv = fcf * factor_dto,
           fcf_pv_cum = cumsum(fcf_pv))
  
  
  fi_df <- data.frame(npv = NPV(flujo$fcf, prm$eval_td$Magnitud))
  
  return(list(van = fi_df$npv / 1000))
}

# sensitivity analysis
sens_anlys <- function(inputs) {

# production: INPUT
inputs_sens <- inputs

sens_df <- data.frame(sens_fact = seq(0.1, 10, by = 0.1)) %>%
  mutate(vans = NA)

for(i in 1:length(sens_df$sens_fact)) {
inputs_sens$fl_pd_ton <- data.frame(periodo = inputs$prm$eval_hrz$Magnitud,
                        yield = inputs$fl_pd_ton$yield ) %>%
  mutate(sens_fact = sens_df$sens_fact[i]) %>% 
  mutate(ton = yield * sens_fact * inputs$prm$pdn_sup$Magnitud)

# revenues: INPUT
inputs_sens$fl_ing_mxp <- data.frame(periodo = inputs$fl_ing_mxp$periodo) %>% 
  mutate(pr_ton = inputs$fl_ing_mxp$pr_ton) %>%
  mutate(ing_mxp = pr_ton * inputs_sens$fl_pd_ton$ton)

sens_df$vans[i] <- mod_fin_flujo(inputs_sens)$van
}

sstep <- sens_df[which.min(abs(sens_df$vans)),1]

sens_df <- data.frame(sens_fact = seq(sstep - 0.1, sstep + 0.1, by = 0.01)) %>% 
  mutate(vans = NA)

for(i in 1:length(sens_df$sens_fact)) {
  inputs_sens$fl_pd_ton <- data.frame(periodo = inputs$prm$eval_hrz$Magnitud,
                                      yield = inputs$fl_pd_ton$yield ) %>%
    mutate(sens_fact = sens_df$sens_fact[i]) %>% 
    mutate(ton = yield * sens_fact * inputs$prm$pdn_sup$Magnitud)
  
  # revenues: INPUT
  inputs_sens$fl_ing_mxp <- data.frame(periodo = inputs$fl_ing_mxp$periodo) %>% 
    mutate(pr_ton = inputs$fl_ing_mxp$pr_ton) %>%
    mutate(ing_mxp = pr_ton * inputs_sens$fl_pd_ton$ton)
  
  sens_df$vans[i] <- mod_fin_flujo(inputs_sens)$van
}

elast_pd <- - 1 / (sens_df[which.min(abs(sens_df$vans)),1] - 1)

# revenues: sensibility
inputs_sens <- inputs

sens_df <- data.frame(sens_fact = seq(0.1, 10, by = 0.1)) %>%
  mutate(vans = NA)

for(i in 1:length(sens_df$sens_fact)) {
inputs_sens$fl_ing_mxp <- data.frame(periodo = inputs$fl_ing_mxp$periodo) %>% 
  mutate(pr_ton = inputs$fl_ing_mxp$pr_ton) %>%
  mutate(sens_fact = sens_df$sens_fact[i]) %>% 
  mutate(ing_mxp = pr_ton * sens_fact * inputs$fl_pd_ton$ton)

sens_df$vans[i] <- mod_fin_flujo(inputs_sens)$van
}

sstep <- sens_df[which.min(abs(sens_df$vans)),1]

sens_df <- data.frame(sens_fact = seq(sstep - 0.1, sstep + 0.1, by = 0.01)) %>% 
  mutate(vans = NA)

for(i in 1:length(sens_df$sens_fact)) {
  inputs_sens$fl_ing_mxp <- data.frame(periodo = inputs$fl_ing_mxp$periodo) %>% 
    mutate(pr_ton = inputs$fl_ing_mxp$pr_ton) %>%
    mutate(sens_fact = sens_df$sens_fact[i]) %>% 
    mutate(ing_mxp = pr_ton * sens_fact * inputs$fl_pd_ton$ton)
  
  sens_df$vans[i] <- mod_fin_flujo(inputs_sens)$van
}

elast_ing <- - 1 / (sens_df[which.min(abs(sens_df$vans)),1] - 1)


# expenses: sensibility
inputs_sens <- inputs

sens_df <- data.frame(sens_fact = seq(0.1, 10, by = 0.1)) %>%
  mutate(vans = NA)

for(i in 1:length(sens_df$sens_fact)) {
inputs_sens$fl_cts_mxp <- data.frame(periodo = inputs$fl_cts_mxp$periodo) %>% 
  mutate(cv = inputs$fl_cts_mxp$cv,
         sens_fact = sens_df$sens_fact[i],
         cf = inputs$fl_cts_mxp$cf,
         gpath = inputs$fl_cts_mxp$gpath,
         cv_mxp = cv * gpath * sens_fact,
         cf_mxp = cf * gpath) %>% 
  mutate_at(vars(-periodo), ~if_else(periodo == 0, 0, .))

sens_df$vans[i] <- mod_fin_flujo(inputs_sens)$van
}

sstep <- sens_df[which.min(abs(sens_df$vans)),1]

sens_df <- data.frame(sens_fact = seq(sstep - 0.1, sstep + 0.1, by = 0.01)) %>% 
  mutate(vans = NA)

for(i in 1:length(sens_df$sens_fact)) {
  inputs_sens$fl_cts_mxp <- data.frame(periodo = inputs$fl_cts_mxp$periodo) %>% 
    mutate(cv = inputs$fl_cts_mxp$cv,
           sens_fact = sens_df$sens_fact[i],
           cf = inputs$fl_cts_mxp$cf,
           gpath = inputs$fl_cts_mxp$gpath,
           cv_mxp = cv * gpath * sens_fact,
           cf_mxp = cf * gpath) %>% 
    mutate_at(vars(-periodo), ~if_else(periodo == 0, 0, .))
  
  sens_df$vans[i] <- mod_fin_flujo(inputs_sens)$van
}

elast_cts <- - 1 / (sens_df[which.min(abs(sens_df$vans)),1] - 1)

# output: elasticities dataframe
sens_van0 <- data.frame(variable = c("yield", "pmr", "cv"),
                        elasticidad = c(elast_pd, elast_ing, elast_cts))

return(sens_van0)
}

# risk analysis
fit_escala <- function(serie) {

if(min(serie) < 0) {
  reescala_sust <- abs(min(serie)) + 1
  serie <- serie + reescala_sust
} else {
  reescala_sust <- 0
}

if(nchar(trunc(max(serie))) > 0) {
  reescala_mult <- 10^nchar(trunc(max(serie)))
  serie <- serie / reescala_mult
} else {
  reescala_mult <- 1
}

reescala <- list(serie = serie,
                 reescala_sust = reescala_sust,
                 reescala_mult = reescala_mult)

return(reescala)

}
fit_selec <- function(serie) {
  
  ajustes <- list()
  for(i in 1:length(dist_names)) {
    ajustes[[i]] <- fitdistrplus::fitdist(serie,
                                          distr = dist_names[i])
    names(ajustes)[i] <- paste0("fit_", dist_names[i])
  }
  attach(ajustes)
  fit_sel <- fitdistrplus::gofstat(list(fit_unif, fit_weibull, fit_norm, fit_logis, fit_lnorm, fit_gamma, fit_exp, fit_cauchy, fit_beta),
                                   fitnames = c("unif", "weibull", "norm", "logis", "lnorm", "gamma", "exp", "cauchy", "beta"))
  dist_win <- dist_names[which.min(fit_sel$ks)]
  dist_win_par <- get(paste0("fit_", dist_win))$estimate
  detach()
  
  objetos <- list(dist_ajust = ajustes[[which.min(fit_sel$ks)]],
                  dist_win = dist_win,
                  dist_win_par = dist_win_par)
  
  return(objetos)
  
}
risk_anlys <- function(serie_pmr, serie_yld, inputs) {

  inputs_risk <- inputs
  
  risk_pmr_scaled <- fit_escala(inputs$serie_pmr)
  risk_yld_scaled <- fit_escala(inputs$serie_yld)
    
  risk_pmr_par <- fit_selec(risk_pmr_scaled$serie)
  risk_yld_par <- fit_selec(risk_yld_scaled$serie)
  
  risk_vans <- rep(NA, 1000)
  for(i in 1:1000) {
    inputs_risk$fl_pd_ton <- data.frame(periodo = inputs$fl_pd_ton$periodo,
                             yield = if(risk_yld_par$dist_win != "exp") {
                               get(paste0("r", risk_yld_par$dist_win))(1, risk_yld_par$dist_win_par[1], risk_yld_par$dist_win_par[2]) * risk_yld_scaled$reescala_mult - risk_yld_scaled$reescala_sust
                             } else {
                               rexp(1, risk_yld_win$dist_win_par[1]) * risk_yld_scaled$reescala_mult - risk_yld_scaled$reescala_sust
                             }) %>%
      mutate(ton = yield * inputs$prm$pdn_sup$Magnitud)
    
    inputs_risk$fl_ing_mxp <- data.frame(periodo = inputs$fl_ing_mxp$periodo) %>% 
      mutate(pr_ton = if(risk_pmr_par$dist_win != "exp") {
        get(paste0("r", risk_pmr_par$dist_win))(1, risk_pmr_par$dist_win_par[1], risk_pmr_par$dist_win_par[2]) * risk_pmr_scaled$reescala_mult - risk_pmr_scaled$reescala_sust
        } else {
          rexp(1, risk_pmr_win$dist_win_par[1]) * risk_pmr_scaled$reescala_mult - risk_pmr_scaled$reescala_sust
        }) %>% 
      mutate(ing_mxp = pr_ton * inputs_risk$fl_pd_ton$ton)
    
    risk_vans[i] <- mod_fin_flujo(inputs_risk)$van

    
    
      }
  
  risk_van_scaled <- fit_escala(risk_vans)
  
  risk_van_par <- fit_selec(risk_van_scaled$serie)
  
  # confidence interval
  prob_van <- data.frame(limites = c("inferior", "superior"),
                         van_000_mxp = if(risk_van_par$dist_win != "exp") {
                           c(get(paste0("q", risk_van_par$dist_win))(0.025, risk_van_par$dist_win_par[1], risk_van_par$dist_win_par[2]) * risk_van_scaled$reescala_mult - risk_van_scaled$reescala_sust,
                             get(paste0("q", risk_van_par$dist_win))(0.975, risk_van_par$dist_win_par[1], risk_van_par$dist_win_par[2]) * risk_van_scaled$reescala_mult - risk_van_scaled$reescala_sust)
                         } else {
                           c(qexp(0.025, risk_van_par$dist_win_par[1]) * risk_van_scaled$reescala_mult - risk_van_scaled$reescala_sust,
                             qexp(0.975, risk_van_par$dist_win_par[1]) * risk_van_scaled$reescala_mult - risk_van_scaled$reescala_sust)
                         }) %>% 
    mutate(van_000_mxp = round(van_000_mxp, 0))
  
  risk_rate <- (if(risk_van_par$dist_win != "exp") {
    get(paste0("p", risk_van_par$dist_win))((-0.01 + risk_van_scaled$reescala_sust) / risk_van_scaled$reescala_mult, risk_van_par$dist_win_par[1], risk_van_par$dist_win_par[2])
  } else {
    pexp((-0.01 + risk_van_scaled$reescala_sust) / risk_van_scaled$reescala_mult, risk_van_par$dist_win_par[1])
  }) %>% round(., 2) %>% format(., nsmall = 2)
  
  return(list(risk_vans = risk_vans %>% tibble(),
              risk_vans_scaled = risk_van_scaled$serie %>% tibble(),
              pdf = risk_van_par$dist_win,
              pdf_par = risk_van_par$dist_win_par,
              risk_rate = risk_rate,
              prob_van_interval = prob_van))

}

# the whole outputs model generator
# free cash flow: OUTPUT Function
mod_fin <- function(prmtrs) {
  
  inputs <- inputs_updt(prmtrs)
  
  for(i in 1:length(inputs)) assign(names(inputs)[i], inputs[[i]])
  
  flujo <- data.frame(periodo = 0:prm$eval_hrz$Magnitud) %>% 
    mutate(ing = fl_ing_mxp$ing_mxp,
           cv = fl_cts_mxp$cv_mxp,
           cf = fl_cts_mxp$cf_mxp,
           ebitda = ing - cv - cf,
           intereses = fl_loan_mxp$interes,
           intereses = if(prm$eval_sel_flj$Magnitud == 2) {intereses} else {rep(0, prm$eval_hrz$Magnitud + 1)},
           dpr = fl_dpr_mxp$dpn_total,
           ebt = ebitda - intereses - dpr,
           taxes = if_else(ebt <0, 0, ebt * prm$cont_tax$Magnitud),
           profit = ebt - taxes,
           capex = fl_inv_mxp$total,
           credito = fl_sch_mxp$credito,
           credito = if(prm$eval_sel_flj$Magnitud == 2) {credito} else {rep(0, prm$eval_hrz$Magnitud + 1)},
           apoyo = fl_sch_mxp$apoyo,
           apoyo = if(prm$eval_sel_flj$Magnitud == 2) {apoyo} else {rep(0, prm$eval_hrz$Magnitud + 1)},
           wk = 0,
           repayment = fl_loan_mxp$pago_capital,
           repayment = if(prm$eval_sel_flj$Magnitud == 2) {repayment} else {rep(0, prm$eval_hrz$Magnitud + 1)},
           tv = 0)
  for(i in 1:(prm$eval_hrz$Magnitud)) {
    if(flujo$ing[i + 1] - (flujo$cv[i + 1] + flujo$cf[i + 1] + flujo$intereses[i + 1] + flujo$taxes[i + 1]) < 0) {
      flujo$wk[i] <- (flujo$cv[i + 1] + flujo$cf[i + 1] + flujo$intereses[i + 1] + flujo$taxes[i + 1])
    } 
  }
  flujo$tv[prm$eval_hrz$Magnitud + 1] <- flujo$profit[prm$eval_hrz$Magnitud + 1] / prm$eval_td$Magnitud
  flujo <- flujo %>% 
    mutate(fcf = profit - capex + credito + apoyo - wk - repayment + dpr + tv,
           factor_dto = 1/(1 + prm$eval_td$Magnitud)^periodo,
           fcf_pv = fcf * factor_dto,
           fcf_pv_cum = cumsum(fcf_pv))
  
  orden <- names(flujo)[-1]
  
  flujo_fmt <- flujo %>%
    mutate_at(vars(-factor_dto, -periodo), ~round(./1000, digits = 0)) %>% 
    select(-factor_dto) %>% gather(concepto, "000_mxp", -periodo) %>% spread(periodo, "000_mxp") %>%
    mutate(concepto = factor(concepto, levels = orden)) %>% .[order(.$concepto),]
  
  fi_df <- data.frame(npv = round(NPV(flujo$fcf, prm$eval_td$Magnitud) / 1000),
                      aev = round(pago(sum(flujo$fcf_pv), prm$eval_td$Magnitud, prm$eval_hrz$Magnitud) / 1000),
                      irr = IRR(flujo$fcf) %>% round(., 3) %>% format(., nsmall = 2),
                      bcr = ((sum((flujo$profit - flujo$repayment + flujo$dpr + flujo$tv) * flujo$factor_dto)) /
                        (sum((flujo$capex + flujo$wk) * flujo$factor_dto))) %>% round(., 2) %>% format(., nsmall = 2),
                      pbk = if(sum(flujo$fcf_pv_cum < 0) - 1 == prm$eval_hrz$Magnitud) {NA} else {sum(flujo$fcf_pv_cum < 0)})
  
  est_res <- data.frame(periodo = flujo$periodo) %>% 
    mutate(ing = fl_ing_mxp$ing_mxp,
           cv = fl_cts_mxp$cv_mxp,
           cf = fl_cts_mxp$cf_mxp,
           ebitda = ing - cv - cf,
           intereses = fl_loan_mxp$interes,
           dpr = fl_dpr_mxp$dpn_total,
           ebt = ebitda - intereses - dpr,
           taxes = if_else(ebt <0, 0, ebt * prm$cont_tax$Magnitud),
           profit = ebt - taxes)
  
  orden <- names(est_res)[-1]
  
  est_res_fmt <- est_res %>%
    mutate_at(vars(-periodo), ~round(./1000, digits = 0)) %>% 
    gather(concepto, "000_mxp", -periodo) %>% spread(periodo, "000_mxp") %>%
    mutate(concepto = factor(concepto, levels = orden)) %>% .[order(.$concepto),]
  
  cts_circ <- data.frame(periodo = flujo$periodo) %>% 
    mutate(almacen = 0,
           cpc = 0,
           cpp = 0,
           almacen = if_else(periodo == 0, 0, fl_ing_mxp$ing_mxp * prm$cont_invent$Magnitud/12),
           cpc = if_else(periodo == 0, 0, fl_ing_mxp$ing_mxp * prm$cont_cc$Magnitud/12),
           cpp = if_else(periodo == 0,0, (fl_cts_mxp$cv + fl_cts_mxp$cf) * prm$cont_cp$Magnitud/12),
           taxes = if_else(periodo == 0, 0, flujo$taxes))
  
  est_fc <- data.frame(periodo = flujo$periodo) %>% 
    mutate(profit = est_res$profit,
           dpr = est_res$dpr,
           fond_act_op = profit + dpr,
           var_act_circ = 0,
           var_pas_circ = 0)
  for(i in 2:length(est_fc$periodo)) {
    est_fc$var_act_circ[i] <- sum(cts_circ$almacen[i] + cts_circ$cpc[i]) - sum(cts_circ$almacen[i - 1] + cts_circ$cpc[i - 1])
    est_fc$var_pas_circ[i] <- sum(cts_circ$cpp[i] + cts_circ$taxes[i]) - sum(cts_circ$cpp[i - 1] + cts_circ$taxes[i - 1])
  }
  est_fc <- est_fc %>% 
    mutate(caja_act_op = fond_act_op + var_act_circ - var_pas_circ,
           inv_sin_wk = fl_inv_mxp$total,
           creditos = flujo$credito,
           apoyos = flujo$apoyo,
           amort_cred = flujo$repayment,
           aport = flujo$wk + if_else(periodo == 0, sch_gral_mxp[sch_gral_mxp$fuente == "aportacion", "mxp"], 0),
           var_caja = caja_act_op - inv_sin_wk + creditos + apoyos - amort_cred + aport,
           caja_ini = 0,
           caja_ter = var_caja + caja_ini)
  for(i in 2:length(est_fc$periodo)) {
    est_fc$caja_ini[i] <- est_fc$caja_ter[i - 1]
    est_fc$caja_ter[i] <- est_fc$var_caja[i] + est_fc$caja_ini[i]
  }
  
  orden <- names(est_fc)[-1]
  
  est_fc_fmt <- est_fc %>%
    mutate_at(vars(-periodo), ~round(./1000, digits = 0)) %>% 
    gather(concepto, "000_mxp", -periodo) %>% spread(periodo, "000_mxp") %>%
    mutate(concepto = factor(concepto, levels = orden)) %>% .[order(.$concepto),]
  
  est_sf <- data.frame(periodo = flujo$periodo) %>% 
    mutate(mye = (cumsum(fl_inv_mxp$Maqu) - cumsum(fl_dpr_mxp$dpn_mye)) * (1 - sch_gral_mxp[sch_gral_mxp$fuente == "apoyo", "pct"]),
           trans = (cumsum(fl_inv_mxp$Tran) - cumsum(fl_dpr_mxp$dpn_trans)) * (1 - sch_gral_mxp[sch_gral_mxp$fuente == "apoyo", "pct"]),
           plantula = cumsum(fl_inv_mxp$Plan),
           prep_terr = cumsum(fl_inv_mxp$Prep) - cumsum(fl_dpr_mxp$dpn_prep),
           caja = est_fc$caja_ter,
           almacen = cts_circ$almacen,
           cpc = cts_circ$cpc,
           tot_activos = mye + trans + plantula + prep_terr + caja + almacen + cpc,
           prestamos = fl_loan_mxp$deuda_lp,
           cpp = cts_circ$cpp,
           taxes = cts_circ$taxes,
           tot_pasivos = prestamos + cpp + taxes,
           cap_soc = sch_gral_mxp[sch_gral_mxp$fuente == "aportacion", "mxp"],
           aport_pend_cap = cumsum(flujo$wk),
           ut_ret = if_else(cumsum(est_res$profit) < 0, 0, cumsum(est_res$profit)),
           tot_capital = cap_soc + aport_pend_cap + ut_ret,
           pasivos_capital = tot_pasivos + tot_capital)
  
  ajuste <- est_sf$tot_activos - est_sf$pasivos_capital
  
  est_sf <- est_sf %>% 
    mutate(aport_pend_cap = aport_pend_cap + ajuste,
           tot_capital = cap_soc + aport_pend_cap + ut_ret,
           pasivos_capital = tot_pasivos + tot_capital)
  
  orden <- names(est_sf)[-1]
  
  est_sf_fmt <- est_sf %>%
    mutate_at(vars(-periodo), ~round(./1000, digits = 0)) %>% 
    gather(concepto, "000_mxp", -periodo) %>% spread(periodo, "000_mxp") %>%
    mutate(concepto = factor(concepto, levels = orden)) %>% .[order(.$concepto),]
  
  elast_df <- sens_anlys(inputs)
  
  prob_van <- risk_anlys(inputs$serie_pmr, inputs$serie_yld, inputs)
  
  modelo <- list(costos = inputs$costos_mxp %>% mutate(Magnitud = round(Magnitud / 1000, 1),
                                                       UM = "000_mxp"),
                 inv = inputs$inv_mxp %>%
                   rbind(data.frame(Categoría = "inv", Concepto = "Capital de trabajo",
                                    Magnitud = NPV(flujo$wk, prm$eval_td$Magnitud), UM = "mxp",
                                    clave = "inv_ctrab", subcat1 = "suj_null", subcat2 = NA)) %>% 
                   mutate(Magnitud = round(Magnitud / 1000, 1),
                                                 UM = "000_mxp"),
                 sch_apy = inputs$sch_apy_mxp %>% mutate_at(vars(-fuente), ~round(./1000, 1)),
                 sch_apy_pct = inputs$sch_apy_pctj,
                 sch_gral = inputs$sch_gral_mxp %>% mutate(mxp = round(mxp / 1000, 1)) %>% 
                   rename("000_mxp" = mxp),
                 loan = inputs$fl_loan_mxp %>% mutate_at(vars(-periodo), ~round(./1000, 1)),
                 est_res = est_res_fmt,
                 est_fc = est_fc_fmt,
                 est_sf = est_sf_fmt,
                 flujo = flujo_fmt,
                 ind_fin = fi_df,
                 van = fi_df$npv,
                 sens = elast_df,
                 risk_vans = prob_van$risk_vans,
                 risk_vans_scaled = prob_van$risk_vans_scaled,
                 pdf = prob_van$pdf,
                 pdf_par = prob_van$pdf_par,
                 risk_rate = prob_van$risk_rate,
                 prob_van_interval = prob_van$prob_van_interval)
  
  
  return(modelo)
  
}  

#### minimal scale ####
esca_min <- function(prmtrs) {
  
  prmtrs_aux <- prmtrs
  
  vans_esca <- expand.grid(sup = seq(from = 0.5, to = 100, by = .5),
                           hrz = seq(from = 8, to = 20, by = 1)) %>% 
    mutate(vans = NA)
  
  for(i in 1:nrow(vans_esca)) {
    prmtrs_aux[prmtrs_aux$clave == "pdn_sup", "Magnitud"] <- vans_esca$sup[i]
    prmtrs_aux[prmtrs_aux$clave == "eval_hrz", "Magnitud"] <- vans_esca$hrz[i]
    inputs_esca <- inputs_updt(prmtrs_aux)
    vans_esca$vans[i] <- mod_fin_flujo_esc(inputs_esca)$van
  }

  escala_min <- vans_esca[which.min(abs(vans_esca$vans)), "sup"]
  escala_opt <- vans_esca[which.max(vans_esca$vans), "sup"]
  
  escala <- data.frame(escala = c("minima", "optima"), sup_ha = c(escala_min, escala_opt))
  
  return(escala)

}

esca_min(prmtrs)
#### varios ####
#FinCal::irr(flujo$fcf)
#FinCal::npv(prm$eval_td$Magnitud, flujo$fcf)
pago(sum(flujo$fcf_pv), prm$eval_td$Magnitud, length(flujo$fcf_pv))
writeClipboard(as.vector(flujo$fcf))
write.table(flujo$fcf, "clipboard", sep = "\t")
#dist_names <- c("unif", "weibull", "norm", "logis", "lnorm", "gamma", "exp", "cauchy", "beta")
fitdistrplus::denscomp(risk_van_par$dist_ajust)
### first stpes building parameters dataframe
#prmtrs <- data.frame(Categoría = "pdn",
#                    Concepto = "Inicio de producciÃ³n",
#                   Magnitud = 3,
#                  UM = "aÃ±o",
#                 clave = "pdn_ini")



vans_esca_fil <- vans_esca %>%
  filter(vans > 0)
#plotly::plot_ly(x=vans_esca_fil$hrz, y=vans_esca_fil$sup, z=vans_esca_fil$vans, type="scatter3d", mode="markers", color = vans_esca_fil$vans)
vans_esca_fil %>% 
  group_by(sup) %>% 
  summarise(hrz = min(hrz))
vans_esca_fil %>% 
  group_by(hrz) %>% 
  summarise(sup = min(sup), van = min(vans)) %>%
  group_by(sup) %>% 
  summarise(hrz = min(hrz), van = min(van)) %>%
  ggplot(aes(hrz, sup)) +
  geom_step(col = "grey90") +
  geom_point(aes(alpha = van), size = 5, col = "yellowgreen") +
  labs(x = "Años", y = "Has",
        title = "Relación entre la escala mínima rentable\ny el horizonte de evaluación",
       subtitle = "VAN en miles de pesos",
       caption = "Fuente: estimaciones propias") +
  tema_gg +
  scale_x_continuous(breaks = c(8,9,10,11,13,17), labels = c(8,9,10,11,13,17)) +
  theme(axis.line.x = element_line(color = "lightgrey"),
        axis.ticks.x = element_line(),
        legend.position = c(0.85, 0.8))
  
vans_esca_fil %>% 
  filter(sup == 14)

vans_esca_fil %>%
  filter(hrz == 10) %>% 
  arrange(desc(vans)) %>% 
  ggplot(aes(sup, vans)) +
  geom_point()

cv_fun <- function(supe, prmtrs) {

esc_cts <- data.frame(sup = c(4,5,6,8,8,10.5,15),
                      dens = c(114,110,131,110,100,100,123),
                      cv = c(30686,50478,38584,29550,34134,56990,45627))
cv_lm <- esc_cts %>% mutate(cv = cv * 100 / dens,
                   index = 1:nrow(.)) %>% 
  filter(index %in% c(1,3,5,7)) %>% 
  select(sup, cv) %>%
  lm(cv ~ log(sup), .)

  cv_lm$coef[1] + 
    (prmtrs %>% filter(Categoría == "cv") %>% summarise(sum(Magnitud)) %>% pull() -
       predict(cv_lm, data.frame(sup = 40))) +
  cv_lm$coef[2] * log(supe)
}

cv_fun(40, prmtrs)
predict(cv_lm, c(40))
predict(cv_lm, newdata = data.frame(sup = 40))

#### PLOTS ####
## elasticities plot
md_fn_xl$sens %>% #cbind(data.frame(elas = c(-0.88, 10.33, 2.33))) %>% select(-elasticidad) %>% rename(elasticidad = elas) %>% 
  mutate(y_ini = rank(-elasticidad, ties.method = "first"),
         aux_fct = abs(2/elasticidad),
         aux2_fct = min(aux_fct),
         fct = if_else(aux2_fct < 1, aux2_fct, 1),
         y_fin = (elasticidad * fct + y_ini)) %>% 
  gather(y_ini, y_fin, key = "posicion", value = "eje_y") %>% 
  mutate(eje_x = if_else(posicion == "y_ini", 2, 5)) %>%
  mutate(lab_ini = if_else(eje_x == 2, variable, as.factor(NA)),
         pos_lab_ini = eje_x - 0.3,
         lab_fin = if_else(eje_x == 2, scales::number(elasticidad, accuracy = 0.01), as.character(NA)),
         pos_lab_fin = eje_x + 0.3,
         col_sel = if_else(abs(elasticidad) == max(abs(elasticidad)), "T", "F")) %>% 
  ggplot(aes(eje_x, eje_y)) +
    geom_point(aes(col = col_sel), size = 6) +
    geom_line(aes(group = variable, col = col_sel), size = 1) +
    geom_text(aes(x = eje_x - 2, label = lab_ini, col = col_sel), hjust = "left", size = 7, family = "Lato Light") +
    geom_text(aes(x = eje_x - 0.5, label = lab_fin, col = col_sel), hjust = "right", size = 7, family = "Lato Light") +
    labs(x = "", y = "",
         title = "Sensibilidad de variables seleccionadas",
         subtitle = "Coeficientes de elasticidad",
         caption = "Fuente: estimaciones propias.") +
    xlim(0,5) + ylim(0,4) +
    scale_color_manual(values = c("F" = "grey80", "T" = "yellowgreen")) +
    tema_gg +
    theme(axis.line.y = element_blank(),
          axis.text = element_blank(),
          axis.ticks.y = element_blank(),
          legend.position = "none")


## waterfall plot (cumulative discounted cash flow)
wf_df <- data.frame(periodo = 0:prmtrs[prmtrs$clave == "eval_hrz", "Magnitud"]) %>% 
  mutate(flujo = md_fn_xl$flujo %>% 
           filter(concepto == "fcf_pv") %>% 
           select(-concepto) %>%
           gather() %>%
           select(value) %>% 
           pull(),
         inicio = 0,
         fin = flujo)
for(i in 2:nrow(wf_df)) {
  wf_df$inicio[i] <- wf_df$fin[i - 1]
  wf_df$fin[i] <- wf_df$flujo[i] + wf_df$inicio[i]
}
wf_df %>% 
  mutate(fin = inicio + flujo,
         eje_x = 1:nrow(wf_df),
         col_sel = if_else(flujo <= 0, T, F),
         txt = scales::comma(fin),
         txt = if_else(fin %in% c(min(fin), max(fin)), txt, ""),
         eje_y_txt = if_else(flujo <= 0, fin + (-0.04406491 * fin), fin - (0.02241248 * fin))) %>% 
  ggplot(aes(xmin = eje_x - 0.45,
             xmax = eje_x + 0.45,
             ymin = inicio,
             ymax = fin)) +
  geom_rect(aes(fill = col_sel)) +
  scale_fill_manual(values = c("grey85", "yellowgreen")) +
  scale_x_continuous(breaks = c(1:11), labels = c(0:10)) +
  geom_hline(yintercept = 0, col = "darkgrey", lty = 2) +
  geom_text(aes(x = eje_x, y = eje_y_txt, label = txt), col = "white", size = 2, family = "Lato") +
  labs(x = "", y = "",
       title = "Flujo de caja del proyecto descontado y acumulado",
       subtitle = "Miles de pesos",
       caption = "Fuente: estimaciones propias.") +
  scale_y_continuous(label = scales::comma) +
  tema_gg +
  theme(legend.position = "none")
        #axis.line.x = element_line(color = "lightgrey"),
        #axis.ticks.x = element_line())
        #axis.line.y = element_blank(),
        #axis.text.y = element_blank(),
        #axis.ticks = element_blank())

## cash flow plot
md_fn_xl$flujo %>%
  filter(concepto == "fcf") %>% 
  select(-concepto) %>%
  gather() %>%
  rename(periodo = key, flujo = value) %>%
  mutate(periodo = as.numeric(periodo),
         col_fill = if_else(flujo <= 0, T, F)) %>% 
  ggplot(aes(x = periodo, y = flujo)) +
  geom_col(aes(fill = col_fill)) +
  geom_hline(yintercept = 0, col = "darkgrey", lty = 2) +
  scale_fill_manual(values = c("grey85","yellowgreen")) +
  scale_x_continuous(breaks = c(0:10)) +
  scale_y_continuous(labels = scales::comma) +
  labs(x = "", y = "",
       title = "Flujo de caja del proyecto",
       subtitle = "Miles de pesos",
       caption = "Fuente: estimaciones propias.") +
  tema_gg +
  theme(legend.position = "none")

# confidence interval plot
md_fn_xl$risk_vans_scaled %>% 
  ggplot(aes(x = .)) +
  geom_histogram(bins = 15, fill = "white", col = "grey90", aes(x = ., y = stat(density))) +
  stat_function(fun = get(paste0("d", md_fn_xl$pdf)), n = 101,
                args = list(location = md_fn_xl$pdf_par[1], scale = md_fn_xl$pdf_par[2]),
                col = "yellowgreen", size = 0.75) +
  scale_y_continuous(breaks = NULL) +
  geom_vline(xintercept = get(paste0("q", md_fn_xl$pdf))(0.025, location = md_fn_xl$pdf_par[1], scale = md_fn_xl$pdf_par[2]),
             col = "grey85", lty = 2) +
  geom_vline(xintercept = get(paste0("q", md_fn_xl$pdf))(0.975, location = md_fn_xl$pdf_par[1], scale = md_fn_xl$pdf_par[2]),
             col = "grey85", lty = 2) +
 geom_polygon(data = md_fn_xl$risk_vans_scaled %>%
              magrittr::set_names("van_sca") %>%
              rbind(data.frame(van_sca = c(get(paste0("q", md_fn_xl$pdf))(0.025, location = md_fn_xl$pdf_par[1], scale = md_fn_xl$pdf_par[2]),
                                           get(paste0("q", md_fn_xl$pdf))(0.975, location = md_fn_xl$pdf_par[1], scale = md_fn_xl$pdf_par[2])))) %>% 
                 arrange(van_sca) %>% 
                 mutate(dens = get(paste0("d", md_fn_xl$pdf))(van_sca, location = md_fn_xl$pdf_par[1], scale = md_fn_xl$pdf_par[2]),
                        dens = if_else(van_sca <= get(paste0("q", md_fn_xl$pdf))(0.025, location = md_fn_xl$pdf_par[1], scale = md_fn_xl$pdf_par[2]), 0, dens),
                        dens = if_else(van_sca >= get(paste0("q", md_fn_xl$pdf))(0.975, location = md_fn_xl$pdf_par[1], scale = md_fn_xl$pdf_par[2]), 0, dens)),
               aes(x = van_sca, y = dens), fill = "grey", alpha = 0.35) +
  labs(x = "", y = "",
       title = "Intervalo de confianza al 95% del VAN",
       subtitle = "Miles de pesos",
       caption = "Fuente: estimaciones propias.") +
  tema_gg +
  theme(axis.ticks.x = element_line()) +
  scale_x_continuous(breaks = c(get(paste0("q", md_fn_xl$pdf))(0.025, location = md_fn_xl$pdf_par[1], scale = md_fn_xl$pdf_par[2]),
                               fit_escala(md_fn_xl$risk_vans)$reescala_sust / fit_escala(md_fn_xl$risk_vans)$reescala_mult,
                               get(paste0("q", md_fn_xl$pdf))(0.975, location = md_fn_xl$pdf_par[1], scale = md_fn_xl$pdf_par[2])),
                     labels = scales::comma(c(md_fn_xl$prob_van_interval$van_000_mxp[1], 0, md_fn_xl$prob_van_interval$van_000_mxp[2])))

# risk interval plot
md_fn_xl$risk_vans_scaled %>% 
  ggplot(aes(x = .)) +
  geom_histogram(bins = 15, fill = "white", col = "grey90", aes(x = ., y = stat(density))) +
  geom_text(data = md_fn_xl$risk_vans_scaled, aes(x = quantile(.,0.99), y = quantile(density(.)$y,0.925),
                                                  label = paste0("TR: ",
                                                                 scales::percent(as.numeric(md_fn_xl$risk_rate),
                                                                                accuracy = 0.1))),
            family = "Lato", color = "grey35", size = 5) +
  stat_function(fun = get(paste0("d", md_fn_xl$pdf)), n = 101,
                args = list(location = md_fn_xl$pdf_par[1], scale = md_fn_xl$pdf_par[2]),
                col = "yellowgreen", size = 0.75) +
  scale_y_continuous(breaks = NULL) +
  geom_polygon(data = md_fn_xl$risk_vans_scaled %>%
                 magrittr::set_names("van_sca") %>%
                 rbind(data.frame(van_sca = c(fit_escala(md_fn_xl$risk_vans)$reescala_sust / fit_escala(md_fn_xl$risk_vans)$reescala_mult))) %>% 
                 arrange(van_sca) %>% 
                 mutate(dens = get(paste0("d", md_fn_xl$pdf))(van_sca, location = md_fn_xl$pdf_par[1], scale = md_fn_xl$pdf_par[2]),
                        dens = if_else(van_sca == min(van_sca), 0, dens),
                        dens = if_else(van_sca > fit_escala(md_fn_xl$risk_vans)$reescala_sust / fit_escala(md_fn_xl$risk_vans)$reescala_mult, 0, dens)),
               aes(x = van_sca, y = dens), fill = "grey", alpha = 0.35) +
  geom_vline(xintercept = fit_escala(md_fn_xl$risk_vans)$reescala_sust / fit_escala(md_fn_xl$risk_vans)$reescala_mult,
             col = "grey50", lty = 2) +
  labs(x = "", y = "",
       title = "Intervalo de riesgo, VAN < 0",
       subtitle = "Miles de pesos",
       caption = "Fuente: estimaciones propias.") +
  tema_gg +
  theme(axis.ticks.x = element_line()) +
  scale_x_continuous(breaks = c(get(paste0("q", md_fn_xl$pdf))(0.025, location = md_fn_xl$pdf_par[1], scale = md_fn_xl$pdf_par[2]),
                                fit_escala(md_fn_xl$risk_vans)$reescala_sust / fit_escala(md_fn_xl$risk_vans)$reescala_mult,
                                get(paste0("q", md_fn_xl$pdf))(0.975, location = md_fn_xl$pdf_par[1], scale = md_fn_xl$pdf_par[2])),
                     labels = scales::comma(c(md_fn_xl$prob_van_interval$van_000_mxp[1], 0, md_fn_xl$prob_van_interval$van_000_mxp[2])))

# financial indicators plot
md_fn_xl$ind_fin %>% 
  magrittr::set_names(c("VAN", "VAE", "TIR", "bcr", "Pbk")) %>% 
  gather() %>% #cbind(data.frame(value2 = c(100000,-3,0.1,1,NA))) %>% select(-value) %>% rename(value = value2) %>% 
  filter(key != "bcr") %>%
  mutate(value = as.numeric(value),
         value_fmt = value,
         value_fmt = if_else(key %in% c("VAN", "VAE"), scales::comma(value), as.character(NA)),
         value_fmt = if_else(key == "TIR", paste0(value*100, "%"), value_fmt),
         value_fmt = if_else(key == "Pbk", if_else((is.na(value)), "> hrz", paste(scales::number(value), "años", "")), value_fmt),
         aux = "P",
         aux = if_else(key == "VAN", if_else(value >= 0, "P", "N"), aux),
         aux = if_else(key == "VAE", if_else(value >= 0, "P", "N"), aux),
         aux = if_else(key == "TIR", if_else(value >= prmtrs[prmtrs$clave == "eval_td", "Magnitud"], "P", "N"), aux),
         aux = if_else(key == "Pbk", if_else(!(is.na(value)), "P", "N"), aux),
         eje_x = if_else(key %in% c("VAN", "VAE"), 1.5, 5.5),
         eje_y = if_else(key %in% c("VAN", "TIR"), 5.5, 1.5)) %>%
  ggplot(aes(x = eje_x, y = eje_y)) +
  ylim(0,8) + xlim(1,8) +
  geom_text(aes(label = value_fmt), hjust = "left", family = "Lato", size = 13, col = "darkgrey") +
  geom_text(aes(label = key, x = eje_x - 0.1, y = eje_y + 0.4), hjust = "right",
            family = "Lato Light", col = "darkgrey") +
  scale_shape_manual(values = c("P" = 17, "N" = 25)) +
  scale_fill_manual(values = c("N" = "red", "P" = "yellowgreen")) +
  scale_color_manual(values = c("N" = "red", "P" = "yellowgreen")) +
  geom_point(aes(x = eje_x - 0.3, y = eje_y - 0.4, shape = aux, col = aux, fill = aux), size = 3) +
  labs(x = "", y = "",
       title = "Indicadores de rentabilidad",
       subtitle = "VAN y VAE en miles de pesos",
       caption = "Fuente: estimaciones propias.") +
  tema_gg +
  theme(legend.position = "none",
        axis.text = element_blank(),
        axis.ticks.y = element_blank(),
        axis.line.y = element_blank())


# investments distribution plot
md_fn_xl$inv %>% 
  select(Concepto, Magnitud) %>% 
  filter(Magnitud != 0) %>% 
  arrange(Magnitud) %>%
  mutate(pct_fmt = scales::percent(Magnitud),
         col_pal = if_else(Magnitud == max(Magnitud), "T", "F"),
         aux = Magnitud / sum(Magnitud),
         txt = if_else(aux > 0.1, scales::percent(aux), "")) %>% 
  ggplot(aes(x = reorder(Concepto, Magnitud), y = Magnitud)) +
  geom_col(aes(fill = col_pal)) +
  coord_flip() +
  labs(x = "", y = "",
       title = "Conceptos de inversión en valor actual",
       subtitle = "Participación porcentual en el total",
       caption = "Fuente: estimación propia.") +
  scale_fill_manual(values = c("T" = "yellowgreen", "F" = "grey85")) +
  geom_text(aes(label = txt), size = 9, fontface = "bold",
            hjust = "right", col = "white",
            nudge_y = -0.0222 * max(md_fn_xl$inv[,"Magnitud"])) + 
  tema_gg +
  theme(legend.position = "none",
    axis.text.x = element_blank())

# expenses distribution plot
md_fn_xl$costos %>% 
  select(Categoría, Concepto, Magnitud) %>% 
  arrange(Magnitud) %>% 
  mutate(aux = Magnitud / sum(Magnitud),
         col_pal = if_else(Magnitud == max(Magnitud), "T", "F"),
         txt = if_else(aux > 0.1, scales::percent(aux), "")) %>% 
  ggplot(aes(x = reorder(Concepto, Magnitud), y = Magnitud)) +
  geom_col(aes(fill = col_pal)) +
  scale_fill_manual(values = c("T" = "yellowgreen", "F" = "grey85")) +
  coord_flip() +
  geom_text(aes(label = txt), hjust = "right", col = "white", fontface = "bold",
            size = 8, nudge_y = - 0.0222 * max(md_fn_xl$costos[,"Magnitud"])) +
  labs(x = "", y = "",
       title = "Costos de operación a partir de la estabilización",
       subtitle = "Participación porcentual en el total",
       caption = "Fuente: estimaciones propias.") +
  tema_gg +
  theme(legend.position = "none",
        axis.text.x = element_blank())

# expenses evolution plot
md_fn_xl$flujo %>% 
  filter(concepto %in% c("cv", "cf")) %>%
  gather(key = "periodo", value = "monto", -concepto) %>% 
  filter(periodo != 0) %>% 
  ggplot(aes(x = as.numeric(periodo), y = monto)) +
  geom_col(aes(fill = concepto)) +
  scale_fill_manual(values = c("cv" = "yellowgreen", "cf" = "grey85")) +
  scale_x_continuous(breaks = 1:10, labels = 1:10) +
  scale_y_continuous(labels = scales::comma) +
  labs(x = "", y = "",
       title = "Evolución de los costos",
       subtitle = "Miles de pesos",
       caption = "Fuente: estimación propia.") +
  tema_gg +
  theme(legend.position = c(.2,.8),
        legend.title = element_blank())

# revenue vs costs evolution plot
md_fn_xl$flujo %>% 
  filter(concepto %in% c("ing", "cv", "cf")) %>% 
  .[,-2] %>% 
  gather(key = "periodo", value = "monto", -concepto) %>% 
  spread(concepto, monto) %>% 
  mutate(ctt = cv + cf) %>% 
  select(-cv, -cf) %>% 
  mutate(periodo = as.numeric(periodo),
         txt_ing = if_else(periodo == 9, "Ingresos", ""),
         txt_ctt = if_else(periodo == 9, "Costos", "")) %>% 
  arrange(periodo) %>% 
  ggplot(aes(x = periodo)) +
  geom_line(aes(y = ing), col = "yellowgreen") +
  geom_point(aes(y = ing), col = "yellowgreen") +
  geom_text(aes(y = ing - 0.05*(max(ing)), label = txt_ing), family = "Lato") +
  geom_line(aes(y = ctt), col = "grey85") +
  geom_point(aes(y = ctt), col = "grey85") +
  geom_text(aes(y = ctt - 0.05*(max(ing)), label = txt_ctt), family = "Lato") +
  scale_x_continuous(breaks = 1:10, labels = 1:10) +
  scale_y_continuous(labels = scales::comma) +
  labs(x = "", y = "",
       title = "Evolución de los ingresos y de los costos de operación",
       subtitle = "Miles de pesos",
       caption = "Fuente: estimaciones propias.") +
  tema_gg
 
# summary statistics of variables included in risk analysis
gridExtra::grid.arrange(nrow = 2,
agt_nal %>%
  filter(anio %in% c(2014:2018), idmodalidad != 2) %>% #filter(rendimiento == 27.95)
  select(anio, rendimiento) %>% #group_by(idmodalidad) %>% count()
  ggplot(aes(rendimiento)) +
  geom_histogram(bins = 15, fill = "grey85", col = "grey85", alpha = 0.2) +
  geom_vline(xintercept = agt_nal %>%
               filter(anio %in% c(2014:2018, idmodalidad != 2)) %>% 
               summarise(rdm = sum(rendimiento * volumenproduccion) / sum(volumenproduccion)) %>% 
               pull(), lty = 2, col = "yellowgreen", size = 1) +
  labs(x = "", y = "",
       title = "Rendimiento por ha",
       subtitle = "Distribución, valor medio ponderado y estadísticos resumen") +
  tema_gg +
  theme(axis.line.y = element_blank(),
        axis.ticks.y = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks.x = element_line()),

data.frame(nom = c("Media", "D.E.", "Mínimo", "1er Q",
                   "Mediana", "3er Q", "Máximo", "MAD", "IQR", "CV"),
           est = agt_nal %>%
  filter(anio %in% c(2014:2018), idmodalidad != 2) %>% #filter(rendimiento == 27.95)
  select(rendimiento) %>% #group_by(idmodalidad) %>% count()
  summarytools::descr() %>% .[1:10,1]) %>% 
  mutate(est = scales::number(est, accuracy = 0.01),
         dp = ":",
         eje_y = 11:2,
         eje_x_n = 1,
         eje_x_dp = 1.8,
         eje_x_e = 2.5) %>% 
  ggplot(aes(y = eje_y)) +
  geom_text(aes(x = eje_x_n, label = nom), family = "Lato", hjust = "left", size = 6, col = "grey") +
  geom_text(aes(x = eje_x_dp, label = dp), family = "Lato", col = "grey") +
  geom_text(aes(x = eje_x_e, label = est), family = "Lato", size = 6, hjust = "right", col = "darkgrey") +
  xlim(0, 3.5) + ylim(1,12) +
  labs(x = "", y = "") +
  tema_gg +
  theme(axis.line.y = element_blank(),
        axis.text = element_blank(),
        axis.ticks.y = element_blank()),

agt_nal %>%
  filter(anio %in% c(2014:2018), idmodalidad != 2) %>% #filter(rendimiento == 27.95)
  select(anio, preciomediorural) %>% #group_by(idmodalidad) %>% count()
  mutate(preciomediorural = preciomediorural / 1000) %>% 
  ggplot(aes(preciomediorural)) +
  geom_histogram(bins = 15, fill = "grey85", col = "grey85", alpha = 0.2) +
  geom_vline(xintercept = agt_nal %>%
               filter(anio %in% c(2014:2018, idmodalidad != 2)) %>% 
               summarise(rdm = sum(preciomediorural * volumenproduccion) / sum(volumenproduccion)) %>% 
               pull() / 1000, lty = 2, col = "yellowgreen", size = 1) +
  labs(x = "", y = "",
       title = "Precio medio rural (mxp/kg)",
       subtitle = "Distribución, valor medio ponderado y estadísticos resumen") +
  tema_gg +
  theme(axis.line.y = element_blank(),
        axis.ticks.y = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks.x = element_line()),

data.frame(nom = c("Media", "D.E.", "Mínimo", "1er Q",
                   "Mediana", "3er Q", "Máximo", "MAD", "IQR", "CV"),
           est = agt_nal %>%
             filter(anio %in% c(2014:2018), idmodalidad != 2) %>% #filter(rendimiento == 27.95)
             select(preciomediorural) %>% #group_by(idmodalidad) %>% count()
             mutate(preciomediorural = preciomediorural / 1000) %>% 
             summarytools::descr() %>% .[1:10,1]) %>% 
  mutate(est = scales::number(est, accuracy = 0.01),
         dp = ":",
         eje_y = 11:2,
         eje_x_n = 1,
         eje_x_dp = 1.8,
         eje_x_e = 2.5) %>% 
  ggplot(aes(y = eje_y)) +
  geom_text(aes(x = eje_x_n, label = nom), family = "Lato", hjust = "left", size = 6, col = "grey") +
  geom_text(aes(x = eje_x_dp, label = dp), family = "Lato", col = "grey") +
  geom_text(aes(x = eje_x_e, label = est), family = "Lato", size = 6, hjust = "right", col = "darkgrey") +
  xlim(0, 3.5) + ylim(1,12) +
  labs(x = "", y = "") +
  tema_gg +
  theme(axis.line.y = element_blank(),
        axis.text = element_blank(),
        axis.ticks.y = element_blank()))



inputs_rm_list <- "(prm, costos_mxp, inv_mxp, inv, fl_inv_mxp, sch_apy_mxp,
                   sch_apy_pctj, sch_gral_mxp, loan, fl_loan_mxp, activos,
                   fl_dpr_mxp, fl_pd_ton, fl_ing_mxp, fl_cts_mxp, fl_sch_mxp)"

tema_gg <- theme(panel.background = element_blank(),
                 panel.grid = element_blank(),
                 text = element_text(family = "Lato"),
                 plot.title = element_text(face = "bold"),
                 plot.subtitle = element_text(face = "bold"),
                 axis.ticks.x = element_blank(),
                 axis.text = element_text(family = "Lato Light"),
                 axis.line.y = element_line(color = "lightgrey"))

prmtrs %>% 
  filter(Categoría == "cont")
  
  
  data.frame(datos = runif(3) * 100000) %>% 
  mutate(datos = scales::number(datos, accuracy = 0.01, big.mark = ","))

vans_esca_fil %>% 
  filter(sup == 10, hrz == 10) %>%
  #group_by(hrz) %>% 
  #nest() %>% 
  #mutate(tc = map_dbl(data, ~exp(lm(log(vans) ~ sup, data = .x)$coef[2]) - 1))
  ggplot(aes(sup, vans)) +
  geom_point()


md_fn_10$risk_rate
