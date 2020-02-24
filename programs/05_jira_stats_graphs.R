# Tabulate statistics and make graphs for the AEA data editor report
# David Wasser
# 12/7/2019

# Inputs
#   - file.path(jiraanon,"jira.anon.RDS") 
# Outputs
#   - ggsave(file.path(images,"revision_round_length_hist.png"), 
#   - ggsave(file.path(images,"revision_round_length_hist2.png"), 
#   - ggsave(file.path(images,"revision_round_length_hist_pos.png"), 
#   - ggsave(file.path(images,"total_length_hist.png"), 
#   - ggsave(file.path(images,"n_rounds_plot.png"), 
#   - ggsave(file.path(images,"n_rounds_journal_plot.png"), 
#   - ggsave(file.path(images,"n_assessments_journal_plot.png"), 
#   - ggsave(file.path(images,"author_response_hist.png"), 
                                                        

### Cleans working environment.
#rm(list = ls())
#gc()

### Load libraries 
### Requirements: have library *here*
source(here::here("programs","config.R"),echo=TRUE)
global.libraries <- c("ggplot2","dplyr","reshape2","here")
results <- sapply(as.list(global.libraries), pkgTest)

pkgTest.github("data.table","Rdatatable")


# Read in data extracted from Jira, anonymized
jira <- readRDS(file.path(jiraanon,"jira.anon.RDS"))

#### Number of unique paper processed since July 16
## Total
jira.manuscripts<- jira %>% 
  select(mc_number_anon) %>% distinct() 

unique_total <- nrow(jira.manuscripts)

## By journal
unique_total_journal <- jira %>%
  group_by(Journal) %>%
  summarise(unique_mc_numbers = n_distinct(mc_number_anon))

#### Length of revision rounds (initial submission to us, and filing to Manuscript Central). 
# This is the duration of each Jira ticket.
# Need to identify when Lars first changes status to "Submitted to MC" (marked as "mc_final")
duration.data <- jira %>%
  mutate(Status = ifelse(Status == "Submitted to MC" & Changed.Fields == "Status" & Change.Author.Anon == "Lars Vilhuber", "mc_final", Status)) %>%
  arrange(ticket, date) %>%
  distinct() %>%
  filter(Status %in% c("Open", "mc_final")) %>%
  filter(Changed.Fields != "Resolution,Status") %>% # Fix problem with 8 tickets that were re-opened after submission to MC
  group_by(ticket) %>%
  summarise(date_received = min(date),
            last_date = max(date)) %>%
  mutate(length = last_date - date_received) %>%
  arrange(length) %>% ungroup()
   
table.duration <- duration.data %>% group_by(length) %>%
  summarise(n_tickets = n_distinct(ticket))

# Histogram
#geom_histogram(aes(y=..density..), colour="white", fill="grey", binwidth = 5)+

revision_round_length <- ggplot(duration.data, aes(x = length)) +
  geom_histogram(aes(y=..density..), colour="white", fill="grey", binwidth = 5)+
  geom_density(alpha=.2, fill = "black", col="black") +
  theme_classic() +
  scale_colour_brewer(palette = "Paired") +
  labs(x = "Days", y = "Density", title = "Length of revision rounds") 

revision_round_length.bar <- ggplot(table.duration, aes(x = length,y=n_tickets)) +
                          geom_bar(stat = "identity") +
                          theme_classic() +
                          scale_colour_brewer(palette = "Paired") +
                          labs(x = "Days", y = "Density", title = "Length of revision rounds") 

revision_round_length.pos <- ggplot(duration.data %>% filter(length >= 1), aes(x = length)) +
  geom_histogram(aes(y=..density..), colour="white", fill="grey", binwidth = 5)+
  geom_density(alpha=.2, fill = "black", col="black") +
  theme_classic() +
  scale_colour_brewer(palette = "Paired") +
  labs(x = "Days", y = "Density", title = "Length of revision rounds (no zeros)") 

ggsave(file.path(images,"revision_round_length_hist.png"), 
       revision_round_length +
         labs(y=element_blank(),title=element_blank()))

