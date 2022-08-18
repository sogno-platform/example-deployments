# SOGNO Example Deployments

This repository contains deployment instructions and configuration files for different example deployments of the SOGNO platform.
More detailed descriptions and high-level architecture descriptions are available on our official [documentation](https://sogno-platform.github.io/docs/) pages.

## Running examples using vagrant and virtualbox

This fork introduces vagrant to help setting up a ready to use environment with examples and has been developed at 
<a href="https://www.areti.it"> 
    <img src="https://www.areti.it/content/dam/acea-areti/icone-loghi/pittogramma_areti_colore.svg" alt="AReti" style="width:50px;"/> areti 
</a> to further ease the execution.

Each example runs in a vm (8gb ram, 2cpu).
We currently provide the following examples:

- [PMU Data Visualization](pmu-data-visualization) execute:  `cd vagrant && vagrant up pmudatavisualization`
- [Pyvolt DPsim Demo](pyvolt-dpsim-demo) execute:  `cd vagrant && vagrant up pyvoltdpsim`
- [Simulation Demo](simulation-demo) execute: `cd vagrant && vagrant up simulation`
