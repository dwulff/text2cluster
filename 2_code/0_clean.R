require(tidyverse)

dat = read_csv("1_data/td_data_coded_1000.csv")

sel = names(dat)[str_detect(names(dat), "decision")]
dat[sel]
which(str_detect(dat$decision_text_crnt, "[:digit:]"))