ggsave(file.path(images,"revision_round_length_hist2.png"), 
       revision_round_length.bar +
         labs(y=element_blank(),title=element_blank()))

ggsave(file.path(images,"revision_round_length_hist_pos.png"), 
       revision_round_length.pos +
         labs(y=element_blank(),title=element_blank()))

revision_round_length
revision_round_length.bar
revision_round_length.pos

# Data: overall
mean(duration.data$length)
median(duration.data$length)
tmp <- mutate(duration.data,n_length = as.numeric(length)) %>% select(n_length) %>% filter(n_length>=1)
mean(tmp$n_length)
median(tmp$n_length)

#### Length between first submission to us, and final "Submitted to Manuscript Central" action 
#### (that might be tricky, but one of the two dumps should have all transaction records). 
#### Note that there are censored obs: all manuscripts not yet published are right-censored durations.
# Need to identify when Lars first changes status to "Submitted to MC" (marked as "mc_final")
length.data <- jira %>% 
  mutate(Status = ifelse(Status == "Submitted to MC" & Changed.Fields == "Status" & Change.Author.Anon == "Lars Vilhuber", "mc_final", Status)) %>%
  filter(mc_number_anon != "",
         ticket != mc_number_anon,
         !grepl("#",mc_number_anon, fixed = TRUE)) %>%
  select(ticket, mc_number_anon, date, Status, Changed.Fields) %>%
  filter(Status %in% c("Open", "mc_final")) %>%
  filter(Changed.Fields != "Resolution,Status") %>%
  distinct() %>%
  group_by(mc_number_anon) %>%
  mutate(first_date = min(date),
         last_date = max(date),
         length = last_date - first_date) %>%
  arrange(length, ticket, date) 
table.issue.length <- length.data %>%
  group_by(length) %>%
  summarise(n_tickets = n_distinct(mc_number_anon))

fig.total_length <- ggplot(table.issue.length, aes(x=length)) + 
                  geom_histogram(aes(y=..density..), colour="white", fill="grey", binwidth = 5) +
                  geom_density(alpha=.2, fill = "black", col="black") +
                  theme_classic() +
                  scale_colour_brewer(palette = "Paired") +
                  labs(x = "Days", y = "Density", title = "Total length of review")
ggsave(file.path(images,"total_length_hist.png"), 
       fig.total_length  +
         labs(y=element_blank(),title=element_blank()))
fig.total_length

#### Length of author responses (time between filing report of first assessment, and getting the next submission)
author_length <- jira %>%
  filter(mc_number_anon != "",
         ticket != mc_number_anon,
         !grepl("#",mc_number_anon, fixed = TRUE)) %>%
  select(ticket, mc_number_anon, date, Status, Journal) %>%
  filter(Journal != "") %>%
  distinct() %>%
  group_by(mc_number_anon) %>%
  mutate(rounds = n_distinct(ticket),
         numeric_ticket = as.numeric(gsub("\\D", "", ticket)),
         first_ticket = min(numeric_ticket),
         last_ticket = max(numeric_ticket),
         ticket_order = ifelse(numeric_ticket == first_ticket, 1, 
                        ifelse(numeric_ticket == last_ticket & rounds == 2, 2, 
                        ifelse(numeric_ticket == last_ticket & rounds == 3, 3,
                        ifelse(numeric_ticket == last_ticket & rounds == 4, 4, 0)))),
         ticket_order = ifelse(ticket_order == 0 & rounds == 3, 2, ticket_order),
         middle_of_4 = ifelse(rounds == 4 & numeric_ticket != first_ticket & numeric_ticket != last_ticket, 1, 0),
         max_middle = max(numeric_ticket[middle_of_4 == 1]),
         ticket_order = ifelse(rounds == 4 & middle_of_4 == 1 & numeric_ticket == max_middle, 3, 
                        ifelse(rounds == 4 & middle_of_4 == 1 & numeric_ticket != max_middle, 2, ticket_order))) %>%
  select(-middle_of_4, -max_middle) %>%
  ungroup 

