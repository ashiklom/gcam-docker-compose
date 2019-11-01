#!/usr/bin/env Rscript
argv <- commandArgs(trailingOnly = TRUE)
hector_version <- argv[1]
stopifnot(!is.na(hector_version))
scenario <- argv[2]
if (is.na(scenario)) scenario <- "reference_run"
input_file <- file.path("local", "input", "reference_run.xml")
stopifnot(file.exists(input_file))

library(xml2)
library(rgcam)

tag <- format(Sys.time(), "%Y%m%d%H%M")

input_xml <- read_xml(input_file)
strings <- xml_child(input_xml, "Strings")

scenario_xml <- xml_find_all(strings, "//Value[@name='scenarioName']")

# Master branch scenario
full_scenario <- sprintf("%s|%s", hector_version, scenario)
xml_text(scenario_xml) <- full_scenario
infile <- "scenario.xml"
write_xml(input_xml, file.path("local", "input", infile))

cmd <- sprintf("./gcam.exe -C %s", file.path("..", "input-local", infile))

system2("docker-compose", c("run", "--rm", "gcam-hector", cmd),
        env = sprintf("HECTOR_VERSION=%s", hector_version))
