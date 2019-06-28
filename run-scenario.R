library(xml2)
library(magrittr)

input_file <- "local/input/reference_run.xml"
input_xml <- read_xml(input_file)
strings <- xml_child(input_xml, "Strings")

scenario_xml <- xml_find_all(strings, "//Value[@name='scenarioName']")

# Master branch scenario
xml_text(scenario_xml) <- "master-branch"
write_xml(input_xml, "local/input/master.xml")

system2("docker-compose", c("run", "gcam", "./gcam.exe -C ../input-local/master.xml"))

# Hector scenario
xml_text(scenario_xml) <- "hector-update"
write_xml(input_xml, "local/input/hector.xml")

system2("docker-compose", c("run", "gcam-dev", "./gcam.exe -C ../input-local/hector.xml"))

# Process results
library(rgcam)

conn <- localDBConn("local/output/", "database_basexdb")
proj <- addScenario(conn, "master.dat", "master-branch")
proj <- addScenario(conn, "master.dat", "hector-update")

master <- dplyr::bind_rows(
  proj[["master-branch"]][c(
    "CO2 concentrations",
    "Climate forcing",
    "Global mean temperature"
  )],
  .id = "variable"
)

hector <- dplyr::bind_rows(
  proj[["hector-update"]][c(
    "CO2 concentrations",
    "Climate forcing",
    "Global mean temperature"
  )],
  .id = "variable"
)

dat <- dplyr::bind_rows(master, hector)

library(ggplot2)
ggplot(dat) +
  aes(x = year, y = value, color = scenario) +
  geom_line() +
  facet_wrap(vars(variable), scales = "free_y")