####

#### Distribution of rounds each paper goes through
## Total
n_rounds <- author_length %>%
  mutate(completed = ifelse(grepl("Pending publication", Status, fixed = TRUE) == TRUE, 1, 0)) %>%
  group_by(mc_number_anon) %>%
  mutate(paper_completed = max(completed)) %>%
  ungroup %>%
  filter(paper_completed == 1) %>%
  select(-completed, -paper_completed) %>%
  group_by(rounds) %>%
  summarise(n_papers = n_distinct(mc_number_anon)) %>%
  ungroup %>%
  mutate(total = sum(n_papers),
         frac_papers = n_papers/total)

n_rounds_plot <- ggplot(n_rounds, aes(x = rounds, y = frac_papers)) +
                  geom_bar(stat = "identity", colour="white", fill="grey") +
                  theme_classic() +
                  scale_colour_brewer(palette = "Paired") +
                  labs(x = "Rounds", y = "Fraction of papers", title = "Distribution of review rounds")
ggsave(file.path(images,"n_rounds_plot.png"), 
       n_rounds_plot  +
         labs(y=element_blank(),title=element_blank()))
n_rounds_plot

## By journal
n_rounds_journal <- author_length %>%
  mutate(completed = ifelse(grepl("Pending publication", Status, fixed = TRUE) == TRUE, 1, 0)) %>%
  group_by(mc_number_anon) %>%
  mutate(paper_completed = max(completed)) %>%
  ungroup %>%
  filter(paper_completed == 1) %>%
  select(-completed, -paper_completed) %>%
  group_by(Journal, rounds) %>%
  summarise(n_papers = n_distinct(mc_number_anon)) %>%
  filter(Journal != "") %>%
  group_by(Journal) %>%
  mutate(total = sum(n_papers),
         frac_papers = n_papers/total) %>%
  ungroup %>%
  mutate(journal_f = factor(Journal, levels=c("AER", "AEJ:Applied Economics", "AEJ:Economic Policy", 
                                              "AEJ:Macro", "AEJ:Micro", "AER:Insights", "AEA P&P")))
  

n_rounds_journal_plot <- ggplot(n_rounds_journal, aes(x = rounds, y = frac_papers)) +
                          geom_bar(stat = "identity", colour="white", fill="grey") +
                          theme_classic() +
                          scale_colour_brewer(palette = "Paired") +
                          labs(x = "Rounds", y = "Fraction of papers", title = "Distribution of review rounds by journal") + 
                          facet_grid(journal_f ~ .) +
                          theme(axis.text.x = element_text(angle=45))
ggsave(file.path(images,"n_rounds_journal_plot.png"), 
       n_rounds_journal_plot  +
         labs(y=element_blank(),title=element_blank()))
n_rounds_journal_plot

#### Total number of assessments made
## Total
n_assessments <- author_length %>%
  mutate(completed = ifelse(grepl("Pending publication", Status, fixed = TRUE) == TRUE, 1, 0)) %>%
  group_by(mc_number_anon) %>%
  mutate(paper_completed = max(completed)) %>%
  ungroup %>%
  filter(paper_completed == 1) %>%
  select(-completed, -paper_completed) %>%
  select(ticket, mc_number_anon, rounds) %>%
  distinct() %>%
  arrange(mc_number_anon) %>%
  summarise(total_assessments_made = sum(rounds))

## By journal
n_assessments_journal <- author_length %>%
  mutate(completed = ifelse(grepl("Pending publication", Status, fixed = TRUE) == TRUE, 1, 0)) %>%
  group_by(mc_number_anon) %>%
  mutate(paper_completed = max(completed)) %>%
  ungroup %>%
  filter(paper_completed == 1) %>%
  select(-completed, -paper_completed) %>%
  select(ticket, mc_number_anon, rounds, Journal) %>%
  distinct() %>%
  arrange(mc_number_anon) %>%
  group_by(Journal) %>%
  summarise(total_assessments_made = sum(rounds)) %>%
  ungroup %>%
  mutate(journal_f = factor(Journal, levels=c("AER", "AEJ:Applied Economics", "AEJ:Economic Policy", 
                                              "AEJ:Macro", "AEJ:Micro", "AER:Insights", "AEA P&P")))

