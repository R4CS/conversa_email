rm(list = ls())

library(tidyverse)
library(httr)
library(gmailr)
source("query.R")

matriculados_df <- GET(url_base,
                       query = body) %>% 
  content(type = "text/csv")

texto <- "Caros, boa tarde
\n Escrevemos para lembrá-los que amanhã (18/04/2018) não haverá aula.
\n Na próxima semana (25/04/2018), nós decidimos por alterar o tema da aula. Iremos explorar a criação de gráficos no R por meio do ggplot2. Não percam essa aula! Além de ser interessante por si só, ela dá as bases para tópicos mais avançados como criação de mapas e gráficos interativos!
\n Atenciosamente
\n Equipe de Programação para Ciências Sociais
\n Enviado pelo R"

emails_df <- matriculados_df %>% 
  mutate(To      = `E-Mail`,
         From    = "programacao.sociais@gmail.com",
         Subject = str_c("CURSO PROGRAMACAO - Avisos Importantes"),
         body    = texto) %>% 
  select(To, From, Subject, body)

emails_mime <- emails_df %>%
  pmap(mime)

safe_send_message <- safely(send_message)

sent_mail <- emails_mime %>% 
  map(safe_send_message)

#Verificação dos erros de envio
errors <- sent_mail %>% 
  transpose() %>% 
  .$error %>% 
  map_lgl(Negate(is.null))

sent_mail[errors]

