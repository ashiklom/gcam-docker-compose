library(xml2)
library(rgcam)

tag <- format(Sys.time(), "%Y%m%d%H%M")

## input_file <- "local/input/reference_run.xml"
input_file <- "./local/input/configuration_ref.xml"
input_xml <- read_xml(input_file)
strings <- xml_child(input_xml, "Strings")

scenario_xml <- xml_find_all(strings, "//Value[@name='scenarioName']")

# Master branch scenario
master <- paste0("master-branch-", tag)
xml_text(scenario_xml) <- master
write_xml(input_xml, "local/input/master.xml")

system2("docker-compose", c("run", "gcam", "./gcam.exe -C ../input-local/master.xml"))

# Hector scenario
branch <- paste0("hector-update-", tag)
xml_text(scenario_xml) <- branch
write_xml(input_xml, "local/input/hector.xml")

system2("docker-compose", c("run", "gcam-dev", "./gcam.exe -C ../input-local/hector.xml"))
