rm(list = ls())

library(tidyverse)
library(httr)
library(gmailr)

send_mail <- function(texto, assunto){
  source("query.R")
  
  matriculados_df <- GET(url_base,
                         query = body) %>% 
    content(type = "text/csv")
  
  emails_df <- matriculados_df %>% 
    mutate(To      = `E-Mail`,
           From    = "programacao.sociais@gmail.com",
           Subject = assunto,
           body    = texto) %>% 
    select(To, From, Subject, body)
  
  emails_mime <- emails_df %>%
    pmap(mime)
  
  safe_send_message <- safely(send_message)
  
  sent_mail <- emails_mime %>% 
    map(safe_send_message)
}

verify_mail <- function(sent_mail){
  #Verificação dos erros de envio
  errors <- sent_mail %>% 
    transpose() %>% 
    .$error %>% 
    map_lgl(Negate(is.null))
  
  sent_mail[errors]
}

texto <- ""

log_msg <- send_mail(texto, "")

verify_mail(log_msg)
