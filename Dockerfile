FROM rocker/verse:4.6.2

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
         locales \
         libcurl4-openssl-dev \
         libssl-dev \
        imagemagick \
        libmagick++-dev \
        gsfonts \
        pandoc \
        libicu-dev \
        libudunits2-dev \
        libtcl8.6 \
        libtk8.6 \
        biber \
        git-lfs \
        python3-pip \
    && rm -rf /var/lib/apt/lists/*
# en_US.UTF-8 is already provided by rocker/verse (LANG=en_US.UTF-8); Ubuntu 26.04
# no longer ships /usr/share/locale/locale.alias, so the former localedef call fails.


COPY global-libraries.R install1.R
#COPY programs/libraries.R install2.R
#COPY text/libraries.R install3.R
RUN cat install?.R > install.R && Rscript install.R

# Fail the build if any declared R package did not install
RUN Rscript -e 'eval(parse(text=grep("^global.libraries", readLines("install1.R"), value=TRUE))); m <- global.libraries[!global.libraries %in% rownames(installed.packages())]; if (length(m)) stop("Missing R packages: ", paste(m, collapse=", ")); message("All R packages present")'

# install the Python requirements
COPY requirements.txt .
RUN pip install --break-system-packages -r requirements.txt \
    && python3 -c "import jira, requests, dotenv, pandas; print('Python packages OK')"
