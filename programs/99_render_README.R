# Export README to Markdown and HTML


source(here::here("programs","config.R"),echo=TRUE)
source(here::here("global-libraries.R"),echo=TRUE)
rmarkdown::render(here::here("README.Rmd"))