n_assessments_journal_plot <- ggplot(n_assessments_journal, aes(x = journal_f, y = total_assessments_made)) +
                                      geom_bar(stat = "identity", colour="white", fill="grey") +
                                      labs(x = "Journal", y = "Number of assessments", title = "Total assessments by journal") + 
                                      theme_classic() +
                                      theme(axis.text.x = element_text(angle=45))
ggsave(file.path(images,"n_assessments_journal_plot.png"), 
       n_assessments_journal_plot  +
         labs(y=element_blank(),title=element_blank()))
n_assessments_journal_plot

####

author_length2 <- author_length %>%
  select(-Journal) %>%
  filter(Status %in% c("Open", "Submitted to MC"),
         rounds > 1) %>%
  distinct() %>%
  group_by(ticket, Status) %>%
  mutate(min_date_ticket_status = min(date),
         max_date_ticket_status = max(date)) %>%
  arrange(mc_number_anon, date) %>%
  filter(date == min_date_ticket_status) %>%
  group_by(mc_number_anon, ticket, ticket_order) %>%
  summarise(min_date = min(date),
            max_date = max(date)) %>%
  arrange(mc_number_anon, ticket_order) %>%
  ungroup %>%
  mutate(end_round1 = fifelse(ticket_order == 1, max_date, as.Date(NA_real_, origin = "2019-07-16")),
         start_round2 = if_else(ticket_order == 2, min_date, as.Date(NA_real_, origin = "2019-07-16")),
         end_round2 = if_else(ticket_order == 2, max_date, as.Date(NA_real_, origin = "2019-07-16")),
         start_round3 = if_else(ticket_order == 3, min_date, as.Date(NA_real_, origin = "2019-07-16")),
         end_round3 = if_else(ticket_order == 3, max_date, as.Date(NA_real_, origin = "2019-07-16")),
         start_round4 = if_else(ticket_order == 4, min_date, as.Date(NA_real_, origin = "2019-07-16"))) %>%
  select(mc_number_anon, end_round1, start_round2, end_round2, start_round3, end_round3, start_round4) %>%
  group_by(mc_number_anon) %>%
  summarise_all(max, na.rm = TRUE)

author_length3 <- author_length2 %>%
  mutate(diff1_2 = start_round2 - end_round1,
         diff2_3 = start_round3 - end_round2,
         diff3_4 = start_round4 - end_round3) %>%
  filter(diff1_2 != -Inf) %>%
  select(mc_number_anon, diff1_2, diff2_3, diff3_4)

# Reshape long
author_response_dist <- reshape2::melt(data = author_length3, id = c("mc_number_anon"))

author_response_dist <- author_response_dist %>%
  rename(response_round = variable,
         length = value) %>%
  select(-response_round) %>%
  mutate(length = ifelse(length == -Inf, NA, length), # This happens if there is no review round to account for
         length = ifelse(length == Inf, NA, length),  # Same thing here
         length = ifelse(length < 0 , NA, length)) %>%    # This happens if there is a weird pattern in Jira data (e.g. first ticket is closed after second is opened)
  group_by(length) %>%
  summarise(n_distinct(mc_number_anon)) %>%
  filter(!is.na(length))
  
author_response_hist <- ggplot(author_response_dist, aes(x = length)) +
                          geom_histogram(aes(y=..density..), colour="white", fill="grey", binwidth = 5) +
                          geom_density(alpha = 0.2, fill = "black") +
                          labs(x = "Days", y = "Density", title = "Length of author responses") +
                          theme_classic()
ggsave(file.path(images,"author_response_hist.png"), 
       author_response_hist  +
         labs(y=element_blank(),title=element_blank()))
author_response_hist
  



